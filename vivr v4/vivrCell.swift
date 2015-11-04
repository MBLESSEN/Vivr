
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
import SwiftyJSON

protocol VivrCellDelegate {
    
    func tappedCommentButton(cell: vivrCell)
    func reloadAPI(cell: vivrCell)
    func tappedUserButton(cell: vivrCell)
    func helpfulTrue(cell: vivrCell)
    func helpfulFalse(cell: vivrCell)
    func wishlistTrue(cell: vivrCell)
    func wishlistFalse(cell: vivrCell)
    func tappedProductButton(cell: vivrCell)

}

class vivrCell: UITableViewCell, UIScrollViewDelegate {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var reviewDescription: UILabel!
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var flavorName: UILabel!
    @IBOutlet weak var brandName: UILabel!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var totalScore: UILabel!
    @IBOutlet weak var throat: UILabel!
    @IBOutlet weak var vapor: UILabel!
    @IBOutlet weak var helpfull: UIButton?
    @IBOutlet weak var helpfullLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var wishlistButton: UIButton?
    @IBOutlet weak var productButton: UIButton!
    @IBOutlet weak var hardwareLabel: UILabel?
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var productImageWrapper: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var productDetailLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var productImageHeight: NSLayoutConstraint!

    @IBOutlet weak var productDetailWrapper: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var juiceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    //detailScrollDataVariables
    var descriptionContent: UILabel = UILabel()
    var tags: UILabel = UILabel()
    
    var descriptionView: UIView = UIView()
    var slideImage: UIImageView = UIImageView()
    var cellID:Int?
    var userID:String?
    var reviewID: String = ""
    var cellDelegate: VivrCellDelegate? = nil
    var productID: String = ""
    var likeImage = UIImage(named: "likeFilled")?.imageWithRenderingMode(.AlwaysTemplate)
    var wishImage = UIImage(named: "plusWhite")?.imageWithRenderingMode(.AlwaysTemplate)
    
    var descriptionState: Bool? {
        didSet {
            switch descriptionState! {
            case true:
                productDescription.hidden = false
                descriptionState = true
            case false:
                productDescription.hidden = true
                descriptionState = false
            }
        }
    }
    
    func revealControllerPanGestureShouldBegin(revealController: SWRevealViewController!) -> Bool {
        let velocity = revealController.panGestureRecognizer().velocityInView(self.scrollView).x
        if velocity < 0 {
            return false
        }else {
            return true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        productImageHeight.constant = myData.productImageHeight!
        imageHeight.constant = myData.imageHeight!
        self.contentView.layer.zPosition = self.contentView.layer.zPosition + 10
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        slideImage.alpha = 0.4 - self.scrollView.contentOffset.x
        if scrollView == self.scrollView {
        let pageWidth = UIScreen.mainScreen().bounds.width
        let fractionalPage = Float(self.scrollView.contentOffset.x / pageWidth)
        let page = lroundf(fractionalPage)
            switch page {
            case 0:
                juiceLabel.alpha = 1.0
                descriptionLabel.alpha = 0.5
                tagsLabel.alpha = 0.5
                self.descriptionView.alpha = 0.0
            case 1:
                juiceLabel.alpha = 0.5
                descriptionLabel.alpha = 1.0
                tagsLabel.alpha = 0.5
                UIView.animateWithDuration(
                    // duration
                    0.3,
                    // delay
                    delay: 0.1,
                    options: [],
                    animations: {
                        self.descriptionView.alpha = 0.4
                    }, completion: {finished in
                        
                    }
                )
            case 2:
                juiceLabel.alpha = 0.5
                descriptionLabel.alpha = 0.5
                tagsLabel.alpha = 1.0
            default:
                print("no selection", terminator: "")
            }
        }
    }
    
    
    func toProduct() {
        cellDelegate?.tappedProductButton(self)
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
        cellDelegate?.tappedProductButton(self)
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
    
    var review:ActivityFeedReviews? {
        didSet {
            self.loadReviews()
        }
    }
    
    var reviewAndComment:SwiftyJSON.JSON? {
        didSet {
            self.loadData()
        }
    }
    
    @IBAction func toComments(sender: AnyObject) {
        cellDelegate?.tappedCommentButton(self)
    }
    
    @IBAction func toUser(sender: AnyObject) {
        cellDelegate?.tappedUserButton(self)
    }
    

    @IBAction func helpfullPressed(sender: AnyObject) {
        executeHelpful()
    }
    func executeHelpful() {
        switch helpfullState! {
        case true:
            helpfullState = false
            Alamofire.request(Router.notHelpful(productID, reviewID))
            cellDelegate?.helpfulFalse(self)
        case false:
            helpfullState = true
            Alamofire.request(Router.isHelpful(productID, reviewID))
            cellDelegate?.helpfulTrue(self)
        }
        helpfulButtonState()
    }

    @IBAction func wishlistPressed(sender: AnyObject) {
        executeWishlist()
    }
   
    func executeWishlist() {
        switch wishlistState! {
        case true:
            wishlistState = false
            Alamofire.request(Router.removeWish(productID))
            cellDelegate?.wishlistFalse(self)
        case false:
            wishlistState = true
            Alamofire.request(Router.addToWish(productID))
            cellDelegate?.wishlistTrue(self)
        }
        wishlistButtonState()
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
            
        }
        
    }
    func loadReviews() {
        self.userID = review!.userID
        self.productID = review!.productID!
        self.reviewID = review!.reviewID!
        if let date = review!.createdAt {
            let dateFor:NSDateFormatter = NSDateFormatter()
            dateFor.timeZone = NSTimeZone(abbreviation: "UTC")
            dateFor.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let theDate:NSDate = dateFor.dateFromString(date)!
            let tempoDate = Tempo(date: theDate)
            let timeStamp = tempoDate.timeAgoNow()
            if let reviewString = review!.description {
                let review = NSMutableAttributedString(string: reviewString + "  -  ")
                let x = NSAttributedString(string: timeStamp, attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
                review.appendAttributedString(x)
                self.reviewDescription.attributedText = review
                self.reviewDescription.sizeToFit()
                
            }
        }
        self.userName.text = review!.user!.userName
        if let urlString = review!.user!.image as String? {
            let url = NSURL(string: urlString)
            self.userImage.hnk_setImageFromURL(url!)
        }
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2
        self.userImage.clipsToBounds = true
        self.hardwareLabel!.text = review!.user?.hardWare
        self.flavorName.text = review!.product?.name
        self.flavorName.sizeToFit()
        self.brandName.text = review!.brand?.name
        self.brandName.sizeToFit()
        self.layoutIfNeeded()
        if let productString = review!.product!.image as String? {
            let purl = NSURL(string: productString)
            self.productImage.hnk_setImageFromURL(purl!)
        }
        if let rating = review!.score {
            self.totalScore.text = rating
        }
        if let throatHit = review!.throat {
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
        if let vaporProduction = review!.vapor {
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
        //vivrcell.productDescription.text = review.product?.description
        self.helpfullState = review!.currentHelpful
        self.wishlistState = review!.product?.currentWishlist
        if let helpfulCount = review!.helpfulCount {
            switch helpfulCount {
            case 0:
                self.helpfullLabel.text = "Was this helpful?"
            default:
                self.helpfullLabel.text = "\(helpfulCount) found this helpful"
            }
        }

    }
    
    func loadData() {
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
        self.userImage.clipsToBounds = true
        userID = self.reviewAndComment!["user"]["id"].stringValue
        self.reviewID = self.reviewAndComment!["id"].stringValue
        self.productID = self.reviewAndComment!["product"]["id"].stringValue
        if let user = self.reviewAndComment!["user"]["username"].stringValue as String?{
            self.userName.text = user
        }
        self.reviewDescription.text = self.reviewAndComment!["description"].string
        self.reviewDescription.sizeToFit()
        self.flavorName.text = self.reviewAndComment!["product"]["name"].string
        if let urlString = self.reviewAndComment!["user"]["image"].stringValue as String? {
            let url = NSURL(string: urlString)
            self.userImage.hnk_setImageFromURL(url!)
        }
        self.hardwareLabel!.text = self.reviewAndComment!["user"]["hardware"].stringValue
        if let urlString = self.reviewAndComment!["product"]["image"].stringValue as String? {
            let url = NSURL(string: urlString)
            self.productImage.hnk_setImageFromURL(url!)
            
        }
        if let rating = self.reviewAndComment?["score"].stringValue{
            self.totalScore.text = rating
        }
        if let throatHit = self.reviewAndComment?["throat"].int {
            var value:String?
            switch throatHit {
            case 1:
                value = "Light"
            case 2:
                value = "Mild"
            case 3:
                value = "Harsh"
            default:
                value = "invalid"
            }
            self.throat.text = ("\(value!) throat hit")
        }
        if let vaporProduction = self.reviewAndComment?["vapor"].int {
            var value:String?
            switch vaporProduction {
            case 1:
                value = "Low"
            case 2:
                value = "Average"
            case 3:
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

        self.descriptionContent.text = self.reviewAndComment?["description"].stringValue
        self.hardwareLabel!.text = self.reviewAndComment?["user"]["hardware"].stringValue
        
       

    }
    
    
    
}


