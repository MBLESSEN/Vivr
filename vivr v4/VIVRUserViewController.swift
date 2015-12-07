//
//  anyUserProfileView.swift
//  vivr v4
//
//  Created by max blessen on 5/5/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire
import Haneke
import SwiftyJSON

class VIVRUserViewController: UIViewController, reviewCellDelegate, UIScrollViewDelegate, MyBoxControllerDelegate {
    var myFavorites:[SwiftyJSON.JSON]? = []
    var myFavoritesData:SwiftyJSON.JSON?
    var myWishlist:[SwiftyJSON.JSON]? = []
    var myWishlistData:SwiftyJSON.JSON?
    var selectedUserID:String?
    var selectedProductID:String?
    var segueIdentifier:String?
    var reviewID:String?
    var userNameLabel:UILabel?
    var selectedBoxID: Int?
    var isLoadingUserData = false
    var isLoadingReviews = false
    var userReviews:Array<ActivityFeedReviews>?
    var userReviewsWrapper:ActivityWrapper?
    var selectedReview: ActivityFeedReviews?
    var isMyUser:Bool = false
    var userData:User?
    var userDataWrapper: UserDataWrapper?
    
    
    @IBOutlet weak var mySettingsButton: UIBarButtonItem!
    @IBOutlet weak var profileTable:UITableView!
    @IBOutlet weak var navBackground: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileTable.contentInset = UIEdgeInsetsMake(0,0,0,0)
    }
    
    override func viewWillAppear(animated: Bool) {
        loadUserData()
        loadFirstReviews()
        configureTableView()
        configureNavBar()
    }

    func configureNavBar() {
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true  
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)
        navigationController?.navigationBarHidden = false
        if isMyUser == true {
            configureNavBarForMyUser()
        }else {
            configureNavBarForAnyUser()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // IB ACTIONs

    @IBAction func boxesTapped(sender: AnyObject) {
        self.segueIdentifier = "userToMyBoxes"
        performSegueWithIdentifier(segueIdentifier!, sender: self)
    }
    @IBAction func wishListTapped(sender: AnyObject) {
        self.segueIdentifier = "anyUserToWishlist"
        performSegueWithIdentifier(segueIdentifier!, sender: self)
    }
    @IBAction func favoritesTapped(sender: AnyObject) {
        self.segueIdentifier = "anyUserToFavorites"
        performSegueWithIdentifier(segueIdentifier!, sender: self)
    }
    
    //TABLEVIEW CELL PROTOCOLS
    
    
    
    func tappedProductbutton(cell: myReviewsCell) {
        self.segueIdentifier = "anyUserToFlavor"
        self.selectedProductID = cell.productID
        performSegueWithIdentifier(segueIdentifier!, sender: self)
    }
    func tappedCommentButton(cell: myReviewsCell) {
        self.segueIdentifier = "anyUserToComments"
        self.selectedReview = cell.review
        selectedReview!.user = self.userData!
        self.selectedProductID = cell.productID
        self.reviewID = cell.reviewID
        performSegueWithIdentifier(segueIdentifier!, sender: self)
    }
    func helpfulTrue(cell: myReviewsCell) {
        if let reviewID = cell.cellID as Int? {
            userReviews![reviewID].currentHelpful = true
            userReviews![reviewID].helpfulCount = userReviews![reviewID].helpfulCount! + 1
        }
        
    }
    
    func helpfulFalse(cell: myReviewsCell) {
        if let reviewID = cell.cellID as Int? {
            userReviews![reviewID].currentHelpful = false
            userReviews![reviewID].helpfulCount = userReviews![reviewID].helpfulCount! - 1
        }
        
    }
    
    func boxSelected(view: MyBoxController) {
        self.segueIdentifier = "userToBox"
        self.selectedBoxID = view.selectedBox!
        performSegueWithIdentifier(segueIdentifier!, sender: self)
    }
    
    func reloadTableViewContent() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.profileTable.reloadData()
        })
    }
    
    func reloadAPI(cell: myReviewsCell) {
        if let row = cell.cellID as Int? {
            let indexPath = NSIndexPath(forRow: row, inSection: 1)
            profileTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    
    func configureTableView() {
        profileTable.estimatedRowHeight = 100
        profileTable.rowHeight = UITableViewAutomaticDimension

        self.profileTable.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            if self.userReviews?.count == 0 {
                return 1
            }else{
            return self.userReviews!.count
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 0:
            return profileCellAtIndexPath(indexPath)
        default:
            if userReviews?.count == 0 {
                return juiceCheckInCell()
            }else{
            return reviewCellAtIndexPath(indexPath)
            }
        }
    }
    
    func juiceCheckInCell() -> UITableViewCell {
        let cell = profileTable.dequeueReusableCellWithIdentifier("checkInJuiceCell")
        return cell!
        
    }
    
    
    func profileCellAtIndexPath(indexPath:NSIndexPath) -> profileCell {
        let cell = self.profileTable.dequeueReusableCellWithIdentifier("profileCell") as! profileCell
        if (userData != nil) {
        setImageForProfile(cell, indexPath: indexPath)
        generateLabel()
        cell.userName.text = userData!.userName
        cell.bio.text = userData!.bio
            cell.bio.sizeToFit()
        cell.hardware.text = userData!.hardWare
        cell.favoritesCount.text = "\(userData!.favorite_count!)"
        cell.wishCount.text = "\(userData!.wishlist_count!)"
        cell.reviewsCount.text = "\(userData!.review_count!)"
        
        }
        cell.preservesSuperviewLayoutMargins = false
        return cell
    }
    func generateLabel() {
        userNameLabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        userNameLabel!.text = userData?.userName
        userNameLabel!.textColor = UIColor.whiteColor()
        userNameLabel!.font = UIFont(name: "PTSans-Bold", size: 17)
        userNameLabel!.textAlignment = .Center
        userNameLabel!.sizeToFit()
    }
    
    func reviewCellAtIndexPath(indexPath:NSIndexPath) -> myReviewsCell {
        let cell = self.profileTable.dequeueReusableCellWithIdentifier("myReviews") as! myReviewsCell
        if self.userReviews != nil && self.userReviews!.count >= indexPath.row {
            if let cID = indexPath.row as Int? {
                cell.cellID = cID
            }
        setImageForReview(cell, indexPath: indexPath)
        setReviewForCell(cell, indexPath: indexPath)
            let rowsToLoadFromBottom = 5
            let rowsLoaded = self.userReviews!.count
            if (!self.isLoadingReviews && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                let totalRows = self.userReviewsWrapper!.count!
                let remainingFeedToLoad = totalRows - rowsLoaded
                if (remainingFeedToLoad > 0) {
                    self.loadMoreReviews()
                }
            }
        }
        cell.cellDelegate = self
        cell.preservesSuperviewLayoutMargins = false
        return cell
    }
    
    func setImageForProfile(cell:profileCell, indexPath:NSIndexPath) {
        if let imageString = userData?.image as String?{
            let url = NSURL(string: imageString)
            cell.userImage.hnk_setImageFromURL(url!)
            cell.userImageBlur.hnk_setImageFromURL(url!)
        }
    }
    
    func setImageForReview(cell:myReviewsCell, indexPath:NSIndexPath) {
        let review = userReviews![indexPath.row]
        if let imageString = review.product?.image {
            let url = NSURL(string: imageString)
            cell.productImage.hnk_setImageFromURL(url!)
        }
    }
    func setReviewForCell(cell:myReviewsCell, indexPath:NSIndexPath) {
        let review = userReviews![indexPath.row]
        cell.review = review
        cell.state = review.currentHelpful
        cell.productID = review.productID
        cell.reviewID = review.reviewID
        cell.productName.text = review.product?.name
        cell.productReview.text = review.description
        cell.brandName.text = review.brand?.name 
        cell.scoreLabel.text = review.score 
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
            cell.throat.text = ("\(value!) throat hit")
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
            cell.vapor.text = ("\(value!) vapor production")
        }
        if let helpfullCount = review.helpfulCount {
            switch helpfullCount {
            case 0:
                cell.helpfullLabel.text = "Was this helpful?"
            default:
                cell.helpfullLabel.text = "\(helpfullCount) people found this helpful"
            }
        }
        if let productID = review.productID {
            if let reviewID = review.reviewID {
                Alamofire.request(Router.readCommentsAPI(productID, reviewID)).responseJSON { (response) in
                    if (response.result.isSuccess) {
                        let json = response.result.value
                        var jsonOBJ = JSON(json!)
                        if let commentsCount = jsonOBJ["total"].stringValue as String? {
                            cell.commentsButton.setTitle("\(commentsCount) comments", forState: .Normal)
                        }
                    }
                }
                
            }
        }
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segueIdentifier != nil {
        switch segueIdentifier! {
        case "anyUserToFavorites":
            let favoritesVC: VIVRFavoritesViewController = segue.destinationViewController as! VIVRFavoritesViewController
            favoritesVC.userID = Int(selectedUserID!)
            favoritesVC.isUser = false
        case "anyUserToFlavor":
            let productVC: VIVRProductViewController = segue.destinationViewController as! VIVRProductViewController
            productVC.boxOrProduct = "product"
            productVC.selectedProductID = selectedProductID
        case "anyUserToWishlist":
            let wishVC: VIVRWishlistViewController = segue.destinationViewController as! VIVRWishlistViewController
            wishVC.userID = Int(selectedUserID!)
            wishVC.isUser = false
        case "anyUserToComments":
            let reviewVC: VIVRCommentsViewController = segue.destinationViewController as! VIVRCommentsViewController
            reviewVC.review = selectedReview!
            reviewVC.reviewID = self.reviewID!
            reviewVC.productID = self.selectedProductID!
        case "userToMyBoxes":
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let boxesVC: MyBoxController = destinationNavigationController.topViewController as! MyBoxController
            boxesVC.viewDelegate = self
            boxesVC.selectedUserID = Int(selectedUserID!)
            boxesVC.createTitleLabel(userData!.userName!)
        case "userToBox":
            let boxVC: VIVRProductViewController = segue.destinationViewController as! VIVRProductViewController
            boxVC.boxOrProduct = "box"
            boxVC.selectedBoxID = self.selectedBoxID!
        default:
            print("no segue", terminator: "")
        }
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let cellOffset = profileTable.contentOffset.y
        print(cellOffset, terminator: "")
        if let topCell = profileTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? profileCell {
        let height = topCell.contentView.frame.height
        let alpha = height - 120 - cellOffset
        let percent = alpha/100
        if (percent > 0) {
            topCell.contentView.alpha = percent
        }
        if (percent <= 0.1 || cellOffset >= height + 120) {
            navBackground.alpha = 1.0
        }else {
            navBackground.alpha = 0
        }
            if cellOffset < 0 {
                topCell.imageTopConstraint.constant = -8 + cellOffset
            }
        if (cellOffset >= 20) {
            self.navigationItem.titleView = userNameLabel
            topCell.userName.hidden = true
        }else {
            self.navigationItem.titleView = UILabel(frame: CGRectMake(0, 0, 0, 0))
            topCell.userName.hidden = false
        }
        }
    }
    func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        navBackground.alpha = 0.0
    }
    
    func loadFirstReviews() {
        self.userReviews = []
        isLoadingReviews = true
        ActivityFeedReviews.getUserReviews(Int(selectedUserID!)!, completionHandler: { (activityWrapper, error) in
            if error != nil {
                self.isLoadingReviews = false
                let alert = UIAlertController(title: "Error", message: "could not load first activity", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.addReviewFromWrapper(activityWrapper)
            self.isLoadingReviews = false
            self.profileTable.reloadData()
        })
    }
    
    func loadMoreReviews() {
        isLoadingReviews = true
        if self.userReviews != nil && self.userReviewsWrapper != nil && self.userReviews!.count < self.userReviewsWrapper!.count
        {
            ActivityFeedReviews.getMoreUserReviews(Int(selectedUserID!)!, wrapper: self.userReviewsWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingReviews = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more activity", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                print("got More")
                self.addReviewFromWrapper(moreWrapper)
                self.isLoadingReviews = false
                self.profileTable.reloadData()
            })
        }
    }
    
    func addReviewFromWrapper(wrapper: ActivityWrapper?) {
        self.userReviewsWrapper = wrapper
        if wrapper?.count == 0 {
            profileTable.separatorStyle = UITableViewCellSeparatorStyle.None
        }else {
            profileTable.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }
        if self.userReviews == nil {
            self.userReviews = self.userReviewsWrapper?.ActivityReviews
        }else if self.userReviewsWrapper != nil && self.userReviewsWrapper!.ActivityReviews != nil{
            self.userReviews = self.userReviews! + self.userReviewsWrapper!.ActivityReviews!
        }
    }
    
    func loadUserData() {
        isLoadingUserData = true
        User.getUserData(Int(selectedUserID!)!, completionHandler: { (userDataWrapper, error) in
            if error != nil {
                self.isLoadingUserData = false
                let alert = UIAlertController(title: "Error", message: "could not load first activity", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.addUserDataFromWrapper(userDataWrapper)
            self.isLoadingUserData = false
            self.profileTable.reloadData()
            
        })
    }
    func addUserDataFromWrapper(wrapper: UserDataWrapper?) {
        self.userDataWrapper = wrapper
        if self.userData == nil {
            self.userData = self.userDataWrapper?.UserData![0]
        }
    }
    
    func configureNavBarForMyUser() {
        mySettingsButton.tintColor = UIColor.whiteColor()
        mySettingsButton.enabled = true
    }
    
    func configureNavBarForAnyUser() {
        mySettingsButton.tintColor = UIColor.clearColor()
        mySettingsButton.enabled = false
    }

}
