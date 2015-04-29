//
//  myReviewsCell.swift
//  vivr v4
//
//  Created by max blessen on 2/21/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Haneke

protocol reviewCellDelegate {
    func tappedProductbutton(cell: myReviewsCell)
}

class myReviewsCell: UITableViewCell {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productReview: UILabel!
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var throat: UILabel!
    @IBOutlet weak var vapor: UILabel!
    @IBOutlet weak var likebutton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var helpfullLabel: UILabel!
    
    var productID:String?
    var likeImage = UIImage(named: "likeFilled")?.imageWithRenderingMode(.AlwaysTemplate)
    var cellDelegate: reviewCellDelegate? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        self.floatRatingView.fullImage = UIImage(named: "StarFull")
        likebutton.layer.borderWidth = 1
        likebutton.layer.cornerRadius = 4
        //likebutton.tintColor = UIColor.lightGrayColor()
        likebutton.setImage(likeImage, forState: .Normal)
        likebutton.imageEdgeInsets = UIEdgeInsetsMake(5, 7.5, 5, 47.5)
        
    }
    
    var state:String? {
        didSet{
            buttonState()
        }
    }

    @IBAction func toButton(sender: AnyObject) {
        cellDelegate?.tappedProductbutton(self)
        
    }
    
    @IBAction func likePressed(sender: AnyObject) {
        switch state! {
            case "isLiked":
                state = "notLiked"
            case "notLiked":
                state = "isLiked"
        default:
            println("error")
        }
        self.buttonState()
    }
    
    func buttonState() {
        switch state! {
        case "isLiked":
            likebutton.titleEdgeInsets = UIEdgeInsetsMake(5, -2.5, 5, 0)
            likebutton.layer.borderColor = (UIColor.purpleColor()).CGColor
            likebutton.tintColor = UIColor.whiteColor()
            likebutton.backgroundColor = UIColor.purpleColor()
            likebutton.setTitle("Helpful", forState: .Normal)
        case "notLiked":
            likebutton.titleEdgeInsets = UIEdgeInsetsMake(5, -2.5, 5, 0)
            likebutton.layer.borderColor = (UIColor.lightGrayColor()).CGColor
            likebutton.tintColor = UIColor.lightGrayColor()
            likebutton.backgroundColor = UIColor.whiteColor()
            likebutton.setTitle("Helpful", forState: .Normal)
        default:
            println("error")
            
        }
    }
    
    
    var review:JSON? {
        didSet {
            self.loadReview()
        }
    }
    
    func loadReview() {
        self.productID = self.review?["product"]["id"].stringValue
        self.productName.text = self.review?["product"]["name"].string
        self.productReview.text = self.review?["description"].string
        if let urlString = self.review?["product"]["image"] {
            let url = NSURL(string: urlString.stringValue)
            //self.productImage.hnk_setImageFromURL(url!)
        }
        if let rating = self.review?["score"].stringValue{
            var number = (rating as NSString).floatValue
            println("rating is \(rating) score is \(number)")
            self.floatRatingView.rating = number
            self.floatRatingView.userInteractionEnabled = false
        }
        self.brandName.text = self.review?["product"]["brand"]["name"].string
        if let throatHit = self.review?["throat"].int {
            var value:String?
            switch throatHit {
            case 1:
                value = "Feather"
            case 2:
                value = "Light"
            case 3:
                value = "Mild"
            case 4:
                value = "Harsh"
            case 5:
                value = "Very Harsh"
            default:
                value = "invalid"
            }
            self.throat.text = ("\(value!) throat hit")
        }
        if let vaporProduction = self.review?["vapor"].int {
            var value:String?
            switch vaporProduction {
            case 1:
                value = "Very low"
            case 2:
                value = "Low"
            case 3:
                value = "Average"
            case 4:
                value = "High"
            case 5:
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

        
    }



}
