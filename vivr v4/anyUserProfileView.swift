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

class anyUserProfileView: UIViewController, reviewCellDelegate, UIScrollViewDelegate {
    var myFavorites:[JSON]? = []
    var myFavoritesData:JSON?
    var myWishlist:[JSON]? = []
    var myWishlistData:JSON?
    var userData:JSON?
    var selectedUserID:String?
    var selectedProductID:String?
    var segueIdentifier:String?
    var reviewID:String?
    var topCell:profileCell?
    var userNameLabel:UILabel?
    var profileCellHeight:CGFloat?

    var isLoadingReviews = false
    var userReviews:Array<ActivityFeedReviews>?
    var userReviewsWrapper:ActivityWrapper?
    
    @IBOutlet weak var profileTable:UITableView!
    @IBOutlet weak var navBackground: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
        self.profileTable.contentInset = UIEdgeInsetsMake(-44,0,0,0)
    }
    override func viewWillAppear(animated: Bool) {
        loadFirstReviews()
        configureTableView()
        configureNavBar()
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }

    func configureNavBar() {
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true  
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)
        navigationController?.navigationBarHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func wishListTapped(sender: AnyObject) {
        self.segueIdentifier = "anyUserToWishlist"
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    @IBAction func favoritesTapped(sender: AnyObject) {
        self.segueIdentifier = "anyUserToFavorites"
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    func tappedProductbutton(cell: myReviewsCell) {
        self.segueIdentifier = "anyUserToFlavor"
        self.selectedProductID = cell.productID
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    func tappedCommentButton(cell: myReviewsCell) {
        self.segueIdentifier = "anyUserToComments"
        self.selectedProductID = cell.productID
        self.reviewID = cell.reviewID
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    
    func refreshData() {
        Alamofire.request(Router.readUser(selectedUserID!)).responseJSON { (request, response, json, error) in
            if let anError = error {
                println(anError)
            }
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let data = jsonOBJ as JSON? {
                    self.userData = data
                    self.reloadTableViewContent()
                }
            }
        }
        Alamofire.request(Router.readUserFavorites(selectedUserID!, 1)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let favoriteData = jsonOBJ as JSON? {
                    self.myFavoritesData = favoriteData
                    self.reloadTableViewContent()
                }
                if let favorites = jsonOBJ["data"].arrayValue as [JSON]? {
                    self.myFavorites = favorites
                    self.reloadTableViewContent()
                }
            }
        }
        Alamofire.request(Router.readWishlist(selectedUserID!)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let wishData = jsonOBJ as JSON? {
                    self.myWishlistData = wishData
                    self.reloadTableViewContent()
                }
                if let wishlist = jsonOBJ["data"].arrayValue as [JSON]? {
                    self.myWishlist = wishlist
                    self.reloadTableViewContent()
                }
            }
        }
        
        
    }
    
    func reloadTableViewContent() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.profileTable.reloadData()
        })
        topCell = (profileTable.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! profileCell)
        profileCellHeight = topCell?.frame.height
    }
    func reloadAPI(cell: myReviewsCell) {
        self.profileTable.reloadData()
    }
    
    func configureTableView() {
        profileTable.estimatedRowHeight = 300
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
            if self.userReviews == nil {
                return 0
            }
            return self.userReviews!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 0:
            return profileCellAtIndexPath(indexPath)
        default:
            return reviewCellAtIndexPath(indexPath)
        }
    }
    
    
    func profileCellAtIndexPath(indexPath:NSIndexPath) -> profileCell {
        let cell = self.profileTable.dequeueReusableCellWithIdentifier("profileCell") as! profileCell
        if (userData != nil && myFavoritesData != nil && myWishlistData != nil) {
        setImageForProfile(cell, indexPath: indexPath)
        generateLabel()
        let review = userReviewsWrapper!
        cell.userName.text = userData!["username"].stringValue
        cell.bio.text = userData!["bio"].stringValue
        cell.hardware.text = userData!["hardware"].stringValue
            if let reviewCount = review.count {
                let reviewString = String(stringInterpolationSegment: reviewCount)
                cell.reviewsCount.text = reviewString
            }
        cell.favoritesCount.text = myFavoritesData!["total"].stringValue
        cell.wishCount.text = myWishlistData!["total"].stringValue
        }
        cell.preservesSuperviewLayoutMargins = false
        return cell
    }
    func generateLabel() {
        userNameLabel = UILabel(frame: CGRectMake(0, 0, 60, 20))
        userNameLabel!.text = userData!["username"].stringValue
        userNameLabel!.textColor = UIColor.whiteColor()
        userNameLabel!.font = UIFont(name: "PTSans-Bold", size: 17)
    }
    
    func reviewCellAtIndexPath(indexPath:NSIndexPath) -> myReviewsCell {
        let cell = self.profileTable.dequeueReusableCellWithIdentifier("myReviews") as! myReviewsCell
        if self.userReviews != nil && self.userReviews!.count >= indexPath.row {
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
        if let imageString = userData!["image"].stringValue as String?{
            let url = NSURL(string: imageString)
            cell.userImage.hnk_setImageFromURL(url!)
        }
    }
    
    func setImageForReview(cell:myReviewsCell, indexPath:NSIndexPath) {
        let review = userReviews![indexPath.row]
        if let imageString = review.product?.image {
            let url = NSURL(string: imageString)
            //cell.productImage.hnk_setImageFromURL(url!)
        }
    }
    func setReviewForCell(cell:myReviewsCell, indexPath:NSIndexPath) {
        let review = userReviews![indexPath.row]
        cell.state = review.currentHelpful
        cell.productID = review.productID
        cell.reviewID = review.reviewID
        cell.productName.text = review.product?.name
        cell.productReview.text = review.description
        cell.brandName.text = review.brand?.name 
        if let rating = review.score {
            let number = (rating as NSString).floatValue
            cell.floatRatingView.rating = number
            cell.floatRatingView.userInteractionEnabled = false
        }
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
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier! {
        case "anyUserToFavorites":
            var favoritesVC: newFavoritesViewController = segue.destinationViewController as! newFavoritesViewController
            favoritesVC.userID = selectedUserID!
        case "anyUserToFlavor":
            var productVC: brandFlavorViewController = segue.destinationViewController as! brandFlavorViewController
            productVC.selectedProductID = selectedProductID
        case "anyUserToWishlist":
            let wishVC: wishListViewControler = segue.destinationViewController as! wishListViewControler
            wishVC.userID = selectedUserID
        default:
            println("no segue")
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let cellOffset = profileTable.contentOffset.y
        let alpha = 200 - cellOffset
        let percent = alpha/100
        if (percent > 0) {
            topCell?.contentView.alpha = percent
        }
        if (percent <= 0.1 || cellOffset >= 186) {
            navBackground.alpha = 1
        }else {
            navBackground.alpha = 0
        }
        if (cellOffset >= 74) {
            self.navigationItem.titleView = userNameLabel
            topCell?.userName.hidden = true
        }else {
            self.navigationItem.titleView = UILabel(frame: CGRectMake(0, 0, 0, 0))
            topCell?.userName.hidden = false
        }
    }
    func loadFirstReviews() {
        self.userReviews = []
        isLoadingReviews = true
        ActivityFeedReviews.getUserReviews(selectedUserID!, completionHandler: { (activityWrapper, error) in
            if error != nil {
                self.isLoadingReviews = false
                var alert = UIAlertController(title: "Error", message: "could not load first activity", preferredStyle: UIAlertControllerStyle.Alert)
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
            ActivityFeedReviews.getMoreUserReviews(selectedUserID!, wrapper: self.userReviewsWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingReviews = false
                    var alert = UIAlertController(title: "Error", message: "Could not load more activity", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                println("got More")
                self.addReviewFromWrapper(moreWrapper)
                self.isLoadingReviews = false
                self.profileTable.reloadData()
            })
        }
    }
    
    func addReviewFromWrapper(wrapper: ActivityWrapper?) {
        self.userReviewsWrapper = wrapper
        if self.userReviews == nil {
            self.userReviews = self.userReviewsWrapper?.ActivityReviews
        }else if self.userReviewsWrapper != nil && self.userReviewsWrapper!.ActivityReviews != nil{
            self.userReviews = self.userReviews! + self.userReviewsWrapper!.ActivityReviews!
        }
    }

    
    

}
