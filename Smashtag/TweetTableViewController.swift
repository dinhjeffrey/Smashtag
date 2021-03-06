//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by jeffrey dinh on 7/8/16.
//  Copyright © 2016 jeffrey dinh. All rights reserved.
//

import UIKit
import Twitter
import CoreData

// first thing to do when creating new VC is what is my model?
class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: Model
    
    // if this is nil, then we simply don't update the database
    // having this default to the AppDelegate's context is a little bit of "demo cheat"
    // probably it would be better to subclass TweetTableViewController
    // and set this var in that subclass and then use that subclass in our storyboard
    // (the only purpose of that subclass would be to pick what database we're using)
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            tweets.removeAll()
            searchForTweets()
            title = searchText
        }
    }
    
    // MARK: Fetching Tweets
    
    private var twitterRequest: Twitter.Request? {
        if let query = searchText where !query.isEmpty {
            return Twitter.Request(search: query + " -filter:retweets", count: 100)
        }
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    // multithread. tableView that is scrolling up and down, it reuses cells. It might come back to a cell that is not display what it used to before
    // two things about asynchronous:
    // 1. break memory cycles
    // 2. things come back may not come back as expected order
    private func searchForTweets() {
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets { newTweets in
                dispatch_async(dispatch_get_main_queue()) { [weak weakSelf = self] in
                    //if request == weakSelf?.lastTwitterRequest {
                    if !newTweets.isEmpty {
                        weakSelf?.tweets.insert(newTweets, atIndex: 0)
                        weakSelf?.updateDatabase(newTweets)
                    }
                    self.refreshControl?.endRefreshing()
                    //}
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    // add the Twitter.Tweets to our database
    
    private func updateDatabase(newTweets: [Twitter.Tweet]) {
        // anytime we access the database we have to use performBlock
        managedObjectContext?.performBlock { [weak weakSelf = self] in
            for twitterInfo in newTweets {
                // the _ = just lets readers of our code know
                // that we are intentionally ignoring the return value
                // create a new, unique Tweet with that Twitter info
                _ = Tweet.tweetWithTwitterInfo(twitterInfo, inManagedObjectContext: (weakSelf?.managedObjectContext!)!) // _ = tells we are returning something
            }
            // there is a method in AppDelegate
            // which will save the context as well
            // but we're just showing how to save and catch any error here
            do {
                try self.managedObjectContext?.save()
            } catch let error {
                print("Core Data Error: \(error)")
            }
        }
        // happens asynchronously
        printDatabaseStatistics()
        // note that even though we do this print()
        // AFTER printDatabaseStatistics() is called
        // it will print BEFORE because printDatabaseStatistics()
        // returns immediately after putting a closure on the context's queue
        // (that closure then runs sometime later, after this print())
        print("done printing database statistics")
    }
    
    // print out how many Tweets and TwitterUsers are in the database
    // uses two different ways of counting them
    // the second way (countForFetchRequest) is much more efficient
    // (since it does the count in the database itself)
    
    private var newSearch = false
    private var previousTweetCount = 0
    private var currentTweetCount = 0
    private var numberOfRowsInSection = 0
    
    private func printDatabaseStatistics() {
        managedObjectContext?.performBlock { [weak weakSelf = self] in
            if let results = try? self.managedObjectContext!.executeFetchRequest(NSFetchRequest(entityName: "TwitterUser")) {
                print("\(results.count) TwitterUsers")
            }
            // a more eficient way to count objects
            let tweetCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "Tweet"), error: nil)
            print("\(tweetCount) Tweets")
            
            
            // keep track of new tweets
            weakSelf?.currentTweetCount = tweetCount
            
            if weakSelf?.newSearch == true {
                weakSelf?.currentTweetCount = (weakSelf?.numberOfRowsInSection)!
                weakSelf?.previousTweetCount = tweetCount
                weakSelf?.newSearch = false
            } else {
                weakSelf?.currentTweetCount -= (weakSelf?.previousTweetCount)!
                weakSelf?.previousTweetCount = tweetCount
            }
            print("weakSelf?.previousTweetCount = \(weakSelf?.previousTweetCount)")
            print("weakSelf?.currentTweetCount = \(weakSelf?.currentTweetCount)")
            self.tableView.reloadData()
        }
    }
    
    // prepare for the segue that happens
    // when the user hits the Tweeters bar button item
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.TweetersMentioningSearchTerm {
            if let tweetersTVC = segue.destinationViewController.contentViewController  as? TweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.managedObjectContext = managedObjectContext
            }
        }
        if segue.identifier == Storyboard.ShowMentionSegue {
            if let mentionTVC = segue.destinationViewController.contentViewController as? MentionTableViewController {
                if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
                    mentionTVC.tweet = tweets[indexPathForSelectedRow.section][indexPathForSelectedRow.row]
                    mentionTVC.title = "Mention Table View Controller"
                }
            }
        }
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        searchForTweets()
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(tweets.count - section) & New Tweets: \(self.currentTweetCount)"
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRowsInSection = tweets[section].count
        return tweets[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetCellIdentifier, forIndexPath: indexPath)
        
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        return cell
    }
    
    // MARK: Constants
    
    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
        static let TweetersMentioningSearchTerm = "TweetersMentioningSearchTerm"
        static let ShowMentionSegue = "Show Mention Segue"
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        newSearch = true
        return true
    }
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight // need to add estimated height
        tableView.rowHeight = UITableViewAutomaticDimension // adds dynamic height for tableViewCells
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}

