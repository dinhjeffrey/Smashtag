//
//  MentionTableViewController.swift
//  Smashtag
//
//  Created by jeffrey dinh on 7/16/16.
//  Copyright © 2016 jeffrey dinh. All rights reserved.
//

import UIKit
import Twitter

class MentionTableViewController: UITableViewController {
    
    var tweet: Twitter.Tweet? {
        didSet {
            if let tweet = tweet {
                title = tweet.user.name
                
                // Images
                if tweet.media.count > 0 {
                    var mediaItems = [Mention]()
                    for mediaItem in tweet.media {
                        mediaItems.append(Mention.Image(mediaItem))
                    }
                    addMentions(mediaItems)
                }
                
                // Hashtags
                if tweet.hashtags.count > 0 {
                    var hashtags = [Mention]()
                    for hashtag in tweet.hashtags {
                        hashtags.append(Mention.Hashtag(hashtag.keyword))
                    }
                    addMentions(hashtags)
                }
                
                // URLs
                if tweet.urls.count > 0 {
                    var urls = [Mention]()
                    for url in tweet.urls {
                        urls.append(Mention.URL(url.keyword))
                    }
                    addMentions(urls)
                }
                
                // Users
                var userMentions = [Mention]()
                userMentions.append(Mention.UserMention("@\(tweet.user.screenName)"))
                if tweet.userMentions.count > 0 {
                    for userMention in tweet.userMentions {
                        userMentions.append(Mention.UserMention(userMention.keyword))
                    }
                }
                addMentions(userMentions)
            }
        }
    }
    
    private var mentions = [[Mention]]()
    private func addMentions(mentionsToInsert: [Mention]) {
        mentions.insert(mentionsToInsert, atIndex: mentions.count)
    }
    
    private enum Mention {
        case Image(Twitter.MediaItem)
        case Hashtag(String)
        case URL(String)
        case UserMention(String)
        
        var description: String {
            switch self {
            case .Image(let mediaItem):
                return mediaItem.url.absoluteString
            case .Hashtag(let hashtag):
                return hashtag
            case .URL(let url):
                return url
            case .UserMention(let userMention):
                return userMention
            }
        }
        
        var type: String {
            switch self {
            case .Image(_):
                return "Images"
            case .Hashtag(_):
                return "Hashtags"
            case .URL(_):
                return "URLs"
            case .UserMention(_):
                return "Users"
            }
        }
    }
    
    private struct Storyboard {
        static let ImageCellIdentifier = "Image Cell"
        static let TextCellIdentifier = "Text Cell"
        static let TwitterSearchSegue = "Twitter Search"
        static let ShowImageSegue = "Show Image"
    }
    
    private struct Constants {
        static let GoldenRatio = (1 + sqrt(5.0)) / 2
    }
    
    // MARK: - View Controller Lifecycle
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
    
    // MARK: - UITableViewDelegate
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let mention = mentions[indexPath.section][indexPath.row]
//        switch mention {
//        case .Image(_):
//            return view.bounds.width / CGFloat(Constants.GoldenRatio)
//        default:
//            return UITableViewAutomaticDimension
//        }
//    }
    
    // MARK: - Table view data source
    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return mentions.count
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return mentions[section].count
//    }
    
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "PokemonGo"// mentions[section].first!.type
//    }
    
// have to implement other files first
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let mention = mentions[indexPath.section][indexPath.row]
//        
//        switch mention {
//        case .Image(let mediaItem):
//            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageCellIdentifier, forIndexPath: indexPath) as! MentionImageTableViewCell
//            cell.mediaItem = mediaItem
//            return cell
//        default:
//            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TextCellIdentifier, forIndexPath: indexPath) as! MentionTextTableViewCell
//            cell.mention = mention.description
//            return cell
//        }
//    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
