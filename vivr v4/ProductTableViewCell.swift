//
//  ProductTableViewCell.swift
//  vivr v4
//
//  Created by max blessen on 1/13/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Haneke

class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var products:JSON? {
        didSet {
            self.loadProducts()
        }
    }
    
    func loadProducts() {
        self.productLabel.text = self.products?["name"].string
        if let urlString = self.products?["image"] {
            let url = NSURL(string: urlString.stringValue)
            self.productImage.hnk_setImageFromURL(url!)
        }
        
        
        
    }

}
