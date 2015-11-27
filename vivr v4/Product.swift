//
//  Product.swift
//  vivr
//
//  Created by max blessen on 11/20/15.
//  Copyright © 2015 max blessen. All rights reserved.
//
import Foundation
import Alamofire
import Haneke
import SwiftyJSON


class ProductWrapper {
    var Products: Array<Product>?
    var count: Int?
    var next: String?
    var previous: String?
    var currentPage: Int?
    var nextPage: Int?
    var lastPage: Int?
}

class Product {
    var ID: Int?
    var productID: Int?
    var brandID: Int?
    var name: String?
    var image: String?
    var imageFromURL: UIImage = UIImage()
    var description: String?
    var currentFavorite: Bool?
    var currentWishlist: Bool?
    var brand: Brand?
    var scores: Score?
    var tags: Array<Tag>?
    
    required init(json: JSON, id: Int?) {
        self.ID = id
        self.productID = json[ActivityFeedReviewsFields.ID.rawValue].intValue
        self.brandID = json[ActivityFeedReviewsFields.brandID.rawValue].intValue
        self.name = json[ActivityFeedReviewsFields.name.rawValue].stringValue
        self.image = json[ActivityFeedReviewsFields.image.rawValue].stringValue
        if self.image != "" {
        self.imageFromURL = UIImage(data: NSData(contentsOfURL: NSURL(string: self.image!)!)!)!
        }
        self.description = json[ActivityFeedReviewsFields.description.rawValue].stringValue
        self.currentFavorite = json[ActivityFeedReviewsFields.currentFavorite.rawValue].boolValue
        self.currentWishlist = json[ActivityFeedReviewsFields.currentWishlist.rawValue].boolValue
        if let brandData = JSON(json[ActivityFeedReviewsFields.brand.rawValue].rawValue) as JSON? {
            self.brand = Brand(json: brandData, id: 0)
        }
        if let scoreData = JSON(json[ActivityFeedReviewsFields.scores.rawValue].rawValue) as JSON? {
            self.scores = Score(json: scoreData)
        }
        if let tagData = JSON(json["tags"].arrayValue) as JSON? {
            self.tags = Array<Tag>()
            for jsonTags in tagData {
                print(jsonTags)
                let tag = Tag(json: jsonTags.1, id: Int(jsonTags.0))
                tags!.append(tag)
            }
        }
    }
    class func endpointForActivity() -> URLRequestConvertible {
        return Router.readAllProducts(1)
    }
    class func endpointForFilteredProducts(tags: String) -> URLRequestConvertible {
        return Router.readAllFilteredProducts(tags, 1)
    }
    class func endpointForSingleProduct(id: String) -> URLRequestConvertible {
        return Router.ReadProductData(id)
    }
    class func endpointForBrandProducts(brandID: String) -> URLRequestConvertible {
        return Router.ReadBrandProducts(brandID)
    }
    class func endpointForFindProducts(searchText: String) -> URLRequestConvertible {
        return Router.findSpecificProduct(searchText, 1)
    }
    class func endpointForPostProductToBrand(brandID: Int, parameters: [String:AnyObject]) -> URLRequestConvertible {
        return Router.postProduct(brandID, parameters)
    }
    
    private class func getProductAtPath(path: URLRequestConvertible, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseProductArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseProductArray { (response) in
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
    class func getProducts(completionHandler: (ProductWrapper?, NSError?) -> Void) {
        getProductAtPath(Product.endpointForActivity(), completionHandler: completionHandler)
    }
    
    class func getMoreProducts(wrapper: ProductWrapper?, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getProductAtPath(Router.readAllProducts(wrapper!.currentPage!), completionHandler: completionHandler)
    }
    private class func getFilteredProductAtPath(path: URLRequestConvertible, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseProductArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseProductArray { (response) in
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
    class func getFilteredProducts(tags: String, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        getFilteredProductAtPath(Product.endpointForFilteredProducts(tags), completionHandler: completionHandler)
    }
    
    class func getMoreFilteredProducts(tags: String, wrapper: ProductWrapper?, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getFilteredProductAtPath(Router.readAllFilteredProducts(tags, wrapper!.currentPage!), completionHandler: completionHandler)
    }
    
    private class func getSingleProductAtPath(path: URLRequestConvertible, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseSingleProduct { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseSingleProduct{ (response) in
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
    
    class func getSingleProductData(productID: String, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        getSingleProductAtPath(Product.endpointForSingleProduct(productID), completionHandler: completionHandler)
    }
    
    private class func getBrandProductsAtPath(path: URLRequestConvertible, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseProductArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseProductArray { (response) in
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
    class func getBrandProducts(brandID: String, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        getBrandProductsAtPath(Product.endpointForBrandProducts(brandID), completionHandler: completionHandler)
    }
    
    class func getMoreBrandProducts(wrapper: ProductWrapper?, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getProductAtPath(Router.readAllProducts(wrapper!.currentPage!), completionHandler: completionHandler)
    }
    
    class func findProducts(searchText: String, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        getProductAtPath(Product.endpointForFindProducts(searchText), completionHandler: completionHandler)
    }
    
    private class func postProductToBrand(parameterspath: URLRequestConvertible, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        Alamofire.request(parameterspath).responseProductArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(parameterspath).responseProductArray { (response) in
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
    class func addProductToBrand(brandID: Int, parameters: [String:AnyObject], completionHandler : (ProductWrapper?, NSError?) -> Void) {
        postProductToBrand(Product.endpointForPostProductToBrand(brandID, parameters: parameters), completionHandler: completionHandler)
    }
    
}
