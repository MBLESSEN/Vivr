
//
//  vivrCell.swift
//  vivr v4
//
//  Created by max blessen on 2/6/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//


import UIKit
import Haneke

protocol VivrCellDelegate {
    
    func tappedCommentButton(cell: vivrCell)
    func tappedProductButton(cell: vivrCell)
    
}

class vivrCell: UITableViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var BrandFlavorName: UILabel!
    @IBOutlet weak var reviewDescription: UILabel!
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var flavorName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var totalScore: UILabel!
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var throat: UILabel!
    @IBOutlet weak var vapor: UILabel!
    @IBOutlet weak var helpfull: UIButton?
    @IBOutlet weak var helpfullLabel: UILabel!
    
    var reviewID: String = ""
    var cellDelegate: VivrCellDelegate? = nil
    var productID: String = ""
    var likeImage = UIImage(named: "likeFilled")?.imageWithRenderingMode(.AlwaysTemplate)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        self.floatRatingView.fullImage = UIImage(named: "StarFull")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var helpfullState: String? {
        didSet {
            helpfull!.layer.borderWidth = 1
            helpfull!.layer.cornerRadius = 4
            helpfull!.setImage(likeImage, forState: .Normal)
            helpfull!.imageEdgeInsets = UIEdgeInsetsMake(5,7.5, 5, 47.5)
            buttonState()
            
        }
    }
    
    var review:JSON? {
        didSet {
            self.loadReviews()
        }
    }
    
    var reviewAndComment:JSON? {
        didSet {
            self.loadData()
        }
    }
    
    @IBAction func toComments(sender: AnyObject) {
            cellDelegate?.tappedCommentButton(self)
    }
    
    @IBAction func toProduct(sender: AnyObject) {
            cellDelegate?.tappedProductButton(self)
    }

    @IBAction func helpfullPressed(sender: AnyObject) {
        switch helpfullState! {
        case "isLiked":
            helpfullState = "notLiked"
        case "notLiked":
            helpfullState = "isLiked"
        default:
            println("error")
        }
        self.buttonState()
    }
    
    func buttonState(){
        switch helpfullState! {
        case "isLiked":
            helpfull!.titleEdgeInsets = UIEdgeInsetsMake(5, -2.5, 5, 0)
            helpfull!.layer.borderColor = (UIColor.purpleColor()).CGColor
            helpfull!.tintColor = UIColor.whiteColor()
            helpfull!.backgroundColor = UIColor.purpleColor()
            helpfull!.setTitle("Helpful", forState: .Normal)
        case "notLiked":
            helpfull!.titleEdgeInsets = UIEdgeInsetsMake(5, -2.5, 5, 0)
            helpfull!.layer.borderColor = (UIColor.lightGrayColor()).CGColor
            helpfull!.tintColor = UIColor.lightGrayColor()
            helpfull!.backgroundColor = UIColor.whiteColor()
            helpfull!.setTitle("Helpful", forState: .Normal)
        default:
            println("error")
            
        }
        
    }
    func loadReviews() {
        self.reviewID = self.review!["id"].stringValue
        self.productID = self.review!["product"]["id"].stringValue
        if let user = self.review?["user"]["username"].stringValue {
            self.userName.text = "\(user) said"
        }
        self.reviewDescription.text = self.review?["description"].string
        reviewDescription.sizeToFit()
        self.flavorName.text = self.review?["product"]["name"].stringValue
        flavorName.sizeToFit()
        /*
        if let urlString = self.review?["product"]["image"].stringValue {
            let url = NSURL(string: urlString)
            self.productImage.hnk_setImageFromURL(url!)
            
        }
        */
        if let rating = self.review?["score"].stringValue{
            var number = (rating as NSString).floatValue
            println("rating is \(rating) score is \(number)")
            self.floatRatingView.rating = number
            self.floatRatingView.userInteractionEnabled = false
        }
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
                self.helpfullLabel.text = "\(helpfullCount) found this helpful"
            }
        }
    

    }
    
    func loadData() {
        self.reviewID = self.reviewAndComment!["id"].stringValue
        self.productID = self.reviewAndComment!["product"]["id"].stringValue
        if let user = self.reviewAndComment?["user"]["username"].stringValue {
            self.userName.text = "\(user) said"
        }
        self.reviewDescription.text = self.reviewAndComment!["description"].string
        self.flavorName.text = self.reviewAndComment!["product"]["name"].string
        /*
        if let urlString = self.reviewAndComment?["product"]["image"].stringValue {
            let url = NSURL(string: urlString)
            self.productImage.hnk_setImageFromURL(url!)
            
        }
        */
        if let rating = self.reviewAndComment?["score"].stringValue{
            var number = (rating as NSString).floatValue
            println("rating is \(rating) score is \(number)")
            self.floatRatingView.rating = number
        }
        
        
       

    }
    
    
    
}


