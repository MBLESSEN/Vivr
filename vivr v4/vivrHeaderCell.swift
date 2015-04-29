//
//  vivrHeaderCell.swift
//  vivr v4
//
//  Created by max blessen on 2/11/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

protocol VivrHeaderCellDelegate {
    
    func tappedUser(cell: vivrHeaderCell)
    
}

class vivrHeaderCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var floatRatingView: FloatRatingView!

    var cellDelegate: VivrHeaderCellDelegate?
    var userID:String = ""
    var userName:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    

    @IBAction func toUser(sender: AnyObject) {
        cellDelegate?.tappedUser(self)
    }
    
    var userInfo:JSON? {
        didSet {
            self.loadInfo()
            
        }
        
    }
    var rating:String? {
        didSet {
            self.floatRatingView.emptyImage = UIImage(named: "StarEmpty")
            self.floatRatingView.fullImage = UIImage(named: "StarFull")
            if let rating = self.userInfo?["score"].stringValue{
                var number = (rating as NSString).floatValue
                self.floatRatingView.rating = number
                self.floatRatingView.userInteractionEnabled = false
                
            }
        }
    }
    
    func loadInfo() {
        println(userInfo)
        if let theUserName = self.userInfo?["user"]["username"].stringValue {
                self.userName = theUserName
                self.userNameButton.setTitle(theUserName, forState:UIControlState.Normal)
                userNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left

        }
        if let theUserID = self.userInfo?["user"]["id"].stringValue {
            self.userID = theUserID
        }
        

    }
    
    
    

}
