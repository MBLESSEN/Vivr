//
//  Favorite.swift
//  vivr
//
//  Created by max blessen on 11/20/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON

class FavoriteWrapper {
    var Products: Array<Favorite>?
    var count: Int?
    var next: String?
    var previous: String?
    var currentPage: Int?
    var nextPage: Int?
    var lastPage: Int?
}


class Favorite {
    var ID: Int?
    var userID: String?
    var productID: Int?
    var product: Product?
    var brand: Brand?
    var createdAt: String?
    
    required init(json: JSON, id: Int?) {
        self.ID = id
        self.productID = json[ActivityFeedReviewsFields.productID.rawValue].intValue
        self.userID = json[ActivityFeedReviewsFields.userID.rawValue].stringValue
        self.createdAt = json[ActivityFeedReviewsFields.createdAt.rawValue].stringValue
        if let productData = JSON(json[ActivityFeedReviewsFields.product.rawValue].rawValue) as JSON? {
            self.product = Product(json: productData, id: 0)
        }
        if let brandData = JSON(json[ActivityFeedReviewsFields.product.rawValue][ActivityFeedReviewsFields.brand.rawValue].rawValue) as JSON? {
            self.brand = Brand(json: brandData, id: 0)
        }
    }
    
    class func endpointForUserFavorites(id: Int) -> URLRequestConvertible {
        return Router.readUserFavorites(id, 1)
    }
    private class func getProductAtPath(userID: Int, path: URLRequestConvertible, completionHandler: (FavoriteWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseFavoriteArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseFavoriteArray { (response) in
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
    class func getProducts(userID: Int, completionHandler: (FavoriteWrapper?, NSError?) -> Void) {
        getProductAtPath(userID, path: Favorite.endpointForUserFavorites(userID), completionHandler: completionHandler)
    }
    
    class func getMoreProducts(userID: Int, wrapper: FavoriteWrapper?, completionHandler: (FavoriteWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getProductAtPath(userID, path: Router.readUserFavorites(userID, wrapper!.currentPage!), completionHandler: completionHandler)
    }
}
