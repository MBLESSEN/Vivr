//
//  profileCell.swift
//  vivr v4
//
//  Created by max blessen on 2/21/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

class profileCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var reviewsButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var favoritesCount: UILabel!
    @IBOutlet weak var reviewsCount: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    
    var profile:String? {
        didSet {
            self.loadProfile()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        favoritesButton.layer.cornerRadius = 3
        reviewsButton.layer.cornerRadius = 3
        commentsButton.layer.cornerRadius = 3
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadProfile(){
        
        Alamofire.request(Router.readUser(self.profile!)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                self.userName.text = jsonOBJ["username"].string

            }
        }
    }
    

}
