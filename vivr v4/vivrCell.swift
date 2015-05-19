
//
//  vivrCell.swift
//  vivr v4
//
//  Created by max blessen on 2/6/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//


import UIKit
import Haneke
import Alamofire

protocol VivrCellDelegate {
    
    func tappedCommentButton(cell: vivrCell)
    func reloadAPI(cell: vivrCell)
    
}

class vivrCell: UITableViewCell{
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var BrandName: UILabel!
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
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var wishlistButton: UIButton?
    @IBOutlet weak var productButton: UIButton!
    @IBOutlet weak var hardwareLabel: UILabel?
    
    var reviewID: String = ""
    var cellDelegate: VivrCellDelegate? = nil
    var productID: String = ""
    var likeImage = UIImage(named: "likeFilled")?.imageWithRenderingMode(.AlwaysTemplate)
    var wishImage = UIImage(named: "plusWhite")?.imageWithRenderingMode(.AlwaysTemplate)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        self.floatRatingView.fullImage = UIImage(named: "StarFull")
        self.contentView.layer.zPosition = self.contentView.layer.zPosition + 10
    }
    
    func resizeButton(){
        let screenSize = UIScreen.mainScreen().bounds
            if (screenSize.width < 370) {
                productButton.frame = CGRectMake(0, 0, 0, 180)
            }else{
                productButton.frame = CGRectMake(0, 0, 0, 220)
            }
        
    }

    
    /*
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if ( CGRectContainsPoint(self.productButton.frame, point) ) {
            return true
        }
        
            return super.pointInside(point, withEvent: event)
        
    }*/
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func toProduct(sender: AnyObject) {
        println("It Worked")
    }
    
    var helpfullState: Bool? {
        didSet {
            helpfull!.layer.borderWidth = 1
            helpfull!.layer.cornerRadius = 4
            helpfull!.setImage(likeImage, forState: .Normal)
            helpfull!.imageEdgeInsets = UIEdgeInsetsMake(5,5, 5, 50)
            helpfulButtonState()
            
            
        }
    }
    var wishlistState:Bool? {
        didSet {
            wishlistButton!.layer.borderWidth = 1
            wishlistButton!.layer.cornerRadius = 4
            wishlistButton!.setImage(wishImage, forState: .Normal)
            wishlistButton!.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 50)
            wishlistButtonState()
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
    
    

    @IBAction func helpfullPressed(sender: AnyObject) {
        executeHelpful()
    }
    func executeHelpful() {
        switch helpfullState! {
        case true:
            helpfullState = false
            Alamofire.request(Router.notHelpful(productID, reviewID))
        case false:
            helpfullState = true
            Alamofire.request(Router.isHelpful(productID, reviewID))
        default:
            println("error")
        }
        self.helpfulButtonState()
        cellDelegate?.reloadAPI(self)
        
    }

    @IBAction func wishlistPressed(sender: AnyObject) {
        executeWishlist()
    }
   
    func executeWishlist() {
        switch wishlistState! {
        case true:
            wishlistState = false
            Alamofire.request(Router.removeWish(productID))
        case false:
            wishlistState = true
            Alamofire.request(Router.addToWish(productID))
        default:
            println("error")
        }
        self.wishlistButtonState()
        cellDelegate?.reloadAPI(self)
    }
    func wishlistButtonState(){
        switch wishlistState! {
        case true:
            wishlistButton!.titleEdgeInsets = UIEdgeInsetsMake(5, -2.5, 5, 5)
            wishlistButton!.layer.borderColor = (UIColor.purpleColor()).CGColor
            wishlistButton!.tintColor = UIColor.whiteColor()
            wishlistButton!.backgroundColor = UIColor.purpleColor()
            wishlistButton!.setTitle("Wishlist", forState: .Normal)
        case false:
            wishlistButton!.titleEdgeInsets = UIEdgeInsetsMake(5, -2.5, 5, 5)
            wishlistButton!.layer.borderColor = (UIColor.lightGrayColor()).CGColor
            wishlistButton!.tintColor = UIColor.lightGrayColor()
            wishlistButton!.backgroundColor = UIColor.whiteColor()
            wishlistButton!.setTitle("Wishlist", forState: .Normal)
            wishlistButton!.sizeToFit()
        default:
        println("error")
        }

    }
    
    func helpfulButtonState(){
        switch helpfullState! {
        case true:
            helpfull!.titleEdgeInsets = UIEdgeInsetsMake(5, -2.5, 5, 5)
            helpfull!.layer.borderColor = (UIColor.purpleColor()).CGColor
            helpfull!.tintColor = UIColor.whiteColor()
            helpfull!.backgroundColor = UIColor.purpleColor()
            helpfull!.setTitle("Helpful", forState: .Normal)
        case false:
            helpfull!.titleEdgeInsets = UIEdgeInsetsMake(5, -2.5, 5, 5)
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
        if let date = self.review?["created_at"].stringValue as String?{
            let dateFor:NSDateFormatter = NSDateFormatter()
            dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let theDate:NSDate = dateFor.dateFromString(date)!
            let tempoDate = Tempo(date: theDate)
            let timeStamp = tempoDate.timeAgoNow()
            if let reviewString = self.review?["description"].stringValue as String? {
                var review = NSMutableAttributedString(string: reviewString + "  -  ")
                let x = NSAttributedString(string: timeStamp, attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
                review.appendAttributedString(x)
                self.reviewDescription.attributedText = review
                
            }
        }
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
        if let productID = self.review?["product_id"].stringValue {
            if let reviewID = self.review?["id"].stringValue {
                Alamofire.request(Router.readCommentsAPI(productID, reviewID)).responseJSON { (request, response, json, error) in
                    if (json != nil) {
                        var jsonOBJ = JSON(json!)
                        if let commentsCount = jsonOBJ["total"].stringValue as String? {
                            self.commentButton.setTitle("\(commentsCount) comments", forState: .Normal)
                        }
                    }
                }
                
            }
        }

    }
    
    func loadData() {
        self.reviewID = self.reviewAndComment!["id"].stringValue
        self.productID = self.reviewAndComment!["product"]["id"].stringValue
        if let user = self.reviewAndComment?["user"]["username"].stringValue {
            self.userName.text = "\(user)"
        }
        self.reviewDescription.text = self.reviewAndComment!["description"].string
        self.reviewDescription.sizeToFit()
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
        if let throatHit = self.reviewAndComment?["throat"].int {
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
        if let vaporProduction = self.reviewAndComment?["vapor"].int {
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
        if let helpfullCount = self.reviewAndComment?["helpful_count"].stringValue {
            switch helpfullCount {
            case "0":
                self.helpfullLabel.text = "Was this helpful?"
            default:
                self.helpfullLabel.text = "\(helpfullCount) found this helpful"
            }
        }

        
       

    }
    
    
    
}


