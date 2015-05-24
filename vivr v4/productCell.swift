//
//  productCell.swift
//  vivr v4
//
//  Created by max blessen on 4/6/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

protocol brandFlavorDelegate {
    func toReview(cell: productCell)
}

class productCell: UITableViewCell {
    
    @IBOutlet weak var brandImage: UIImageView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var flavorName: UILabel!
    @IBOutlet weak var rating: UIImageView!
    @IBOutlet weak var reviewCount: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet var floatRatingView: FloatRatingView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var wishlistButton: UIButton!
    
    var cellDelegate: brandFlavorDelegate? = nil
    var productID:String?
    var likeImage = UIImage(named: "likeFilled")?.imageWithRenderingMode(.AlwaysTemplate)
    var wishImage = UIImage(named: "plusWhite")?.imageWithRenderingMode(.AlwaysTemplate)
    var reviewImage = UIImage(named: "reviewFilled")?.imageWithRenderingMode(.AlwaysTemplate)
    
    var favoriteState: Bool? {
        didSet{
            favoriteButtonState()
        }
    }
    
    var reviewState: Bool? {
        didSet {
            reviewButtonState()
        }
    }
    
    var wishState: Bool? {
        didSet {
            wishlistButtonState()
        }
    }
    
    var product:JSON? {
        didSet {
            self.loadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureButtons()
    }
    
    func configureButtons() {
        let x = favoriteButton.frame.width
        let y = reviewButton.frame.width
        let z = wishlistButton.frame.width
        favoriteButton.layer.cornerRadius = 2
        reviewButton.layer.cornerRadius = 2
        wishlistButton.layer.cornerRadius = 2
        favoriteButton.setImage(likeImage, forState: .Normal)
        reviewButton.setImage(reviewImage, forState: .Normal)
        wishlistButton.setImage(wishImage, forState: .Normal)
        
    }
    
    @IBAction func favoritePressed(sender: AnyObject) {
        switch favoriteState! {
        case true:
            favoriteState = false
            Alamofire.request(Router.Favorite(productID!))
        case false:
            favoriteState = true
            Alamofire.request(Router.unFavorite(productID!))
        default:
            println("error")
        }
        self.favoriteButtonState()
    }
    
    @IBAction func reviewPressed(sender: AnyObject) {
        cellDelegate?.toReview(self)
    }
    
    @IBAction func wishPressed(sender: AnyObject) {
        switch wishState! {
        case true:
            wishState = false
            Alamofire.request(Router.addToWish(productID!))
        case false:
            wishState = true
            Alamofire.request(Router.removeWish(productID!))
        default:
            println("error")
        }
        self.wishlistButtonState()
    }
    
    func reviewButtonState(){
        let x = reviewButton.frame.width
        switch reviewState! {
        case true:
            reviewButton.tintColor = UIColor.whiteColor()
            reviewButton.backgroundColor = UIColor.purpleColor()
        case false:
            reviewButton.tintColor = UIColor.lightGrayColor()
            reviewButton.backgroundColor = UIColor.whiteColor()
        default:
            println("error")
        }
    }
    func wishlistButtonState(){
        switch wishState! {
        case true:
            wishlistButton.tintColor = UIColor.whiteColor()
            wishlistButton.backgroundColor = UIColor.purpleColor()
        case false:
            wishlistButton.tintColor = UIColor.lightGrayColor()
            wishlistButton.backgroundColor = UIColor.whiteColor()
        default:
            println("error")
        }
        
    }
    
    func favoriteButtonState(){
        switch favoriteState! {
        case true:
            favoriteButton.tintColor = UIColor.whiteColor()
            favoriteButton.backgroundColor = UIColor.purpleColor()
        case false:
            favoriteButton.tintColor = UIColor.lightGrayColor()
            favoriteButton.backgroundColor = UIColor.whiteColor()
        default:
            println("error")
            
        }
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        self.floatRatingView.fullImage = UIImage(named: "StarFull")
    }
    
    func loadData() {
        self.productDescription.text = self.product!["description"].string
        //self.productDescription.sizeToFit()
        self.flavorName.text = self.product!["name"].string
        self.flavorName.sizeToFit()
        //self.floatRatingView.rating
        
        
    }
    

}
