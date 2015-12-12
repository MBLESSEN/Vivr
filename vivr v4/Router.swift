
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
    static let baseURLString = "https://api.vivr.com"
    
    case PostComment(String, String, [String: AnyObject])
    case ReadBrands(Int)
    case ReadBrandProducts(String)
    case readAllProducts(Int)
    case readAllFilteredProducts(String, Int)
    case AddReview(String, [String: AnyObject])
    case ReadReviews(String, Int)
    case ReadProductData(String)
    case ReadProductTags(String)
    case Favorite(String)
    case unFavorite(String)
    case readFeed(Int)
    case readFeedFiltered(String, Int)
    case readCurrentUser()
    case readUser(Int)
    case readUserReviews(Int, Int)
    case readUserFavorites(Int, Int)
    case readUserComments(String)
    case readComments(String, String)
    case readCommentsAPI(String, String)
    case readWishlist(Int, Int)
    case addToWish(String)
    case removeWish(String)
    case isHelpful(String, String)
    case notHelpful(String, String)
    case loadAllTags(Int)
    case editProfile([String: AnyObject])
    case search(String, Int)
    case registerNewUser([String: AnyObject])
    case requestAccessToken([String: AnyObject])
    case submitFeedback([String: AnyObject])
    case uploadProfile()
    case readAllBoxes(Int)
    case readBox(Int)
    case readBoxProducts(Int)
    case createBox([String:AnyObject])
    case addProductToBox(Int, [String:AnyObject])
    case removeProductFromBox(Int, [String:AnyObject])
    case readUserBoxes(Int, Int)
    case findSpecificBrands(String, Int)
    case findSpecificProduct(String, Int)
    case editBox(Int, [String:AnyObject])
    case readBlog(Int)
    case postProduct([String:AnyObject])
    case createNewBrand([String:AnyObject])

    
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
        case .readAllFilteredProducts:
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
        case .readFeedFiltered:
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
        case .search:
            return .GET
        case .registerNewUser:
            return .POST
        case .requestAccessToken:
            return .POST
        case .submitFeedback:
            return .POST
        case .uploadProfile:
            return .POST
        case .readAllBoxes:
            return .GET
        case .readBox:
            return .GET
        case .readBoxProducts:
            return .GET
        case .createBox:
            return .POST
        case .addProductToBox:
            return .POST
        case .removeProductFromBox:
            return .DELETE
        case .readUserBoxes:
            return .GET
        case .findSpecificBrands:
            return .GET
        case .findSpecificProduct:
            return .GET
        case .editBox:
            return .PUT
        case .readBlog:
            return .GET
        case .postProduct:
            return .POST
        case .createNewBrand:
            return .POST
        }
    }
    
    var path: String {
        switch self {
        case .AddReview(let id, _):
            return "/products/\(id)/reviews"
        case .PostComment(let pid, let rid, _):
            return "/products/\(pid)/reviews/\(rid)/comments"
        case .ReadBrands(let pageid):
            return "/brands?page=\(pageid)"
        case .ReadBrandProducts(let id):
            return "/brands/\(id)/products"
        case .readAllProducts(let id):
            return "/products?page=\(id)"
        case .readAllFilteredProducts(let tags, let pageid):
            return "/products?tags=\(tags)&page=\(pageid)"
        case .ReadProductData(let id):
            return "/products/\(id)"
        case .ReadProductTags(let id):
            return "/products/\(id)/tags"
        case .ReadReviews(let id, let pageid):
            return "/products/\(id)/reviews?page=\(pageid)"
        case .Favorite(let id):
            return "/products/\(id)/favorites"
        case .unFavorite(let id):
            return "/products/\(id)/favorites"
        case .readFeed(let id):
            return "/activity?page=\(id)"
        case .readFeedFiltered(let id1, let pageid):
            return "/activity?tags=\(id1)&page=\(pageid)"
        case .readCurrentUser:
            return "/users/~"
        case .readUser(let id):
            return "/users/\(id)"
        case .readUserReviews(let id, let pageid):
            return "/users/\(id)/reviews?page=\(pageid)"
        case .readUserFavorites(let id, let pageid):
            return "/users/\(id)/favorites?page=\(pageid)"
        case .readUserComments(let id):
            return "/users/\(id)/comments"
        case .readComments(let pid, let rid):
            return "/products/\(pid)/reviews/\(rid)/comments"
        case .readCommentsAPI(let pid , let rid):
            return "/products/\(pid)/reviews/\(rid)/comments"
        case .readWishlist(let id, let pageid):
            return "/users/\(id)/wishlist?page=\(pageid)"
        case .addToWish(let id):
            return "/products/\(id)/wishlist"
        case .removeWish(let id):
            return "/products/\(id)/wishlist"
        case .isHelpful(let pid, let rid):
            return "/products/\(pid)/reviews/\(rid)/helpful"
        case .notHelpful(let pid, let rid):
            return "/products/\(pid)/reviews/\(rid)/helpful"
        case .loadAllTags(let pID):
            return "/tags?page=\(pID)"
        case .editProfile(_):
            return "/profile"
        case .search(let id, let pageID):
            return "/search?name=\(id)&page=\(pageID)"
        case .registerNewUser(_):
            return "/auth/register"
        case .requestAccessToken(_):
            return "/oauth/access-token"
        case .submitFeedback(_):
            return "/feedback"
        case .uploadProfile():
            return "/profile/picture"
        case .readAllBoxes(let pageID):
            return "/boxes?page=\(pageID)"
        case .readBox(let boxID):
            return "/boxes/\(boxID)"
        case .readBoxProducts(let boxID):
            return "/boxes/\(boxID)/products"
        case .createBox(_):
            return "/boxes"
        case .addProductToBox(let bid, _):
            return "/boxes/\(bid)/products"
        case .removeProductFromBox(let bid, _):
            return "/boxes/\(bid)"
        case .readUserBoxes(let uid, let pid):
            return "/users/\(uid)/boxes?page=\(pid)"
        case .findSpecificBrands(let id, let pageID):
            return "/brands?name=\(id)&page=\(pageID)"
        case .findSpecificProduct(let id, let pageID):
            return "/products?name=\(id)&page=\(pageID)"
        case .editBox(let boxID, _):
            return "/boxes/\(boxID)"
        case .readBlog(let pID):
            return "/featured?page=\(pID)"
        case .postProduct(_):
            return "/products"
        case .createNewBrand(_):
            return "/brands"
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: Router.baseURLString + path)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let token = KeychainWrapper.stringForKey("authToken") {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        switch self {
        case .AddReview(_, let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .editProfile(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .PostComment(_, _, let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .registerNewUser(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .requestAccessToken(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .submitFeedback(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .createBox(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .addProductToBox(_, let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .removeProductFromBox(_, let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .editBox(_, let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .postProduct(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .createNewBrand(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        default:
            return mutableURLRequest
        }
    }
}
