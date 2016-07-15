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
            request.fetchTweets { [weak weakSelf = self] newTweets in
                dispatch_async(dispatch_get_main_queue()) {
                    //if request == weakSelf?.lastTwitterRequest {
                    if !newTweets.isEmpty {
                        weakSelf?.tweets.insert(newTweets, atIndex: 0)
                        weakSelf?.updateDatabase(newTweets)
                    }
                    //}
                    weakSelf?.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    private func updateDatabase(newTweets: [Twitter.Tweet]) {
        // anytime we access the database we have to use performBlock
        managedObjectContext?.performBlock{
            for twitterInfo in newTweets {
                // create a new, unique Tweet with that Twitter info
                _ = Tweet.tweetWithTwitterInfo(twitterInfo, inManagedObjectContext: self.managedObjectContext!) // _ = tells we are returning something
            }
            do {
                try self.managedObjectContext?.save()
            } catch let error {
                print("Core Data Error: \(error)")
            }
        }
        // happens asynchronously
        printDatabaseStatistics()
        print("done printing database statistics")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TweetersMentioningSearchTerm" {
            if let tweetersTVC = segue.destinationViewController  as? TweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.managedObjectContext = managedObjectContext
            }
        }
    }
    
    private func printDatabaseStatistics() {
        managedObjectContext?.performBlock{
            if let results = try? self.managedObjectContext!.executeFetchRequest(NSFetchRequest(entityName: "TwitterUser")) {
                print("\(results.count) TwitterUsers")
            }
            // a more eficient way to count objects
            let tweetCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "Tweet"), error: nil)
            print("\(tweetCount) Tweets")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight // need to add estimated height
        tableView.rowHeight = UITableViewAutomaticDimension // adds dynamic height for tableViewCells
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetCellIdentifier, forIndexPath: indexPath)
        
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        
        return cell
    }
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
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
