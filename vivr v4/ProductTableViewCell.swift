//
//  ProductTableViewCell.swift
//  vivr v4
//
//  Created by max blessen on 1/13/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Haneke

protocol productCellDelegate {
    func toProduct(cell: ProductTableViewCell)
}

class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productImage: UIImageView?
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var productBrandName: UILabel?
    
    var productID:String?
    var cellDelegate:productCellDelegate? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func bugbuttonToProductPressed(sender: AnyObject) {
        cellDelegate?.toProduct(self)
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
            self.productImage!.hnk_setImageFromURL(url!)
        }
    }

}
