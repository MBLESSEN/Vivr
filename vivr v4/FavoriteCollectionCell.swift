//
//  FavoriteCollectionCell.swift
//  vivr v4
//
//  Created by max blessen on 3/9/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

protocol favoritesCellDelegate {
    func tappedProductButton(cell: FavoriteCollectionCell)
}

class FavoriteCollectionCell: UICollectionViewCell {
    
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var brandName: UILabel!
    @IBOutlet var flavorName: UILabel!
    var cellDelegate: favoritesCellDelegate? = nil
    var productID:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var favorite:JSON? {
        didSet {
            self.loadProduct()
        }
    }
    
    func loadProduct(){
        self.brandName.text = self.favorite?["product"]["brand"]["name"].string
        self.flavorName.text = self.favorite?["product"]["name"].string
       /* if let urlString = self.favorite?["product"]["image"].stringValue {
            let url = NSURL(string: urlString)
            self.productImage.hnk_setImageFromURL(url!)
        }*/
        if let pID = self.favorite?["product"]["id"].stringValue {
        self.productID = pID
        }
    }
    
    @IBAction func productTapped(sender: AnyObject) {
        cellDelegate?.tappedProductButton(self)
    }
    

}
