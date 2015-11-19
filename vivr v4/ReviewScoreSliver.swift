//
//  ReviewScoreSliver.swift
//  vivr v4
//
//  Created by max blessen on 7/14/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class ReviewScoreSliver: UISlider {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(0, 0, self.frame.width, 25)
    }

}
