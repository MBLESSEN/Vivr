//
//  BoxCell.swift
//  vivr v4
//
//  Created by max blessen on 7/22/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol boxBrandFlavorDelegate {
    //func toReview(cell: BoxCell)
    //func favoriteTrue(cell: BoxCell)
    //func favoriteFalse(cell: BoxCell)
    //func wishlistTrue(cell: BoxCell)
    //func wishlistFalse(cell: BoxCell)
    func juiceInBoxSelected(id: Int)
}

class BoxCell: UITableViewCell, UIScrollViewDelegate, iCarouselDataSource, iCarouselDelegate {
    
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var boxName: UILabel!
    @IBOutlet weak var brandImage: UIImageView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var flavorName: UILabel!
    @IBOutlet weak var rating: UIImageView!
    @IBOutlet weak var reviewCount: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var brandName: UILabel!
    
    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var userImage: UIImageView!
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
    
    @IBOutlet weak var productViewTopConstraint: NSLayoutConstraint!
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
    var productLeadingConstraint: NSLayoutConstraint?
    var productTrailingConstraint: NSLayoutConstraint?
    var previousPosition: CGFloat?
    var positionSet = false
    var isEven = false
    
    @IBOutlet weak var createdAt: UILabel!
    
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var productDetailWrapper: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var juiceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorBottom: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorTop: NSLayoutConstraint!
    @IBOutlet weak var blackBackgroundTopConstraint: NSLayoutConstraint!
    
    
    var selectedTagsView: UIView = UIView()
    var score: UILabel = UILabel()
    let scoreSlider: UISlider = UISlider()
    var review: UITextView = UITextView()
    var detailActive:Bool?
    var reviewActive:Bool?
    var cellDelegate: boxBrandFlavorDelegate? = nil
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
    
    var box: Boxes? {
        didSet {
            loadData()
        }
    }
    
    var wishState: Bool = false {
        didSet {
            wishlistButtonState()
        }
    }
    
    var products: Array<Product>? {
        didSet{
            if isEven == false {
            //createProductsView()
            }
        }
    }
    
    
    
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int
    {
        if products != nil {
        return products!.count
        }
        return 0
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView
    {
        var itemView: UIImageView
        
        //create new view if no view is available for recycling
        if (view == nil)
        {
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later
            itemView = UIImageView(frame:CGRect(x:0, y: 0, width:UIScreen.mainScreen().bounds.width/2, height:productView.frame.height - 42))
            itemView.contentMode = .ScaleAspectFill
        }
        else
        {
            //get a reference to the label in the recycled view
            itemView = view as! UIImageView;
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        itemView.backgroundColor = UIColor.clearColor()
        if let urlString = products![index].image as String? {
            let url = NSURL(string: urlString)
            itemView.hnk_setImageFromURL(url!)
        }
        return itemView
    }
    
    func carouselDidEndScrollingAnimation(carousel: iCarousel) {
        let index = carousel.currentItemIndex
        if products != nil {
        flavorName.text = products![index].name
        brandName.text = products![index].brand?.name
        }
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        let selectedProductID = products![index].productID
        cellDelegate?.juiceInBoxSelected(selectedProductID!)
    }
    
    func carouselDidScroll(carousel: iCarousel) {
        let index = carousel.currentItemIndex
        let offSet = carousel.offsetForItemAtIndex(index)
        let squareOffSet = offSet * offSet
        print(squareOffSet, terminator: "")
        let deltaAlpha = squareOffSet/0.25
        let alpha = 1 - deltaAlpha
        if products != nil {
        flavorName.text = products![index].name
        brandName.text = products![index].brand?.name
        }
        flavorName.alpha = alpha
        brandName.alpha = alpha
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        
        switch (option) {
        case .FadeMax:
            return 0.5
        case .FadeMin:
            return -0.5
        case .FadeRange:
            return 2.0
        case .FadeMinAlpha:
            return 0.35
        default:
            return value;
        }
    }
    
    
    
    
    
    
    
    
    
    
    func changeScrollView(view: Int) {
        let pageWidth = UIScreen.mainScreen().bounds.width
        scrollView.setContentOffset(CGPointMake(CGFloat(view) * pageWidth, 0), animated: true)
        previousPosition = scrollView.contentOffset.x
        positionSet = true
        for imageView in productView.subviews {
            if imageView.tag == view {
                imageView.alpha = 1.0
                self.flavorName.text = products![imageView.tag].name
                self.brandName.text = products![imageView.tag].brand!.name
            }else {
                imageView.alpha = 0.6
            }
        }

    }
    
    func createProductsView() {
        self.activityIndicator.hidden = true
        self.activityIndicator.stopAnimating()
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        var viewTag = 0
        var productCount = products!.count
        if productCount == 2 || productCount == 4 {
            let product = Product(json: JSON(""), id: productCount)
            isEven = true
            products!.append(product)
            productCount = productCount + 1
        }
        let width = UIScreen.mainScreen().bounds.width/CGFloat(productCount)
        print(width, terminator: "")
        let screenWidth = UIScreen.mainScreen().bounds.width
        var x = CGFloat(viewTag) * width
        var pageX = CGFloat(viewTag) * screenWidth
        for _ in products! as [Product] {
            let pageView = UIView(frame: CGRectMake(pageX, 0, screenWidth, productView.frame.height))
            pageView.tag = viewTag
            self.scrollView.addSubview(pageView)
            let imageView = UIView(frame: CGRectMake(x, 0, width, productView.frame.height))
            let productImageView = UIImageView(frame: CGRectMake(0, 0, width, myData.productImageHeight!))
            imageView.tag = viewTag
            print("imageView with tag \(imageView.tag) added", terminator: "")
            productImageView.tag = viewTag
            productImageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.addSubview(productImageView)
            productView.addSubview(imageView)
            productImageView.contentMode = UIViewContentMode.ScaleAspectFill
            if let urlString = products![viewTag].image as String? {
                let url = NSURL(string: urlString)
                productImageView.hnk_setImageFromURL(url!)
            }
            imageView.addConstraint(NSLayoutConstraint(item: productImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
            imageView.addConstraint(NSLayoutConstraint(item: productImageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
            imageView.addConstraint(NSLayoutConstraint(item: productImageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Width, multiplier: 0.5, constant: 0))
            imageView.addConstraint(NSLayoutConstraint(item: productImageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: -32))
            
            productView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: width))
            productView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: productView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
            productView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: productView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
            viewTag++
            x = x + width
            pageX = pageX + screenWidth
            if isEven == true && viewTag == productCount {
                pageView.removeFromSuperview()
                products!.removeAtIndex(viewTag - 1)
                productCount = productCount - 1
            }
        }
        self.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width*CGFloat(productCount), myData.imageHeight!)
        centerView()
    }
    
    
    
    func centerView() {
        _ = products!.count - 1
        let center = CGPointMake(UIScreen.mainScreen().bounds.width/2, productView.frame.height/2)
        print(center, terminator: "")
        var currentView: UIView = UIView()
        for view in productView.subviews {
            if view.tag == 0 {
                print("first view constrant added", terminator: "")
                productLeadingConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: productView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant:0)
            productView.addConstraint(productLeadingConstraint!)
            }else {
                print("\(view.tag) view constrant added", terminator: "")
                productView.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: currentView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
            }
            
            if view.tag == productView.subviews.count - 1 {
                print("last view constrant added", terminator: "")
                productTrailingConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: productView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
                productView.addConstraint(productTrailingConstraint!)
            }
            currentView = view
        
            let pointInSubview = view.convertPoint(center, toView: nil)
            print(pointInSubview, terminator: "")
            print(view.frame, terminator: "")
            if CGRectContainsPoint(view.frame, pointInSubview) == true  {
                print(view.tag, terminator: "")
                print("found cneter", terminator: "")
                let viewConstraints = view.constraints 
                print(viewConstraints, terminator: "")
                viewConstraints[3].constant = 0
                changeScrollView(view.tag)
                
            }
            
        }
    }
    
    
    /*
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let pageWidth = UIScreen.mainScreen().bounds.width
            var productWidth = pageWidth/CGFloat(products!.count)
            if isEven == true {
                productWidth = pageWidth/CGFloat(products!.count + 1)
            }
            let translationRatio = UIScreen.mainScreen().bounds.width/productWidth
            let fractionalPage = Float(self.scrollView.contentOffset.x / pageWidth)
            let page = lroundf(fractionalPage)
            if products?.count != 0 {
            self.flavorName.text = products![page].name
            self.brandName.text = products![page].brand!.name
            let textAlpha = CGFloat(1.0) - (2 * (CGFloat(fractionalPage) - CGFloat(page)))
            self.flavorName.alpha = textAlpha
            self.brandName.alpha = textAlpha
            }
            println(page)
            let scrollOffset = scrollView.contentOffset.x
            println(scrollOffset)
            
            let center = productView.center
        
            let viewToMove = productView.viewWithTag(page)
            if positionSet == true && scrollOffset >= 0 {
            if let translation = scrollOffset - previousPosition! as CGFloat? {
                for view in productView.subviews as! [UIView] {
                    var deltaX = -translation * (productWidth/pageWidth)
                    view.frame.offset(dx: deltaX, dy: 0)
                    let viewCenter = view.center
                    let page = CGFloat(view.tag) + CGFloat(1)
                    let convertedCenter = view.center.x
                    println("view center is \(convertedCenter)")
                    let centerOffset = convertedCenter - center.x
                    let squaredOffset = centerOffset * centerOffset
                    let rootOffset = Int(sqrt(squaredOffset))
                    println("root Offset is \(rootOffset)")
                    var heightMultiplier = CGFloat(rootOffset)/productWidth
                    let stringHeight = NSString(format: "%.2f", heightMultiplier)
                    var floatHeight = stringHeight.floatValue
                    println("the float Height i \(floatHeight)")
                    println("height multiplier is \(heightMultiplier)")
                    let heightRatio = CGFloat(32)/CGFloat(pageWidth)
                    let positionFromZero = CGFloat(0) - CGFloat(floatHeight)
                    if positionFromZero >= -1 {
                        let viewConstraints = view.constraints() as! [NSLayoutConstraint]
                        let heightConstraint = viewConstraints[3].constant
                        viewConstraints[3].constant = positionFromZero * 32
                        view.alpha = positionFromZero * 0.4 + 1
                    }else {
                        let viewConstraints = view.constraints() as! [NSLayoutConstraint]
                        let heightConstraint = viewConstraints[3].constant
                        viewConstraints[3].constant = -32
                        view.alpha = 0.6
                    }
                    
                    
                }
                previousPosition = scrollOffset
            }
            }
        }
        
        
    }
*/
    
    var product:Product? {
        didSet {
            self.loadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        carousel.type = .Rotary
        isEven = false
        configureButtons()
        reviewButton.enabled = false
        favoriteButton.enabled = false
        wishlistButton.enabled = false
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2
        self.userImage.clipsToBounds = true
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
    
    
    func configureButtons() {
        wishlistButtonState()
        favoriteButtonState()
        reviewButtonState()
        favoriteButton.setImage(likeImage, forState: .Normal)
        reviewButton.setImage(reviewImage, forState: .Normal)
        wishlistButton.setImage(wishImage, forState: .Normal)
        
    }
    
    @IBAction func favoritePressed(sender: AnyObject) {
        switch favoriteState {
        case true:
            favoriteState = false
            Alamofire.request(Router.unFavorite(productID!))
            //cellDelegate?.favoriteFalse(self)
        case false:
            favoriteState = true
            Alamofire.request(Router.Favorite(productID!))
           // cellDelegate?.favoriteTrue(self)
        }
        self.favoriteButtonState()
    }
    
    @IBAction func reviewPressed(sender: AnyObject) {
        //cellDelegate?.toReview(self)
    }
    
    @IBAction func wishPressed(sender: AnyObject) {
        switch wishState {
        case true:
            wishState = false
            Alamofire.request(Router.removeWish(productID!))
            //cellDelegate?.wishlistFalse(self)
        case false:
            wishState = true
            Alamofire.request(Router.addToWish(productID!))
            //cellDelegate?.wishlistTrue(self)
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
        self.userName.setTitle(box?.user?.userName, forState: .Normal)
        if let urlString = box?.user?.image as String? {
            let url = NSURL(string: urlString)
            self.userImage.hnk_setImageFromURL(url!)
        }
        if (box?.description == nil || box?.description == ""){
            descriptionLabel.text = "There is no description for this box"
        }else {
            self.descriptionLabel.text = box?.description
        }
        
        self.boxName.text = box?.name
        
        if let date = box!.createdAt {
            let dateFor:NSDateFormatter = NSDateFormatter()
            dateFor.timeZone = NSTimeZone(abbreviation: "UTC")
            dateFor.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let theDate:NSDate = dateFor.dateFromString(date)!
            dateFor.dateStyle = .MediumStyle
            let dateString = dateFor.stringFromDate(theDate)
            self.createdAt.text = "Created \(dateString)"
        }
        
    }

    
}
