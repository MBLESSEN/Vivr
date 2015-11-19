
//
//  searchResultCell.swift
//  vivr v4
//
//  Created by max blessen on 6/2/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class searchResultCell: UITableViewCell {

    @IBOutlet weak var brandImage: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    
    var imageURL:String?
    var productID:String?
    var userID:String?
    var brandID:String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
