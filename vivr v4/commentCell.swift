//
//  commentCell.swift
//  vivr v4
//
//  Created by max blessen on 2/24/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

protocol CommentCellDelegate {
    func tappedCommentUserButton(cell: commentCell)
}

class commentCell: UITableViewCell {
    
    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var commentContent: UILabel!
    
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
        userID = self.comment?["user"]["id"].stringValue
        if let theUserName = self.comment?["user"]["username"].stringValue {
            self.user = theUserName
            self.userName.setTitle(theUserName, forState:UIControlState.Normal)
            userName.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        }
        if let date = self.comment?["created_at"].stringValue as String?{
            let dateFor:NSDateFormatter = NSDateFormatter()
            dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
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
