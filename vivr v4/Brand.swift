//
//  Brand.swift
//  vivr
//
//  Created by max blessen on 11/20/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON

class BrandWrapper {
    var Brands: Array<Brand>?
    var count: Int?
    var next: String?
    var previous: String?
    var currentPage: Int?
    var nextPage: Int?
    var lastPage: Int?
}

class Brand {
    var id: Int?
    var name: String?
    var description: String?
    var image:String?
    var logo: String?
    var productCount: Int?
    
    required init(json: JSON, id: Int?) {
        self.id = json[ActivityFeedReviewsFields.ID.rawValue].intValue
        self.name = json[ActivityFeedReviewsFields.name.rawValue].stringValue
        self.description = json[ActivityFeedReviewsFields.description.rawValue].stringValue
        self.image = json["logo"].stringValue
        self.productCount = json["product_count"].intValue
    }
    
    class func endpointForBrowseBrands() -> URLRequestConvertible {
        return Router.ReadBrands(1)
    }
    
    class func endpointForFindBrands(searchText: String) -> URLRequestConvertible {
        return Router.findSpecificBrands(searchText, 1)
    }
    
    class func endpointForCreateNewBrand(parameters: [String:AnyObject]) -> URLRequestConvertible {
        return Router.createNewBrand(parameters)
    }
    
    
    private class func getBrandsAtPath(path: URLRequestConvertible, completionHandler: (BrandWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseBrandArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseBrandArray{ (response) in
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
    class func getBrands(completionHandler: (BrandWrapper?, NSError?) -> Void) {
        getBrandsAtPath(Brand.endpointForBrowseBrands(), completionHandler: completionHandler)
    }
    
    class func getMoreBrands(wrapper: BrandWrapper?, completionHandler: (BrandWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getBrandsAtPath(Router.ReadBrands(wrapper!.currentPage!), completionHandler: completionHandler)
    }
    class func findBrands(searchText: String, completionHandler: (BrandWrapper?, NSError?) -> Void) {
        getBrandsAtPath(Brand.endpointForFindBrands(searchText), completionHandler: completionHandler)
    }
    
    class func createNewBrand(parameters: [String:AnyObject], completionHandler: (BrandWrapper?, NSError?) -> Void) {
        Alamofire.request(Router.createNewBrand(parameters)).responseJSON { (response) in
            if response.response?.statusCode != 200 {
                completionHandler(nil,response.result.error)
                return
            }
            let brandWrapper = BrandWrapper()
            var brandArray = Array<Brand>()
            let brand = Brand(json: JSON(response.result.value!), id: 0)
            brandArray.append(brand)
            brandWrapper.Brands = brandArray
            completionHandler(brandWrapper, response.result.error)
        }
        
    }
    
}
