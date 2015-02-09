
//
//  reviewTableViewCell.swift
//  vivr v4
//
//  Created by max blessen on 1/26/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class reviewTableViewCell: UITableViewCell {
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var reviewContent: UILabel!
    @IBOutlet weak var userTaste: UILabel!
    @IBOutlet weak var userFlavor: UILabel!
    @IBOutlet weak var userThroat: UILabel!
    @IBOutlet weak var userVapor: UILabel!
    @IBOutlet weak var reputation: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var review:JSON? {
        didSet {
            self.loadReviews()
            
        }
    
    }
    func loadReviews() {
        self.userName.text = self.review?["user"]["username"].string
        self.reviewContent.text = self.review?["description"].string
        self.userTaste.text = self.review?["taste"].stringValue
        self.userFlavor.text = self.review?["flavor"].stringValue
        self.userVapor.text = self.review?["vapor"].stringValue
        self.userThroat.text = self.review?["throat"].stringValue
        
        
    }
    
    @IBAction func up(sender: AnyObject) {
        
    }

    @IBAction func down(sender: AnyObject) {
    }
}
