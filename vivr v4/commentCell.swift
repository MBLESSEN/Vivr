//
//  commentCell.swift
//  vivr v4
//
//  Created by max blessen on 2/24/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol CommentCellDelegate {
    func tappedCommentUserButton(cell: commentCell)
}

class commentCell: UITableViewCell {
    
    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var commentContent: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var hardware: UILabel!
    
    var userID:String?
    var cellDelegate:CommentCellDelegate? = nil
    var user:String = ""
    
    var comment:JSON?{
        didSet{
            self.loadComment()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func tappedUser(sender: AnyObject) {
        cellDelegate?.tappedCommentUserButton(self)
    }

    func loadComment() {
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
        self.userImage.clipsToBounds = true
        userID = self.comment?["user"]["id"].stringValue
        if let theUserName = self.comment?["user"]["username"].stringValue {
            self.user = theUserName
            self.userName.setTitle(theUserName, forState:UIControlState.Normal)
            userName.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        }
        if let urlString = self.comment?["user"]["image"].stringValue as String? {
            let url = NSURL(string: urlString)
            self.userImage.hnk_setImageFromURL(url!)
        }
        self.hardware.text = self.comment?["user"]["hardware"].stringValue
        if let date = self.comment?["created_at"].stringValue as String?{
            let dateFor:NSDateFormatter = NSDateFormatter()
            dateFor.timeZone = NSTimeZone(abbreviation: "UTC")
            dateFor.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let theDate:NSDate = dateFor.dateFromString(date)!
            let tempoDate = Tempo(date: theDate)
            let timeStamp = tempoDate.timeAgoNow()
            if let commentString = self.comment?["description"].stringValue as String? {
                var comment = NSMutableAttributedString(string: commentString + "  -  ")
                let x = NSAttributedString(string: timeStamp, attributes: [NSForegroundColorAttributeName:UIColor.lightGrayColor()])
                comment.appendAttributedString(x)
                self.commentContent.attributedText = comment
                self.commentContent.sizeToFit() 
            }
        }
    }
}
