//
//  productCell.swift
//  vivr v4
//
//  Created by max blessen on 4/6/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

protocol brandFlavorDelegate {
    func toReview(cell: productCell)
    func favoriteTrue(cell: productCell)
    func favoriteFalse(cell: productCell)
    func wishlistTrue(cell: productCell)
    func wishlistFalse(cell: productCell)
    func addToBox(cell: productCell)
}

class productCell: UITableViewCell, UIScrollViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var tagsList: UILabel!
    @IBOutlet weak var brandImage: UIImageView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var flavorName: UILabel!
    @IBOutlet weak var rating: UIImageView!
    @IBOutlet weak var reviewCount: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var brandName: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var wishlistButton: UIButton!
    @IBOutlet weak var actionsBar: UIView!
    @IBOutlet weak var descriptionBar: UIView!

    @IBOutlet weak var flavorNameCenter: NSLayoutConstraint!
    @IBOutlet weak var productImageCenter: NSLayoutConstraint!
    @IBOutlet weak var productWrapperHeight: NSLayoutConstraint!
    @IBOutlet weak var productDetailWrapperBottom: NSLayoutConstraint!
    @IBOutlet weak var flavorNameTop: NSLayoutConstraint!
    @IBOutlet weak var beTheFirstLabelHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var addToBoxButton: UIButton!
    @IBOutlet weak var scoreTextLabel: UILabel!
    @IBOutlet weak var reviewTextLabel: UILabel!
    
    @IBOutlet weak var throatLabel: UILabel!
    @IBOutlet weak var vaporLabel: UILabel!
    // review data variable
    var vaporScore:Int?
    var throatScore:Int?
    var reviewScore: String? = "2.5"
    
    var slideImage: UIImageView = UIImageView()
    var throatButton: [UIButton] = Array()
    var vaporButton: [UIButton] = Array()
    var vaporWrapper:UIView = UIView()
    var throatWrapper:UIView = UIView()
    
    var tagWrapper:UIView = UIView()
    var descriptionView:UIView = UIView()
    var tags: UILabel = UILabel()
    @IBOutlet weak var productDetailWrapper: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var juiceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorBottom: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorTop: NSLayoutConstraint!
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!

    
    var selectedTagsView: UIView = UIView()
    var score: UILabel = UILabel()
    let scoreSlider: UISlider = UISlider()
    var review: UITextView = UITextView()
    var detailActive:Bool?
    var reviewActive:Bool?
    var cellDelegate: brandFlavorDelegate? = nil
    var productID:String?
    var likeImage = UIImage(named: "likeFilled")?.imageWithRenderingMode(.AlwaysTemplate)
    var wishImage = UIImage(named: "plusWhite")?.imageWithRenderingMode(.AlwaysTemplate)
    var reviewImage = UIImage(named: "reviewFilled")?.imageWithRenderingMode(.AlwaysTemplate)
    
    var favoriteState: Bool = false {
        didSet{
            favoriteButtonState()
        }
    }
    
    var reviewState: Bool = false {
        didSet {
            reviewButtonState()
        }
    }
    
    var wishState: Bool = false {
        didSet {
            wishlistButtonState()
        }
    }
    
    var product:Product? {
        didSet {
            self.loadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureButtons()
        reviewButton.enabled = false
        favoriteButton.enabled = false
        wishlistButton.enabled = false
    }
    
    /*
    func loadProductDetails() {
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        scrollView.scrollEnabled = true
        scrollView.delegate = self
        self.contentView.layer.zPosition = self.contentView.layer.zPosition + 10
        scrollView.pagingEnabled = true
        let button = UIButton(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, scrollView.frame.height))
        //button.addTarget(self, action: "toProduct", forControlEvents: UIControlEvents.TouchUpInside)
        let slideIndicator = UIView(frame:CGRectMake(UIScreen.mainScreen().bounds.width - 25, 0, 25.0, scrollView.frame.height))
        slideIndicator.backgroundColor = UIColor.clearColor()
        let image = UIImage(named: "forward")
        slideImage.image = image
        slideImage.alpha = 0.4
        slideImage.frame = CGRectMake(0, scrollView.frame.height/2 - 12.5, 25, 25)
        slideIndicator.addSubview(slideImage)
        let tagsView = UIView(frame: CGRectMake(2*(UIScreen.mainScreen().bounds.width), 0, UIScreen.mainScreen().bounds.width, scrollView.frame.height))
        let tagShadow = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, scrollView.frame.height))
        tagShadow.backgroundColor = UIColor.blackColor()
        tagShadow.alpha = 0.4
        tagsView.addSubview(tagShadow)
        tags.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width - 64, myData.imageHeight! - 16)
        tags.textAlignment = .Center
        tags.numberOfLines = 0
        tags.text = "no tags"
        tags.font = UIFont(name: "PTSans-Bold", size: 15.0)
        tags.textColor = UIColor.whiteColor()
        tags.center = button.center
        tagsView.addSubview(tags)
        scrollView.addSubview(button)
        scrollView.addSubview(descriptionView)
        scrollView.addSubview(tagsView)
        //pageControl.layer.zPosition = descriptionView.layer.zPosition + 2
        self.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width*3, myData.imageHeight!)
        
    }
    
    func removeProductDetail() {
        let views = scrollView.subviews
        for view in views {
            view.removeFromSuperview()
        }
    }
    */
    func removeReviewWrappers() {
        let views = scrollView.subviews
        for view in views {
            view.removeFromSuperview()
        }
        let vaporViews = vaporWrapper.subviews
        for vView in vaporViews {
            vView.removeFromSuperview()
        }
        vaporButton = []
        let throatViews = throatWrapper.subviews
        for tView in throatViews {
            tView.removeFromSuperview()
        }
        throatButton = []
        
    }
    
    func changeReviewView(view: Int) {
        let pageWidth = UIScreen.mainScreen().bounds.width
        
        switch view {
        case 0:
            scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
            review.becomeFirstResponder()
            
        case 1:
            scrollView.setContentOffset(CGPointMake(pageWidth, 0), animated: true)
            review.becomeFirstResponder()
        case 2:
            scrollView.setContentOffset(CGPointMake(pageWidth*2, 0), animated: true)
            review.becomeFirstResponder()
        case 3:
            scrollView.setContentOffset(CGPointMake(pageWidth*3, 0), animated: true)
            review.becomeFirstResponder()
        case 4:
            scrollView.setContentOffset(CGPointMake(pageWidth*4, 0), animated: true)
            self.review.endEditing(true)
        default:
            print("error", terminator: "") 
            
        }
    }
    
    
    func presentReviewView() {
        scrollView.scrollEnabled = false
        review.frame = CGRectMake(self.productImage.frame.maxX + 16, 0, UIScreen.mainScreen().bounds.width - self.productImage.frame.maxX - 16, self.productDetailWrapper.frame.height)
        review.textColor = UIColor.lightGrayColor()
        review.text = "What did it taste like?"
        review.backgroundColor = UIColor.clearColor()
        review.font = UIFont(name: "PTSans-Bold", size: 18.0)
        review.autocorrectionType = UITextAutocorrectionType.No
        review.delegate = self
        review.selectedTextRange = review.textRangeFromPosition(review.beginningOfDocument, toPosition: review.beginningOfDocument)
        self.productDetailWrapper.addSubview(review)
        
        
        review.becomeFirstResponder()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let currentText:NSString = review.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        if updatedText.characters.count == 0 {
            
            review.text = "What did it taste like?"
            review.textColor = UIColor.lightGrayColor()
            review.alpha = 0.5
            
            
            review.selectedTextRange = review.textRangeFromPosition(review.beginningOfDocument, toPosition: review.beginningOfDocument)
            
            return false
        }
            
        else if review.textColor == UIColor.lightGrayColor() && text.characters.count > 0 {
            review.text = nil
            review.textColor = UIColor.whiteColor()
            review.alpha = 1.0
        }
        
        return true
    }

    func textViewDidChangeSelection(textView: UITextView) {
            if review.textColor == UIColor.lightGrayColor() {
                review.selectedTextRange = review.textRangeFromPosition(review.beginningOfDocument, toPosition: review.beginningOfDocument)
            }
        
    }
    
    func adjustViews(){
        vaporWrapper.frame = CGRectMake(UIScreen.mainScreen().bounds.width*2, 0, UIScreen.mainScreen().bounds.width, scrollView.frame.height)
        throatWrapper.frame = CGRectMake(UIScreen.mainScreen().bounds.width*3, 0, UIScreen.mainScreen().bounds.width, scrollView.frame.height)
        if let vShadow = vaporWrapper.viewWithTag(10) as UIView? {
            vShadow.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, scrollView.frame.height)
        }
        if let tShadow = throatWrapper.viewWithTag(11) as UIView? {
            tShadow.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, scrollView.frame.height)
        }
    }
    
    func vaporPressed(sender: UIButton) {
        sender.selected = true
        sender.backgroundColor = UIColor.whiteColor()
        sender.setTitleColor(UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9), forState: .Normal)
        for button in vaporButton
        {
            print(button.tag, terminator: "")
            if button.tag != sender.tag {
                button.backgroundColor = UIColor.clearColor()
                button.setTitleColor(UIColor.blackColor(), forState: .Normal)
            }
        }
        vaporScore = sender.tag
    
    }
    
    func vaporTouchDown(sender: UIButton) {
        sender.backgroundColor = UIColor.whiteColor()
        sender.setTitleColor(UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9), forState: .Normal)
    }
    func throatPressed(sender: UIButton) {
        sender.selected = true
        sender.backgroundColor = UIColor.whiteColor()
        sender.setTitleColor(UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9), forState: .Normal)
        for button in throatButton
        {
            print(button.tag, terminator: "")
            if button.tag != sender.tag {
                button.backgroundColor = UIColor.clearColor()
                button.setTitleColor(UIColor.blackColor(), forState: .Normal)
            }
        }
        throatScore = sender.tag
        
    }
    
    func throatTouchDown(sender: UIButton) {
        sender.backgroundColor = UIColor.whiteColor()
        sender.setTitleColor(UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9), forState: .Normal)
    }
    
    func sliderValueDidChange(sender:UISlider!)
    {
        
        let f = sender.value
        
        let nf = NSNumberFormatter()
        nf.numberStyle = .DecimalStyle
        nf.maximumFractionDigits = 1
        // Configure the number formatter to your liking
        let s2 = nf.stringFromNumber(f)
        reviewScore = s2
        score.text = s2
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
    
    func configureButtons() {
        wishlistButtonState()
        favoriteButtonState()
        reviewButtonState()
        favoriteButton.setImage(likeImage, forState: .Normal)
        //reviewButton.setImage(reviewImage, forState: .Normal)
        wishlistButton.setImage(wishImage, forState: .Normal)
        let boxImage = UIImage(named: "forward")?.imageWithRenderingMode(.AlwaysTemplate)
        addToBoxButton.setImage(boxImage, forState: .Normal)
        addToBoxButton.titleLabel?.textAlignment = .Left
        addToBoxButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
        addToBoxButton.imageEdgeInsets = UIEdgeInsetsMake(2, 100, 2, 20)
        addToBoxButton.contentEdgeInsets = UIEdgeInsetsMake(0, -25, 0, -20)
        
    }
    
    @IBAction func addToBoxPressed(sender: AnyObject) {
        cellDelegate?.addToBox(self)
    }
    @IBAction func favoritePressed(sender: AnyObject) {
        switch favoriteState {
        case true:
            favoriteState = false
            Alamofire.request(Router.unFavorite(productID!))
            cellDelegate?.favoriteFalse(self)
        case false:
            favoriteState = true
            Alamofire.request(Router.Favorite(productID!))
            cellDelegate?.favoriteTrue(self)
        }
        self.favoriteButtonState()
    }
    
    @IBAction func reviewPressed(sender: AnyObject) {
        cellDelegate?.toReview(self)
    }
    
    @IBAction func wishPressed(sender: AnyObject) {
        switch wishState {
        case true:
            wishState = false
            Alamofire.request(Router.removeWish(productID!))
            cellDelegate?.wishlistFalse(self)
        case false:
            wishState = true
            Alamofire.request(Router.addToWish(productID!))
            cellDelegate?.wishlistTrue(self)
        }
        self.wishlistButtonState()
    }
    
    func reviewButtonState(){
        switch reviewState{
        case true:
            reviewButton.tintColor = UIColor.whiteColor()
            reviewButton.backgroundColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
        case false:
            reviewButton.tintColor = UIColor.lightGrayColor()
            reviewButton.backgroundColor = UIColor.whiteColor()
        }
    }
    func wishlistButtonState(){
        switch wishState {
        case true:
            wishlistButton.tintColor = UIColor.whiteColor()
            wishlistButton.backgroundColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
        case false:
            wishlistButton.tintColor = UIColor.lightGrayColor()
            wishlistButton.backgroundColor = UIColor.whiteColor()
        }
        
    }
    
    func favoriteButtonState(){
        switch favoriteState {
        case true:
            favoriteButton.tintColor = UIColor.whiteColor()
            favoriteButton.backgroundColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
        case false:
            favoriteButton.tintColor = UIColor.lightGrayColor()
            favoriteButton.backgroundColor = UIColor.whiteColor()
            
        }
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //self.floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        //self.floatRatingView.fullImage = UIImage(named: "StarFull")
    }
    
    func loadData() {
        self.favoriteButton.enabled = true
        self.wishlistButton.enabled = true
        self.reviewButton.enabled = true
        self.activityIndicator.hidden = true
        self.activityIndicator.stopAnimating()
        self.descriptionLabel.text = self.product!.description
        self.brandName.text = self.product!.brand!.name
        print(self.product!.brand!.name, terminator: "")
        self.brandName.sizeToFit()
        self.flavorName.text = self.product!.name
        self.flavorName.sizeToFit()
        if let throatHit = self.product!.scores!.throat! as Float? {
            if product!.scores!.reviewCount != 0 {
            let x = round(throatHit)
            print(x, terminator: "")
            let throatInt = Int(x)
            print(throatInt, terminator: "")
            var value:String?
            switch throatInt {
            case 0:
                value = "Light"
            case 1:
                value = "Mild"
            case 2:
                value = "Harsh"
            default:
                value = "invalid"
            }
            self.throatLabel.text = ("\(value!) throat hit")
            }else {
                self.throatLabel.text = "No throat reviews"
            }
        }
        if let vaporProduction = self.product!.scores!.vapor! as Float?{
            if product!.scores!.reviewCount != 0 {
            let x = round(vaporProduction)
            let vaporInt = Int(x)
            var value:String?
            switch vaporInt {
            case 0:
                value = "Low"
            case 1:
                value = "Average"
            case 2:
                value = "Cloudy"
            default:
                value = "invalid"
            }
            self.vaporLabel.text = ("\(value!) vapor production")
            }else {
                self.vaporLabel.text = "No vapor reviews"
            }
        }
        
        
        if let floatRating = self.product!.scores!.score! as Float? {
                let stringRating = String(format: "%.1f", floatRating)
                self.ratingLabel.text = stringRating

        }
        let productString = self.product!.image
        let purl = NSURL(string: productString!)
        self.productImage.hnk_setImageFromURL(purl!, placeholder: UIImage(named: "vivrLogo"))

        if let tags = self.product!.tags {
            var tagString = ""
            for tag in tags {
                tagString = tagString + "\(tag.name!), "
                tagsList.text = tagString
            }
            if tags.count == 0 {
                tagsList.text = "No flavor tags"
            }
            self.tagsList.sizeToFit()
        }
        self.descriptionLabel.sizeToFit()
        
        
    }
    

}
