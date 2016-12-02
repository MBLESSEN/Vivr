//
//  VIVRFeaturedPost.swift
//  vivr
//
//  Created by max blessen on 12/15/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class FeaturedPostWrapper {
    var featuredPosts: Array<FeaturedPost>?
    var count: Int?
    var next: String?
    var previous: String?
    var currentPage: Int?
    var nextPage: Int?
    var lastPage: Int?
}

class FeaturedPost {
    var ID: Int?
    var featuredID: Int?
    var title: String?
    var image: String?
    var description: String?
    
    var m: Markdown = Markdown()
    
    required init(json: JSON, id: Int?) {
        self.ID = id
        self.featuredID = json["id"].intValue
        self.title = json["name"].stringValue
        self.image = json["image"].stringValue
        self.description = m.transform(json["description"].stringValue)
    }
    
    class func endpointForAllFeaturedPosts() -> URLRequestConvertible {
        return Router.readFeatured(1)
    }
    
    private class func getFeaturedPostsAtPath(path: URLRequestConvertible, completionHandler: (FeaturedPostWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseFeaturedArray { (response) in
            let data = response.result.value
            let error = response.result.error
            print(data)
            print(response.request)
            print(response.response)
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseFeaturedArray{ (response) in
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
    
    class func getFeaturedPosts(completionHandler: (FeaturedPostWrapper?,NSError?) -> Void) {
        getFeaturedPostsAtPath(FeaturedPost.endpointForAllFeaturedPosts(), completionHandler: completionHandler)
    }
    
    class func getMoreFeaturedPosts(wrapper: FeaturedPostWrapper?, completionHandler: (FeaturedPostWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getFeaturedPostsAtPath(Router.readFeatured(wrapper!.currentPage!), completionHandler: completionHandler)
    }
    
    
}