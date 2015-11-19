//
//  APIWrapper.swift
//  vivr v4
//
//  Created by max blessen on 5/21/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
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
                if let accessToken = jsonResponse["access_token"].string, refreshToken = jsonResponse["refresh_token"].string {
                        myData.authToken = accessToken
                        myData.refreshToken = refreshToken
                        KeychainWrapper.setString(myData.authToken!, forKey: "authToken")
                        KeychainWrapper.setString(myData.refreshToken!, forKey: "refreshToken")
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.loadProfileData()
                    
                    let response = RefreshTokenResponse(accessToken: accessToken, refreshToken: refreshToken)
                    var clearance = ApiError()
                    clearance.success = true
                    clearance.message = "success"
                    completionHandler(response, clearance)
                    return
                    
                } else {
                    var response = ApiError()
                    response.success = false
                    response.message = "access_token or refresh_token is nil"
                    completionHandler(nil, response)
                    return
                }
            } else {
                var APIresponse = ApiError()
                print("refresh failed")
                APIresponse.error = response.result.error as NSError!
                completionHandler(nil, APIresponse)
                return
            }
            
        }
    }
}

enum ActivityFeedReviewsFields: String {
    case ID = "id"
    case userID = "user_id"
    case productID = "product_id"
    case brandID = "brand_id"
    case description = "description"
    case throat = "throat"
    case vapor = "vapor"
    case score = "score"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case helpfulCount = "helpful_count"
    case currentHelpful = "current_helpful"
    case currentFavorite = "current_favorite"
    case currentWishlist = "current_wishlist"
    case product = "product"
    case brand = "brand"
    case user = "user"
    case name = "name"
    case userName = "username"
    case image = "image"
    case reviewCount = "review_count"
    case scores = "scores"
    case hardWare = "hardware"
    case bio = "bio"
    
}

class ActivityWrapper {
    var ActivityReviews: Array<ActivityFeedReviews>?
    var count: Int?
    var next: String?
    var previous: String?
    var currentPage: Int?
    var nextPage: Int?
    var lastPage: Int?
}

class BoxesWrapper {
    var Box: Array<Boxes>?
    var count: Int?
    var next: String?
    var previous: String?
    var currentPage: Int?
    var nextPage: Int?
    var lastPage: Int?
    
}

class BrandWrapper {
    var Brands: Array<Brand>?
    var count: Int?
    var next: String?
    var previous: String?
    var currentPage: Int?
    var nextPage: Int?
    var lastPage: Int?
}

class ProductWrapper {
    var Products: Array<Product>?
    var count: Int?
    var next: String?
    var previous: String?
    var currentPage: Int?
    var nextPage: Int?
    var lastPage: Int?
}

class FavoriteWrapper {
    var Products: Array<Favorite>?
    var count: Int?
    var next: String?
    var previous: String?
    var currentPage: Int?
    var nextPage: Int?
    var lastPage: Int?
}
class WishWrapper {
    var Products: Array<Wish>?
    var count: Int?
    var next: String?
    var previous: String?
    var currentPage: Int?
    var nextPage: Int?
    var lastPage: Int?
}
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

class TagWrapper {
    var Tags: Array<Tag>?
    var count: Int?
    var next: String?
    var previous: String?
    var currentPage: Int?
    var nextPage: Int?
    var lastPage: Int?
}

class searchWrapper {
    var Products: Array<Product>?
    var Brands: Array<Brand>?
    var Users: Array<User>?
    
}



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
}

class ActivityFeedReviews {
    var ID: Int?
    var reviewID: String?
    var userID: String?
    var productID: String?
    var description: String?
    var throat: Int?
    var vapor: Int?
    var score: String?
    var createdAt: String?
    var updatedAt: String?
    var image: String?
    var helpfulCount: Int?
    var currentHelpful: Bool?
    var product: Product?
    var user: User?
    var brand: Brand?
    
    required init(json: JSON, id: Int?) {
        self.ID = id
        self.reviewID = json[ActivityFeedReviewsFields.ID.rawValue].stringValue
        self.userID = json[ActivityFeedReviewsFields.userID.rawValue].stringValue
        self.productID = json[ActivityFeedReviewsFields.productID.rawValue].stringValue
        self.description = json[ActivityFeedReviewsFields.description.rawValue].stringValue
        self.throat = json[ActivityFeedReviewsFields.throat.rawValue].intValue
        self.vapor = json[ActivityFeedReviewsFields.vapor.rawValue].intValue
        self.score = json[ActivityFeedReviewsFields.score.rawValue].stringValue
        self.image = json["image"].stringValue
        self.createdAt = json[ActivityFeedReviewsFields.createdAt.rawValue].stringValue
        self.updatedAt = json[ActivityFeedReviewsFields.updatedAt.rawValue].stringValue
        self.helpfulCount = json[ActivityFeedReviewsFields.helpfulCount.rawValue].intValue
        self.currentHelpful = json[ActivityFeedReviewsFields.currentHelpful.rawValue].boolValue
        if let productData = JSON(json[ActivityFeedReviewsFields.product.rawValue].rawValue) as JSON? {
            self.product = Product(json: productData, id: 0)
        }
        if let userData = JSON(json[ActivityFeedReviewsFields.user.rawValue].rawValue) as JSON? {
            self.user = User(json: userData)
        }
        if let brandData = JSON(json[ActivityFeedReviewsFields.product.rawValue][ActivityFeedReviewsFields.brand.rawValue].rawValue) as JSON? {
            self.brand = Brand(json: brandData, id: 0)
        }
    }
    
    class func endpointForActivity() -> URLRequestConvertible {
        return Router.readFeed(1)
    }
    class func endpointForUserReviews(id: Int) -> URLRequestConvertible {
        return Router.readUserReviews(id, 1)
    }
    class func endpointForProductReviews(id: String) -> URLRequestConvertible {
        return Router.ReadReviews(id, 1)
    }
    class func endpointForFilteredActivity(tags: String) -> URLRequestConvertible {
        return Router.readFeedFiltered(tags, 1)
    }
    private class func getActivity(path: URLRequestConvertible, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseActivityArray { response in
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                    Alamofire.request(path).responseActivityArray { (response) in
                        if let err = response.result.error {
                            completionHandler(nil, err)
                            return
                        }
                        completionHandler(response.result.value, nil)
                        }
                    }else {
                        completionHandler(nil, response.result.error)
                        return
                    }
                }
            }else if response.result.isFailure  {
                completionHandler(nil, response.result.error)
                return
            }
            completionHandler(response.result.value, nil)
    
        }

    }
    class func getReviews(completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        getActivity(ActivityFeedReviews.endpointForActivity(), completionHandler: completionHandler)
    }
    
    class func getMoreReviews(wrapper: ActivityWrapper?, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getActivity(Router.readFeed(wrapper!.currentPage!), completionHandler: completionHandler)
    }
    private class func getFilteredActivity(path: URLRequestConvertible, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseActivityArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        print("true")
                        Alamofire.request(path).responseActivityArray { (response) in
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
    class func getFilteredReviews(tags: String, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        getFilteredActivity(ActivityFeedReviews.endpointForFilteredActivity(tags), completionHandler: completionHandler)
    }
    
    class func getMoreFilteredReviews(tags: String, wrapper: ActivityWrapper?, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getActivity(Router.readFeedFiltered(tags, wrapper!.currentPage!), completionHandler: completionHandler)
    }
    private class func getUserReviewAtPath(userID: String, path: URLRequestConvertible, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseActivityArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseActivityArray { (response) in
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
    class func getUserReviews(id: Int, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        getActivity(ActivityFeedReviews.endpointForUserReviews(id), completionHandler: completionHandler)
    }
    
    class func getMoreUserReviews(id: Int, wrapper: ActivityWrapper?, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getActivity(Router.readUserReviews(id, wrapper!.currentPage!), completionHandler: completionHandler)
    }
    
    private class func getProductReviewAtPath(productID: String, path: URLRequestConvertible, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseActivityArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseActivityArray { (response) in
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
    class func getProductReviews(id: String, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        getActivity(ActivityFeedReviews.endpointForProductReviews(id), completionHandler: completionHandler)
    }
    
    class func getMoreProductReviews(id: String, wrapper: ActivityWrapper?, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getActivity(Router.ReadReviews(id, wrapper!.currentPage!), completionHandler: completionHandler)
    }

}

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


class Brand {
    var id: Int?
    var name: String?
    var description: String?
    var image:String?
    var logo: String?
    var productCount: Int?
    
    required init(json: JSON, id: Int?) {
        self.id = json[ActivityFeedReviewsFields.ID.rawValue].intValue
        self.name = json[ActivityFeedReviewsFields.name.rawValue].stringValue
        self.description = json[ActivityFeedReviewsFields.description.rawValue].stringValue
        self.image = json["logo"].stringValue
        self.productCount = json["product_count"].intValue
    }
    
    class func endpointForBrowseBrands() -> URLRequestConvertible {
        return Router.ReadBrands(1)
    }
    
    class func endpointForFindBrands(searchText: String) -> URLRequestConvertible {
        return Router.findSpecificBrands(searchText, 1)
    }
    
    class func endpointForCreateNewBrand(parameters: [String:AnyObject]) -> URLRequestConvertible {
        return Router.createNewBrand(parameters)
    }
    
    
    private class func getBrandsAtPath(path: URLRequestConvertible, completionHandler: (BrandWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseBrandArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseBrandArray{ (response) in
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
    class func getBrands(completionHandler: (BrandWrapper?, NSError?) -> Void) {
        getBrandsAtPath(Brand.endpointForBrowseBrands(), completionHandler: completionHandler)
    }
    
    class func getMoreBrands(wrapper: BrandWrapper?, completionHandler: (BrandWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getBrandsAtPath(Router.ReadBrands(wrapper!.currentPage!), completionHandler: completionHandler)
    }
    class func findBrands(searchText: String, completionHandler: (BrandWrapper?, NSError?) -> Void) {
        getBrandsAtPath(Brand.endpointForFindBrands(searchText), completionHandler: completionHandler)
    }
    
    class func createNewBrand(parameters: [String:AnyObject], completionHandler: (BrandWrapper?, NSError?) -> Void) {
        Alamofire.request(Router.createNewBrand(parameters)).responseJSON { (response) in
            
        }
        
    }
}

class Favorite {
    var ID: Int?
    var userID: String?
    var productID: Int?
    var product: Product?
    var brand: Brand?
    var createdAt: String?
    
    required init(json: JSON, id: Int?) {
        self.ID = id
        self.productID = json[ActivityFeedReviewsFields.productID.rawValue].intValue
        self.userID = json[ActivityFeedReviewsFields.userID.rawValue].stringValue
        self.createdAt = json[ActivityFeedReviewsFields.createdAt.rawValue].stringValue
        if let productData = JSON(json[ActivityFeedReviewsFields.product.rawValue].rawValue) as JSON? {
            self.product = Product(json: productData, id: 0)
        }
        if let brandData = JSON(json[ActivityFeedReviewsFields.product.rawValue][ActivityFeedReviewsFields.brand.rawValue].rawValue) as JSON? {
            self.brand = Brand(json: brandData, id: 0)
        }
    }
    
    class func endpointForUserFavorites(id: Int) -> URLRequestConvertible {
        return Router.readUserFavorites(id, 1)
    }
    private class func getProductAtPath(userID: Int, path: URLRequestConvertible, completionHandler: (FavoriteWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseFavoriteArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseFavoriteArray { (response) in
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
    class func getProducts(userID: Int, completionHandler: (FavoriteWrapper?, NSError?) -> Void) {
        getProductAtPath(userID, path: Favorite.endpointForUserFavorites(userID), completionHandler: completionHandler)
    }
    
    class func getMoreProducts(userID: Int, wrapper: FavoriteWrapper?, completionHandler: (FavoriteWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getProductAtPath(userID, path: Router.readUserFavorites(userID, wrapper!.currentPage!), completionHandler: completionHandler)
    }
}

class Photo {
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

class Product {
    var ID: Int?
    var productID: Int?
    var brandID: Int?
    var name: String?
    var image: String?
    var description: String?
    var currentFavorite: Bool?
    var currentWishlist: Bool?
    var brand: Brand?
    var scores: Score?
    var tags: Array<Tag>?
    
    required init(json: JSON, id: Int?) {
        self.ID = id
        self.productID = json[ActivityFeedReviewsFields.ID.rawValue].intValue
        self.brandID = json[ActivityFeedReviewsFields.brandID.rawValue].intValue
        self.name = json[ActivityFeedReviewsFields.name.rawValue].stringValue
        self.image = json[ActivityFeedReviewsFields.image.rawValue].stringValue
        self.description = json[ActivityFeedReviewsFields.description.rawValue].stringValue
        self.currentFavorite = json[ActivityFeedReviewsFields.currentFavorite.rawValue].boolValue
        self.currentWishlist = json[ActivityFeedReviewsFields.currentWishlist.rawValue].boolValue
        if let brandData = JSON(json[ActivityFeedReviewsFields.brand.rawValue].rawValue) as JSON? {
            self.brand = Brand(json: brandData, id: 0)
        }
        if let scoreData = JSON(json[ActivityFeedReviewsFields.scores.rawValue].rawValue) as JSON? {
            self.scores = Score(json: scoreData)
        }
        if let tagData = JSON(json["tags"].arrayValue) as JSON? {
            self.tags = Array<Tag>()
            for jsonTags in tagData {
                print(jsonTags)
                let tag = Tag(json: jsonTags.1, id: Int(jsonTags.0))
                tags!.append(tag)
            }
        }
    }
    class func endpointForActivity() -> URLRequestConvertible {
        return Router.readAllProducts(1)
    }
    class func endpointForFilteredProducts(tags: String) -> URLRequestConvertible {
        return Router.readAllFilteredProducts(tags, 1)
    }
    class func endpointForSingleProduct(id: String) -> URLRequestConvertible {
        return Router.ReadProductData(id)
    }
    class func endpointForBrandProducts(brandID: String) -> URLRequestConvertible {
        return Router.ReadBrandProducts(brandID)
    }
    class func endpointForFindProducts(searchText: String) -> URLRequestConvertible {
        return Router.findSpecificProduct(searchText, 1)
    }
    class func endpointForPostProductToBrand(brandID: Int, parameters: [String:AnyObject]) -> URLRequestConvertible {
        return Router.postProduct(brandID, parameters)
    }
    
    private class func getProductAtPath(path: URLRequestConvertible, completionHandler: (ProductWrapper?, NSError?) -> Void) {
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
    class func getProducts(completionHandler: (ProductWrapper?, NSError?) -> Void) {
        getProductAtPath(Product.endpointForActivity(), completionHandler: completionHandler)
    }
    
    class func getMoreProducts(wrapper: ProductWrapper?, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getProductAtPath(Router.readAllProducts(wrapper!.currentPage!), completionHandler: completionHandler)
    }
    private class func getFilteredProductAtPath(path: URLRequestConvertible, completionHandler: (ProductWrapper?, NSError?) -> Void) {
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
    class func getFilteredProducts(tags: String, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        getFilteredProductAtPath(Product.endpointForFilteredProducts(tags), completionHandler: completionHandler)
    }
    
    class func getMoreFilteredProducts(tags: String, wrapper: ProductWrapper?, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getFilteredProductAtPath(Router.readAllFilteredProducts(tags, wrapper!.currentPage!), completionHandler: completionHandler)
    }
    
    private class func getSingleProductAtPath(path: URLRequestConvertible, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseSingleProduct { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseSingleProduct{ (response) in
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
    
    class func getSingleProductData(productID: String, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        getSingleProductAtPath(Product.endpointForSingleProduct(productID), completionHandler: completionHandler)
    }
    
    private class func getBrandProductsAtPath(path: URLRequestConvertible, completionHandler: (ProductWrapper?, NSError?) -> Void) {
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
    class func getBrandProducts(brandID: String, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        getBrandProductsAtPath(Product.endpointForBrandProducts(brandID), completionHandler: completionHandler)
    }
    
    class func getMoreBrandProducts(wrapper: ProductWrapper?, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil {
            completionHandler(nil, nil)
            return
        }
        getProductAtPath(Router.readAllProducts(wrapper!.currentPage!), completionHandler: completionHandler)
    }
    
    class func findProducts(searchText: String, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        getProductAtPath(Product.endpointForFindProducts(searchText), completionHandler: completionHandler)
    }
    
    private class func postProductToBrand(parameterspath: URLRequestConvertible, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        Alamofire.request(parameterspath).responseProductArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(parameterspath).responseProductArray { (response) in
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
    class func addProductToBrand(brandID: Int, parameters: [String:AnyObject], completionHandler : (ProductWrapper?, NSError?) -> Void) {
       postProductToBrand(Product.endpointForPostProductToBrand(brandID, parameters: parameters), completionHandler: completionHandler)
    }
    
}

class SearchResult {
    var Products: ProductWrapper
    var Brands: BrandWrapper
    var Users: UserDataWrapper
    
    required init(json: JSON) {
        self.Products = ProductWrapper()
        self.Brands = BrandWrapper()
        self.Users = UserDataWrapper()
    }
    
    class func endpointForSearch(searchText: String) -> URLRequestConvertible {
        return Router.search(searchText, 1)
    }
    
    private class func getSearchResultsAtPath(path: URLRequestConvertible, completionHandler: (SearchResult?, NSError?) -> Void) {
        Alamofire.request(path).responseSearchResults { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseSearchResults { (response) in
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
    class func getSearchResults(searchText: String, completionHandler: (SearchResult?, NSError?) -> Void) {
        getSearchResultsAtPath(SearchResult.endpointForSearch(searchText), completionHandler: completionHandler)
    }
    
    class func getMoreProductSearchResults(searchText: String, wrapper: SearchResult?, completionHandler: (SearchResult?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.Products.next == nil {
            completionHandler(nil, nil)
            return
        }
        getSearchResultsAtPath(Router.search(searchText, wrapper!.Products.currentPage!), completionHandler: completionHandler)
    }
    class func getMoreBrandSearchResults(searchText: String, wrapper: SearchResult?, completionHandler: (SearchResult?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.Brands.next == nil {
            completionHandler(nil, nil)
            return
        }
        getSearchResultsAtPath(Router.search(searchText, wrapper!.Brands.currentPage!), completionHandler: completionHandler)
    }
    class func getMoreUserSearchResults(searchText: String, wrapper: SearchResult?, completionHandler: (SearchResult?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.Users.next == nil {
            completionHandler(nil, nil)
            return
        }
        getSearchResultsAtPath(Router.search(searchText, wrapper!.Users.currentPage!), completionHandler: completionHandler)
    }
}

class Score {
    var productID: Int?
    var reviewCount: Int?
    var throat: Float?
    var vapor: Float?
    var score: Float?
    
    required init(json: JSON) {
        self.productID = json[ActivityFeedReviewsFields.productID.rawValue].intValue
        self.reviewCount = json[ActivityFeedReviewsFields.reviewCount.rawValue].intValue
        self.throat = json[ActivityFeedReviewsFields.throat.rawValue].floatValue
        self.vapor = json[ActivityFeedReviewsFields.vapor.rawValue].floatValue
        self.score = json[ActivityFeedReviewsFields.score.rawValue].floatValue
    }
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
            if response.response?.statusCode != 200
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
    
    

}
class Wish {
    var ID: Int?
    var userID: String?
    var productID: Int?
    var product: Product?
    var brand: Brand?
    var createdAt: String?
    
    required init(json: JSON, id: Int?) {
        self.ID = id
        self.productID = json[ActivityFeedReviewsFields.productID.rawValue].intValue
        self.userID = json[ActivityFeedReviewsFields.userID.rawValue].stringValue
        self.createdAt = json[ActivityFeedReviewsFields.createdAt.rawValue].stringValue
        if let productData = JSON(json[ActivityFeedReviewsFields.product.rawValue].rawValue) as JSON? {
            self.product = Product(json: productData, id: 0)
        }
        if let brandData = JSON(json[ActivityFeedReviewsFields.product.rawValue][ActivityFeedReviewsFields.brand.rawValue].rawValue) as JSON? {
            self.brand = Brand(json: brandData, id: 0)
        }
    }
    
    class func endpointForUserWishlist(id: Int) -> URLRequestConvertible {
        return Router.readWishlist(id, 1)
    }
    private class func getProductAtPath(userID: Int, path: URLRequestConvertible, completionHandler: (WishWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseWishArray { (response) in
            let data = response.result.value
            let error = response.result.error
            if response.result.isFailure
            {
                print("fetching refresh token")
                DeviceInfo.refreshAuthToken() {
                    result in
                    print("authenticating")
                    if result.1?.success == true {
                        Alamofire.request(path).responseWishArray { (response) in
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
    
    class func getProducts(userID: Int, completionHandler: (WishWrapper?, NSError?) -> Void) {
        getProductAtPath(userID, path: Wish.endpointForUserWishlist(userID), completionHandler: completionHandler)
    }
    
    class func getMoreProducts(userID: Int, wrapper: WishWrapper?, completionHandler: (WishWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil{
            completionHandler(nil, nil)
            return
        }
        getProductAtPath(userID, path: Router.readWishlist(userID, wrapper!.currentPage!), completionHandler: completionHandler)
    }
}


extension Alamofire.Request {
    class func authResponseSerializer() -> ResponseSerializer<Authorization, NSError> {
        return ResponseSerializer {request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            var jsonData: AnyObject?
            var jsonError: NSError?
            do {
                jsonData = try NSJSONSerialization.JSONObjectWithData(validData, options: [])
            } catch let error as NSError {
                jsonError = error
                jsonData = nil
            } catch {
                fatalError()
            }
            if jsonData == nil || jsonError != nil {
                let failureReason = "No data returned"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            let json = JSON(jsonData!)
            do {
                let auth:Authorization = Authorization(json: json)
                return .Success(auth)
                
            }
        }
        
    }
    
    class func ActivityArrayResponseSerializer() -> ResponseSerializer<ActivityWrapper, NSError> {
        return ResponseSerializer {request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            if response?.statusCode != 200 {
                let failureReason = "access denied"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            var jsonData: AnyObject?
            var jsonError: NSError?
            do {
                jsonData = try NSJSONSerialization.JSONObjectWithData(validData, options: [])
            } catch let error as NSError {
                jsonError = error
                jsonData = nil
            } catch {
                fatalError()
            }
            if jsonData == nil || jsonError != nil {
                let failureReason = "No data returned"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let json = JSON(jsonData!)
            
            let wrapper:ActivityWrapper = ActivityWrapper()
            wrapper.count = json["total"].intValue
            wrapper.currentPage = json["current_page"].intValue
            if let nextPage = wrapper.currentPage!++ as Int? {
                wrapper.nextPage = nextPage
            }
            wrapper.lastPage = json["last_page"].intValue
            wrapper.next = json["next_page_url"].stringValue
            
            var allReviews:Array = Array<ActivityFeedReviews>()
            let results = json["data"]
            for jsonReviews in results {
                let review = ActivityFeedReviews(json: jsonReviews.1, id: Int(jsonReviews.0))
                allReviews.append(review)
            }
            wrapper.ActivityReviews = allReviews
            return .Success(wrapper)
            
        }
    }
    class func ProductArrayResponseSerializer() -> ResponseSerializer<ProductWrapper, NSError> {
        return ResponseSerializer {request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            var jsonData: AnyObject?
            var jsonError: NSError?
            do {
                jsonData = try NSJSONSerialization.JSONObjectWithData(validData, options: [])
            } catch let error as NSError {
                jsonError = error
                jsonData = nil
            } catch {
                fatalError()
            }
            if jsonData == nil || jsonError != nil {
                let failureReason = "No data returned"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let json = JSON(jsonData!)
            
            
            let wrapper:ProductWrapper = ProductWrapper()
            wrapper.count = json["total"].intValue
            wrapper.currentPage = json["current_page"].intValue
            if let nextPage = wrapper.currentPage!++ as Int? {
                wrapper.nextPage = nextPage
            }
            wrapper.lastPage = json["last_page"].intValue
            wrapper.next = json["next_page_url"].stringValue
            
            var allProducts:Array = Array<Product>()
            let results = json["data"]
            for jsonProducts in results {
                let product = Product(json: jsonProducts.1, id: Int(jsonProducts.0))
                allProducts.append(product)
            }
            wrapper.Products = allProducts
            return .Success(wrapper)
            
        }
    }
    class func SingleProductResponseSerializer() -> ResponseSerializer<ProductWrapper, NSError> {
        return ResponseSerializer {request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            var jsonData: AnyObject?
            var jsonError: NSError?
            do {
                jsonData = try NSJSONSerialization.JSONObjectWithData(validData, options: [])
            } catch let error as NSError {
                jsonError = error
                jsonData = nil
            } catch {
                fatalError()
            }
            if jsonData == nil || jsonError != nil {
                let failureReason = "No data returned"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let json = JSON(jsonData!)
            
            let wrapper:ProductWrapper = ProductWrapper()
            let product = Product(json: json, id: 0)
            wrapper.Products = [product]
            return .Success(wrapper)
            
        }
    }
    class func SingleBoxResponseSerializer() -> ResponseSerializer<BoxesWrapper, NSError> {
        return ResponseSerializer {request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            var jsonData: AnyObject?
            var jsonError: NSError?
            do {
                jsonData = try NSJSONSerialization.JSONObjectWithData(validData, options: [])
            } catch let error as NSError {
                jsonError = error
                jsonData = nil
            } catch {
                fatalError()
            }
            if jsonData == nil || jsonError != nil {
                let failureReason = "No data returned"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let json = JSON(jsonData!)
            
            let wrapper:BoxesWrapper = BoxesWrapper()
            let box = Boxes(json: json, id: 0)
            wrapper.Box = [box]
            return .Success(wrapper)
            
        }
    }
    class func FavoriteArrayResponseSerializer() -> ResponseSerializer<FavoriteWrapper, NSError> {
        return ResponseSerializer {request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            var jsonData: AnyObject?
            var jsonError: NSError?
            do {
                jsonData = try NSJSONSerialization.JSONObjectWithData(validData, options: [])
            } catch let error as NSError {
                jsonError = error
                jsonData = nil
            } catch {
                fatalError()
            }
            if jsonData == nil || jsonError != nil {
                let failureReason = "No data returned"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let json = JSON(jsonData!)
            
            
            let wrapper:FavoriteWrapper = FavoriteWrapper()
            wrapper.count = json["total"].intValue
            wrapper.currentPage = json["current_page"].intValue
            if let nextPage = wrapper.currentPage!++ as Int? {
                wrapper.nextPage = nextPage
            }
            wrapper.lastPage = json["last_page"].intValue
            wrapper.next = json["next_page_url"].stringValue
            
            var allFavorites:Array = Array<Favorite>()
            let results = json["data"]
            for jsonFavorites in results {
                let favorite = Favorite(json: jsonFavorites.1, id: Int(jsonFavorites.0))
                allFavorites.append(favorite)
            }
            wrapper.Products = allFavorites
            return .Success(wrapper)
            
        }
    }
    class func WishArrayResponseSerializer() -> ResponseSerializer<WishWrapper, NSError> {
        return ResponseSerializer {request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            var jsonData: AnyObject?
            var jsonError: NSError?
            do {
                jsonData = try NSJSONSerialization.JSONObjectWithData(validData, options: [])
            } catch let error as NSError {
                jsonError = error
                jsonData = nil
            } catch {
                fatalError()
            }
            if jsonData == nil || jsonError != nil {
                let failureReason = "No data returned"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let json = JSON(jsonData!)
            
            
            let wrapper:WishWrapper = WishWrapper()
            wrapper.count = json["total"].intValue
            wrapper.currentPage = json["current_page"].intValue
            if let nextPage = wrapper.currentPage!++ as Int? {
                wrapper.nextPage = nextPage
            }
            wrapper.lastPage = json["last_page"].intValue
            wrapper.next = json["next_page_url"].stringValue
            
            var allWish:Array = Array<Wish>()
            let results = json["data"]
            for jsonWish in results {
                let wish = Wish(json: jsonWish.1, id: Int(jsonWish.0))
                allWish.append(wish)
            }
            wrapper.Products = allWish
            return .Success(wrapper)
            
        }
    }
    class func UserDataResponseSerializer() -> ResponseSerializer<UserDataWrapper, NSError> {
        return ResponseSerializer {request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            if response?.statusCode != 200 {
                let failureReason = "access denied"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            guard let validData = data else {
                let failureReason = "Data could not be serialized."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            var jsonData: AnyObject?
            var jsonError: NSError?
            do {
                jsonData = try NSJSONSerialization.JSONObjectWithData(validData, options: [])
            } catch let error as NSError {
                jsonError = error
                jsonData = nil
            } catch {
                fatalError()
            }
            if jsonData == nil || jsonError != nil {
                let failureReason = "No data returned"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let json = JSON(jsonData!)
            
            var allUsers:Array = Array<User>()
            let wrapper:UserDataWrapper = UserDataWrapper()
            let user = User(json: json)
            allUsers.append(user)
            wrapper.UserData = allUsers
            return .Success(wrapper)
            
        }
    }
    class func BrandArrayResponseSerializer() -> ResponseSerializer<BrandWrapper, NSError> {
        return ResponseSerializer {request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            var jsonData: AnyObject?
            var jsonError: NSError?
            do {
                jsonData = try NSJSONSerialization.JSONObjectWithData(validData, options: [])
            } catch let error as NSError {
                jsonError = error
                jsonData = nil
            } catch {
                fatalError()
            }
            if jsonData == nil || jsonError != nil {
                let failureReason = "No data returned"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let json = JSON(jsonData!)
            
            
            let wrapper:BrandWrapper = BrandWrapper()
            wrapper.count = json["total"].intValue
            wrapper.currentPage = json["current_page"].intValue
            if let nextPage = wrapper.currentPage!++ as Int? {
                wrapper.nextPage = nextPage
            }
            wrapper.lastPage = json["last_page"].intValue
            wrapper.next = json["next_page_url"].stringValue
            
            var allBrands:Array = Array<Brand>()
            let results = json["data"]
            for jsonBrands in results {
                let brand = Brand(json: jsonBrands.1, id: Int(jsonBrands.0))
                allBrands.append(brand)
            }
            wrapper.Brands = allBrands
            return .Success(wrapper)
            
        }
    }
    class func SearchResponseSerializer() -> ResponseSerializer<SearchResult, NSError> {
        return ResponseSerializer {request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            var jsonData: AnyObject?
            var jsonError: NSError?
            do {
                jsonData = try NSJSONSerialization.JSONObjectWithData(validData, options: [])
            } catch let error as NSError {
                jsonError = error
                jsonData = nil
            } catch {
                fatalError()
            }
            if jsonData == nil || jsonError != nil {
                let failureReason = "No data returned"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let json = JSON(jsonData!)
            
            
            let wrapper: SearchResult = SearchResult(json: json)
            
            let productJSON = json["products"]
            let brandJSON = json["brands"]
            let userJSON = json["users"]
            
            let bWrapper:BrandWrapper = BrandWrapper()
            let pWrapper:ProductWrapper = ProductWrapper()
            let uWrapper:UserDataWrapper = UserDataWrapper()
            
            pWrapper.count = productJSON["total"].intValue
            pWrapper.currentPage = productJSON["current_page"].intValue
            if let nextPage = pWrapper.currentPage!++ as Int? {
                pWrapper.nextPage = nextPage
            }
            pWrapper.lastPage = productJSON["last_page"].intValue
            pWrapper.next = productJSON["next_page_url"].stringValue
            
            
            var allProducts:Array = Array<Product>()
            let productResults = productJSON["data"]
            for jsonProducts in productResults {
                let product = Product(json: jsonProducts.1, id: Int(jsonProducts.0))
                allProducts.append(product)
            }
            
            bWrapper.count = brandJSON["total"].intValue
            bWrapper.currentPage = brandJSON["current_page"].intValue
            if let nextPage = bWrapper.currentPage!++ as Int? {
                bWrapper.nextPage = nextPage
            }
            bWrapper.lastPage = brandJSON["last_page"].intValue
            bWrapper.next = brandJSON["next_page_url"].stringValue
            
            var allBrands:Array = Array<Brand>()
            let brandResults = brandJSON["data"]
            for jsonBrands in brandResults {
                let brand = Brand(json: jsonBrands.1, id: Int(jsonBrands.0))
                allBrands.append(brand)
            }
            
            uWrapper.count = userJSON["total"].intValue
            uWrapper.currentPage = userJSON["current_page"].intValue
            if let nextPage = uWrapper.currentPage!++ as Int? {
                uWrapper.nextPage = nextPage
            }
            uWrapper.lastPage = userJSON["last_page"].intValue
            uWrapper.next = userJSON["next_page_url"].stringValue
            
            var allUsers:Array = Array<User>()
            let userResults = userJSON["data"]
            for jsonUsers in userResults {
                let user = User(json: jsonUsers.1)
                allUsers.append(user)
            }
            print(allUsers.first?.userName)
            print(allProducts)
            print(allBrands)
            wrapper.Users.UserData = allUsers
            wrapper.Products.Products = allProducts
            wrapper.Brands.Brands = allBrands
            return .Success(wrapper)
            
        }
    }
    
    class func BoxesArrayResponseSerializer() -> ResponseSerializer<BoxesWrapper, NSError> {
        return ResponseSerializer {request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            var jsonData: AnyObject?
            var jsonError: NSError?
            do {
                jsonData = try NSJSONSerialization.JSONObjectWithData(validData, options: [])
            } catch let error as NSError {
                jsonError = error
                jsonData = nil
            } catch {
                fatalError()
            }
            if jsonData == nil || jsonError != nil {
                let failureReason = "No data returned"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let json = JSON(jsonData!)
            
            let wrapper:BoxesWrapper = BoxesWrapper()
            wrapper.count = json["total"].intValue
            wrapper.currentPage = json["current_page"].intValue
            if let nextPage = wrapper.currentPage!++ as Int? {
                wrapper.nextPage = nextPage
            }
            wrapper.lastPage = json["last_page"].intValue
            wrapper.next = json["next_page_url"].stringValue
            
            var allBoxes:Array = Array<Boxes>()
            let results = json["data"]
            for jsonBoxes in results {
                let box = Boxes(json: jsonBoxes.1, id: Int(jsonBoxes.0))
                allBoxes.append(box)
            }
            wrapper.Box = allBoxes
            return .Success(wrapper)
            
        }
    }
    
    class func TagsArrayResponseSerializer() -> ResponseSerializer<TagWrapper, NSError> {
        return ResponseSerializer {request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            var jsonData: AnyObject?
            var jsonError: NSError?
            do {
                jsonData = try NSJSONSerialization.JSONObjectWithData(validData, options: [])
            } catch let error as NSError {
                jsonError = error
                jsonData = nil
            } catch {
                fatalError()
            }
            if jsonData == nil || jsonError != nil {
                let failureReason = "No data returned"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let json = JSON(jsonData!)
            
            let wrapper:TagWrapper = TagWrapper()
            wrapper.count = json["total"].intValue
            wrapper.currentPage = json["current_page"].intValue
            if let nextPage = wrapper.currentPage!++ as Int? {
                wrapper.nextPage = nextPage
            }
            wrapper.lastPage = json["last_page"].intValue
            wrapper.next = json["next_page_url"].stringValue
            
            var allTags:Array = Array<Tag>()
            let results = json["data"]
            for jsonTags in results {
                let tag = Tag(json: jsonTags.1, id: Int(jsonTags.0))
                allTags.append(tag)
            }
            wrapper.Tags = allTags
            return .Success(wrapper)
            
        }
    }
    
    func responseAuthorization(completionHandler: Response<Authorization, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.authResponseSerializer(), completionHandler: completionHandler)
    }
    
    func responseActivityArray(completionHandler: Response<ActivityWrapper, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.ActivityArrayResponseSerializer(), completionHandler: completionHandler)
    }
    func responseProductArray(completionHandler: Response<ProductWrapper, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.ProductArrayResponseSerializer(), completionHandler: completionHandler)
    }
    func responseSingleProduct(completionHandler: Response<ProductWrapper, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.SingleProductResponseSerializer(), completionHandler: completionHandler)
    }
    func responseSingleBox(completionHandler: Response<BoxesWrapper, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.SingleBoxResponseSerializer(), completionHandler: completionHandler)
    }
    func responseFavoriteArray(completionHandler: Response<FavoriteWrapper, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.FavoriteArrayResponseSerializer(), completionHandler: completionHandler)
    }
    func responseWishArray(completionHandler: Response<WishWrapper, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.WishArrayResponseSerializer(), completionHandler: completionHandler)
    }
    func responseUserData(completionHandler: Response<UserDataWrapper, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.UserDataResponseSerializer(), completionHandler: completionHandler)
    }
    func responseBrandArray(completionHandler: Response<BrandWrapper, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.BrandArrayResponseSerializer(), completionHandler: completionHandler)
    }
    func responseSearchResults(completionHandler: Response<SearchResult, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.SearchResponseSerializer(), completionHandler: completionHandler)
    }
    func responseBoxesArray(completionHandler: Response<BoxesWrapper, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.BoxesArrayResponseSerializer(), completionHandler: completionHandler)
    }
    func responseTagsArray(completionHandler: Response<TagWrapper, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.TagsArrayResponseSerializer(), completionHandler: completionHandler)
    }
}
