//
//  blogCell.swift
//  vivr
//
//  Created by max blessen on 9/27/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class blogCell: UITableViewCell {

    @IBOutlet weak var blogImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var featuredImage: UIImageView!
    @IBOutlet weak var featuredTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
