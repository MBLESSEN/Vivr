//
//  Tag.swift
//  vivr
//
//  Created by max blessen on 11/20/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON

class TagWrapper {
    var Tags: Array<Tag>?
    var count: Int?
    var next: String?
    var previous: String?
    var currentPage: Int?
    var nextPage: Int?
    var lastPage: Int?
}

class Tag {
    var ID: Int?
    var tagID: Int?
    var name: String?
    var description: String?
    
    required init (json: JSON, id: Int?) {
        self.ID = id
        self.tagID = json["id"].intValue
        self.name = json["name"].stringValue
        self.description = json["description"].stringValue
    }
    class func endpointForAllTags() -> URLRequestConvertible {
        return Router.loadAllTags(1)
    }
    private class func getTagsAtPath(path: URLRequestConvertible, completionHandler: (TagWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseTagsArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseTagsArray{ (response) in
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
    class func getTags(completionHandler: (TagWrapper?, NSError?) -> Void) {
        getTagsAtPath(Tag.endpointForAllTags(), completionHandler: completionHandler)
    }
    
    class func getMoreTags(wrapper: TagWrapper?, completionHandler: (TagWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getTagsAtPath(Router.loadAllTags(wrapper!.currentPage!), completionHandler: completionHandler)
    }
    
}
