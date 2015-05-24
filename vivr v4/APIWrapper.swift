//
//  APIWrapper.swift
//  vivr v4
//
//  Created by max blessen on 5/21/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//
import Foundation
import Alamofire

class ActivityWrapper {
    var ActivityReviews: Array<ActivityFeedReviews>?
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
    var helpfulCount: Int?
    var currentHelpful: Bool?
    var product: Product?
    var user: User?
    var brand: Brand?
    
    required init(json: JSON, id: Int?) {
        println(json)
        self.ID = id
        self.reviewID = json[ActivityFeedReviewsFields.ID.rawValue].stringValue
        self.userID = json[ActivityFeedReviewsFields.userID.rawValue].stringValue
        self.productID = json[ActivityFeedReviewsFields.productID.rawValue].stringValue
        self.description = json[ActivityFeedReviewsFields.description.rawValue].stringValue
        self.throat = json[ActivityFeedReviewsFields.throat.rawValue].intValue
        self.vapor = json[ActivityFeedReviewsFields.vapor.rawValue].intValue
        self.score = json[ActivityFeedReviewsFields.score.rawValue].stringValue
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
            self.brand = Brand(json: brandData)
        }
    }
    
    class func endpointForActivity() -> URLRequestConvertible {
        return Router.readFeed(1)
    }
    class func endpointForUserReviews(id: String) -> URLRequestConvertible {
        return Router.readUserReviews(id, 1)
    }
    
    private class func getActivity(path: URLRequestConvertible, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseActivityArray { (request, response, activityWrapper, error) in
            if let anError = error
            {
                completionHandler(nil, error)
                return
            }
            completionHandler(activityWrapper, nil)
    }

    }
    class func getReviews(completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        getActivity(ActivityFeedReviews.endpointForActivity(), completionHandler: completionHandler)
    }
    
    class func getMoreReviews(wrapper: ActivityWrapper?, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil || wrapper?.currentPage == wrapper?.lastPage {
            completionHandler(nil, nil)
            return
        }
        getActivity(Router.readFeed(wrapper!.nextPage!), completionHandler: completionHandler)
    }
    private class func getUserReviewAtPath(userID: String, path: URLRequestConvertible, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseActivityArray { (request, response, activityWrapper, error) in
            if let anError = error
            {
                completionHandler(nil, error)
                return
            }
            completionHandler(activityWrapper, nil)
        }
        
    }
    class func getUserReviews(id: String, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        getActivity(ActivityFeedReviews.endpointForUserReviews(id), completionHandler: completionHandler)
    }
    
    class func getMoreUserReviews(id: String, wrapper: ActivityWrapper?, completionHandler: (ActivityWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil || wrapper?.currentPage == wrapper?.lastPage {
            completionHandler(nil, nil)
            return
        }
        getActivity(Router.readUserReviews(id, wrapper!.nextPage!), completionHandler: completionHandler)
    }

}


class Brand {
    var id: Int?
    var name: String?
    var description: String?
    var image:String?
    var logo: String?
    var productCount: Int?
    
    required init(json: JSON) {
        self.id = json[ActivityFeedReviewsFields.ID.rawValue].intValue
        self.name = json[ActivityFeedReviewsFields.name.rawValue].stringValue
        self.description = json[ActivityFeedReviewsFields.description.rawValue].stringValue
        self.image = json[ActivityFeedReviewsFields.image.rawValue].stringValue
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
            self.brand = Brand(json: brandData)
        }
    }
    
    class func endpointForUserFavorites(id: String) -> URLRequestConvertible {
        return Router.readUserFavorites(id, 1)
    }
    private class func getProductAtPath(userID: String, path: URLRequestConvertible, completionHandler: (FavoriteWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseFavoriteArray { (request, response, favoriteWrapper, error) in
            if let anError = error
            {
                completionHandler(nil, error)
                return
            }
            completionHandler(favoriteWrapper, nil)
        }
        
    }
    class func getProducts(userID: String, completionHandler: (FavoriteWrapper?, NSError?) -> Void) {
        getProductAtPath(userID, path: Favorite.endpointForUserFavorites(userID), completionHandler: completionHandler)
    }
    
    class func getMoreProducts(userID: String, wrapper: FavoriteWrapper?, completionHandler: (FavoriteWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil || wrapper?.currentPage == wrapper?.lastPage {
            completionHandler(nil, nil)
            return
        }
        getProductAtPath(userID, path: Router.readUserFavorites(userID, wrapper!.nextPage!), completionHandler: completionHandler)
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
    
    required init(json: JSON, id: Int?) {
        self.ID = id
        self.productID = json[ActivityFeedReviewsFields.ID.rawValue].intValue
        self.brandID = json[ActivityFeedReviewsFields.brandID.rawValue].intValue
        self.name = json[ActivityFeedReviewsFields.name.rawValue].stringValue
        self.image = json[ActivityFeedReviewsFields.image.rawValue].stringValue
        self.description = json[ActivityFeedReviewsFields.description.rawValue].stringValue
        self.currentFavorite = json[ActivityFeedReviewsFields.currentFavorite.rawValue].boolValue
        self.currentWishlist = json[ActivityFeedReviewsFields.currentWishlist.rawValue].boolValue
        if let brandData = JSON(json[ActivityFeedReviewsFields.brand.rawValue].stringValue) as JSON? {
            self.brand = Brand(json: brandData)
        }
        if let scoreData = JSON(json[ActivityFeedReviewsFields.scores.rawValue].rawValue) as JSON? {
            self.scores = Score(json: scoreData)
        }
    }
    class func endpointForActivity() -> URLRequestConvertible {
        return Router.readAllProducts(1)
    }
    
    private class func getProductAtPath(path: URLRequestConvertible, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        Alamofire.request(path).responseProductArray { (request, response, productWrapper, error) in
            if let anError = error
            {
                completionHandler(nil, error)
                return
            }
            completionHandler(productWrapper, nil)
        }
        
    }
    class func getProducts(completionHandler: (ProductWrapper?, NSError?) -> Void) {
        getProductAtPath(Product.endpointForActivity(), completionHandler: completionHandler)
    }
    
    class func getMoreProducts(wrapper: ProductWrapper?, completionHandler: (ProductWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil || wrapper?.currentPage == wrapper?.lastPage {
            completionHandler(nil, nil)
            return
        }
        getProductAtPath(Router.readAllProducts(wrapper!.nextPage!), completionHandler: completionHandler)
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
    
    required init(json: JSON) {
        self.ID = json[ActivityFeedReviewsFields.ID.rawValue].intValue
        self.userName = json[ActivityFeedReviewsFields.userName.rawValue].stringValue
    }
}

extension Alamofire.Request {
    class func ActivityArrayResponseSerializer() -> Serializer {
        return {request, response, data in
            if data == nil {
                return (nil, nil)
            }
            var jsonError: NSError?
            let jsonData:AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &jsonError)
            if jsonData == nil || jsonError != nil {
                return(nil, jsonError)
            }
            let json = JSON(jsonData!)
            if json.error != nil || json == nil {
                return (nil, json.error)
            }
            
            var wrapper:ActivityWrapper = ActivityWrapper()
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
                let review = ActivityFeedReviews(json: jsonReviews.1, id: jsonReviews.0.toInt())
                allReviews.append(review)
            }
            wrapper.ActivityReviews = allReviews
            return (wrapper, nil)
            
        }
    }
    class func ProductArrayResponseSerializer() -> Serializer {
        return {request, response, data in
            if data == nil {
                return (nil, nil)
            }
            var jsonError: NSError?
            let jsonData:AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &jsonError)
            if jsonData == nil || jsonError != nil {
                return(nil, jsonError)
            }
            let json = JSON(jsonData!)
            if json.error != nil || json == nil {
                return (nil, json.error)
            }
            
            var wrapper:ProductWrapper = ProductWrapper()
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
                let product = Product(json: jsonProducts.1, id: jsonProducts.0.toInt())
                allProducts.append(product)
            }
            wrapper.Products = allProducts
            return (wrapper, nil)
            
        }
    }
    class func FavoriteArrayResponseSerializer() -> Serializer {
        return {request, response, data in
            if data == nil {
                return (nil, nil)
            }
            var jsonError: NSError?
            let jsonData:AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &jsonError)
            if jsonData == nil || jsonError != nil {
                return(nil, jsonError)
            }
            let json = JSON(jsonData!)
            if json.error != nil || json == nil {
                return (nil, json.error)
            }
            
            var wrapper:FavoriteWrapper = FavoriteWrapper()
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
                let favorite = Favorite(json: jsonFavorites.1, id: jsonFavorites.0.toInt())
                allFavorites.append(favorite)
            }
            wrapper.Products = allFavorites
            return (wrapper, nil)
            
        }
    }
    func responseActivityArray(completionHandler: (NSURLRequest, NSHTTPURLResponse?, ActivityWrapper?, NSError?) -> Void) -> Self {
        return response(serializer: Request.ActivityArrayResponseSerializer(), completionHandler: { (request, response, activityWrapper, error) in
            completionHandler(request, response, activityWrapper as? ActivityWrapper, error)
        })
    }
    func responseProductArray(completionHandler: (NSURLRequest, NSHTTPURLResponse?, ProductWrapper?, NSError?) -> Void) -> Self {
        return response(serializer: Request.ProductArrayResponseSerializer(), completionHandler: { (request, response, productWrapper, error) in
            completionHandler(request, response, productWrapper as? ProductWrapper, error)
        })
    }
    func responseFavoriteArray(completionHandler: (NSURLRequest, NSHTTPURLResponse?, FavoriteWrapper?, NSError?) -> Void) -> Self {
        return response(serializer: Request.FavoriteArrayResponseSerializer(), completionHandler: { (request, response, favoriteWrapper, error) in
            completionHandler(request, response, favoriteWrapper as? FavoriteWrapper, error)
        })
    }
}
