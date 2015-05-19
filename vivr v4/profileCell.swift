//
//  profileCell.swift
//  vivr v4
//
//  Created by max blessen on 2/21/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire
import Haneke

protocol profileDelegate {
    func reloadUI(cell: profileCell)
}

class profileCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var reviewsButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var favoritesCount: UILabel!
    @IBOutlet weak var reviewsCount: UILabel!
    @IBOutlet weak var wishCount: UILabel!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var hardware: UILabel!
    var cellDelegate:profileDelegate? = nil
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        userName.sizeToFit() 
        favoritesButton.layer.cornerRadius = 3
        reviewsButton.layer.cornerRadius = 3
        commentsButton.layer.cornerRadius = 3
        userImage.layer.zPosition = userImage.layer.zPosition + 4
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
        self.userImage.clipsToBounds = true
        self.userImage.layer.borderWidth = 3.0
        self.userImage.layer.borderColor = UIColor.whiteColor().CGColor

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

   
    

}
