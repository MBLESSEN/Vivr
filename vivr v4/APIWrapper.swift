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
    
    class func FeaturedArrayResponseSerializer() -> ResponseSerializer<FeaturedPostWrapper, NSError> {
        return ResponseSerializer {request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "data could not be serialized."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            var jsonData:AnyObject?
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
            
            let wrapper:FeaturedPostWrapper = FeaturedPostWrapper()
            wrapper.count = json["total"].intValue
            wrapper.currentPage = json["current_page"].intValue
            if let nextPage = wrapper.currentPage!++ as Int? {
                wrapper.nextPage = nextPage
            }
            wrapper.lastPage = json["last_page"].intValue
            wrapper.next = json["next_page_url"].stringValue
            
            var allFeatured:Array = Array<FeaturedPost>()
            let results = json["data"]
            for jsonFeatured in results {
                let post = FeaturedPost(json: jsonFeatured.1, id: Int(jsonFeatured.0))
                allFeatured.append(post)
            }
            wrapper.featuredPosts = allFeatured
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
    func responseFeaturedArray(completionHandler: Response<FeaturedPostWrapper, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.FeaturedArrayResponseSerializer(), completionHandler: completionHandler)
    }
}
