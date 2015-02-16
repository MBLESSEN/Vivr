
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
    static let baseURLString = "http://mickeyschwab.com/vivr/public"
    
    case ReadBrands()
    case ReadBrandProducts(String)
    case AddReview(String, [String: AnyObject])
    case ReadReviews(String)
    case ReadProductData(String)
    case Favorite(String)
    case readFeed()

    
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
        case .Favorite:
            return .POST
        case .readFeed:
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
        case .ReadReviews(let id):
            return "/products/\(id)/reviews"
        case .Favorite(let id):
            return "/products/\(id)/favorite"
        case .readFeed:
            return "/activity"
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSURLRequest {
        let URL = NSURL(string: Router.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let token = KeychainService.loadToken() {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        switch self {
        case .AddReview(_, let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        default:
            return mutableURLRequest
        }
    }
}
