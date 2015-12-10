//
//  DeviceInfo.swift
//  vivr
//
//  Created by max blessen on 11/20/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON



struct RefreshTokenResponse {
    var accessToken: String
    var refreshToken: String
}

struct ApiError {
    var error: NSError?
    var message: String?
    var success: Bool?
    
    var description: String {
        if let error = error {
            return error.description
        }
        else if let message = message {
            return message
        }
        return "ApiError"
    }
}

class DeviceInfo {
    class func refreshAuthToken(completionHandler: (RefreshTokenResponse?, ApiError?) -> ()) -> Void {
        let token = KeychainWrapper.stringForKey("refreshToken")
        let parameters: [String:AnyObject] = [
            "grant_type" : "refresh_token",
            "client_id" : "1",
            "client_secret" : "vapordelivery2015",
            "refresh_token" : token!
            
        ]
        print("parameters are")
        print(parameters)
        Alamofire.request(Router.requestAccessToken(parameters)).validate().responseJSON { (response) -> Void in
            print(response.response)
            if (response.response?.statusCode == 200) {
                let jsonResponse = JSON(response.result.value!)
                let authorization = Authorization(json: jsonResponse)
                authorization.addAuthorizationToKeychain(authorization)
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.loadProfileData()
                    
                let response = RefreshTokenResponse(accessToken: authorization.authKey!, refreshToken: authorization.refreshToken!)
                var clearance = ApiError()
                clearance.success = true
                clearance.message = "success"
                completionHandler(response, clearance)
                return
            }else if response.response?.statusCode == 401 {
                self.logOutDevice()
            }else {
                var APIresponse = ApiError()
                print("refresh failed")
                APIresponse.error = response.result.error as NSError!
                completionHandler(nil, APIresponse)
                return
            }
            
        }
    }
    
    class func logOutDevice() {
        Authorization.wipeAuthorizationFromKeyChain()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.logout()
    }
    
    class func checkIfFirstLoginEver(completionHandler: (Bool) -> Void) {
        if (!NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce")) {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            completionHandler(true)
            return
        }
        completionHandler(false)
    }
    
}

