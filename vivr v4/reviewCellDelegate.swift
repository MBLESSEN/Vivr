//
//  reviewCellDelegate.swift
//  vivr
//
//  Created by max blessen on 12/1/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import Foundation

@objc protocol reviewCellDelegate {
    optional func tappedProductbutton(cell: myReviewsCell)
    optional func tappedCommentButton(cell: myReviewsCell)
    optional func reloadAPI(cell: myReviewsCell)
    optional func helpfulTrue(cell: myReviewsCell)
    optional func helpfulFalse(cell: myReviewsCell)
}