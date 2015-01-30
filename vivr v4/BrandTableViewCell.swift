//
//  BrandTableViewCell.swift
//  vivr v4
//
//  Created by max blessen on 1/12/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Haneke

class BrandTableViewCell: UITableViewCell {

    @IBOutlet weak var brandImage: UIImageView!
    @IBOutlet weak var brandLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    var brand:JSON? {
        didSet {
            self.loadBrand()
        }
        
    }
    
    func loadBrand() {
        self.brandLabel.text = self.brand?["name"].string
        if let urlString = self.brand?["logo"] {
            let url = NSURL(string: urlString.stringValue)
            self.brandImage.hnk_setImageFromURL(url!)
        }

    }


}
