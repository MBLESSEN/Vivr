//
//  Authorization.swift
//  vivr
//
//  Created by max blessen on 11/20/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON


class Authorization {
    var authKey: String?
    var refreshToken: String?
    
    required init(json: JSON){
        self.authKey = json["access_token"].stringValue
        self.refreshToken = json["refresh_token"].stringValue
    }
    
    
    class func endpointForRequestAccessToken(parameters: [String:AnyObject]) -> URLRequestConvertible {
        return Router.requestAccessToken(parameters)
    }
    
    private class func requestToken(parameters: [String:AnyObject], path: URLRequestConvertible, completionHandler: (Authorization?, NSError?) -> Void) {
        Alamofire.request(Router.requestAccessToken(parameters)).responseAuthorization { (response) in
            if response.result.isSuccess {
                completionHandler(response.result.value, nil)
            }else {
                completionHandler(nil, response.result.error)
            }
        }
        
    }
    
    class func isApplicationAuthorized(completionHandler: Bool -> Void)  {
        let authToken = KeychainWrapper.stringForKey("authToken")
        if authToken == nil {
            return completionHandler(false)
        }else {
        return completionHandler(true)
        }
    }
    
    func addAuthorizationToKeychain(authorization: Authorization) {
        myData.authToken = authorization.authKey!
        myData.refreshToken = authorization.refreshToken!
        KeychainWrapper.setString(authorization.authKey!, forKey: "authToken")
        KeychainWrapper.setString(authorization.refreshToken!, forKey: "refreshToken")
    }
    
    class func wipeAuthorizationFromKeyChain() {
        KeychainWrapper.removeObjectForKey("authToken")
        KeychainWrapper.removeObjectForKey("refreshToken")
    }
    
}