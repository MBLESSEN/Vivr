//
//  JuiceCheckInViewController.swift
//  vivr v4
//
//  Created by max blessen on 7/1/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire



protocol JuiceCheckInDelegate {
    func juiceCheckIn(view: JuiceCheckInViewController)
}

class JuiceCheckInViewController: UIViewController, UISearchBarDelegate, searchDelegate, UINavigationBarDelegate, UITextViewDelegate {

    @IBOutlet weak var searchViewWrapper: UIView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
   
    @IBOutlet weak var reviewBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewWrapperBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var productImageHeight: NSLayoutConstraint!
    //check in Variables
    @IBOutlet weak var productImage: UIImageView!
    
    var reviewScoreView:VIVRReviewScoreViewController?
    var productWrapper: ProductWrapper?
    var productData: Product?
    
    var topView: UIView = UIView()
    var bottomView:UIView = UIView()
    
    @IBOutlet weak var scrollView: UIScrollView!
    var throatButton: [UIButton] = Array()
    var vaporButton: [UIButton] = Array()
    var score: UILabel = UILabel()
    let scoreSlider: UISlider = UISlider()
    var review: UITextView = UITextView()
    var vaporScore:Int?
    var throatScore:Int?
    var reviewScore: String? = "2.5"
    var titleLabel: UILabel = UILabel()
    @IBOutlet weak var reviewBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var reviewButtonViewWrapper: UIView!
    var reviewActionButtons: [UIButton] = Array()
    var viewDelegate: JuiceCheckInDelegate? = nil
    var originalLocation:CGRect?
    var searchView: searchViewController?
    var segueIdentifier: String?
    var productID:String?
    var reviewView: ProductTableViewCell?
    var reviewNavBar: UINavigationBar = UINavigationBar()
    var reviewNavItem:UINavigationItem = UINavigationItem()
    lazy   var search:UISearchBar = UISearchBar()
    var keyboardActive:Bool?
    var reviewActive = false
    var reviewBarHeight: CGFloat?
    var scoreButton: UIButton = UIButton()
    var reviewButton: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instantiateSearchView()
        startObservingKeyboardEvents()
        createScoreView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if (UIScreen.mainScreen().bounds.width < 370) {
            reviewBarHeight = 50.0
        }else {
            reviewBarHeight = 75.0
        }
        searchView!.controllerViewHeight.constant = 0
        self.view.layoutIfNeeded()
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func instantiateSearchView() {
        let textField = search.valueForKey("searchField") as! UITextField
        textField.backgroundColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.3)
        textField.textColor = UIColor.whiteColor()
        let attributedString = NSAttributedString(string: "Find your juice", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        textField.attributedPlaceholder = attributedString
        let iconView:UIImageView = textField.leftView as! UIImageView
        //Make the icon to a template which you can edit
        iconView.image = iconView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        //Set the color of the icon
        iconView.tintColor = UIColor.whiteColor()
        let searchWidth = self.view.frame.width - 82
        search.frame = CGRectMake(0, 0, searchWidth, 20)
        search.placeholder = "Find your juice"
        let leftNavBarButton = UIBarButtonItem(customView:search)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        self.search.delegate = self
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        searchView = storyboard.instantiateViewControllerWithIdentifier("searchTable") as? searchViewController
        searchView!.viewDelegate = self
        self.addChildViewController(self.searchView!)
        self.searchView!.view.frame = CGRectMake(0, 0, searchViewWrapper.frame.width, searchViewWrapper.frame.height)
        self.searchViewWrapper.addSubview(searchView!.view)
        self.searchView!.didMoveToParentViewController(self)
        self.searchView!.searchTable.contentInset = UIEdgeInsetsMake(0,0,0,0)

    }
    
    func reloadSearch() {
        searchView?.loadFirstSearch(search.text!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                UIView.animateWithDuration(1, animations: { () -> Void in
                    self.searchView?.bottomConstraint.constant = keyboardSize.height
                    self.reviewBarBottomConstraint.constant = keyboardSize.height
                    self.reviewScoreView?.view.alpha = 0.0
                    self.view.layoutIfNeeded()
                    self.keyboardActive = true
                    if self.scoreButton.backgroundColor != UIColor.whiteColor() && self.reviewActive == true {
                        self.reviewButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                    }
                    })
            
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
                UIView.animateWithDuration(1, animations: { () -> Void in
                    self.searchView!.bottomConstraint.constant = 0
                    self.reviewBarBottomConstraint.constant = 0
                    self.reviewScoreView?.view.alpha = 1.0
                    self.view.layoutIfNeeded()
                    self.keyboardActive = false
                })
    }
    
    func createScoreView() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        reviewScoreView = storyboard.instantiateViewControllerWithIdentifier("reviewScore") as? VIVRReviewScoreViewController
    }
    
    func presentReviewView() {
        self.createReviewActionBar()
        productImageHeight.constant = 0.936 * myData.brandFlavorImageHeight!
        topView = UIView(frame: CGRectMake(0, 64, UIScreen.mainScreen().bounds.width, myData.brandFlavorImageHeight!))
        self.view.layoutIfNeeded()
        bottomView = UIView(frame: CGRectMake(0, topView.frame.height + 72, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - topView.frame.height - reviewButtonViewWrapper.frame.height - 72))
        bottomView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(topView)
        self.view.addSubview(bottomView)
        reviewScoreView!.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, bottomView.frame.height)
        reviewScoreView!.view.alpha = 0.0
        reviewScoreView!.didMoveToParentViewController(self)
        bottomView.addSubview(reviewScoreView!.view)
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleLabel.font = UIFont(name: "PTSans-Bold", size: 17)
        self.titleLabel.textAlignment = .Center
        self.titleLabel.text = "Check-in"
        self.titleLabel.sizeToFit()
        self.reviewNavItem.titleView = self.titleLabel
        reviewNavBar.frame = CGRectMake(0, 20, UIScreen.mainScreen().bounds.width, 44)
        reviewNavBar.delegate = self
        reviewNavBar.barTintColor = UIColor.blackColor()
        reviewNavBar.translucent = false
        reviewNavBar.backgroundColor = UIColor.blackColor()
        reviewNavBar.tintColor = UIColor.whiteColor()
        // Create left and right button for navigation item
        let leftButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelReview:")
        leftButton.tag = 0
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
        review.frame = CGRectMake(self.productImage.frame.maxX + 16, 8, UIScreen.mainScreen().bounds.width - self.productImage.frame.maxX - 32, myData.brandFlavorImageHeight!)
        review.textColor = UIColor.lightGrayColor()
        review.text = "What did it taste like?"
        review.backgroundColor = UIColor.clearColor()
        review.font = UIFont(name: "PTSans-Bold", size: 18.0)
        review.delegate = self
        review.autocorrectionType = UITextAutocorrectionType.No
        review.selectedTextRange = review.textRangeFromPosition(review.beginningOfDocument, toPosition: review.beginningOfDocument)
        topView.addSubview(review)
        self.view.bringSubviewToFront(reviewButtonViewWrapper)
        review.becomeFirstResponder()
        UIView.animateWithDuration(
            // duration
            0.2,
            // delay
            delay: 0.0,
            options: [],
            animations: {
                
            }, completion: {finished in
                
                UIView.animateWithDuration(
                    // duration
                    0.2,
                    // delay
                    delay: 0.0,
                    options: [],
                    animations: {
                    }, completion: {finished in
                        
                        
                    }
                )
            }
        )

        
        
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
            review.text = ""
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
    func removeReviewWrappers() {
        
    }

    /*
    func checkInJuice(cell: ProductTableViewCell) {
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
        reviewNavBar.items = [reviewNavItem]

        reviewView = cell
        originalLocation = cell.frame
        reviewView!.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
        reviewView!.frame = cell.frame
        reviewView!.frame.offset(dx: 0, dy: 64)
        self.view.addSubview(reviewView!)
        UIView.animateWithDuration(
            // duration
            0.2,
            // delay
            delay: 0.0,
            options: nil,
            animations: {
                self.view.backgroundColor = UIColor.blackColor()
            }, completion: {finished in
                self.searchViewWrapper.alpha = 0.0
                UIView.animateWithDuration(
                    // duration
                    0.2,
                    // delay
                    delay: 0.0,
                    options: nil,
                    animations: {
                        self.reviewView!.frame = CGRectMake(0, 64, self.reviewView!.frame.width, self.reviewView!.frame.height)
                        self.navigationController?.navigationBar.alpha = 0.0
                    }, completion: {finished in
                        UIView.animateWithDuration(
                            // duration
                            0.2,
                            // delay
                            delay: 0.0,
                            options: nil,
                            animations: {
                                 self.reviewView!.productImageCenterConstraint.constant = self.reviewView!.productImage!.center.x - 58
                                self.view.layoutIfNeeded()
                            }, completion: {finished in
                                self.navigationController?.navigationBarHidden = true
                                self.view.addSubview(self.reviewNavBar)
                                
                            }
                        )
                        
                    }
                )
                
            }
        )
        
    }*/
    func cancelReview(sender: UIButton?) {
        topView.removeFromSuperview()
        bottomView.removeFromSuperview()
        reviewActive = false
        self.navigationController?.navigationBarHidden = false
        self.reviewNavBar.removeFromSuperview()
        removeReviewWrappers()
        self.searchView!.view.hidden = false
        if sender?.tag == nil {
            let emptyAlert = UIAlertController(title: "Success", message: "You checked in your juice, view it in your profile", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in self.dismissViewControllerAnimated(true, completion: nil)}))
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        }else {
            UIView.animateWithDuration(
                // duration
                0.2,
                // delay
                delay: 0.0,
                options: [],
                animations: {
                    self.searchView!.view.alpha = 1.0
                    self.removeActionBar()
                }, completion: {finished in
                    
                    self.search.becomeFirstResponder()
                }
            )
        }
        
    }
    
    
    func submitReview() {
        let reviewText = review
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
            if let vapor = reviewScoreView!.vaporController.selectedSegmentIndex as Int? {
                if let throat = reviewScoreView!.throatController.selectedSegmentIndex as Int? {
                    let score = "\(reviewScoreView!.reviewScore)"
                    let parameters: [ String : AnyObject] = [
                        "throat": throat,
                        "vapor": vapor,
                        "description": reviewText.text,
                        "score": score
                        
                    ]
                    
                    
                    Alamofire.request(Router.AddReview(productID!, parameters)).responseJSON { (response) in
                        myData.reviewsCount = myData.reviewsCount! + 1
                        self.cancelReview(nil)
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

    func dismissSearch(view: searchViewController, cell: ProductTableViewCell?) {
        if let segueString = view.segueIdentifier as String? {
            if segueString.isEmpty {
                
            }else {
                reviewActive = true
                self.checkInJuice(cell!)
                search.resignFirstResponder()
            }
        }
        
    }
    
    func checkInJuice(cell: ProductTableViewCell) {
        if let selectedProductID = cell.productID! as String? {
            productID = selectedProductID
            loadProductData(selectedProductID)
            UIView.animateWithDuration(
                // duration
                0.2,
                // delay
                delay: 0.0,
                options: [],
                animations: {
                    self.searchView!.view.alpha = 0
                }, completion: {finished in
                    self.searchView!.view.hidden = true
                    self.presentReviewView()
                    UIView.animateWithDuration(
                        // duration
                        0.2,
                        // delay
                        delay: 0.0,
                        options: [],
                        animations: {
                            
                        }, completion: {finished in
                            
                        }
                    )
                }
            )
        }
        
    }
    
    func loadProductData(ID: String) {
        self.productData = nil
        Product.getSingleProductData(ID, completionHandler: { (singleProductWrapper, error) in
            if error != nil {
                
            }
            self.addProductFromWrapper(singleProductWrapper)
        })
    }
    
    func addProductFromWrapper(wrapper: ProductWrapper?) {
        self.productWrapper = wrapper
        if self.productData == nil {
            self.productData = self.productWrapper?.Products?.first
            setProductImage()
        }
    }
    
    func setProductImage() {
        if let urlString = productData!.image as String? {
            let url = NSURL(string: urlString)
            self.productImage.hnk_setImageFromURL(url!)
        }
    }
    
    func createReviewActionBar() {
        reviewButtonViewWrapper.layer.zPosition = reviewScoreView!.view.layer.zPosition + 1
        reviewButtonViewWrapper.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width, reviewBarHeight!)
        reviewBarHeightConstraint.constant = reviewBarHeight!
        let buttonWidth = reviewButtonViewWrapper.frame.width/2
        reviewButton = UIButton(frame: CGRectMake(0, 0, buttonWidth, reviewButtonViewWrapper.frame.height))
        reviewButton.tag = 0
        reviewButton.setTitle("Review", forState: .Normal)
        reviewButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        reviewButton.backgroundColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        reviewButton.titleLabel!.font = UIFont(name: "PTSans-Bold", size: 15.0)
        reviewButton.addTarget(self, action: "reviewPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        reviewButton.addTarget(self, action: "buttonTouchDown:", forControlEvents: .TouchDown)
        scoreButton = UIButton(frame: CGRectMake(buttonWidth, 0, buttonWidth, reviewButtonViewWrapper.frame.height))
        scoreButton.tag = 1
        scoreButton.setTitle("Score", forState: .Normal)
        scoreButton.setTitleColor(UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9), forState: .Normal)
        scoreButton.backgroundColor = UIColor.whiteColor()
        scoreButton.titleLabel!.font = UIFont(name: "PTSans-Bold", size: 15.0)
        scoreButton.addTarget(self, action: "reviewPressed:", forControlEvents: .TouchUpInside)
        scoreButton.addTarget(self, action: "buttonTouchDown:", forControlEvents: .TouchDown)
        /*let tagsButton = UIButton(frame: CGRectMake(buttonWidth*4, 0, buttonWidth, reviewButtonViewWrapper.frame.height))
        tagsButton.tag = 4
        tagsButton.setTitle("Tags", forState: .Normal)
        tagsButton.setTitleColor(UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9), forState: .Normal)
        tagsButton.backgroundColor = UIColor.whiteColor()
        tagsButton.titleLabel!.font = UIFont(name: "PTSans-Bold", size: 15.0)
        tagsButton.addTarget(self, action: "reviewPressed:", forControlEvents: .TouchUpInside)
        tagsButton.addTarget(self, action: "buttonTouchDown:", forControlEvents: .TouchDown)
        */
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
        self.reviewBarHeightConstraint.constant = 0.0
        self.view.layoutIfNeeded()
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
            review.resignFirstResponder()
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
            review.becomeFirstResponder()
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
    
    func buttonTouchDown(sender: UIButton) {
        print("touch down", terminator: "")
        sender.backgroundColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    func setTitleLabelForNav(view: Int) {
        switch view {
        case 0:
            titleLabel.text = "Write a review"
            titleLabel.sizeToFit()
        case 1:
            titleLabel.text = "Rate it"
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
    
    
    func hideKeyboard(view: searchViewController) {
        
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchView!.searchTextCount = searchText.characters.count
        if searchText.characters.count >= 3 {
            if let searchString = searchBar.text!.stringByReplacingOccurrencesOfString(" ", withString: "_") as String! {
                if searchString.characters.count >= 3 {
                    searchView!.juiceSearch = true
                    searchView!.loadFirstSearch(searchString)
                }else {
                    let emptyAlert = UIAlertController(title: "oops!", message: "search must be atleast 3 letters long", preferredStyle: UIAlertControllerStyle.Alert)
                    emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(emptyAlert, animated: true, completion: nil)
                }
            }
        }
        if searchText.characters.count == 0 {
            searchView!.clearSearch()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchString = searchBar.text!.stringByReplacingOccurrencesOfString(" ", withString: "_") as String!{
            if searchString.characters.count >= 3 {
                searchView!.juiceSearch = true
                searchView!.loadFirstSearch(searchString)
            }else {
                let emptyAlert = UIAlertController(title: "oops!", message: "search must be atleast 3 letters long", preferredStyle: UIAlertControllerStyle.Alert)
                emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(emptyAlert, animated: true, completion: nil)
            }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchView!.clearSearch()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    /*
    score.frame = CGRectMake(0, 0, 100, 100)
    score.text = "2.5"
    score.font = UIFont(name: "PTSans-Bold", size: 50.0)
    score.textColor = UIColor.whiteColor()
    scoreWrapper.addSubview(score)
    score.center = scrollView.center
    score.frame.offset(dx: scrollView.frame.width/5, dy: -16)
    scoreSlider.frame = CGRectMake(self.productImage.frame.maxX + 16, scoreWrapper.frame.height - 50, UIScreen.mainScreen().bounds.width - self.productImage.frame.maxX - 32, 25)
    scoreSlider.minimumValue = 0
    scoreSlider.maximumValue = 5
    scoreSlider.continuous = true
    scoreSlider.tintColor = UIColor.whiteColor()
    scoreSlider.value = 2.5
    scoreSlider.addTarget(self, action: "sliderValueDidChange:", forControlEvents: .ValueChanged)
    scoreWrapper.addSubview(scoreSlider)
    
    let vapor0 = UIButton(frame: CGRectMake(0,0,0,0))
    vapor0.setTranslatesAutoresizingMaskIntoConstraints(false)
    let vapor4 = UIButton(frame: CGRectMake(0,0,0,0))
    vapor4.setTranslatesAutoresizingMaskIntoConstraints(false)
    let vapor1 = UIButton(frame: CGRectMake(0,0,0,0))
    vapor1.setTranslatesAutoresizingMaskIntoConstraints(false)
    let vapor2 = UIButton(frame: CGRectMake(0,0,0,0))
    vapor2.setTranslatesAutoresizingMaskIntoConstraints(false)
    let vapor3 = UIButton(frame: CGRectMake(0,0,0,0))
    vapor3.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    vapor0.backgroundColor = UIColor.whiteColor()
    vapor0.tag = 0
    vapor0.setTitle("feather", forState: .Normal)
    vapor0.setTitleColor(UIColor.blackColor(), forState: .Normal)
    vapor0.alpha = 1.0
    vapor0.titleLabel?.font = UIFont(name: "PTSans-Bold", size: 15)
    vapor0.layer.backgroundColor = UIColor.clearColor().CGColor
    vapor0.layer.borderWidth = 1.0
    vapor0.addTarget(self, action: "vaporPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    vapor0.addTarget(self, action: "vaporTouchDown:", forControlEvents: .TouchDown)
    vaporButton.append(vapor0)
    
    vapor1.backgroundColor = UIColor.whiteColor()
    vapor1.tag = 1
    vapor1.setTitle("low", forState: .Normal)
    vapor1.setTitleColor(UIColor.blackColor(), forState: .Normal)
    vapor1.alpha = 1.0
    vapor1.titleLabel?.font = UIFont(name: "PTSans-Bold", size: 15)
    vapor1.layer.backgroundColor = UIColor.clearColor().CGColor
    vapor1.layer.borderWidth = 1.0
    vapor1.addTarget(self, action: "vaporPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    vapor1.addTarget(self, action: "vaporTouchDown:", forControlEvents: .TouchDown)
    vaporButton.append(vapor1)
    
    vapor2.backgroundColor = UIColor.whiteColor()
    vapor2.tag = 2
    vapor2.setTitle("medium", forState: .Normal)
    vapor2.setTitleColor(UIColor.blackColor(), forState: .Normal)
    vapor2.alpha = 1.0
    vapor2.titleLabel?.font = UIFont(name: "PTSans-Bold", size: 15)
    vapor2.layer.backgroundColor = UIColor.clearColor().CGColor
    vapor2.layer.borderWidth = 1.0
    vapor2.addTarget(self, action: "vaporPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    vapor2.addTarget(self, action: "vaporTouchDown:", forControlEvents: .TouchDown)
    vaporButton.append(vapor2)
    
    vapor3.backgroundColor = UIColor.whiteColor()
    vapor3.tag = 3
    vapor3.setTitle("high", forState: .Normal)
    vapor3.setTitleColor(UIColor.blackColor(), forState: .Normal)
    vapor3.alpha = 1.0
    vapor3.titleLabel?.font = UIFont(name: "PTSans-Bold", size: 15)
    vapor3.layer.backgroundColor = UIColor.clearColor().CGColor
    vapor3.layer.borderWidth = 1.0
    vapor3.addTarget(self, action: "vaporPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    vapor3.addTarget(self, action: "vaporTouchDown:", forControlEvents: .TouchDown)
    vaporButton.append(vapor3)
    
    vapor4.backgroundColor = UIColor.whiteColor()
    vapor4.tag = 4
    vapor4.setTitle("clouds", forState: .Normal)
    vapor4.setTitleColor(UIColor.blackColor(), forState: .Normal)
    vapor4.alpha = 1.0
    vapor4.titleLabel?.font = UIFont(name: "PTSans-Bold", size: 15)
    vapor4.layer.backgroundColor = UIColor.clearColor().CGColor
    vapor4.layer.borderWidth = 1.0
    vapor4.addTarget(self, action: "vaporPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    vapor4.addTarget(self, action: "vaporTouchDown:", forControlEvents: .TouchDown)
    vaporButton.append(vapor4)
    
    let shadowView = UIView(frame: scrollView.frame)
    shadowView.backgroundColor = UIColor.whiteColor()
    shadowView.alpha = 0.6
    
    
    vaporWrapper.addSubview(shadowView)
    vaporWrapper.addSubview(vapor0)
    vaporWrapper.addSubview(vapor1)
    vaporWrapper.addSubview(vapor2)
    vaporWrapper.addSubview(vapor3)
    vaporWrapper.addSubview(vapor4)
    
    let throat0 = UIButton(frame: CGRectMake(0,0,0,0))
    throat0.setTranslatesAutoresizingMaskIntoConstraints(false)
    let throat4 = UIButton(frame: CGRectMake(0,0,0,0))
    throat4.setTranslatesAutoresizingMaskIntoConstraints(false)
    let throat1 = UIButton(frame: CGRectMake(0,0,0,0))
    throat1.setTranslatesAutoresizingMaskIntoConstraints(false)
    let throat2 = UIButton(frame: CGRectMake(0,0,0,0))
    throat2.setTranslatesAutoresizingMaskIntoConstraints(false)
    let throat3 = UIButton(frame: CGRectMake(0,0,0,0))
    throat3.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    throat0.backgroundColor = UIColor.whiteColor()
    throat0.tag = 0
    throat0.setTitle("feather", forState: .Normal)
    throat0.setTitleColor(UIColor.blackColor(), forState: .Normal)
    throat0.alpha = 1.0
    throat0.titleLabel?.font = UIFont(name: "PTSans-Bold", size: 15)
    throat0.layer.backgroundColor = UIColor.clearColor().CGColor
    throat0.layer.borderWidth = 1.0
    throat0.addTarget(self, action: "throatPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    throat0.addTarget(self, action: "throatTouchDown:", forControlEvents: .TouchDown)
    throatButton.append(throat0)
    
    throat1.backgroundColor = UIColor.whiteColor()
    throat1.tag = 1
    throat1.setTitle("low", forState: .Normal)
    throat1.setTitleColor(UIColor.blackColor(), forState: .Normal)
    throat1.alpha = 1.0
    throat1.titleLabel?.font = UIFont(name: "PTSans-Bold", size: 15)
    throat1.layer.backgroundColor = UIColor.clearColor().CGColor
    throat1.layer.borderWidth = 1.0
    throat1.addTarget(self, action: "throatPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    throat1.addTarget(self, action: "throatTouchDown:", forControlEvents: .TouchDown)
    throatButton.append(throat1)
    
    throat2.backgroundColor = UIColor.whiteColor()
    throat2.tag = 2
    throat2.setTitle("mild", forState: .Normal)
    throat2.setTitleColor(UIColor.blackColor(), forState: .Normal)
    throat2.alpha = 1.0
    throat2.titleLabel?.font = UIFont(name: "PTSans-Bold", size: 15)
    throat2.layer.backgroundColor = UIColor.clearColor().CGColor
    throat2.layer.borderWidth = 1.0
    throat2.addTarget(self, action: "throatPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    throat2.addTarget(self, action: "throatTouchDown:", forControlEvents: .TouchDown)
    throatButton.append(throat2)
    
    throat3.backgroundColor = UIColor.whiteColor()
    throat3.tag = 3
    throat3.setTitle("heavy", forState: .Normal)
    throat3.setTitleColor(UIColor.blackColor(), forState: .Normal)
    throat3.alpha = 1.0
    throat3.titleLabel?.font = UIFont(name: "PTSans-Bold", size: 15)
    throat3.layer.backgroundColor = UIColor.clearColor().CGColor
    throat3.layer.borderWidth = 1.0
    throat3.addTarget(self, action: "throatPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    throat3.addTarget(self, action: "throatTouchDown:", forControlEvents: .TouchDown)
    throatButton.append(throat3)
    
    throat4.backgroundColor = UIColor.whiteColor()
    throat4.tag = 4
    throat4.setTitle("harsh", forState: .Normal)
    throat4.setTitleColor(UIColor.blackColor(), forState: .Normal)
    throat4.alpha = 1.0
    throat4.titleLabel?.font = UIFont(name: "PTSans-Bold", size: 15)
    throat4.layer.backgroundColor = UIColor.clearColor().CGColor
    throat4.layer.borderWidth = 1.0
    throat4.addTarget(self, action: "throatPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    throat4.addTarget(self, action: "throatTouchDown:", forControlEvents: .TouchDown)
    throatButton.append(throat4)
    
    let throatShadowView = UIView(frame: scrollView.frame)
    throatShadowView.backgroundColor = UIColor.whiteColor()
    throatShadowView.alpha = 0.6
    
    throatWrapper.addSubview(throatShadowView)
    throatWrapper.addSubview(throat0)
    throatWrapper.addSubview(throat1)
    throatWrapper.addSubview(throat2)
    throatWrapper.addSubview(throat3)
    throatWrapper.addSubview(throat4)
    
    self.scrollView.addSubview(reviewWrapper)
    self.scrollView.addSubview(scoreWrapper)
    self.scrollView.addSubview(vaporWrapper)
    self.scrollView.addSubview(throatWrapper)
    
    //leading
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat0, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: throatWrapper, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat1, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: throatWrapper, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat2, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: throat1, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat3, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: throat2, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
    
    
    //vertical
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat1, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: throat0, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat2, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: throat0, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat3, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: throat0, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
    
    //trailing
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat0, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: throat4, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat4, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: throatWrapper, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat3, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: throatWrapper, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
    
    //top
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat4, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: throatWrapper, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat0, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: throatWrapper, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat1, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: throat0, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat2, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: throat0, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat3, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: throat0, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
    
    //bottom
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat1, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: throatWrapper, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat2, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: throatWrapper, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat3, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: throatWrapper, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat4, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: throat3, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0))
    
    //height
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat0, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: throat1, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat4, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: throat1, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat0, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: throat2, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat0, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: throat3, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
    
    //width
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat0, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: throat4, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat1, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: throat2, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
    throatWrapper.addConstraint(NSLayoutConstraint(item: throat2, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: throat3, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
    
    
    //leading
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor0, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: vaporWrapper, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor1, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: vaporWrapper, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor2, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: vapor1, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor3, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: vapor2, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
    
    
    //vertical
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor1, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: vapor0, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor2, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: vapor0, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor3, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: vapor0, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
    
    //trailing
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor0, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: vapor4, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor4, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: vaporWrapper, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor3, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: vaporWrapper, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
    
    //top
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor4, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: vaporWrapper, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor0, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: vaporWrapper, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor1, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: vapor0, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor2, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: vapor0, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor3, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: vapor0, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
    
    //bottom
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor1, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: vaporWrapper, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor2, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: vaporWrapper, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor3, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: vaporWrapper, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor4, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: vapor3, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0))
    
    //height
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor0, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: vapor1, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor4, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: vapor1, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor0, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: vapor2, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor0, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: vapor3, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
    
    //width
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor0, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: vapor4, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor1, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: vapor2, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
    vaporWrapper.addConstraint(NSLayoutConstraint(item: vapor2, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: vapor3, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
    
    scrollView.addConstraint(NSLayoutConstraint(item: reviewWrapper, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
    review.becomeFirstResponder()
    */


}
