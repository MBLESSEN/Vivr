//
//  commentCell.swift
//  vivr v4
//
//  Created by max blessen on 2/24/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class commentCell: UITableViewCell {
    
    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var commentContent: UILabel!
    
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

    func loadComment() {
        if let theUserName = self.comment?["user"]["username"].stringValue {
            self.user = theUserName
            self.userName.setTitle(theUserName, forState:UIControlState.Normal)
            userName.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        }
        self.commentContent.text = self.comment?["description"].stringValue
    }
}
