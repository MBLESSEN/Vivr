//
//  VIVRWishlistButton.swift
//  vivr
//
//  Created by max blessen on 1/26/16.
//  Copyright © 2016 max blessen. All rights reserved.
//

import UIKit

class VIVRWishlistButton: UIButton {
    
    override func awakeFromNib() {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 4
        self.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 50)
        self.setImage(UIImage(named: "plusWhite")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    }
    
    var currentWishlist:Bool? {
        didSet {
            setImageForState(currentWishlist!)
        }
    }
    
    func setImageForState(currentWishlist: Bool) {
        switch currentWishlist {
        case true:
            self.titleEdgeInsets = UIEdgeInsetsMake(5, -2.5, 5, 5)
            self.layer.borderColor = (UIColor.purpleColor()).CGColor
            self.tintColor = UIColor.whiteColor()
            self.backgroundColor = UIColor.purpleColor()
            self.setTitle("Wishlist", forState: .Normal)
        case false:
            self.titleEdgeInsets = UIEdgeInsetsMake(5, -2.5, 5, 5)
            self.layer.borderColor = (UIColor.lightGrayColor()).CGColor
            self.tintColor = UIColor.lightGrayColor()
            self.backgroundColor = UIColor.whiteColor()
            self.setTitle("Wishlist", forState: .Normal)
        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
