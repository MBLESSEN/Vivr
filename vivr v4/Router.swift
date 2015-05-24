
//
//  Router.swift
//  vivr v4
//
//  Created by max blessen on 2/8/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//
import UIKit
import Alamofire
import Foundation

enum Router: URLRequestConvertible {
    static let baseURLString = "http://mickeyschwab.com/vivr-dev/public"
    
    case PostComment(String, String, [String: AnyObject])
    case ReadBrands()
    case ReadBrandProducts(String)
    case readAllProducts(Int)
    case AddReview(String, [String: AnyObject])
    case ReadReviews(String)
    case ReadProductData(String)
    case ReadProductTags(String)
    case Favorite(String)
    case unFavorite(String)
    case readFeed(Int)
    case readFeedFiletered(String, String?, String?)
    case readCurrentUser()
    case readUser(String)
    case readUserReviews(String, Int)
    case readUserFavorites(String, Int)
    case readUserComments(String)
    case readComments(String, String)
    case readCommentsAPI(String, String)
    case readWishlist(String)
    case addToWish(String)
    case removeWish(String)
    case isHelpful(String, String)
    case notHelpful(String, String)
    case loadAllTags()
    case editProfile([String: AnyObject])

    
    var method: Alamofire.Method {
        switch self {
        case .AddReview:
            return .POST
        case .PostComment:
            return .POST
        case .ReadBrands:
            return .GET
        case .ReadBrandProducts:
            return .GET
        case .readAllProducts:
            return .GET
        case .ReadReviews:
            return .GET
        case .ReadProductData:
            return .GET
        case .ReadProductTags:
            return .GET
        case .Favorite:
            return .POST
        case .unFavorite:
            return .DELETE
        case .readFeed:
            return .GET
        case .readFeedFiletered:
            return .GET
        case .readCurrentUser:
            return .GET
        case .readUser:
            return .GET
        case .readUserReviews:
            return .GET
        case .readUserFavorites:
            return .GET
        case .readUserComments:
            return .GET
        case .readComments:
            return .GET
        case .readCommentsAPI:
            return .GET
        case .readWishlist:
            return .GET
        case .addToWish:
            return .POST
        case .removeWish:
            return .DELETE
        case .isHelpful:
            return .POST
        case .notHelpful:
            return .DELETE
        case .loadAllTags:
            return .GET
        case .editProfile:
            return .PUT
        
        }
    }
    
    var path: String {
        switch self {
        case .AddReview(let id, _):
            return "/products/\(id)/reviews"
        case .PostComment(let pid, let rid, _):
            return "/products/\(pid)/reviews/\(rid)/comments"
        case .ReadBrands:
            return "/brands"
        case .ReadBrandProducts(let id):
            return "/brands/\(id)/products"
        case .readAllProducts(let id):
            return "/products?page=\(id)"
        case .ReadProductData(let id):
            return "/products/\(id)"
        case .ReadProductTags(let id):
            return "/products/\(id)/tags"
        case .ReadReviews(let id):
            return "/products/\(id)/reviews"
        case .Favorite(let id):
            return "/products/\(id)/favorites"
        case .unFavorite(let id):
            return "/products/\(id)/favorites"
        case .readFeed(let id):
            return "/activity?page=\(id)"
        case .readFeedFiletered(let id1, let id2, let id3):
            return "/activity?tags=\(id1)"
        case .readCurrentUser:
            return "/profile"
        case .readUser(let id):
            return "/users/\(id)"
        case .readUserReviews(let id, let pageid):
            return "/users/\(id)/reviews?page=\(pageid)"
        case .readUserFavorites(let id, let pageid):
            return "/users/\(id)/favorites?page=\(pageid)"
        case .readUserComments(let id):
            return "/users/\(id)/comments"
        case .readComments(let pid, let rid):
            return "/products/\(pid)/reviews/\(rid)"
        case .readCommentsAPI(let pid , let rid):
            return "/products/\(pid)/reviews/\(rid)/comments"
        case .readWishlist(let id):
            return "/users/\(id)/wishlist"
        case .addToWish(let id):
            return "/products/\(id)/wishlist"
        case .removeWish(let id):
            return "/products/\(id)/wishlist"
        case .isHelpful(let pid, let rid):
            return "/products/\(pid)/reviews/\(rid)/helpful"
        case .notHelpful(let pid, let rid):
            return "/products/\(pid)/reviews/\(rid)/helpful"
        case .loadAllTags():
            return "/tags"
        case .editProfile(_):
            return "/profile"
            
            
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSURLRequest {
        let URL = NSURL(string: Router.baseURLString + path)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        //if let token = "NMYGPEEpWxShiL9rYCnxxDTQES3eQlTRTaZ0DhF5" {
            mutableURLRequest.setValue("Bearer NMYGPEEpWxShiL9rYCnxxDTQES3eQlTRTaZ0DhF5", forHTTPHeaderField: "Authorization")
        
        
        switch self {
        case .AddReview(_, let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .editProfile(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .PostComment(_, _, let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0 
        default:
            return mutableURLRequest
        }
    }
}
