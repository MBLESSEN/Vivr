//
//  User.swift
//  vivr
//
//  Created by max blessen on 11/20/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON

class UserDataWrapper {
    var UserData: Array<User>?
    var count: Int?
    var next: String?
    var previous: String?
    var currentPage: Int?
    var nextPage: Int?
    var lastPage: Int?
    var status: Int?
}


class User {
    var ID: Int?
    var userName: String?
    var email: String?
    var image: String?
    var hardWare: String?
    var bio: String?
    var review_count: Int?
    var favorite_count: Int?
    var wishlist_count: Int?
    var box_count: Int?
    
    static var currentUser: User?
    
    required init(json: JSON) {
        self.ID = json[ActivityFeedReviewsFields.ID.rawValue].intValue
        self.userName = json[ActivityFeedReviewsFields.userName.rawValue].stringValue
        self.image = json[ActivityFeedReviewsFields.image.rawValue].stringValue
        if let hardwareSting = json[ActivityFeedReviewsFields.hardWare.rawValue].stringValue as String? {
            if hardwareSting == "" {
                self.hardWare = "No hardware entered"
            }else {
                self.hardWare = hardwareSting
            }
        }
        if let bioString = json[ActivityFeedReviewsFields.bio.rawValue].stringValue as String? {
            if bioString == "" {
                self.bio = "I am a new user on vivr!"
            }else {
                self.bio = bioString
            }
        }
        self.review_count = json["review_count"].intValue
        self.favorite_count = json["favorite_count"].intValue
        self.wishlist_count = json["wishlist_count"].intValue
        self.box_count = json["box_count"].intValue
    }
    
    class func endpointForUserData(id: Int) -> URLRequestConvertible {
        return Router.readUser(id)
    }
    class func endpointForMyUserData() -> URLRequestConvertible {
        return Router.readCurrentUser()
    }
    private class func getData(userID: Int, path: URLRequestConvertible, completionHandler: (UserDataWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseUserData() { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print(result.1?.message)
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseUserData() { (response) in
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
    
    class func getUserData(userID: Int, completionHandler: (UserDataWrapper?, NSError?) -> Void) {
        getData(userID, path: User.endpointForUserData(userID), completionHandler: completionHandler)
    }
    
    class func getMyUserData(userID: Int, completionHandler: (UserDataWrapper?, NSError?) -> Void) {
        getData(userID, path: User.endpointForMyUserData(), completionHandler: completionHandler)
    }
    
    class func setUserDataToMyData(user: User) {
        myData.user = user
        myData.myProfileID = user.ID
        myData.myProfileName = user.userName!
        if let imageURL = user.image {
            if imageURL != "" {
                let url = NSURL(string: imageURL)
                if let data = NSData(contentsOfURL: url!) {
                    myData.userImage = UIImage(data: data)!
                }
            }else {
                let image = UIImage(named:"user_100")
                myData.userImage = image!
            }
        }
        myData.reviewsCount = user.review_count
        if user.bio == "" {
            myData.bio = "I am a new user on vivr!"
        }
        else{
            myData.bio = user.bio
        }
        if user.hardWare == "" {
            myData.hardWare =  "Let everyone know what hardware youre using."
        }else {
            myData.hardWare = user.hardWare
        }
        myData.wishlistCount = user.wishlist_count
        myData.favoritesCount = user.favorite_count
        myData.boxes_count = user.box_count
    }
    
    
}
