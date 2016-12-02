//
//  VIVRHelpfulButton.swift
//  vivr
//
//  Created by max blessen on 1/26/16.
//  Copyright © 2016 max blessen. All rights reserved.
//

import UIKit

class VIVRHelpfulButton: UIButton {
    
    var currentHelpful: Bool? {
        didSet {
            self.setImageForState(currentHelpful!)
        }
    }
    
    func setImageForState(currentHelpful: Bool) {
        switch currentHelpful {
        case true:
            self.setImage(UIImage(named: "likeFilled-1"), forState: .Normal)
            self.tintColor = UIColor.purpleColor()
        case false:
            self.setImage(UIImage(named: "like"), forState: .Normal)
            self.tintColor = UIColor.lightGrayColor()
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
