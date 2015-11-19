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

    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageBlur: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var reviewsButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var favoritesCount: UILabel!
    @IBOutlet weak var boxCount: UILabel!
    @IBOutlet weak var reviewsCount: UILabel!
    @IBOutlet weak var wishCount: UILabel!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var hardware: UILabel!
    var cellDelegate:profileDelegate? = nil
    

    override func layoutSubviews() {
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userName.sizeToFit()
        userImageBlur.bounds = self.contentView.bounds
        //favoritesButton.layer.cornerRadius = 3
        //reviewsButton.layer.cornerRadius = 3
        //commentsButton.layer.cornerRadius = 3
        userImage.layer.zPosition = userImage.layer.zPosition + 4
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
        self.userImage.clipsToBounds = true
        self.userImage.layer.borderWidth = 3.0
        self.userImage.layer.borderColor = UIColor(white: 1.0, alpha: 0.5).CGColor

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

   
    

}
