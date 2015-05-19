//
//  userTableViewController.swift
//  vivr v4
//
//  Created by max blessen on 2/21/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//
import UIKit
import Alamofire

class userViewController: UIViewController, reviewCellDelegate, UIScrollViewDelegate, UITableViewDelegate{
    var myFavorites:[JSON]? = []
    var myFavoritesData:JSON?
    var myReviews:[JSON]? = []
    var myReviewsData:JSON?
    var myWishlist:[JSON]? = []
    var myWishlistData:JSON?
    var userData:JSON?
    var selectedUserID:String?
    var selectedProductID:String?
    var segueIdentifier:String?
    var reviewID:String?
    var topCell:profileCell?
    var userNameLabel:UILabel?

    
    @IBOutlet weak var navBackground: UIView!
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var profileTable:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
        configureTableView()
        if let z = profileTable.layer.zPosition as CGFloat?{
            navBackground.layer.zPosition = z + 2
        }
    }
    override func viewWillAppear(animated: Bool) {
        addMenu()
        configureNavigation()
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
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    @IBAction func favoritesTapped(sender: AnyObject) {
        self.segueIdentifier = "myUserToFavorites"
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    func tappedProductbutton(cell: myReviewsCell) {
        self.segueIdentifier = "myUserToFlavor"
        self.selectedProductID = cell.productID
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    func tappedCommentButton(cell: myReviewsCell) {
        self.segueIdentifier = "myUserToComments"
        self.selectedProductID = cell.productID
        self.reviewID = cell.reviewID
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    
    func refreshData() {
        Alamofire.request(Router.readUser(myData.myProfileID)).responseJSON { (request, response, json, error) in
            if let anError = error {
                //println(anError)
            }
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let data = jsonOBJ as JSON? {
                    self.userData = data
                   
                }
                self.reloadTableViewContent()
            }
        }
        Alamofire.request(Router.readUserReviews(myData.myProfileID)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let reviewData = jsonOBJ as JSON? {
                    self.myReviewsData = reviewData
                }
                if let reviews = jsonOBJ["data"].arrayValue as [JSON]? {
                    self.myReviews = reviews
                    
                }
                self.reloadTableViewContent()
                
            }
        }
        Alamofire.request(Router.readUserFavorites(myData.myProfileID)).responseJSON { (request, response, json, error) in
            if (json != nil) {
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
        Alamofire.request(Router.readWishlist(myData.myProfileID)).responseJSON { (request, response, json, error) in
            if (json != nil) {
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
        Alamofire.request(Router.readUserReviews(myData.myProfileID)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let reviewData = jsonOBJ as JSON? {
                    self.myReviewsData = reviewData
                    self.reloadTableViewContent()
                }
                if let reviews = jsonOBJ["data"].arrayValue as [JSON]? {
                    self.myReviews = reviews
                    self.reloadTableViewContent()
                }
                
            }
        }
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
            return self.myReviews?.count ?? 0
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
        let cell = self.profileTable.dequeueReusableCellWithIdentifier("profileCell") as profileCell
        if (userData != nil && myReviewsData != nil && myFavoritesData != nil && myWishlistData != nil) {
            setImageForProfile(cell, indexPath: indexPath)
            cell.userName.text = userData!["username"].stringValue
            self.userNameLabel = UILabel(frame: CGRectMake(0, 0, 60, 20))
            self.userNameLabel!.text = userData!["username"].stringValue
            userNameLabel?.textColor = UIColor.whiteColor()
            userNameLabel?.font = UIFont(name: "PTSans-Bold", size: 17)
            cell.bio.text = userData!["bio"].stringValue
            cell.hardware.text = userData!["hardware"].stringValue
            cell.reviewsCount.text = myReviewsData!["total"].stringValue
            cell.favoritesCount.text = myFavoritesData!["total"].stringValue
            cell.wishCount.text = myWishlistData!["total"].stringValue
        }
        return cell
    }
    
    func reviewCellAtIndexPath(indexPath:NSIndexPath) -> myReviewsCell {
        let cell = self.profileTable.dequeueReusableCellWithIdentifier("myReviews") as myReviewsCell
        if (myReviews != nil) {
            setImageForReview(cell, indexPath: indexPath)
            setReviewForCell(cell, indexPath: indexPath)
        }
        cell.cellDelegate = self
        return cell
    }
    
    func setImageForProfile(cell:profileCell, indexPath:NSIndexPath) {
        if let imageString = userData!["image"].stringValue as String?{
            let url = NSURL(string: imageString)
            cell.userImage.hnk_setImageFromURL(url!)
        }
    }
    
    func setImageForReview(cell:myReviewsCell, indexPath:NSIndexPath) {
        if let imageString = myReviews![indexPath.row]["image"].stringValue as String? {
            //let url = NSURL(string: imageString)
            //cell.productImage.hnk_setImageFromURL(url!)
        }
    }
    func setReviewForCell(cell:myReviewsCell, indexPath:NSIndexPath) {
        let reviewIndex = myReviews![indexPath.row]
        cell.state = reviewIndex["current_helpful"].bool
        cell.productID = reviewIndex["product"]["id"].stringValue
        cell.reviewID = reviewIndex["id"].stringValue
        cell.productName.text = reviewIndex["product"]["name"].stringValue
        cell.productReview.text = reviewIndex["description"].stringValue
        cell.brandName.text = reviewIndex["product"]["brand"]["name"].string
        if let rating = reviewIndex["score"].stringValue as String?{
            let number = (rating as NSString).floatValue
            cell.floatRatingView.rating = number
            cell.floatRatingView.userInteractionEnabled = false
        }
        if let throatHit = reviewIndex["throat"].int {
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
        if let vaporProduction = reviewIndex["vapor"].int {
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
        if let helpfullCount = reviewIndex["helpful_count"].stringValue as String? {
            switch helpfullCount {
            case "0":
                cell.helpfullLabel.text = "Was this helpful?"
            default:
                cell.helpfullLabel.text = "\(helpfullCount) people found this helpful"
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier! {
        case "myUserToFavorites":
            var favoritesVC: newFavoritesViewController = segue.destinationViewController as newFavoritesViewController
            favoritesVC.userID = myData.myProfileID
        case "myUserToFlavor":
            var productVC: brandFlavorViewController = segue.destinationViewController as brandFlavorViewController
            productVC.selectedProductID = selectedProductID
        case "userToWishlist":
            let wishVC: wishListViewControler = segue.destinationViewController as wishListViewControler
            wishVC.userID = myData.myProfileID
        default:
            println("no segue")
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let cellOffset = profileTable.contentOffset.y
        println(cellOffset)
        let alpha = 124-cellOffset
        let percent = alpha/100
        if (percent > 0) {
            topCell?.contentView.alpha = percent
        }
        if (percent <= 0.1 || cellOffset >= 180) {
                navBackground.alpha = 1
            }else {
                navBackground.alpha = 0
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

    
    
