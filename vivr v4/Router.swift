
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
    
    case ReadBrands()
    case ReadBrandProducts(String)
    case AddReview(String, [String: AnyObject])
    case ReadReviews(String)
    case ReadProductData(String)
    case ReadProductTags(String)
    case Favorite(String)
    case unFavorite(String)
    case readFeed()
    case readCurrentUser()
    case readUser(String)
    case readUserReviews(String)
    case readUserFavorites(String)
    case readUserComments(String)
    case readComments(String, String)

    
    var method: Alamofire.Method {
        switch self {
        case .AddReview:
            return .POST
        case .ReadBrands:
            return .GET
        case .ReadBrandProducts:
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
        
        }
    }
    
    var path: String {
        switch self {
        case .AddReview(let id, _):
            return "/products/\(id)/reviews"
        case .ReadBrands:
            return "/brands"
        case .ReadBrandProducts(let id):
            return "/brands/\(id)/products"
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
        case .readFeed:
            return "/activity"
        case .readCurrentUser:
            return "/profile"
        case .readUser(let id):
            return "/users/\(id)"
        case .readUserReviews(let id):
            return "/users/\(id)/reviews"
        case .readUserFavorites(let id):
            return "/users/\(id)/favorites"
        case .readUserComments(let id):
            return "/users/\(id)/comments"
        case .readComments(let pid, let rid):
            return "/products/\(pid)/reviews/\(rid)"
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
        default:
            return mutableURLRequest
        }
    }
}
