//
//  productCell.swift
//  vivr v4
//
//  Created by max blessen on 4/6/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class productCell: UITableViewCell {
    
    @IBOutlet weak var brandImage: UIImageView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var flavorName: UILabel!
    @IBOutlet weak var rating: UIImageView!
    @IBOutlet weak var reviewCount: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet var floatRatingView: FloatRatingView!
    
    var product:JSON? {
        didSet {
            self.loadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        self.floatRatingView.fullImage = UIImage(named: "StarFull")
    }
    
    func loadData() {
        self.productDescription.text = self.product!["description"].string
        self.productDescription.sizeToFit()
        self.flavorName.text = self.product!["name"].string
        self.flavorName.sizeToFit()
        //self.floatRatingView.rating
        
        
    }
    

}
