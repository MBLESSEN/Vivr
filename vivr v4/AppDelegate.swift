//
//  AppDelegate.swift
//  vivr v4
//
//  Created by max blessen on 12/17/14.
//  Copyright (c) 2014 max blessen. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
//testing commit

struct myData {
    static var myProfileID:Int?
    static var myProfileName:String = ""
    static var favoritesCount:Int?
    static var reviewsCount:Int?
    static var wishlistCount:Int?
    static var hardWare:String?
    static var bio:String?
    static var userImage:UIImage = UIImage()
    static var authToken: String?
    static var refreshToken: String?
    static var imageHeight: CGFloat?
    static var brandFlavorImageHeight: CGFloat?
    static var productImageHeight: CGFloat?
    static var user: User?
    static var userWrapper: UserDataWrapper?
    static var boxes_count: Int?
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var initialNavController = UINavigationController()
    var window: UIWindow?
    var isLoggedIn: Bool?
    var isLoadingUserData = false
    var loggedOut = false
    var userData: User?
    var userWrapper: UserDataWrapper?

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        initializeMixPanel()
        Authorization.isApplicationAuthorized({ (isAuthorized) in
            if isAuthorized == false {
                self.isLoggedIn = false
            }else if isAuthorized == true {
                self.loadProfileData()
                self.login()
                self.isLoggedIn = true
                self.loggedOut = false
                }
            })
            self.setMyIphoneSizeStruct()
            self.applyTheme()
        
        
        return true
        
    }
    
    func setMyIphoneSizeStruct() {
        if (UIScreen.mainScreen().bounds.width < 370) {
            myData.imageHeight = 200
            myData.brandFlavorImageHeight = 200
            myData.productImageHeight = 160
        }else{
            myData.imageHeight = 220
            myData.brandFlavorImageHeight = 240
            myData.productImageHeight = 180
        }
    }
    
    func initializeMixPanel() {
       // Mixpanel.sharedInstanceWithToken("c1599b606c61921e73a4c5d6f1e2491b")
       // let mixpanel: Mixpanel = Mixpanel.sharedInstance()
        //mixpanel.track("App Launched")
    }
    
    func storeUserData(user: User) {
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
    
    func createUserStruct() {
        let context:NSManagedObjectContext = self.managedObjectContext!
        let request = NSFetchRequest(entityName: "UserData")
        request.returnsObjectsAsFaults = false
        let results:NSArray = try! context.executeFetchRequest(request)
        if results.count > 0 {
            let data = results[0] as! NSManagedObject
            myData.myProfileName = data.valueForKey("userName") as! String
            myData.myProfileID = data.valueForKey("userID") as? Int
            if let imageURL = data.valueForKey("userImage") as? String {
                let url = NSURL(string: imageURL)
                if let data = NSData(contentsOfURL: url!) {
                    myData.userImage = UIImage(data: data)!
                }
            }
            myData.reviewsCount = data.valueForKey("juice_count") as? Int
            myData.bio = data.valueForKey("bio") as? String
            myData.hardWare = data.valueForKey("hardware") as? String
            myData.wishlistCount = data.valueForKey("wish_count") as? Int
            myData.favoritesCount = data.valueForKey("favorite_count") as? Int
            
        }
        
    }
    
    func logout() {
        window?.rootViewController = nil
        KeychainWrapper.removeObjectForKey("authToken")
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyBoard.instantiateViewControllerWithIdentifier("Walk") as! loginViewController
        initialNavController = UINavigationController(rootViewController: initialViewController)
        self.window?.rootViewController = initialNavController
        self.window?.makeKeyAndVisible()
        
    }
    
    
    func login() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyBoard.instantiateViewControllerWithIdentifier("HomeView") as! UITabBarController
        let nav = initialViewController.viewControllers![0] as! UINavigationController
        let vc = nav.viewControllers[0] as! VIVRHomeViewController
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        DeviceInfo.checkIfFirstLoginEver( {firstLaunch in
            if firstLaunch == true {
                vc.isFirstLaunch = true
            }
        })
    }

    
    func applyTheme() {
       // UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        UINavigationBar.appearance().tintColor = UIColor(red: 43.0/255, green: 169.0/255, blue: 41.0/255, alpha: 1.0)
        UINavigationBar.appearance().translucent = true;
    }
    
    func addUserDataFromWrapper(wrapper: UserDataWrapper?) {
        self.userWrapper = wrapper
        if self.userData == nil {
            self.userData = self.userWrapper?.UserData?.first
        }
        if userData != nil {
            storeUserData((self.userWrapper?.UserData?.first)!)
        }
    }
    
    
    func loadProfileData() {
        isLoadingUserData = true
        self.userData = nil
        User.getMyUserData(0, completionHandler: { (userDataWrapper, error) in
            if error != nil {
                self.isLoadingUserData = false
                print("error in load Profile")
            }
            self.addUserDataFromWrapper(userDataWrapper)
            self.isLoadingUserData = false
        })
        
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
        
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("userData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("vivr_v4.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: mOptions)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    


}

