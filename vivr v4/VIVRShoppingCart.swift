//
//  VIVRShoppingCart.swift
//  vivr
//
//  Created by max blessen on 11/20/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire


class VIVRShoppingCart: NSObject {
    var Products: Array<Product>?
    var orderDetails: VIVRShoppingCartDetails?
    
    func initWithJson(json: JSON, id: Int?) {
        
    }
    
   // class func endpointForShoppingCart() -> URLRequestConvertible {
        
   // }
    
    private class func getShoppingCartAtPath(path: URLRequestConvertible, completionHandler: (VIVRShoppingCart?, NSError?) -> Void) {
        
    }
    class func getShoppingCart(completiongHandler: (VIVRShoppingCart?, NSError?) ->Void) {
        
    }
    
    class func addProductToCart(product: Product, completionHandler: (VIVRShoppingCart?, NSError?) -> Void) {
        
    }
    
    

}
