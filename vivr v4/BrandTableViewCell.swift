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
    @IBOutlet weak var flavorCount: UILabel!
    @IBOutlet weak var flavorsLabel: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var averageRating: UILabel!
    
    var brandID: Int?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    var brand:Brand? {
        didSet {
            self.loadBrand()
        }
        
    }
    
    func loadBrand() {
        self.brandLabel.text = brand?.name
        print(brand?.name, terminator: "")
        self.flavorCount.text = "\(brand?.productCount!)"
        if let urlString = self.brand!.image as String? {
            print(urlString, terminator: "")
            let url = NSURL(string: urlString)
            self.brandImage.hnk_setImageFromURL(url!)

            }

        }

    }



