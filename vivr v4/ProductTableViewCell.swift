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
    
    @IBOutlet weak var productImageCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var productImage: UIImageView?
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var productBrandName: UILabel?
    @IBOutlet weak var productButton: UIButton!
    @IBOutlet weak var checkMarkImage: UIImageView?
    
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var productID:String?
    var cellDelegate:productCellDelegate? = nil
    var editView:UIView!
    var product: Product?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let checkImage = UIImage(named: "checkmark")?.imageWithRenderingMode(.AlwaysTemplate)
        checkMarkImage?.image = checkImage
        checkMarkImage?.tintColor = UIColor.whiteColor()
    }
    
    var editingEnabled:Bool?
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func bugbuttonToProductPressed(sender: AnyObject) {
        cellDelegate?.toProduct(self)
    }
    
    var products:Product? {
        didSet {
            self.loadProducts()
        }
    }
    
    func loadProducts() {
        self.productLabel.text = products?.name
        if let urlString = self.products?.image {
            print(urlString, terminator: "")
            if urlString != "NA" {
            let url = NSURL(string: urlString)
            self.productImage!.hnk_setImageFromURL(url!)
            }else {
                let placeHolderImage = UIImage(named: "vivrLogo")
                self.productImage!.image = placeHolderImage
            }
        }
    }
    

}
