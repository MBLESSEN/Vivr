//
//  AppDelegate.swift
//  vivr v4
//
//  Created by max blessen on 12/17/14.
//  Copyright (c) 2014 max blessen. All rights reserved.
//

import UIKit
import Alamofire

struct myData {
    static var myProfileID:String = ""
    static var myProfileName:String = ""
    static var favoritesCount:String = ""
    static var reviewsCount:String = ""
    static var wishlistCount:String = ""
    static var hardWare:String?
    static var bio:String?
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.applyTheme()
        self.loadProfileData()
        // Override point for customization after application launch.
        return true
    }
    
    func applyTheme() {
        
        let backImage = UIImage(named: "back")?.imageWithRenderingMode(.AlwaysTemplate)
        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        UINavigationBar.appearance().tintColor = UIColor(red: 43.0/255, green: 169.0/255, blue: 41.0/255, alpha: 1.0)
        UINavigationBar.appearance().translucent = true;
    }
    
    func loadProfileData() {
        Alamofire.request(Router.readCurrentUser()).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let id = jsonOBJ["id"].stringValue as String? {
                    myData.myProfileID = id
                    Alamofire.request(Router.readUserReviews(id)).responseJSON { (request, response, json, error) in
                        if (json != nil) {
                            var jsonOBJ = JSON(json!)
                            if let rcount = jsonOBJ["total"].stringValue as String? {
                                myData.reviewsCount = rcount
                            }
                            
                        }
                    }
                    Alamofire.request(Router.readUserFavorites(id)).responseJSON { (request, response, json, error) in
                        if (json != nil) {
                            var jsonOBJ = JSON(json!)
                            if let fcount = jsonOBJ["total"].stringValue as String? {
                                myData.favoritesCount = fcount
                            }
                        }
                    }
                    Alamofire.request(Router.readWishlist(id)).responseJSON { (request, response, json, error) in
                        if (json != nil) {
                            var jsonOBJ = JSON(json!)
                            if let wcount = jsonOBJ["total"].stringValue as String? {
                                myData.wishlistCount = wcount
                            }
                        }
                    }
                }
                if let name = jsonOBJ["username"].stringValue as String? {
                    myData.myProfileName = name
                }
                if let hardware = jsonOBJ["hardware"].stringValue as String? {
                    myData.hardWare = hardware
                }
                if let bio = jsonOBJ["bio"].stringValue as String? {
                    myData.bio = bio
                }
            }
        }
    
        Alamofire.request(Router.readUserReviews(myData.myProfileID)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let rcount = jsonOBJ["total"].stringValue as String? {
                    myData.reviewsCount = rcount
                }
                
            }
        }
        Alamofire.request(Router.readUserFavorites(myData.myProfileID)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let fcount = jsonOBJ["total"].stringValue as String? {
                    myData.favoritesCount = fcount
                }
            }
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

