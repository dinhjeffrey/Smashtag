//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by jeffrey dinh on 7/8/16.
//  Copyright © 2016 jeffrey dinh. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    // Attributes for highlighting tweet text: hashtags, urls, and user mentions
    private struct Attributes {
        static let Hashtags = [
            NSForegroundColorAttributeName: UIColor.redColor()
        ]
        static let Urls = [
            NSForegroundColorAttributeName: UIColor.blueColor()
        ]
        static let UserMentions = [
            NSForegroundColorAttributeName: UIColor.purpleColor()
        ]
    }
    
    
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    private func updateUI() { 
        // reset any existing tweet info
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new info from our tweet (if any)
        if let tweet = self.tweet {
            
            // Tweet text
            let tweetText = NSMutableAttributedString(string: tweet.text)
            tweetText.addAttributes(Attributes.Hashtags, indexedKeywords: tweet.hashtags)
            tweetText.addAttributes(Attributes.Urls, indexedKeywords: tweet.urls)
            tweetText.addAttributes(Attributes.UserMentions, indexedKeywords: tweet.userMentions)
            
            if tweetTextLabel?.text != nil {
                for _ in tweet.media {
                    tweetTextLabel.text! += " 📷"
                }
            }
            
            tweetTextLabel?.attributedText = tweetText
            
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
                if let profileImageURL = tweet.user.profileImageURL, imageData = NSData(contentsOfURL: profileImageURL) { // blocks main thread. fixed?
                    dispatch_async(dispatch_get_main_queue()) {
                        weakSelf?.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
// An example of creating elegant code through private extension
private extension NSMutableAttributedString {
    func addAttributes(attrs: [String: AnyObject], indexedKeywords: [Twitter.Tweet.IndexedKeyword]) {
        for indexedKeyword in indexedKeywords {
            self.addAttributes(attrs, range: indexedKeyword.nsrange)
        }
    }
}