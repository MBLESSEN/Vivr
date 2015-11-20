//
//  Boxes.swift
//  vivr
//
//  Created by max blessen on 11/20/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON



class BoxesWrapper {
    var Box: Array<Boxes>?
    var count: Int?
    var next: String?
    var previous: String?
    var currentPage: Int?
    var nextPage: Int?
    var lastPage: Int?
    
}

class Boxes {
    var id: Int?
    var boxID: Int?
    var userID: Int?
    var name: String?
    var description: String?
    var createdAt: String?
    var productCount: Int?
    var Products: Array<Product>?
    var user: User?
    
    required init(json: JSON, id: Int?) {
        self.id = id
        self.boxID = json["id"].intValue
        self.userID = json["user_id"].intValue
        self.name = json["name"].stringValue
        if let descriptionString = json["description"].stringValue as String? {
            if descriptionString == "" {
                
            }
            self.description = json["description"].stringValue
        }
        self.createdAt = json["created_at"].stringValue
        self.productCount = json["product_count"].intValue
        if let userData = JSON(json[ActivityFeedReviewsFields.user.rawValue].rawValue) as JSON? {
            self.user = User(json: userData)
        }
        if let productData = JSON(json["products"].arrayValue) as JSON? {
            self.Products = Array<Product>()
            for jsonProducts in productData {
                let product = Product(json: jsonProducts.1, id: Int(jsonProducts.0))
                print(product)
                Products!.append(product)
            }
        }
    }
    
    class func endpointForReadAllBoxes(pageID: Int) -> URLRequestConvertible {
        return Router.readAllBoxes(1)
    }
    
    class func endpointForReadBox(boxID: Int) -> URLRequestConvertible {
        return Router.readBox(boxID)
    }
    
    class func endpointForReadBoxProducts(boxID: Int) -> URLRequestConvertible {
        return Router.readBoxProducts(boxID)
    }
    
    class func endpointForReadUserBoxes(userID: Int) -> URLRequestConvertible {
        return Router.readUserBoxes(userID, 1)
    }
    
    private class func getBoxesAtPath(path: URLRequestConvertible, completionHandler: (BoxesWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseBoxesArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseBoxesArray { (response) in
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
    
    private class func getSingleBoxAtPath(path: URLRequestConvertible, completionHandler: (BoxesWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseSingleBox{ (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseBoxesArray { (response) in
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
    
    private class func getBoxProductsAtPath(path: URLRequestConvertible, completionHandler: (ProductWrapper?, NSError?) -> Void) {
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
    
    
    class func getAllBoxes(completionHandler: (BoxesWrapper?, NSError?) -> Void) {
        getBoxesAtPath(Boxes.endpointForReadAllBoxes(1), completionHandler: completionHandler)
    }
    
    class func getMoreBoxes(wrapper: BoxesWrapper?, completionHandler: (BoxesWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getBoxesAtPath(Router.readAllBoxes(wrapper!.currentPage!), completionHandler: completionHandler)
    }
    
    class func getSingleBox(boxID: Int, completionHandler: (BoxesWrapper?, NSError?) -> Void) {
        getSingleBoxAtPath(Boxes.endpointForReadBox(boxID), completionHandler: completionHandler)
    }
    class func getBoxProducts(boxID: Int, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        getBoxProductsAtPath(Boxes.endpointForReadBoxProducts(boxID), completionHandler: completionHandler)
    }
    
    class func getAllUserBoxes(userID: Int, completionHandler: (BoxesWrapper?, NSError?) -> Void) {
        getBoxesAtPath(Boxes.endpointForReadUserBoxes(userID), completionHandler: completionHandler)
    }
    class func getMoreUserBoxes(userID: Int, wrapper: BoxesWrapper?, completionHandler: (BoxesWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getBoxesAtPath(Router.readUserBoxes(userID, wrapper!.currentPage!), completionHandler: completionHandler)
    }
    
    class func addProductToBox(boxID: Int, productID: Int, completionHandler : (NSError?) -> Void) {
        let parameters: [String:AnyObject] = [
            "product_id": productID
        ]
        Alamofire.request(Router.addProductToBox(boxID, parameters)).responseJSON { response  in
            if response.result.isFailure {
                completionHandler(response.result.error as NSError!)
                return
            }
            return completionHandler(nil)
        }
    }
    
    
}
