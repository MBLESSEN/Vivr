//
//  brandFlavorViewController.swift
//  vivr v4
//
//  Created by max blessen on 12/21/14.
//  Copyright (c) 2014 max blessen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class VIVRProductViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, VivrHeaderCellDelegate, ReviewCellDelegate, brandFlavorDelegate, UINavigationBarDelegate, MyBoxControllerDelegate, boxBrandFlavorDelegate {
    
    var keyboardActive:Bool?
    var userID:String?
    var revCount:Int?
    var reviewResults:[JSON]? = []
    var productWrapper: ProductWrapper?
    var productData:Product?
    
    var boxWrapper: BoxesWrapper?
    var boxData: Boxes?
    
    var tags:JSON? = ""
    var segueIdentifier:String = ""
    var selectedUserID:String = ""
    var productThroat:Int?
    var productVapor:Int?
    var finalCell:Int?
    var currentLikeButton:UIBarButtonItem?
    var favoritesList:[JSON]? = []
    var favoritesIDList:[AnyObject] = []
    var isFavorite:Bool = false
    var selectedReviewID:String?
    var productLabel:UILabel?
    var isLoadingFeed = false
    var reviews:Array<ActivityFeedReviews>?
    var reviewsWrapper: ActivityWrapper?
    var reviewButtonViewWrapper: UIView = UIView()
    var activeWishlistContainer: UIView?
    var topView: UIView = UIView()
    var bottomView:UIView = UIView()
    var reviewScoreView:VIVRReviewScoreViewController?
    var isBeingCheckedIn: Bool?
    var titleLabel: UILabel = UILabel()

    var reviewNavBar: UINavigationBar = UINavigationBar()
    var reviewNavItem:UINavigationItem = UINavigationItem()
    var backToBoxButton:UIBarButtonItem = UIBarButtonItem()
    
    var verticalConstraint: NSLayoutConstraint?
    
    var navBackground = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 64))
    var boxOrProduct = "product"
    
    var tagPickerView: UIView = UIView(frame: CGRectMake(0, 0, 0, 0))
    var reviewView: productCell?
    var imageHeight: CGFloat?
    var reviewActionButtons: [UIButton] = Array()
    
    var products: Array<Product>?
    var backButtonIsActive = true
    
    @IBOutlet weak var mainTable: UITableView!


    var selectedProductID:String? {
        didSet {
            print(selectedProductID, terminator: "")
            self.loadProductData()
            self.loadFirstReview(selectedProductID!)
        }
    }
    
    var selectedBoxID: Int? {
        didSet {
            self.loadBoxData()
            self.loadBoxProducts()
            //self.loadFirstReview("\(selectedBoxID!)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObservingKeyboardEvents()
        self.mainTable.separatorColor = UIColor.clearColor()
        self.mainTable.contentInset = UIEdgeInsetsMake(0,0,0,0)
        print("id is \(selectedProductID)", terminator: "")
        mainTable.estimatedRowHeight = 100.0
        mainTable.rowHeight = UITableViewAutomaticDimension
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleLabel.font = UIFont(name: "PTSans-Bold", size: 17)
        self.titleLabel.textAlignment = .Center
        self.titleLabel.sizeToFit()
        self.titleLabel.alpha = 0.0
        self.titleLabel.frame = CGRectMake(0, 0, 0, 0)
        createScoreView()
        createCloseButton()
    }
    
    
    func createCloseButton() {
        let myBackButton:UIButton = UIButton(type: UIButtonType.Custom)
        myBackButton.addTarget(self, action: "backToBox", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("close", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myBackButton.sizeToFit()
        backToBoxButton = UIBarButtonItem(customView: myBackButton)
    }
    
    func backToBox() {
        boxOrProduct = "box"
        self.mainTable.reloadData()
        backButtonActive(true)
        productLabel!.alpha = 0
        
    }
    
    override func viewWillAppear(animated: Bool) {
        configureNavBar()
        self.mainTable.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        if backButtonIsActive == false {
            self.boxOrProduct = "box"
            self.mainTable.reloadData()
            backButtonIsActive = true
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.navBackground.removeFromSuperview()
    }
    
    func configureNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = true
        navBackground.backgroundColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 1.0)
        navBackground.alpha = 0.0
        self.view.addSubview(navBackground)
        self.tabBarController?.tabBar.hidden = true 
    }
    
    override func viewDidLayoutSubviews() {
        //productDescription.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func startObservingKeyboardEvents() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:Selector("keyboardWillShow:"),
            name:UIKeyboardWillShowNotification,
            object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:Selector("keyboardWillHide:"),
            name:UIKeyboardWillHideNotification,
            object:nil)
    }
    
    private func stopObservingKeyboardEvents() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
                if keyboardActive != true {
                    UIView.animateWithDuration(
                        // duration
                        2.0,
                        // delay
                        delay: 0.0,
                        options: [],
                        animations: {
                            self.verticalConstraint?.constant = keyboardFrame.height
                            self.reviewButtonViewWrapper.layoutSubviews()
                            self.keyboardActive = true
                            self.view.layoutIfNeeded()
                            self.reviewView?.adjustViews()
                            
                        }, completion: {finished in
                        }
                    )

                }
    }
    func keyboardWillHide(notification: NSNotification) {
                if keyboardActive != false {
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.verticalConstraint?.constant = 0
                    self.view.layoutIfNeeded()
                    self.reviewButtonViewWrapper.layoutSubviews()
                    self.keyboardActive = false
                })
                }
        
    }
    
    @IBAction func favoriteSelected(sender: AnyObject) {
        
        Alamofire.request(Router.Favorite(selectedProductID!)).responseJSON { response in
            print(response)
        }
        
        
        
    }
    

    @IBAction func loadMore(sender: AnyObject) {

    }
    
    func createReviewActionBar() {
        if (UIScreen.mainScreen().bounds.width < 370) {
            reviewButtonViewWrapper.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 50)
        }else {
            reviewButtonViewWrapper.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 75)
        }
        let buttonWidth = reviewButtonViewWrapper.frame.width/2
        let reviewButton = UIButton(frame: CGRectMake(0, 0, buttonWidth, reviewButtonViewWrapper.frame.height))
        reviewButton.tag = 0
        reviewButton.setTitle("Review", forState: .Normal)
        reviewButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        reviewButton.backgroundColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        reviewButton.titleLabel!.font = UIFont(name: "PTSans-Bold", size: 15.0)
        reviewButton.addTarget(self, action: "reviewPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        reviewButton.addTarget(self, action: "buttonTouchDown:", forControlEvents: .TouchDown)
        let scoreButton = UIButton(frame: CGRectMake(buttonWidth, 0, buttonWidth, reviewButtonViewWrapper.frame.height))
        scoreButton.tag = 1
        scoreButton.setTitle("Score", forState: .Normal)
        scoreButton.setTitleColor(UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9), forState: .Normal)
        scoreButton.backgroundColor = UIColor.whiteColor()
        scoreButton.titleLabel!.font = UIFont(name: "PTSans-Bold", size: 15.0)
        scoreButton.addTarget(self, action: "reviewPressed:", forControlEvents: .TouchUpInside)
        scoreButton.addTarget(self, action: "buttonTouchDown:", forControlEvents: .TouchDown)
        
        reviewActionButtons.append(reviewButton)
        reviewActionButtons.append(scoreButton)
        reviewButtonViewWrapper.addSubview(reviewButton)
        reviewButtonViewWrapper.addSubview(scoreButton)
        reviewButtonViewWrapper.bringSubviewToFront(reviewButton)
        reviewButtonViewWrapper.bringSubviewToFront(scoreButton)
       
        reviewButtonViewWrapper.addConstraint(NSLayoutConstraint(item: reviewButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: reviewButtonViewWrapper, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0))
    }
    
    func removeActionBar() {
        for buttons in reviewButtonViewWrapper.subviews {
            buttons.removeFromSuperview()
        }
        reviewActionButtons = []
    }
    
    func reviewPressed(sender: UIButton) {
        sender.selected = true
        sender.backgroundColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        let tag = sender.tag
        print(tag, terminator: "")
        for button in reviewActionButtons
        {
            if button.tag != sender.tag {
                button.backgroundColor = UIColor.whiteColor()
                button.setTitleColor(UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9), forState: .Normal)
            }
        }
        if tag == 1 {
            reviewView?.review.resignFirstResponder()
            UIView.animateWithDuration(
                // duration
                0.2,
                // delay
                delay: 0.0,
                options: [],
                animations: {
                    self.reviewScoreView!.view.alpha = 1.0
                }, completion: {finished in
                }
            )
            
        }
        if tag == 0 {
            reviewView?.review.becomeFirstResponder()
            UIView.animateWithDuration(
                // duration
                0.2,
                // delay
                delay: 0.0,
                options: [],
                animations: {
                    self.reviewScoreView!.view.alpha = 0.0
                }, completion: {finished in
                }
            )
        }
        setTitleLabelForNav(tag)
    }
    func setTitleLabelForNav(view: Int) {
        switch view {
        case 0:
            titleLabel.text = "Write a review"
            titleLabel.sizeToFit()
        case 1:
            titleLabel.text = "Rate it"
            titleLabel.sizeToFit()
        case 2:
            titleLabel.text = "Vapor Production"
            titleLabel.sizeToFit()
        case 3:
            titleLabel.text = "Throat hit"
            titleLabel.sizeToFit()
        case 4:
            titleLabel.text = "Tastes like"
            titleLabel.sizeToFit()
        default:
            print("rror", terminator: "")
        }
        UIView.animateWithDuration(
            // duration
            0.3,
            // delay
            delay: 0.0,
            options: [],
            animations: {
                
                self.reviewNavItem.titleView = self.titleLabel
                self.titleLabel.alpha = 1.0
            }, completion: {finished in
                
            }
        )
    }
    func hideKeyboard() {
        if(keyboardActive == true) {
            self.becomeFirstResponder()
            self.view.endEditing(true)
        }
    }
    
    func buttonTouchDown(sender: UIButton) {
        print("touch down", terminator: "")
        sender.backgroundColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    func cancelReview() {
        navBackground.hidden = false
        hideKeyboard()
        self.reviewView!.review.text = nil
        self.reviewView!.vaporScore = nil
        self.reviewView?.throatScore = nil
        self.reviewView!.removeReviewWrappers()
        reviewNavBar.removeFromSuperview()
        UIView.animateWithDuration(
            // duration
            0.2,
            // delay
            delay: 0.0,
            options: [],
            animations: {
                self.reviewView!.productImageCenter.constant = 0
                self.reviewView!.layoutIfNeeded()
            }, completion: {finished in
                UIView.animateWithDuration(
                    // duration
                    0.2,
                    // delay
                    delay: 0.0,
                    options: [],
                    animations: {
                        self.reviewView!.frame.offsetInPlace(dx: 0, dy: -44)
                        self.bottomView.alpha = 0.0
                        self.view.backgroundColor = UIColor.whiteColor()
                    }, completion: {finished in
                    self.navigationController?.navigationBarHidden = false
                    self.reviewButtonViewWrapper.removeFromSuperview()
                    }
                )
                UIView.animateWithDuration(
                    // duration
                    0.2,
                    // delay
                    delay: 0.0,
                    options: [],
                    animations: {
                        self.reviewView!.backgroundColor = UIColor.whiteColor()
                    }, completion: {finished in
                        UIView.animateWithDuration(
                            // duration
                            0.2,
                            // delay
                            delay: 0.0,
                            options: [],
                            animations: {
                                self.mainTable.alpha = 1.0
                                self.reviewView!.actionsBar.alpha = 1.0
                                self.reviewView!.detailsView.alpha = 1.0
                                self.reviewView!.flavorName.alpha = 1.0
                                self.reviewView!.brandName.alpha = 1.0
                            }, completion: {finished in
                                self.mainTable.reloadData()
                                self.removeActionBar()
                                self.reviewView!.removeFromSuperview()
                                self.topView.removeFromSuperview()
                                self.bottomView.removeFromSuperview()
                                
                            }
                        )
                    }
                )
            }
        )

    }
    
    func submitReview() {
        let reviewText = reviewView!.review
        switch reviewText.text {
        case nil:
            let emptyAlert = UIAlertController(title: "oops!", message: "Please enter a review", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        case "Write a comment...":
            let emptyAlert = UIAlertController(title: "oops!", message: "Please enter a review", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        default:
            if let vapor = reviewScoreView!.vaporController.selectedSegmentIndex as Int?{
                if let throat = reviewScoreView!.throatController.selectedSegmentIndex as Int? {
                        let score = "\(reviewScoreView!.reviewScore)"
                    let parameters: [ String : AnyObject] = [
                        "throat": throat,
                        "vapor": vapor,
                        "description": reviewText.text,
                        "score": score
                        
                    ]
                    
                    
                    Alamofire.request(Router.AddReview(reviewView!.productID!, parameters)).responseJSON { (response) in
                        self.cancelReview()
                        self.mainTable.reloadData()
                    }
                    
                }else {
                    let emptyAlert = UIAlertController(title: "oops!", message: "How was the throat hit?", preferredStyle: UIAlertControllerStyle.Alert)
                    emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(emptyAlert, animated: true, completion: nil)
                }
            }
            else {
                let emptyAlert = UIAlertController(title: "oops!", message: "How was the vapor production?", preferredStyle: UIAlertControllerStyle.Alert)
                emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(emptyAlert, animated: true, completion: nil)
            }
            
            
            }
    }
    
    func createScoreView() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        reviewScoreView = storyboard.instantiateViewControllerWithIdentifier("reviewScore") as? VIVRReviewScoreViewController
    }
    
    func toReview(cell: productCell) {
        reviewFlavor()
    }
    
    func boxSelected(view: MyBoxController) {
        let alert = UIAlertController(title: "Success", message: "Added this juice to your box!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func addToBox(cell: productCell) {
        segueIdentifier = "addToBox"
        self.performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    
    func reviewFlavor() {
        createReviewActionBar()
        navBackground.hidden = true
        reviewNavBar.frame = CGRectMake(0, 20, UIScreen.mainScreen().bounds.width, 44)
        reviewNavBar.delegate = self
        reviewNavBar.barTintColor = UIColor.blackColor()
        reviewNavBar.translucent = false
        reviewNavBar.backgroundColor = UIColor.blackColor()
        reviewNavBar.tintColor = UIColor.whiteColor()
        // Create left and right button for navigation item
        let leftButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelReview")
        leftButton.image = UIImage(named: "delete")
        let rightButton = UIBarButtonItem(title: "submit", style: UIBarButtonItemStyle.Plain, target: self, action: "submitReview")
        if let font = UIFont(name: "PTSans-Bold", size: 15.00){
            rightButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        
        // Create two buttons for the navigation item
        reviewNavItem.leftBarButtonItem = leftButton
        reviewNavItem.rightBarButtonItem = rightButton
        
        // Assign the navigation item to the navigation bar
        self.view.addSubview(reviewNavBar)
        self.navigationController?.navigationBarHidden = true
        reviewNavBar.items = [reviewNavItem]
        reviewButtonViewWrapper.backgroundColor = UIColor.whiteColor()
        reviewButtonViewWrapper.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(reviewButtonViewWrapper)
        verticalConstraint = NSLayoutConstraint(item: bottomLayoutGuide, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: reviewButtonViewWrapper, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let horizontalConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: reviewButtonViewWrapper, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        view.addConstraint(NSLayoutConstraint(item: reviewButtonViewWrapper, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        self.view.addConstraint(verticalConstraint!)
        self.view.addConstraint(horizontalConstraint)
        if let cell = mainTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? productCell {
            topView = UIView(frame: CGRectMake(0, 108, UIScreen.mainScreen().bounds.width, cell.productWrapperHeight.constant))

            bottomView = UIView(frame: CGRectMake(0, topView.frame.height + 72, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - topView.frame.height - reviewButtonViewWrapper.frame.height - 72))
            bottomView.backgroundColor = UIColor.blackColor()
            self.view.addSubview(topView)
            self.view.addSubview(bottomView)
            reviewScoreView!.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, bottomView.frame.height)
            reviewScoreView!.view.alpha = 0.0
            reviewScoreView!.didMoveToParentViewController(self)
            reviewView = cell
            reviewView!.frame.offsetInPlace(dx: 0, dy: -40)
            self.view.layoutMargins = UIEdgeInsetsMake(00, -16, 0, -16)
            topView.addSubview(reviewView!)
            self.bottomView.addSubview(self.reviewScoreView!.view)
            self.view.bringSubviewToFront(reviewButtonViewWrapper)
            self.view.bringSubviewToFront(reviewNavBar)
            self.reviewView!.actionsBar.alpha = 0.0
            self.reviewView!.detailsView.alpha = 0.0
            self.reviewView!.flavorName.alpha = 0.0
            self.reviewView!.brandName.alpha = 0.0
            UIView.animateWithDuration(
                // duration
                0.2,
                // delay
                delay: 0.0,
                options: [],
                animations: {
                    self.mainTable.alpha = 0.0
                    self.reviewView!.backgroundColor = UIColor.blackColor()
                    self.view.backgroundColor = UIColor.blackColor()
                    self.reviewView!.frame.offsetInPlace(dx: 0, dy: 40)
                }, completion: {finished in
                    self.titleLabel.text = "Write a review"
                    self.titleLabel.sizeToFit()
                    self.reviewNavItem.titleView = self.titleLabel
                    UIView.animateWithDuration(
                        // duration
                        0.2,
                        // delay
                        delay: 0.0,
                        options: [],
                        animations: {
                            self.reviewView!.productImageCenter.constant = self.reviewView!.productImage.center.x - 58
                            self.reviewView!.layoutIfNeeded()
                        }, completion: {finished in
                            self.reviewView!.scrollView.setContentOffset(CGPointMake(0, 0), animated: false)
                            self.reviewView!.presentReviewView()
                            
                        }
                    )
                }
            )
        }

    }
    
    func tappedUser(cell: vivrHeaderCell) {
        self.segueIdentifier = "flavorToUser"
        selectedUserID = cell.userID
        performSegueWithIdentifier(segueIdentifier, sender: cell)
    }
    
    func tappedProductButton(cell: vivrHeaderCell) {
    }
    
    func helpfulFalse(cell: reviewTableViewCell) {
        if let reviewID = cell.cellID as Int? {
            reviews![reviewID-2].currentHelpful = false
            reviews![reviewID-2].helpfulCount = reviews![reviewID-2].helpfulCount! - 1
        }
    }
    
    func helpfulTrue(cell: reviewTableViewCell) {
        if let reviewID = cell.cellID as Int? {
            reviews![reviewID-2].currentHelpful = true
            reviews![reviewID-2].helpfulCount = reviews![reviewID-2].helpfulCount! + 1
        }
    }
    
    func reloadAPI(cell: reviewTableViewCell) {
        if let section = cell.cellID as Int? {
            print(section, terminator: "")
            let indexPath = NSIndexPath(forRow: 0, inSection: section)
            mainTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    func tappedFlavorReviewCommentbutton(cell: reviewTableViewCell) {
        self.segueIdentifier = "flavorToComments"
        selectedReviewID = cell.reviewID
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    
    func juiceInBoxSelected(id: Int) {
        boxOrProduct = "product"
        selectedProductID = "\(id)"
        backButtonActive(false)
    }
    
    func backButtonActive(active: Bool) {
        if active == true {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.hidesBackButton = false
            
        }else{
            self.navigationItem.hidesBackButton = true
            self.navigationItem.leftBarButtonItem  = backToBoxButton
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if boxOrProduct == "box" {
            return 2
        }else if self.reviews == nil {
            return 2
        }
        let count = self.reviews!.count
        finalCell = 3 + count
                return 2 + count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch boxOrProduct {
                case "box":
                    let box: BoxCell = mainTable.dequeueReusableCellWithIdentifier("boxCell") as! BoxCell
                    if boxData != nil && products != nil{
                        box.contentView.frame = box.bounds
                        box.contentView.autoresizingMask = [UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
                        box.box = boxData
                        box.products = self.products!
                        box.carousel.reloadData()
                        box.cellDelegate = self
                    }
                    
                    box.preservesSuperviewLayoutMargins = false
                    return box
                
                default:
                    let product: productCell = mainTable.dequeueReusableCellWithIdentifier("productCell") as! productCell
                    product.activityIndicator.startAnimating()
                    product.productWrapperHeight.constant = myData.brandFlavorImageHeight!
                    if productData != nil {
                        product.productID = "\(productData!.productID!)"
                        product.product = productData
                        generateLabel()
                        if revCount != nil {
                            product.reviewCount.text = "\(revCount!)"
                        }
                        if revCount == 0 {
                            product.beTheFirstLabelHeight.constant = 20.0
                        }else {
                            product.beTheFirstLabelHeight.constant = 0.0
                        }
                        product.favoriteState = productData!.currentFavorite!
                        product.wishState = productData!.currentWishlist!
                    }
                    product.reviewState = false
                    product.cellDelegate = self
                    product.preservesSuperviewLayoutMargins = false
                    self.view.layoutIfNeeded()
                    return product
            }
        case 1:
            let reviewHeader: UITableViewCell = mainTable.dequeueReusableCellWithIdentifier("Reviews") as UITableViewCell!
            reviewHeader.preservesSuperviewLayoutMargins = false
            let label = reviewHeader.viewWithTag(3) as! UILabel
            if boxOrProduct == "box" {
                label.text = "Features coming soon!"
            }else {
                label.text = "No Reviews"
            }
            return reviewHeader
        default:
            return reviewForCellAtIndexPath(indexPath)
        }
    }
    
    func generateLabel() {
        productLabel = UILabel(frame: CGRectMake(0, 0, 0, 0))   
        productLabel!.textColor = UIColor.whiteColor()
        productLabel!.backgroundColor = UIColor.clearColor()
        productLabel!.text = productData!.name!
        productLabel!.font = UIFont(name: "PTSans-Bold", size: 17)
        productLabel!.sizeToFit()
        productLabel!.textAlignment = .Center
    }
    
    func reviewForCellAtIndexPath(indexPath: NSIndexPath) -> reviewTableViewCell {
        let reviewCell: reviewTableViewCell = mainTable.dequeueReusableCellWithIdentifier("reviewCell") as! reviewTableViewCell
        if self.reviews != nil && self.reviews!.count >= (indexPath.section - 2) {
            if let section = indexPath.section as Int? {
                reviewCell.cellID = section
            }
            let review = reviews![indexPath.section - 2]
            reviewCell.productID = review.productID
            reviewCell.reviewID = review.reviewID
            if let date = review.createdAt {
                let dateFor:NSDateFormatter = NSDateFormatter()
                dateFor.timeZone = NSTimeZone(abbreviation: "UTC")
                dateFor.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let theDate:NSDate = dateFor.dateFromString(date)!
                let tempoDate = Tempo(date: theDate)
                let timeStamp = tempoDate.timeAgoNow()
                if let reviewString = review.description {
                    let review = NSMutableAttributedString(string: reviewString + "  -  ")
                    let x = NSAttributedString(string: timeStamp, attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
                    review.appendAttributedString(x)
                    reviewCell.reviewContent.attributedText = review
                    
                }
            }
            if let state = review.currentHelpful {
                reviewCell.helpfullState = state
            }
            if let throatHit = review.throat {
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
                reviewCell.throat.text = ("\(value!) throat hit")
            }
            if let vaporProduction = review.vapor {
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
                reviewCell.vapor.text = ("\(value!) vapor production")
            }
            if let helpfullCount = review.helpfulCount {
                switch helpfullCount {
                case 0:
                    reviewCell.helpfulLabel.text = "Was this helpful?"
                default:
                    reviewCell.helpfulLabel.text = "\(helpfullCount) found this helpful"
                }
            }
            mainTable.rowHeight = UITableViewAutomaticDimension
            reviewCell.cellDelegate = self
            let rowsToLoadFromBottom = 5
            let rowsLoaded = self.reviews!.count
            if (!self.isLoadingFeed && (indexPath.section-4 >= (rowsLoaded - rowsToLoadFromBottom))) {
                let totalRows = self.reviewsWrapper!.count!
                let remainingFeedToLoad = totalRows - rowsLoaded
                if (remainingFeedToLoad > 0) {
                    self.loadMoreReviews(selectedProductID!)
                }
            }
            reviewCell.preservesSuperviewLayoutMargins = false
            if let productID = review.productID {
                if let reviewID = review.reviewID {
                    Alamofire.request(Router.readCommentsAPI(productID, reviewID)).responseJSON { (response) in
                        if (response.result.isSuccess) {
                            let json = response.data
                            var jsonOBJ = JSON(json!)
                            if let commentsCount = jsonOBJ["total"].stringValue as String? {
                                reviewCell.commentButton.setTitle("\(commentsCount) comments", forState: .Normal)
                            }
                        }
                    }
                    
                }
            }
        }
        return reviewCell
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell: vivrHeaderCell = tableView.dequeueReusableCellWithIdentifier("ReviewHeaderCell") as! vivrHeaderCell
        headerCell.frame = CGRectMake(0, 0, self.view.frame.width, 40.0)
        let headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 40.0))
            if self.reviews != nil && self.reviews!.count >= (section - 2) {
                let review = reviews![section - 2]
                if let theUserName = review.user?.userName {
                    headerCell.userNameButton!.setTitle(theUserName, forState:UIControlState.Normal)
                    headerCell.userNameButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                }
                if let urlString = review.user?.image as String? {
                    let url = NSURL(string: urlString)
                    headerCell.userImage.hnk_setImageFromURL(url!)
                }
                headerCell.userHardware.text = review.user?.hardWare
                headerCell.rating = review.score
                headerCell.userID = review.userID!
                headerCell.backgroundColor = UIColor.whiteColor()
                headerCell.cellDelegate = self
                headerView.addSubview(headerCell)
        }
        return headerView
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return 0
        default:
            return 40.0
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 600
        }
        return 40.0
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier {
            case "flavorToUser":
                let userVC: VIVRUserViewController = segue.destinationViewController as! VIVRUserViewController
                userVC.selectedUserID = self.selectedUserID
            case "flavorToComments":
                let commentVC: VIVRCommentsViewController = segue.destinationViewController as! VIVRCommentsViewController
                commentVC.reviewID = selectedReviewID!
                commentVC.productID = selectedProductID!
            case "addToBox":
                let destinationNavigationController = segue.destinationViewController as! UINavigationController
                let boxVC: MyBoxController = destinationNavigationController.topViewController as! MyBoxController
                boxVC.selectedProductID = Int(selectedProductID!)
                boxVC.title = "Add to which box?"
                boxVC.viewDelegate = self
                boxVC.productActive = true
                boxVC.isMyUser = true 
                boxVC.selectedUserID = myData.myProfileID
        default:
            print("no segue", terminator: "")
            
        }

    }
    func loadProductData() {
        self.productData = nil
        Product.getSingleProductData(selectedProductID!, completionHandler: { (singleProductWrapper, error) in
            if error != nil {
            print(error, terminator: "")
        
        }
        print(singleProductWrapper, terminator: "")
        self.addProductFromWrapper(singleProductWrapper)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.mainTable.beginUpdates()
        self.mainTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        self.mainTable.endUpdates()
    })
    
    }
    
    func loadBoxData() {
        self.productData = nil
        Boxes.getSingleBox(selectedBoxID!, completionHandler: { (boxWrapper, error) in
            if error != nil {
                print(error, terminator: "")
                
            }
            self.addBoxFromWrapper(boxWrapper)
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.mainTable.beginUpdates()
            self.mainTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            self.mainTable.endUpdates()
        })
        
    }
    
    func loadFirstReview(id: String) {
        self.reviews = []
        isLoadingFeed = true
        ActivityFeedReviews.getProductReviews(id, completionHandler: { (activityWrapper, error) in
            if error != nil {
                self.isLoadingFeed = false
                let alert = UIAlertController(title: "Error", message: "could not load first activity", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.addReviewFromWrapper(activityWrapper)
            self.isLoadingFeed = false
            self.mainTable.reloadData()
        })
    }
    
    func loadMoreReviews(id: String) {
        isLoadingFeed = true
        if self.reviews != nil && self.reviewsWrapper != nil && self.reviews!.count < self.reviewsWrapper!.count
        {
            ActivityFeedReviews.getMoreProductReviews(id, wrapper: self.reviewsWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingFeed = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more activity", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                print("got More", terminator: "")
                self.addReviewFromWrapper(moreWrapper)
                self.isLoadingFeed = false
                self.mainTable.reloadData()
            })
        }
    }
    
    func addReviewFromWrapper(wrapper: ActivityWrapper?) {
        self.reviewsWrapper = wrapper
        self.revCount = reviewsWrapper?.count
        if self.reviews == nil {
            self.reviews = self.reviewsWrapper?.ActivityReviews
        }else if self.reviewsWrapper != nil && self.reviewsWrapper!.ActivityReviews != nil{
            self.reviews = self.reviews! + self.reviewsWrapper!.ActivityReviews!
        }
    }
    func addProductFromWrapper(wrapper: ProductWrapper?) {
        self.productWrapper = wrapper
        if self.productData == nil {
            self.productData = self.productWrapper?.Products?.first
        }
    }
    
    func addBoxFromWrapper(wrapper: BoxesWrapper?) {
        self.boxWrapper = wrapper
        if self.boxData == nil {
            self.boxData = self.boxWrapper?.Box?.first
        }
    }
    
    func loadBoxProducts() {
        Boxes.getBoxProducts(selectedBoxID!, completionHandler: { (productWrapper, error) in
            if error != nil {
                print("error loading products", terminator: "")
            }
            self.addProductsFromWrapper(productWrapper)
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.mainTable.beginUpdates()
            self.mainTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            self.mainTable.endUpdates()
        })
    }
    
    func addProductsFromWrapper(wrapper: ProductWrapper?) {
        self.products = wrapper!.Products!
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let cellOffset = mainTable.contentOffset.y
        if let topCell = mainTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? BoxCell {
            if cellOffset < 0 {
                topCell.blackBackgroundTopConstraint.constant = CGFloat(64.0) + cellOffset
            }
        }
        if let topCell = mainTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? productCell {
            if cellOffset < 0 {
                topCell.imageTopConstraint.constant = CGFloat(64.0) + cellOffset
            }
        }
        print(cellOffset, terminator: "")
        if let height = myData.brandFlavorImageHeight! as CGFloat? {
        if (cellOffset >= -108 + height) {
            self.navBackground.alpha = 1.0
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.productLabel!.alpha = 1
            self.navigationItem.titleView = self.productLabel!
            })
        }else {
            self.navBackground.alpha = 0.0
            if self.productLabel != nil {
                self.productLabel!.alpha = 0
            }
        }
        }
        
    }
    
    
    
    
    func wishlistFalse(cell: productCell) {
        productData!.currentWishlist = false
        cell.wishlistButton.enabled = false
        cell.favoriteButton.enabled = false
        activeWishlistContainer = UIView(frame: cell.productDetailWrapper.bounds)
        cell.productDetailWrapper.addSubview(activeWishlistContainer!)
        activeWishlistContainer?.userInteractionEnabled = false
        let circle = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
        circle.layer.cornerRadius = 25.0
        
        let startingColor = UIColor(red: (118/255.0), green: (48.0/255.0), blue: (157/255.0), alpha: 1.0)
        circle.backgroundColor = startingColor
        
        activeWishlistContainer!.addSubview(circle)
        circle.center = CGPointMake(activeWishlistContainer!.bounds.width/2, activeWishlistContainer!.bounds.height/2)
        activeWishlistContainer!.clipsToBounds = true
        print(circle.frame, terminator: "")
        let plus = UIImage(named: "minusWhite")
        let plusImage = UIImageView(image: plus)
        plusImage.frame = CGRectMake(0, 0, 25, 25)
        self.activeWishlistContainer!.addSubview(plusImage)
        plusImage.center = circle.center
        UIView.animateWithDuration(
            // duration
            0.15,
            // delay
            delay: 0.3,
            options: [],
            animations: {
                let scaleTransform = CGAffineTransformMakeScale(10.0, 10.0)
                
                circle.transform = scaleTransform
                
            }, completion: {finished in
                UIView.animateWithDuration(
                    // duration
                    0.2,
                    // delay
                    delay: 0.1,
                    options: [],
                    animations: {
                        plusImage.frame.offsetInPlace(dx: -100, dy: 0)
                        
                    }, completion: {finished in
                        let label = UILabel(frame: CGRectMake(0, 0, 200, 25))
                        label.text = "Removed from wishlist"
                        label.font = UIFont(name: "PTSans-Bold", size: 20)
                        label.textColor = UIColor.whiteColor()
                        self.activeWishlistContainer!.addSubview(label)
                        label.center = circle.center
                        label.frame.offsetInPlace(dx: 400, dy: 0)
                        UIView.animateWithDuration(
                            // duration
                            0.1,
                            // delay
                            delay: 0,
                            options: [],
                            animations: {
                                label.frame.offsetInPlace(dx: -380, dy: 0)
                                
                            }, completion: {finished in
                                cell.favoriteButton.enabled = true
                                cell.wishlistButton.enabled = true
                                UIView.animateWithDuration(
                                    // duration
                                    1.2,
                                    // delay
                                    delay: 0.1,
                                    options: [],
                                    animations: {
                                        circle.alpha = 0.0
                                        label.alpha = 0.0
                                        plusImage.alpha = 0.0
                                        circle.backgroundColor = UIColor.whiteColor()
                                        
                                    }, completion: {finished in
                                       
                                    }
                                )
                            }
                        )
                    }
                )
                
            }
        )
    }
    func wishlistTrue(cell: productCell) {
        productData!.currentWishlist = true
        cell.wishlistButton.enabled = false
        cell.favoriteButton.enabled = false
        activeWishlistContainer = UIView(frame: cell.productDetailWrapper.bounds)
        cell.productDetailWrapper.addSubview(activeWishlistContainer!)
        activeWishlistContainer?.userInteractionEnabled = false
        let circle = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
        circle.layer.cornerRadius = 25.0
        
        let startingColor = UIColor(red: (118/255.0), green: (48.0/255.0), blue: (157/255.0), alpha: 1.0)
        circle.backgroundColor = startingColor
        
        activeWishlistContainer!.addSubview(circle)
        circle.center = CGPointMake(activeWishlistContainer!.bounds.width/2, activeWishlistContainer!.bounds.height/2)
        activeWishlistContainer!.clipsToBounds = true
        print(circle.frame, terminator: "")
        let plus = UIImage(named: "plusWhite")
        let plusImage = UIImageView(image: plus)
        plusImage.frame = CGRectMake(0, 0, 25, 25)
        self.activeWishlistContainer!.addSubview(plusImage)
        plusImage.center = circle.center
        UIView.animateWithDuration(
            // duration
            0.15,
            // delay
            delay: 0.3,
            options: [],
            animations: {
                let scaleTransform = CGAffineTransformMakeScale(10.0, 10.0)
                
                circle.transform = scaleTransform
                
            }, completion: {finished in
                UIView.animateWithDuration(
                    // duration
                    0.2,
                    // delay
                    delay: 0.1,
                    options: [],
                    animations: {
                        plusImage.frame.offsetInPlace(dx: -80, dy: 0)
                        
                    }, completion: {finished in
                        let label = UILabel(frame: CGRectMake(0, 0, 0, 0))
                        label.text = "Added to wishlist"
                        label.font = UIFont(name: "PTSans-Bold", size: 20)
                        label.sizeToFit()
                        label.textColor = UIColor.whiteColor()
                        self.activeWishlistContainer!.addSubview(label)
                        label.center = circle.center
                        label.frame.offsetInPlace(dx: 400, dy: 0)
                        UIView.animateWithDuration(
                            // duration
                            0.1,
                            // delay
                            delay: 0,
                            options: [],
                            animations: {
                                label.frame.offsetInPlace(dx: -386, dy: 0)
                                
                            }, completion: {finished in
                                cell.favoriteButton.enabled = true
                                cell.wishlistButton.enabled = true
                                UIView.animateWithDuration(
                                    // duration
                                    1.2,
                                    // delay
                                    delay: 0.1,
                                    options: [],
                                    animations: {
                                        circle.alpha = 0.0
                                        label.alpha = 0.0
                                        plusImage.alpha = 0.0
                                        circle.backgroundColor = UIColor.whiteColor()
                                        
                                    }, completion: {finished in
                                        
                                    }
                                )
                            }
                        )
                    }
                )
                
            }
        )
        
    }
    

    func favoriteFalse(cell: productCell) {
        productData!.currentFavorite = false
        cell.favoriteButton.enabled = false
        cell.wishlistButton.enabled = false
        activeWishlistContainer = UIView(frame: cell.productDetailWrapper.bounds)
        cell.productDetailWrapper.addSubview(activeWishlistContainer!)
        activeWishlistContainer?.userInteractionEnabled = false
        let circle = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
        circle.layer.cornerRadius = 25.0
        
        let startingColor = UIColor(red: (118/255.0), green: (48.0/255.0), blue: (157/255.0), alpha: 1.0)
        circle.backgroundColor = startingColor
        
        activeWishlistContainer!.addSubview(circle)
        circle.center = CGPointMake(activeWishlistContainer!.bounds.width/2, activeWishlistContainer!.bounds.height/2)
        activeWishlistContainer!.clipsToBounds = true
        print(circle.frame, terminator: "")
        let plus = UIImage(named: "likeEmpty")?.imageWithRenderingMode(.AlwaysTemplate)
        let plusImage = UIImageView(image: plus)
        plusImage.tintColor = UIColor.whiteColor()
        plusImage.frame = CGRectMake(0, 0, 25, 25)
        self.activeWishlistContainer!.addSubview(plusImage)
        plusImage.center = circle.center
        let label = UILabel(frame: CGRectMake(0, 0, 0, 0))
        label.text = "Removed from Favorites"
        label.font = UIFont(name: "PTSans-Bold", size: 20)
        label.sizeToFit()
        label.textColor = UIColor.whiteColor()
        self.activeWishlistContainer!.addSubview(label)
        label.center = circle.center
        label.frame.offsetInPlace(dx: 400, dy: 0)
        UIView.animateWithDuration(
            // duration
            0.15,
            // delay
            delay: 0.3,
            options: [],
            animations: {
                
                let scaleTransform = CGAffineTransformMakeScale(10.0, 10.0)
                
                circle.transform = scaleTransform
                
            }, completion: {finished in
                UIView.animateWithDuration(
                    // duration
                    0.2,
                    // delay
                    delay: 0.1,
                    options: [],
                    animations: {
                        plusImage.frame.offsetInPlace(dx: -label.frame.width/2 - 22 , dy: 0)
                        
                    }, completion: {finished in
                        UIView.animateWithDuration(
                            // duration
                            0.1,
                            // delay
                            delay: 0,
                            options: [],
                            animations: {
                                label.center = self.activeWishlistContainer!.center
                                
                            }, completion: {finished in
                                cell.favoriteButton.enabled = true
                                cell.wishlistButton.enabled = true
                                UIView.animateWithDuration(
                                    // duration
                                    1.2,
                                    // delay
                                    delay: 0.1,
                                    options: [],
                                    animations: {
                                        circle.alpha = 0.0
                                        label.alpha = 0.0
                                        plusImage.alpha = 0.0
                                        circle.backgroundColor = UIColor.whiteColor()
                                        
                                    }, completion: {finished in
                                        
                                    }
                                )
                            }
                        )
                    }
                )
                
            }
        )
    }
    func favoriteTrue(cell: productCell) {
        productData!.currentFavorite = true
        cell.favoriteButton.enabled = false
        cell.wishlistButton.enabled = false
        activeWishlistContainer = UIView(frame: cell.productDetailWrapper.bounds)
        cell.productDetailWrapper.addSubview(activeWishlistContainer!)
        activeWishlistContainer?.userInteractionEnabled = false
        let circle = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
        circle.layer.cornerRadius = 25.0
        
        let startingColor = UIColor(red: (118/255.0), green: (48.0/255.0), blue: (157/255.0), alpha: 1.0)
        circle.backgroundColor = startingColor
        
        activeWishlistContainer!.addSubview(circle)
        circle.center = CGPointMake(activeWishlistContainer!.bounds.width/2, activeWishlistContainer!.bounds.height/2)
        activeWishlistContainer!.clipsToBounds = true
        print(circle.frame, terminator: "")
        let plus = UIImage(named: "likeFilled")?.imageWithRenderingMode(.AlwaysTemplate)
        let plusImage = UIImageView(image: plus)
        plusImage.tintColor = UIColor.whiteColor()
        plusImage.frame = CGRectMake(0, 0, 25, 25)
        self.activeWishlistContainer!.addSubview(plusImage)
        plusImage.center = circle.center
        let label = UILabel(frame: CGRectMake(0, 0, 0, 0))
        label.text = "Favorited"
        label.font = UIFont(name: "PTSans-Bold", size: 20)
        label.sizeToFit()
        label.textColor = UIColor.whiteColor()
        self.activeWishlistContainer!.addSubview(label)
        label.center = circle.center
        label.frame.offsetInPlace(dx: 400, dy: 0)
        UIView.animateWithDuration(
            // duration
            0.15,
            // delay
            delay: 0.3,
            options: [],
            animations: {
                let scaleTransform = CGAffineTransformMakeScale(10.0, 10.0)
                
                circle.transform = scaleTransform
                
            }, completion: {finished in
                UIView.animateWithDuration(
                    // duration
                    0.2,
                    // delay
                    delay: 0.1,
                    options: [],
                    animations: {
                        plusImage.frame.offsetInPlace(dx: -label.frame.width/2 - 22, dy: 0)
                        
                    }, completion: {finished in
                        UIView.animateWithDuration(
                            // duration
                            0.1,
                            // delay
                            delay: 0,
                            options: [],
                            animations: {
                                label.center = self.activeWishlistContainer!.center
                                
                            }, completion: {finished in
                                cell.favoriteButton.enabled = true
                                cell.wishlistButton.enabled = true
                                UIView.animateWithDuration(
                                    // duration
                                    1.2,
                                    // delay
                                    delay: 0.1,
                                    options: [],
                                    animations: {
                                        circle.alpha = 0.0
                                        label.alpha = 0.0
                                        plusImage.alpha = 0.0
                                        circle.backgroundColor = UIColor.whiteColor()
                                        
                                    }, completion: {finished in
                                    
                                    }
                                )
                            }
                        )
                    }
                )
                
            }
        )
        
    }
    


}
    


