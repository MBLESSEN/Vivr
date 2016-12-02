//
//  myReviewsCell.swift
//  vivr v4
//
//  Created by max blessen on 2/21/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire
import Haneke

class myReviewsCell: UITableViewCell {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productReview: UILabel!
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var throat: UILabel!
    @IBOutlet weak var vapor: UILabel!
    @IBOutlet weak var likebutton: VIVRHelpfulButton?
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var helpfullLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!

    
    var cellID:Int? 
    var reviewID:String?
    var productID:String?
    var cellDelegate: reviewCellDelegate? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var state:Bool? {
        didSet{
            self.likebutton?.currentHelpful = state!
        }
    }

    @IBAction func toButton(sender: AnyObject) {
        cellDelegate?.tappedProductbutton!(self)
        
    }
    
    @IBAction func toComments(sender: AnyObject) {
        cellDelegate?.tappedCommentButton!(self)
    }
    @IBAction func likePressed(sender: AnyObject) {
        switch state! {
            case true:
                state = false
                Alamofire.request(Router.notHelpful(productID!, reviewID!))
                cellDelegate?.helpfulFalse!(self)
            case false:
                state = true
                Alamofire.request(Router.isHelpful(productID!, reviewID!))
                cellDelegate?.helpfulTrue!(self)
        }
        self.cellDelegate?.reloadAPI!(self)
    }
    
    
    var review:ActivityFeedReviews? {
        didSet {
            //self.loadReview()
        }
    }
    @IBAction func morePressed(sender: AnyObject) {
        cellDelegate?.tappedMoreButton!(self)
    }
    
    func loadReview() {/*
        self.productID = self.review?["product"]["id"].stringValue
        self.reviewID = self.review?["id"].stringValue
        self.productName.text = self.review?["product"]["name"].string
        self.productReview.text = self.review?["description"].string
        if let urlString = self.review?["product"]["image"] {
            let url = NSURL(string: urlString.stringValue)
            //self.productImage.hnk_setImageFromURL(url!)
        }
        if let rating = self.review?["score"].stringValue{
            var number = (rating as NSString).floatValue
            println("rating is \(rating) score is \(number)")
            
        }
        self.brandName.text = self.review?["product"]["brand"]["name"].string
        if let throatHit = self.review?["throat"].int {
            var value:String?
            switch throatHit {
            case 0:
                value = "Light"
            case 1:
                value = "Mild"
            case 2:
                value = "Harsh"
            default:
                value = "invalid"
            }
            self.throat.text = ("\(value!) throat hit")
        }
        if let vaporProduction = self.review?["vapor"].int {
            var value:String?
            switch vaporProduction {
            case 0:
                value = "Low"
            case 1:
                value = "Average"
            case 2:
                value = "Cloudy"
            default:
                value = "invalid"
            }
            self.vapor.text = ("\(value!) vapor production")
        }
        if let helpfullCount = self.review?["helpful_count"].stringValue {
            switch helpfullCount {
            case "0":
                self.helpfullLabel.text = "Was this helpful?"
            default:
                self.helpfullLabel.text = "\(helpfullCount) people found this helpful"
            }
        }
    */
        
    }



}
