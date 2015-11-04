//
//  userTableViewController.swift
//  vivr v4
//
//  Created by max blessen on 2/21/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON

class userViewController: UIViewController, reviewCellDelegate, UIScrollViewDelegate, UITableViewDelegate, MyBoxControllerDelegate {
    var myFavorites:[JSON]? = []
    var myFavoritesData:JSON?
    var myWishlist:[JSON]? = []
    var myWishlistData:JSON?
    var selectedUserID:String?
    var selectedProductID:String?
    var selectedBoxID: Int?
    var segueIdentifier:String?
    var reviewID:String?
    var topCell:profileCell?
    var userNameLabel:UILabel?
    
    var isLoadingUserData = false
    var isLoadingReviews = false
    var userReviews:Array<ActivityFeedReviews>?
    var userReviewsWrapper: ActivityWrapper?
    var selectedReview: ActivityFeedReviews?
    var userData:User?
    var userDataWrapper: UserDataWrapper?
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var navBackground: UIView!
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var profileTable:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        if let z = profileTable.layer.zPosition as CGFloat?{
            navBackground.layer.zPosition = z + 2
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        refreshData()
        if userReviews == nil {
            loadFirstReviews()
        }
        addMenu()
        configureNavigation()
        
        self.tabBarController!.tabBar.hidden = false 
    }
    func addMenu(){
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    func configureNavigation() {
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBarHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func wishlistTapped(sender: AnyObject) {
        self.segueIdentifier = "userToWishlist"
        performSegueWithIdentifier(segueIdentifier!, sender: self)
    }
    @IBAction func favoritesTapped(sender: AnyObject) {
        self.segueIdentifier = "myUserToFavorites"
        performSegueWithIdentifier(segueIdentifier!, sender: self)
    }
    func tappedProductbutton(cell: myReviewsCell) {
        self.segueIdentifier = "myUserToFlavor"
        self.selectedProductID = cell.productID
        performSegueWithIdentifier(segueIdentifier!, sender: self)
    }
    func tappedCommentButton(cell: myReviewsCell) {
        self.segueIdentifier = "myUserToComments"
        self.selectedProductID = cell.productID
        self.reviewID = cell.reviewID
        self.selectedReview = cell.review
        selectedReview!.user = self.userData!
        performSegueWithIdentifier(segueIdentifier!, sender: self)
    }
    @IBAction func boxesTapped(sender: AnyObject) {
        self.segueIdentifier = "userToMyBoxes"
        performSegueWithIdentifier(segueIdentifier!, sender: self)
    }
    
    func boxSelected(view: MyBoxController) {
        self.segueIdentifier = "userToBox"
        self.selectedBoxID = view.selectedBox!
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
    
    func refreshData() {
        loadUserData()
        Alamofire.request(Router.readUserFavorites(myData.myProfileID!, 1)).responseJSON { (response) in
            if (response.result.isSuccess) {
                let json = response.data
                var jsonOBJ = JSON(json!)
                if let favoriteData = jsonOBJ as JSON? {
                    self.myFavoritesData = favoriteData
                }
                if let favorites = jsonOBJ["data"].arrayValue as [JSON]? {
                    self.myFavorites = favorites
                    
                }
                self.reloadTableViewContent()
            }
        }
        Alamofire.request(Router.readWishlist(myData.myProfileID!, 1)).responseJSON { (response) in
            if (response.result.isSuccess) {
                let json = response.data
                var jsonOBJ = JSON(json!)
                if let wishData = jsonOBJ as JSON? {
                    self.myWishlistData = wishData
                }
                if let wishlist = jsonOBJ["data"].arrayValue as [JSON]? {
                    self.myWishlist = wishlist
                    
                }
                self.reloadTableViewContent()
            }
        }
        
        
        
        
        
    }
    
    func reloadTableViewContent() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.profileTable.reloadData()
        })
        if let cell = (profileTable.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as? profileCell) {
            topCell = cell
        }
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
        let cell = profileTable.dequeueReusableCellWithIdentifier("checkInJuiceCell") as UITableViewCell!
        return cell
        
    }
    
    func profileCellAtIndexPath(indexPath:NSIndexPath) -> profileCell {
        let cell = self.profileTable.dequeueReusableCellWithIdentifier("profileCell") as! profileCell
        cell.separatorInset = UIEdgeInsetsZero
        if (userData != nil && myFavoritesData != nil && myWishlistData != nil && userReviewsWrapper != nil) {
            setImageForProfile(cell, indexPath: indexPath)
            let review = userReviewsWrapper!
            cell.userName.text = userData!.userName
            self.userNameLabel = UILabel(frame: CGRectMake(0, 0, 60, 20))
            self.userNameLabel!.text = userData!.userName
            userNameLabel?.textColor = UIColor.whiteColor()
            userNameLabel?.font = UIFont(name: "PTSans-Bold", size: 17)
            userNameLabel?.textAlignment = .Center
            userNameLabel?.sizeToFit()
            cell.bio.text = myData.bio
            cell.bio.sizeToFit()
            cell.hardware.text = myData.hardWare
            if let reviewCount = review.count {
                let reviewString = String(stringInterpolationSegment: reviewCount)
                cell.reviewsCount.text = reviewString
            }
            cell.favoritesCount.text = "\(userData!.favorite_count!)"
            cell.wishCount.text = "\(userData!.wishlist_count!)"
            cell.boxCount.text = "\(userData!.box_count!)"
        }
        cell.preservesSuperviewLayoutMargins = false
        return cell
    }
    
    func reviewCellAtIndexPath(indexPath:NSIndexPath) -> myReviewsCell {
        let cell = self.profileTable.dequeueReusableCellWithIdentifier("myReviews") as! myReviewsCell
        if self.userReviews != nil && self.userReviews!.count >= indexPath.row && isLoadingReviews == false {
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
        cell.preservesSuperviewLayoutMargins = true
        return cell
    }
    
    func setImageForProfile(cell:profileCell, indexPath:NSIndexPath) {
        if let imageString = userData!.image as String?{
            let url = NSURL(string: imageString)
            cell.userImage.hnk_setImageFromURL(url!)
            cell.userImageBlur.hnk_setImageFromURL(url!)
        }
    }
    
    func setImageForReview(cell:myReviewsCell, indexPath:NSIndexPath) {
        if isLoadingReviews == false {
        let review = userReviews![indexPath.row]
        if let imageString = review.product?.image {
            let url = NSURL(string: imageString)
            cell.productImage.hnk_setImageFromURL(url!)
        }
        }
    }
    func setReviewForCell(cell:myReviewsCell, indexPath:NSIndexPath) {
        let review = userReviews![indexPath.row]
        cell.review = review
        cell.cellID = indexPath.row 
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
            cell.throat.text = ("\(value!) throat hit")
        }
        if let vaporProduction = review.vapor {
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
                        let json = response.data
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
        case "myUserToFavorites":
            let favoritesVC: newFavoritesViewController = segue.destinationViewController as! newFavoritesViewController
            favoritesVC.userID = myData.myProfileID
            favoritesVC.isUser = true
        case "myUserToFlavor":
            let productVC: brandFlavorViewController = segue.destinationViewController as! brandFlavorViewController
            productVC.boxOrProduct = "product"
            productVC.selectedProductID = selectedProductID
        case "userToWishlist":
            let wishVC: wishListViewControler = segue.destinationViewController as! wishListViewControler
            wishVC.userID = myData.myProfileID
            wishVC.isUser = true
        case "myUserToComments":
            let reviewVC: commentsViewController = segue.destinationViewController as! commentsViewController
            reviewVC.reviewID = self.reviewID!
            reviewVC.productID = self.selectedProductID!
            reviewVC.review = selectedReview!
        case "userToMyBoxes":
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let boxesVC: MyBoxController = destinationNavigationController.topViewController as! MyBoxController
            boxesVC.viewDelegate = self
            boxesVC.isMyUser = true
            boxesVC.selectedUserID = myData.myProfileID
            boxesVC.createTitleLabel(myData.myProfileName)
        case "userToBox":
            let boxVC: brandFlavorViewController = segue.destinationViewController as! brandFlavorViewController
            boxVC.boxOrProduct = "box"
            boxVC.selectedBoxID = self.selectedBoxID!
        default:
            print("no segue", terminator: "")
        }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let cellOffset = profileTable.contentOffset.y
        if let height = topCell?.contentView.frame.height as CGFloat? {
            print(height, terminator: "")
            print(cellOffset, terminator: "")
        let alpha = height - cellOffset - 120
        let percent = alpha/100
        if (percent > 0) {
            topCell?.contentView.alpha = percent
        }
        if (percent <= 0.1 || cellOffset >= height + 120) {
                navBackground.alpha = 1
            }else {
                navBackground.alpha = 0
            }
            if (cellOffset  < 0) {
                topCell?.imageTopConstraint.constant = -8 + cellOffset
            }
        if (cellOffset >= 20) {
                self.navigationItem.titleView = userNameLabel
                topCell?.userName.hidden = true
        }else {
            self.navigationItem.titleView = UILabel(frame: CGRectMake(0, 0, 0, 0))
            topCell?.userName.hidden = false
        }
        }
    }
    func loadFirstReviews() {
        self.userReviews = []
        isLoadingReviews = true
        ActivityFeedReviews.getUserReviews(myData.myProfileID!, completionHandler: { (activityWrapper, error) in
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
            ActivityFeedReviews.getMoreUserReviews(myData.myProfileID!, wrapper: self.userReviewsWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingReviews = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more activity", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                print("got More", terminator: "")
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
        User.getMyUserData(0, completionHandler: { (userDataWrapper, error) in
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
            self.userData = self.userDataWrapper?.UserData?.first
        }
    }
    
    
}

    
    
