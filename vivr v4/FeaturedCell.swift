//
//  FeaturedCell.swift
//  vivr
//
//  Created by max blessen on 9/12/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class FeaturedCell: UITableViewCell {

    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    let gradientLayer = CAGradientLayer()
    var featuredPost:FeaturedPost?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
