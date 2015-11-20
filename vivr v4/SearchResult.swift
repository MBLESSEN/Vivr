//
//  SearchResult.swift
//  vivr
//
//  Created by max blessen on 11/20/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON

class searchWrapper {
    var Products: Array<Product>?
    var Brands: Array<Brand>?
    var Users: Array<User>?
    
}


class SearchResult {
    var Products: ProductWrapper
    var Brands: BrandWrapper
    var Users: UserDataWrapper
    
    required init(json: JSON) {
        self.Products = ProductWrapper()
        self.Brands = BrandWrapper()
        self.Users = UserDataWrapper()
    }
    
    class func endpointForSearch(searchText: String) -> URLRequestConvertible {
        return Router.search(searchText, 1)
    }
    
    private class func getSearchResultsAtPath(path: URLRequestConvertible, completionHandler: (SearchResult?, NSError?) -> Void) {
        Alamofire.request(path).responseSearchResults { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseSearchResults { (response) in
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
    class func getSearchResults(searchText: String, completionHandler: (SearchResult?, NSError?) -> Void) {
        getSearchResultsAtPath(SearchResult.endpointForSearch(searchText), completionHandler: completionHandler)
    }
    
    class func getMoreProductSearchResults(searchText: String, wrapper: SearchResult?, completionHandler: (SearchResult?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.Products.next == nil {
            completionHandler(nil, nil)
            return
        }
        getSearchResultsAtPath(Router.search(searchText, wrapper!.Products.currentPage!), completionHandler: completionHandler)
    }
    class func getMoreBrandSearchResults(searchText: String, wrapper: SearchResult?, completionHandler: (SearchResult?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.Brands.next == nil {
            completionHandler(nil, nil)
            return
        }
        getSearchResultsAtPath(Router.search(searchText, wrapper!.Brands.currentPage!), completionHandler: completionHandler)
    }
    class func getMoreUserSearchResults(searchText: String, wrapper: SearchResult?, completionHandler: (SearchResult?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.Users.next == nil {
            completionHandler(nil, nil)
            return
        }
        getSearchResultsAtPath(Router.search(searchText, wrapper!.Users.currentPage!), completionHandler: completionHandler)
    }
}
