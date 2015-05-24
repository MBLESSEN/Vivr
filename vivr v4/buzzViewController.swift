//
//  buzzViewController.swift
//  vivr v4
//
//  Created by max blessen on 12/21/14.
//  Copyright (c) 2014 max blessen. All rights reserved.
//

import UIKit
import Alamofire


class buzzViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, VivrCellDelegate, VivrHeaderCellDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var loadMore: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var mainTable: UITableView!
    @IBOutlet weak var controller: UISegmentedControl!
    var selectedUserID:String?
    var productID:String = ""
    var reviewID:String = ""
    var segueIdentifier: String = ""
    var cellIdentifier: String = "vivrCell"
    var whatsHot:[JSON]? = []
    var feedReviewResults:[JSON]? = []
    var feedProductResults:[JSON]? = []
    var feedUserResults:[JSON]? = []
    var selectedReview: String = ""
    var refreshControl: UIRefreshControl!
    let screenSize = UIScreen.mainScreen().bounds
    var topHeaderCell:vivrHeaderCell?
    var currentPage:Int = 1
    var helpfulCount:Int?
    var feedReviews:Array<ActivityFeedReviews>?
    var activityWrapper:ActivityWrapper?
    var isLoadingFeed = false
    
    @IBOutlet weak var loadMoreView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureTableView()
    }
    
    func configureTableView() {
        mainTable.contentInset = UIEdgeInsetsZero
        self.automaticallyAdjustsScrollViewInsets = false
        mainTable.estimatedRowHeight = 200.0
        mainTable.rowHeight = UITableViewAutomaticDimension
        refreshControl = UIRefreshControl()
        refreshControl.alpha = 1
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "reload", forControlEvents:UIControlEvents.ValueChanged)
        mainTable.addSubview(refreshControl)
        
        self.refreshControl.layer.zPosition = mainTable.layer.zPosition-1

        
    }

    
    func configureNavBar() {
        var logo = UIImage(named: "logoWhiteBorder")?.imageWithRenderingMode(.AlwaysOriginal)
        var imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        loadFirstActivity()
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController?.navigationBar.tintColor = UIColor(red: 43.0/255, green: 169.0/255, blue: 41.0/255, alpha: 1.0)
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeData(sender: AnyObject) {
        switch controller.selectedSegmentIndex{
        case 0:
            cellIdentifier = "featuredCell"
            mainTable.rowHeight = 200
            loadMoreView.hidden = true
            mainTable.reloadData()
        case 1:
            cellIdentifier = "vivrCell"
            mainTable.rowHeight = UITableViewAutomaticDimension
            loadMore.enabled = true
            loadMore.hidden = false
            loadMoreView.hidden = false
            mainTable.scrollEnabled = true 
            mainTable.reloadData()
        case 2:
            cellIdentifier = "newCell"
            loadMore.enabled = false
            loadMore.hidden = true
            loadMoreView.hidden = true
            mainTable.scrollEnabled = false
            mainTable.reloadData()
        default:
            println("no segment")
            
        }
 
    }
    
    func reload(){
        loadFeed()
        println("refreshing")
        refreshControl.endRefreshing()
    }
    
    func tappedUserButton(cell: vivrCell) {
        self.segueIdentifier = "toUserSegue"
        selectedUserID = cell.userID!
        performSegueWithIdentifier(segueIdentifier, sender: cell)
    }
    
    func tappedUser(cell: vivrHeaderCell) {
        self.segueIdentifier = "toUserSegue"
        selectedUserID = cell.userID
        performSegueWithIdentifier(segueIdentifier, sender: cell)
    }
    
    func tappedCommentButton(cell: vivrCell) {
        self.segueIdentifier = "buzzToComments"
        reviewID = cell.reviewID
        productID = cell.productID
        performSegueWithIdentifier(segueIdentifier, sender: cell)
        
    }
    
    func tappedProductButton(cell: vivrHeaderCell) {
        self.segueIdentifier = "buzzToProduct"
        productID = cell.productID!
        performSegueWithIdentifier(segueIdentifier, sender: cell)
    }
    
    func reloadAPI(cell: vivrCell) {
        if let section = cell.cellID as Int? {
            println(section)
            let indexPath = NSIndexPath(forRow: 0, inSection: section)
        mainTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    func helpfulFalse(cell: vivrCell) {
        if let reviewID = cell.cellID as Int? {
            feedReviews![reviewID].currentHelpful = false
            feedReviews![reviewID].helpfulCount = feedReviews![reviewID].helpfulCount! - 1
        }
    }
    
    func helpfulTrue(cell: vivrCell) {
        if let reviewID = cell.cellID as Int? {
            feedReviews![reviewID].currentHelpful = true
            feedReviews![reviewID].helpfulCount = feedReviews![reviewID].helpfulCount! + 1
        }
    }
    
    func wishlistFalse(cell: vivrCell) {
        if let reviewID = cell.cellID as Int? {
            feedReviews![reviewID].product?.currentWishlist = false
        }
    }
    func wishlistTrue(cell: vivrCell) {
        if let reviewID = cell.cellID as Int? {
            feedReviews![reviewID].product?.currentWishlist = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier {
        case "buzzToComments":
            var reviewVC: commentsViewController = segue.destinationViewController as! commentsViewController
            reviewVC.reviewID = self.reviewID
            reviewVC.productID = self.productID
        case "buzzToProduct":
            var productVC: brandFlavorViewController = segue.destinationViewController as! brandFlavorViewController
            productVC.selectedProductID = self.productID
        case "toUserSegue":
            var userVC: anyUserProfileView = segue.destinationViewController as! anyUserProfileView
            userVC.selectedUserID = self.selectedUserID
            //userVC.automaticallyAdjustsScrollViewInsets = false
        default:
            println("noSegue")
            
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (cellIdentifier == "vivrCell") {
            println(screenSize.width)
            if (screenSize.width < 370) {
                return 180
            }else{
                return 220
            }
        }else {
            return 0.0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (cellIdentifier == "vivrCell") {
            let headerCell = mainTable.dequeueReusableCellWithIdentifier("vivrHeaderCell") as! vivrHeaderCell
            topHeaderCell = headerCell
            headerCell.productID = self.feedReviews![section].productID
            headerCell.cellDelegate = self
            headerCell.layer.zPosition = headerCell.layer.zPosition - 1
            headerCell.contentView.layer.zPosition = headerCell.contentView.layer.zPosition - 1
            headerCell.contentView.userInteractionEnabled = false 
            return headerCell.contentView
        }
        return nil
    }
    
    /*
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch cellIdentifier {
            case "vivrCell":
                return self.feedReviewResults?.count ?? 0
            case "newCell":
                return 1
        default:
            return 1
            
        }
    }
*/
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch cellIdentifier {
            case "vivrCell":
                if self.feedReviews == nil {
                    return 0
            }
            return self.feedReviews!.count
            case "newCell":
                return 1
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch cellIdentifier {
            case "featuredCell":
                let noNewProductsView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                noNewProductsView.backgroundColor = UIColor.groupTableViewBackgroundColor()
                let checkBackLabel = UILabel(frame: CGRectMake(0, 0, 200, 80.0))
                checkBackLabel.numberOfLines = 3
                checkBackLabel.textAlignment = NSTextAlignment.Center
                checkBackLabel.center = CGPointMake(self.view.center.x, self.view.center.y-100)
                checkBackLabel.textColor = UIColor.lightGrayColor()
                checkBackLabel.text = "Check back for featured products and updates from vivr headquarters"
                noNewProductsView.addSubview(checkBackLabel)
                var newcell = mainTable.dequeueReusableCellWithIdentifier("newCell") as! newCell
                newcell.contentView.addSubview(noNewProductsView)
                noNewProductsView.layer.zPosition = noNewProductsView.layer.zPosition + 1
                return newcell
            case "vivrCell":
                return vivrCellAtIndexPath(indexPath)
            
        default:
            let noNewProductsView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
            noNewProductsView.backgroundColor = UIColor.groupTableViewBackgroundColor()
            let checkBackLabel = UILabel(frame: CGRectMake(0, 0, 200, 80.0))
            checkBackLabel.numberOfLines = 3
            checkBackLabel.textAlignment = NSTextAlignment.Center
            checkBackLabel.center = CGPointMake(self.view.center.x, self.view.center.y-100)
            checkBackLabel.textColor = UIColor.lightGrayColor()
            checkBackLabel.text = "Check back for new products!"
            noNewProductsView.addSubview(checkBackLabel)
            var newcell = mainTable.dequeueReusableCellWithIdentifier(cellIdentifier) as! newCell
            newcell.contentView.addSubview(noNewProductsView)
            noNewProductsView.layer.zPosition = noNewProductsView.layer.zPosition + 1
            return newcell
            
        }
    }

    func vivrCellAtIndexPath(indexPath:NSIndexPath) -> vivrCell {
        let vivrcell = mainTable.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! vivrCell
        if self.feedReviews != nil && self.feedReviews!.count >= indexPath.section {
            if let section = indexPath.section as Int? {
                vivrcell.cellID = section
            }
        let review = self.feedReviews![indexPath.section]
            vivrcell.userID = review.userID
            vivrcell.productID = review.productID!
            vivrcell.reviewID = review.reviewID!
            if let date = review.createdAt {
                let dateFor:NSDateFormatter = NSDateFormatter()
                dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let theDate:NSDate = dateFor.dateFromString(date)!
                let tempoDate = Tempo(date: theDate)
                let timeStamp = tempoDate.timeAgoNow()
                if let reviewString = review.description {
                    var review = NSMutableAttributedString(string: reviewString + "  -  ")
                    let x = NSAttributedString(string: timeStamp, attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
                    review.appendAttributedString(x)
                    vivrcell.reviewDescription.attributedText = review
                    vivrcell.reviewDescription.sizeToFit()
                    
                }
            }
            vivrcell.userName.text = review.user?.userName
            vivrcell.flavorName.text = review.product?.name
            vivrcell.flavorName.sizeToFit()
            if let rating = review.score {
                let number = (rating as NSString).floatValue
                vivrcell.floatRatingView.rating = number
                vivrcell.floatRatingView.userInteractionEnabled = false
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
                vivrcell.throat.text = ("\(value!) throat hit")
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
                vivrcell.vapor.text = ("\(value!) vapor production")
            }
            vivrcell.helpfullState = review.currentHelpful
            vivrcell.wishlistState = review.product?.currentWishlist
            if let helpfullCount = review.helpfulCount {
                helpfulCount = helpfullCount
                switch helpfulCount! {
                case 0:
                    vivrcell.helpfullLabel.text = "Was this helpful?"
                default:
                    vivrcell.helpfullLabel.text = "\(helpfulCount!) found this helpful"
                }
            }
            if let productID = review.productID {
                if let reviewID = review.reviewID {
                    Alamofire.request(Router.readCommentsAPI(productID, reviewID)).responseJSON { (request, response, json, error) in
                        if (json != nil) {
                            var jsonOBJ = JSON(json!)
                            if let commentsCount = jsonOBJ["total"].stringValue as String? {
                                vivrcell.commentButton.setTitle("\(commentsCount) comments", forState: .Normal)
                            }
                        }
                    }
                    
                }
            }
            vivrcell.cellDelegate = self
            
            let rowsToLoadFromBottom = 5
            let rowsLoaded = self.feedReviews!.count
            if (!self.isLoadingFeed && (indexPath.section >= (rowsLoaded - rowsToLoadFromBottom))) {
                let totalRows = self.activityWrapper!.count!
                let remainingFeedToLoad = totalRows - rowsLoaded
                if (remainingFeedToLoad > 0) {
                    self.loadMoreActivity()
                }
            }
            
            
        }
        return vivrcell
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }
        /*
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch cellIdentifier{
            case "featuredCell":
                let noNewProductsView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                noNewProductsView.backgroundColor = UIColor.groupTableViewBackgroundColor()
                let checkBackLabel = UILabel(frame: CGRectMake(0, 0, 200, 80.0))
                checkBackLabel.numberOfLines = 3
                checkBackLabel.textAlignment = NSTextAlignment.Center
                checkBackLabel.center = CGPointMake(self.view.center.x, self.view.center.y-100)
                checkBackLabel.textColor = UIColor.lightGrayColor()
                checkBackLabel.text = "Check back for featured products and updates from vivr headquarters"
                noNewProductsView.addSubview(checkBackLabel)
                var newcell = mainTable.dequeueReusableCellWithIdentifier("newCell") as! newCell
                newcell.contentView.addSubview(noNewProductsView)
                noNewProductsView.layer.zPosition = noNewProductsView.layer.zPosition + 1
                return newcell
            case "vivrCell":
                var vivrcell = mainTable.dequeueReusableCellWithIdentifier(cellIdentifier) as! vivrCell
                vivrcell.review = self.feedReviewResults![indexPath.section]
                vivrcell.reviewID = self.feedReviewResults![indexPath.section]["id"].stringValue
                if let state = self.feedReviewResults![indexPath.section]["current_helpful"].boolValue as Bool?{
                    vivrcell.helpfullState = state
                }
                if let wstate = self.feedReviewResults![indexPath.section]["product"]["current_wishlist"].boolValue as Bool? {
                    vivrcell.wishlistState = wstate
                }
                vivrcell.cellDelegate = self
                vivrcell.layer.zPosition = vivrcell.layer.zPosition
                //vivrcell.preservesSuperviewLayoutMargins = false
                return vivrcell
            default:
                let noNewProductsView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                noNewProductsView.backgroundColor = UIColor.groupTableViewBackgroundColor()
                let checkBackLabel = UILabel(frame: CGRectMake(0, 0, 200, 80.0))
                checkBackLabel.numberOfLines = 3
                checkBackLabel.textAlignment = NSTextAlignment.Center
                checkBackLabel.center = CGPointMake(self.view.center.x, self.view.center.y-100)
                checkBackLabel.textColor = UIColor.lightGrayColor()
                checkBackLabel.text = "Check back for new products!"
                noNewProductsView.addSubview(checkBackLabel)
                var newcell = mainTable.dequeueReusableCellWithIdentifier(cellIdentifier) as! newCell
                newcell.contentView.addSubview(noNewProductsView)
                noNewProductsView.layer.zPosition = noNewProductsView.layer.zPosition + 1
                return newcell
            
        }
    }
*/
    
    func loadFirstActivity() {
        self.feedReviews = []
        isLoadingFeed = true
        ActivityFeedReviews.getReviews({ (activityWrapper, error) in
            if error != nil {
                self.isLoadingFeed = false
                var alert = UIAlertController(title: "Error", message: "could not load first activity", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.addReviewFromWrapper(activityWrapper)
            self.isLoadingFeed = false
            self.mainTable.reloadData()
            })
    }
    
    func loadMoreActivity() {
        isLoadingFeed = true
        if self.feedReviews != nil && self.activityWrapper != nil && self.feedReviews!.count < self.activityWrapper!.count
        {
            ActivityFeedReviews.getMoreReviews(self.activityWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingFeed = false
                    var alert = UIAlertController(title: "Error", message: "Could not load more activity", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                println("got More")
                self.addReviewFromWrapper(moreWrapper)
                self.isLoadingFeed = false
                self.mainTable.reloadData()
            })
        }
    }
    
    func addReviewFromWrapper(wrapper: ActivityWrapper?) {
        self.activityWrapper = wrapper
        if self.feedReviews == nil {
            self.feedReviews = self.activityWrapper?.ActivityReviews
        }else if self.activityWrapper != nil && self.activityWrapper!.ActivityReviews != nil{
            self.feedReviews = self.feedReviews! + self.activityWrapper!.ActivityReviews!
        }
    }
    
    func loadFeed() {
        Alamofire.request(Router.readFeed(currentPage)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let reviewData = jsonOBJ["data"].arrayValue as [JSON]? {
                    self.feedReviewResults = reviewData
                }
                if let productData = jsonOBJ["products"].arrayValue as [JSON]? {
                    self.feedProductResults = productData
                }
                if let userData = jsonOBJ["users"].arrayValue as [JSON]? {
                    self.feedUserResults = userData
                }
                self.mainTable.reloadData()
            }
        }
    }
    
    @IBAction func loadMore(sender: AnyObject) {
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
