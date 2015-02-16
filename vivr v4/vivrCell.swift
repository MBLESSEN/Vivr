
//
//  vivrCell.swift
//  vivr v4
//
//  Created by max blessen on 2/6/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//


import UIKit
import Haneke

class vivrCell: UITableViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var BrandFlavorName: UILabel!
    @IBOutlet weak var reviewDescription: UILabel!
    @IBOutlet weak var taste: UILabel!
    @IBOutlet weak var flavor: UILabel!
    @IBOutlet weak var throat: UILabel!
    @IBOutlet weak var vapor: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var review:JSON? {
        didSet {
            self.loadReviews()
        }
    }
    var product:JSON? {
        didSet {
            self.loadProducts()
        }
    }
    
    func loadReviews() {
        self.reviewDescription.text = self.review?["description"].string
        self.taste.text = self.review?["taste"].stringValue
        self.flavor.text = self.review?["flavor"].stringValue
        self.throat.text = self.review?["throat"].stringValue
        self.vapor.text = self.review?["vapor"].stringValue
    }
    
    func loadProducts() {
        
       

    }
    
    
    
}


