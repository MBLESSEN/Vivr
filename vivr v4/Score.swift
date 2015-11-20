//
//  Score.swift
//  vivr
//
//  Created by max blessen on 11/20/15.
//  Copyright © 2015 max blessen. All rights reserved.
//
import Foundation
import Alamofire
import CoreData
import SwiftyJSON


class Score {
    var productID: Int?
    var reviewCount: Int?
    var throat: Float?
    var vapor: Float?
    var score: Float?
    
    required init(json: JSON) {
        self.productID = json[ActivityFeedReviewsFields.productID.rawValue].intValue
        self.reviewCount = json[ActivityFeedReviewsFields.reviewCount.rawValue].intValue
        self.throat = json[ActivityFeedReviewsFields.throat.rawValue].floatValue
        self.vapor = json[ActivityFeedReviewsFields.vapor.rawValue].floatValue
        self.score = json[ActivityFeedReviewsFields.score.rawValue].floatValue
    }
}
