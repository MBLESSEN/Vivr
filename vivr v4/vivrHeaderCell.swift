//
//  vivrHeaderCell.swift
//  vivr v4
//
//  Created by max blessen on 2/11/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class vivrHeaderCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeStamp: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var userInfo:JSON? {
        didSet {
            self.loadReviews()
            
        }
        
    }
    func loadReviews() {
        self.userName.text = self.userInfo?["user"]["username"].string
        
    }
    
    @IBAction func up(sender: AnyObject) {
        
    }
    
    @IBAction func down(sender: AnyObject) {
    }


}
