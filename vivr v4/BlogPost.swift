//
//  BlogPost.swift
//  vivr
//
//  Created by max blessen on 11/20/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON

class BlogPost {
    
    var title: String?
    var description: String?
    var image: String?
    var createdAt: String?
    var productID: NSMutableArray?
    
    
    class func endpointForReadFeatured(pageID: Int) -> URLRequestConvertible {
        return Router.readBox(pageID)
    }
    
    
}