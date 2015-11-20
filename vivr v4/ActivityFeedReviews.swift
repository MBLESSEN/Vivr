//
//  ActivityFeedReviews.swift
//  vivr
//
//  Created by max blessen on 11/20/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON

enum ActivityFeedReviewsFields: String {
    case ID = "id"
    case userID = "user_id"
    case productID = "product_id"
    case brandID = "brand_id"
    case description = "description"
    case throat = "throat"
    case vapor = "vapor"
    case score = "score"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case helpfulCount = "helpful_count"
    case currentHelpful = "current_helpful"
    case currentFavorite = "current_favorite"
    case currentWishlist = "current_wishlist"
    case product = "product"
    case brand = "brand"
    case user = "user"
    case name = "name"
    case userName = "username"
    case image = "image"
    case reviewCount = "review_count"
    case scores = "scores"
    case hardWare = "hardware"
    case bio = "bio"
    
}

class ActivityWrapper {
    var ActivityReviews: Array<ActivityFeedReviews>?
    var count: Int?
    var next: String?
    var previous: String?
    var currentPage: Int?
    var nextPage: Int?
    var lastPage: Int?
}

class ActivityFeedReviews {
    var ID: Int?
    var reviewID: String?
    var userID: String?
    var productID: String?
    var description: String?
    var throat: Int?
    var vapor: Int?
    var score: String?
    var createdAt: String?
    var updatedAt: String?
    var image: String?
    var helpfulCount: Int?
    var currentHelpful: Bool?
    var product: Product?
    var user: User?
    var brand: Brand?
    
    required init(json: JSON, id: Int?) {
        self.ID = id
        self.reviewID = json[ActivityFeedReviewsFields.ID.rawValue].stringValue
        self.userID = json[ActivityFeedReviewsFields.userID.rawValue].stringValue
        self.productID = json[ActivityFeedReviewsFields.productID.rawValue].stringValue
        self.description = json[ActivityFeedReviewsFields.description.rawValue].stringValue
        self.throat = json[ActivityFeedReviewsFields.throat.rawValue].intValue
        self.vapor = json[ActivityFeedReviewsFields.vapor.rawValue].intValue
        self.score = json[ActivityFeedReviewsFields.score.rawValue].stringValue
        self.image = json["image"].stringValue
        self.createdAt = json[ActivityFeedReviewsFields.createdAt.rawValue].stringValue
        self.updatedAt = json[ActivityFeedReviewsFields.updatedAt.rawValue].stringValue
        self.helpfulCount = json[ActivityFeedReviewsFields.helpfulCount.rawValue].intValue
        self.currentHelpful = json[ActivityFeedReviewsFields.currentHelpful.rawValue].boolValue
        if let productData = JSON(json[ActivityFeedReviewsFields.product.rawValue].rawValue) as JSON? {
            self.product = Product(json: productData, id: 0)
        }
        if let userData = JSON(json[ActivityFeedReviewsFields.user.rawValue].rawValue) as JSON? {
            self.user = User(json: userData)
        }
        if let brandData = JSON(json[ActivityFeedReviewsFields.product.rawValue][ActivityFeedReviewsFields.brand.rawValue].rawValue) as JSON? {
            self.brand = Brand(json: brandData, id: 0)
        }
    }
    
    class func endpointForActivity() -> URLRequestConvertible {
        return Router.readFeed(1)
    }
    class func endpointForUserReviews(id: Int) -> URLRequestConvertible {
        return Router.readUserReviews(id, 1)
    }
    class func endpointForProductReviews(id: String) -> URLRequestConvertible {
        return Router.ReadReviews(id, 1)
    }
    class func endpointForFilteredActivity(tags: String) -> URLRequestConvertible {
        return Router.readFeedFiltered(tags, 1)
    }
    private class func getActivity(path: URLRequestConvertible, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseActivityArray { response in
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseActivityArray { (response) in
                            if let err = response.result.error {
                                completionHandler(nil, err)
                                return
                            }
                            completionHandler(response.result.value, nil)
                        }
                    }else {
                        completionHandler(nil, response.result.error)
                        return
                    }
                }
            }else if response.result.isFailure  {
                completionHandler(nil, response.result.error)
                return
            }
            completionHandler(response.result.value, nil)
            
        }
        
    }
    class func getReviews(completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        getActivity(ActivityFeedReviews.endpointForActivity(), completionHandler: completionHandler)
    }
    
    class func getMoreReviews(wrapper: ActivityWrapper?, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getActivity(Router.readFeed(wrapper!.currentPage!), completionHandler: completionHandler)
    }
    private class func getFilteredActivity(path: URLRequestConvertible, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseActivityArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        print("true")
                        Alamofire.request(path).responseActivityArray { (response) in
                            let data = response.result.value
                            let error = response.result.error
                            if let err = error {
                                completionHandler(nil, err)
                                return
                            }
                            completionHandler(data, nil)
                        }
                    }else {
                        completionHandler(nil, error)
                        return
                    }
                }
            }else if error != nil {
                completionHandler(nil, error)
                return
            }
            completionHandler(data, nil)
            
        }
        
    }
    class func getFilteredReviews(tags: String, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        getFilteredActivity(ActivityFeedReviews.endpointForFilteredActivity(tags), completionHandler: completionHandler)
    }
    
    class func getMoreFilteredReviews(tags: String, wrapper: ActivityWrapper?, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getActivity(Router.readFeedFiltered(tags, wrapper!.currentPage!), completionHandler: completionHandler)
    }
    private class func getUserReviewAtPath(userID: String, path: URLRequestConvertible, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseActivityArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseActivityArray { (response) in
                            let data = response.result.value
                            let error = response.result.error
                            if let err = error {
                                completionHandler(nil, err)
                                return
                            }
                            completionHandler(data, nil)
                        }
                    }else {
                        completionHandler(nil, error)
                        return
                    }
                }
            }else if error != nil {
                completionHandler(nil, error)
                return
            }
            completionHandler(data, nil)
            
        }
        
    }
    class func getUserReviews(id: Int, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        getActivity(ActivityFeedReviews.endpointForUserReviews(id), completionHandler: completionHandler)
    }
    
    class func getMoreUserReviews(id: Int, wrapper: ActivityWrapper?, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getActivity(Router.readUserReviews(id, wrapper!.currentPage!), completionHandler: completionHandler)
    }
    
    private class func getProductReviewAtPath(productID: String, path: URLRequestConvertible, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseActivityArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseActivityArray { (response) in
                            let data = response.result.value
                            let error = response.result.error
                            if let err = error {
                                completionHandler(nil, err)
                                return
                            }
                            completionHandler(data, nil)
                        }
                    }else {
                        completionHandler(nil, error)
                        return
                    }
                }
            }else if error != nil {
                completionHandler(nil, error)
                return
            }
            completionHandler(data, nil)
            
        }
        
    }
    class func getProductReviews(id: String, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        getActivity(ActivityFeedReviews.endpointForProductReviews(id), completionHandler: completionHandler)
    }
    
    class func getMoreProductReviews(id: String, wrapper: ActivityWrapper?, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getActivity(Router.ReadReviews(id, wrapper!.currentPage!), completionHandler: completionHandler)
    }
    
}
