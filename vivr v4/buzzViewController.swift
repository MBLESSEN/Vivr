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
    var selectedUserID:String = ""
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
    @IBOutlet weak var loadMoreView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        loadFeed()
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
        loadFeed()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier {
        case "buzzToComments":
            var reviewVC: commentsViewController = segue.destinationViewController as commentsViewController
            reviewVC.reviewID = self.reviewID
            reviewVC.productID = self.productID
        case "buzzToProduct":
            var productVC: brandFlavorViewController = segue.destinationViewController as brandFlavorViewController
            productVC.selectedProductID = self.productID
        case "toUserSegue":
            var userVC: anyUserProfileView = segue.destinationViewController as anyUserProfileView
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
            let headerCell = mainTable.dequeueReusableCellWithIdentifier("vivrHeaderCell") as vivrHeaderCell
            topHeaderCell = headerCell
            headerCell.productID = self.feedReviewResults![section]["product"]["id"].stringValue
            headerCell.cellDelegate = self
            headerCell.layer.zPosition = headerCell.layer.zPosition-1
            return headerCell
        }
        return nil
    }
    
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }
    
    
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
                var newcell = mainTable.dequeueReusableCellWithIdentifier("newCell") as newCell
                newcell.contentView.addSubview(noNewProductsView)
                noNewProductsView.layer.zPosition = noNewProductsView.layer.zPosition + 1
                return newcell
            case "vivrCell":
                var vivrcell = mainTable.dequeueReusableCellWithIdentifier(cellIdentifier) as vivrCell
                vivrcell.review = self.feedReviewResults![indexPath.section]
                vivrcell.reviewID = self.feedReviewResults![indexPath.section]["id"].stringValue
                if let state = self.feedReviewResults![indexPath.section]["current_helpful"].boolValue as Bool?{
                    vivrcell.helpfullState = state
                }
                vivrcell.wishlistState = true 
                vivrcell.cellDelegate = self
                vivrcell.layer.zPosition = vivrcell.layer.zPosition
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
                var newcell = mainTable.dequeueReusableCellWithIdentifier(cellIdentifier) as newCell
                newcell.contentView.addSubview(noNewProductsView)
                noNewProductsView.layer.zPosition = noNewProductsView.layer.zPosition + 1
                return newcell
            
        }
    }

    
    
    func loadFeed() {
        Alamofire.request(Router.readFeed()).responseJSON { (request, response, json, error) in
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
        /*
        let cells = mainTable.visibleCells()
        let vivrHelpButton = cells[0] as vivrCell
        let vivrCellHelpButtonOrigin = vivrHelpButton.helpfull!.frame.origin.y
        let adjustedCellOriginY = Float(vivrCellHelpButtonOrigin)
        let finalY = CGPointMake(8, CGFloat(adjustedCellOriginY))
        let convertedY = vivrHelpButton.helpfull!.convertPoint(vivrHelpButton.helpfull!.center, toView: nil).y
        let adjustedY = Float(convertedY)
        topHeaderCell?.helpfullButton.center = CGPointMake(8, CGFloat(adjustedY))
        println("VivrCell Y \(adjustedY)")
        println("headerButton is at position to header \(topHeaderCell?.helpfullButton.frame.origin.y)")
        //println(topHeaderCell?.helpfullButton.frame.origin)
        */
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
