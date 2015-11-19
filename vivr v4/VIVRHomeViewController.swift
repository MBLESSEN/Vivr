//
//  buzzViewController.swift
//  vivr v4
//
//  Created by max blessen on 12/21/14.
//  Copyright (c) 2014 max blessen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Haneke


class VIVRHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, VivrCellDelegate, VivrHeaderCellDelegate, UIScrollViewDelegate, flavorTagsDelegate, UISearchBarDelegate, searchDelegate, BWWalkthroughViewControllerDelegate, SWRevealViewControllerDelegate, UIGestureRecognizerDelegate, NSXMLParserDelegate {
    
    @IBOutlet weak var searchTopConstraint: NSLayoutConstraint!

    var menuCopy: UIBarButtonItem = UIBarButtonItem()
    @IBOutlet weak var mainTable: UITableView!
    @IBOutlet weak var controller: UISegmentedControl!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var searchViewBackgroundHeight: NSLayoutConstraint!
    @IBOutlet weak var searchViewBackground: UIView!
    @IBOutlet weak var mainTableWrapper: UIView!
    @IBOutlet weak var tagViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagView: UIView!

    @IBOutlet weak var searchButton: UIBarButtonItem!
    var filterButton: UIBarButtonItem = UIBarButtonItem()
    //top nav bar
    @IBOutlet weak var featuredLabel: UILabel!
    @IBOutlet weak var juicesLabel: UILabel!
    @IBOutlet weak var newLabel: UILabel!
    
    
    @IBOutlet weak var selectionIndicatorLeading: NSLayoutConstraint!
    @IBOutlet weak var featuredBottom: NSLayoutConstraint!
    @IBOutlet weak var juicesBottom: NSLayoutConstraint!
    @IBOutlet weak var newBottom: NSLayoutConstraint!
    
    //delegates
    var viewDelegate:searchDelegate?
    
    //xml parser
    var parser = NSXMLParser()
    var element = NSString()
    var elements = NSMutableDictionary()
    var featuredTitleText = NSMutableString()
    var featuredDateText = NSMutableString()
    var featuredDescriptionText = NSMutableString()
    var featuredImage = UIImage()
    var featuredProductID:NSMutableArray = []
    var posts: Array<BlogPost> = []
    var blogPost = BlogPost()
    
    //data variables
    var selectedBrandImage:String? 
    var selectedUserID:String?
    var selectedBrandID:String?
    var productID:String?
    var reviewID:String = ""
    var filterTagsString:String?
    var segueIdentifier: String = ""
    var cellIdentifier: String = "vivrCell"
    var selectedReview: String = ""
    let screenSize = UIScreen.mainScreen().bounds
    var currentPage:Int = 1
    var helpfulCount:Int?
    
    //data object Arrays
    var whatsHot:[SwiftyJSON.JSON]? = []
    var feedReviewResults:[SwiftyJSON.JSON]? = []
    var feedProductResults:[SwiftyJSON.JSON]? = []
    var feedUserResults:[SwiftyJSON.JSON]? = []
    var filterTags:NSMutableArray = []
    
    //data objects
    var feedReviews:Array<ActivityFeedReviews>?
    var activityWrapper:ActivityWrapper?
    var topHeaderCell:vivrHeaderCell?
    var tags: addFlavorTagsView?
    var searchView: searchViewController?
    var pressDownCell:vivrCell?
    var selectedFeedReview:ActivityFeedReviews?
    
    //local view/object initializers
    var activeWishlistContainer: UIView?
    var loadingView = UIView()
    var loadingText: UILabel! = UILabel()
    var refreshControl: UIRefreshControl!
    lazy   var search:UISearchBar = UISearchBar()
    lazy var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var refreshText: UILabel = UILabel()
    var loadButton: UIButton = UIButton()
    
    //Bool markers
    var searchActive = false {
        didSet {
            if searchActive == true {
                filterButton.customView?.hidden = true
            }else {
                filterButton.customView?.hidden = false
            }
        }
    }
    var filterActive = false
    var tagViewIsActive = false
    var loadingViewActive = false
    var isLoadingFeed = false {
        didSet {
            if isLoadingFeed == true {
                showLoadingScreen()
            }
            if isLoadingFeed == false {
                removeLoadingScreen()
            }
        }
    }
    var keyboardActive = false
    
    
    // override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // 2
        let filterImage = UIImage(named: "filter")?.imageWithRenderingMode(.AlwaysTemplate)
        let button   = UIButton(type: UIButtonType.System)
        button.frame = CGRectMake(0, 0, 22, 22)
        button.setImage(filterImage, forState: .Normal)
        button.addTarget(self, action: "filterFeed:", forControlEvents: UIControlEvents.TouchUpInside)
        filterButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "filterFeed:")
        filterButton.customView = button
        
        // 3
        self.navigationItem.setRightBarButtonItems([searchButton,filterButton], animated: true )
        configureNavBar()
        configureTableView()
        loadTagsView()
        instantiateSearchView()
        addRefreshControl()
        startObservingKeyboardEvents()
        prepareToLoadData()
        createLoadingScreen()
        checkIfSessionIsFirst()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController?.navigationBar.tintColor = UIColor(red: 43.0/255, green: 169.0/255, blue: 41.0/255, alpha: 1.0)
        tabBarController?.tabBar.hidden = false
        let leading = UIScreen.mainScreen().bounds.width/3
        selectionIndicatorLeading.constant = leading * CGFloat(controller.selectedSegmentIndex)
        self.view.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkIfSessionIsFirst() {
        
    }
    
    //PARSING FUNCTIONS
    func beginParsing() {
        posts = []
        parser = NSXMLParser(contentsOfURL:(NSURL(string:"http://images.apple.com/main/rss/hotnews/hotnews.rss"))!)!
        parser.delegate = self
        parser.parse()
        mainTable.reloadData()
    }
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        element = elementName
        if (elementName as NSString).isEqualToString("item")
        {
            elements = NSMutableDictionary()
            elements = [:]
            featuredTitleText = NSMutableString()
            featuredTitleText = ""
            featuredDateText = NSMutableString()
            featuredDateText = ""
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if (elementName as NSString).isEqualToString("item") {
            if !featuredTitleText.isEqual(nil) {
                blogPost.title = featuredTitleText as String
            }
            if !featuredDateText.isEqual(nil) {
                blogPost.createdAt = featuredDateText as String
            }
            
            posts.append(blogPost)
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        if element.isEqualToString("title") {
            featuredTitleText.appendString(string)
        } else if element.isEqualToString("pubDate") {
            featuredDateText.appendString(string)
        }
    }
    
    //INSTANTIATE CHILD VIEW CONTROLLERS
    
    func instantiateSearchView() {
        self.search.delegate = self
        let textField = search.valueForKey("searchField") as! UITextField
        textField.backgroundColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 1.0)
        textField.textColor = UIColor.whiteColor()
        let attributedString = NSAttributedString(string: "Find your juice", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        textField.attributedPlaceholder = attributedString
        let iconView:UIImageView = textField.leftView as! UIImageView
        //Make the icon to a template which you can edit
        iconView.image = iconView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        //Set the color of the icon
        iconView.tintColor = UIColor.whiteColor()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        searchView = storyboard.instantiateViewControllerWithIdentifier("searchTable") as? searchViewController
        searchView!.viewDelegate = self
        searchViewBackground.clipsToBounds = true
    }
    
    func createLoadingScreen() {
        loadingView.frame = CGRectMake(0, 110, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-110)
        loadingView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        loadingText = UILabel(frame: CGRectMake(0, 0, 200, 80))
        loadingText.numberOfLines = 2
        loadingText.textAlignment = NSTextAlignment.Center
        loadingText.center = CGPointMake(self.view.center.x, self.view.center.y - 100)
        loadingText.textColor = UIColor.lightGrayColor()
        loadingText.text = "Loading juices"
        loadingView.addSubview(loadingText)
        activityIndicator.color = UIColor.lightGrayColor()
        activityIndicator.startAnimating()
        activityIndicator.frame = CGRectMake(0, 0, 50, 50)
        activityIndicator.center = self.view.center
        loadingView.addSubview(activityIndicator)
        refreshText = UILabel(frame: CGRectMake(0, 0, 200, 80))
        refreshText.numberOfLines = 2
        refreshText.textAlignment = NSTextAlignment.Center
        refreshText.center = CGPointMake(self.view.center.x, self.view.center.y + 33)
        refreshText.textColor = UIColor.lightGrayColor()
        refreshText.text = "Try again"
        refreshText.hidden = true
        loadingView.addSubview(refreshText)
        loadButton = UIButton(frame: CGRectMake(0, 0, 100, 100))
        let image = UIImage(named: "refresh")?.imageWithRenderingMode(.AlwaysTemplate)
        loadButton.setImage(image, forState: .Normal)
        loadButton.tintColor = UIColor.lightGrayColor()
        loadButton.addTarget(self, action: "prepareToLoadData", forControlEvents: UIControlEvents.TouchUpInside)
        loadButton.center = self.view.center
        loadButton.hidden = true
        loadingView.addSubview(loadButton)
    }
    
    
    func loadTagsView() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        tags = storyboard.instantiateViewControllerWithIdentifier("tags") as? addFlavorTagsView
    }
    
    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.alpha = 1
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "reload", forControlEvents:UIControlEvents.ValueChanged)
        mainTable.addSubview(refreshControl)
        self.refreshControl.layer.zPosition = mainTable.layer.zPosition-1
    }
    
    // User Interface, show/hide functions
    func configureTableView() {
        mainTable.contentInset = UIEdgeInsetsZero
        self.automaticallyAdjustsScrollViewInsets = false
        mainTable.estimatedRowHeight = 400
        mainTable.rowHeight = UITableViewAutomaticDimension
    }

    
    func configureNavBar() {
        showTitleLogo()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)

    }
    func showTitleLogo(){
        let logo = UIImage(named: "vivrTitleLogo")?.imageWithRenderingMode(.AlwaysOriginal)
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
    }
    func hideTitleLogo() {
        self.navigationItem.titleView = nil
    }
    
    func showMenuButton() {
        self.navigationItem.leftBarButtonItem = menuCopy
    }
    
    
    func prepareToLoadData() {
        if filterTags.count != 0 {
            loadFirstFilteredActivity(filterTagsString!)
        }else {
            loadFirstActivity()
        }
        
    }
    
    
    //searchButton
    
    @IBAction func searchPressed(sender: AnyObject) {
        tagView.layer.zPosition = searchViewBackground.layer.zPosition - 1
        switch searchActive {
        case false:
            searchActive = true
            hideTitleLogo()
            let leftNavBarButton = UIBarButtonItem(customView:search)
            search.frame = CGRectMake(0, 0, 0, 20)
            self.navigationItem.leftBarButtonItem = leftNavBarButton
            let searchWidth = self.view.frame.width - 82
            self.addChildViewController(self.searchView!)
            self.searchView!.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 64)
            searchViewBackground.autoresizesSubviews = false 
            self.searchViewBackground.addSubview(self.searchView!.view)
            self.searchView!.view.layer.zPosition = self.searchViewBackground.layer.zPosition + 1
            self.searchView!.didMoveToParentViewController(self)
            UIView.animateWithDuration(
                // duration
                0.5,
                // delay
                delay: 0.0,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    self.search.frame = CGRectMake(0, self.search.frame.origin.y, searchWidth, 20)
                    self.view.layoutIfNeeded()
                    
                }, completion: {finished in
                }
                
            )
            UIView.animateWithDuration(
                // duration
                0.3,
                // delay
                delay: 0.1,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    self.searchViewBackgroundHeight.constant = self.view.frame.height - 64
                    self.view.layoutIfNeeded()
                    
                }, completion: {finished in
                    
                }
            )
        case true:
            searchActive = false
            UIView.animateWithDuration(
                // duration
                0.2,
                // delay
                delay: 0.0,
                options: [],
                animations: {
                    
                    self.searchViewBackgroundHeight.constant = 0.0
                    self.view.layoutIfNeeded()
                }, completion: {finished in
                    self.searchView!.removeFromParentViewController()

                }
            )
            UIView.animateWithDuration(
                // duration
                0.5,
                // delay
                delay: 0.0,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    self.search.alpha = 0.0
                    self.navigationItem.leftBarButtonItem = nil
                    self.showTitleLogo()
                    self.showMenuButton()
                
                }, completion: {finished in

                }
            )
    
        }
    }
    
    func dismissSearch(view: searchViewController, cell: ProductTableViewCell?) {
        if let segueString = view.segueIdentifier as String? {
            if segueString.isEmpty {
                
            }else {
                segueIdentifier = view.segueIdentifier!
                searchActive = false
                search.resignFirstResponder()
                UIView.animateWithDuration(
                    // duration
                    0.2,
                    // delay
                    delay: 0.0,
                    options: [],
                    animations: {
                        self.searchViewBackgroundHeight.constant = 0.0
                    }, completion: {finished in
                        self.searchView!.removeFromParentViewController()
                        self.checkSearchSelection(view)
                        
                    }
                )
                UIView.animateWithDuration(
                    // duration
                    0.5,
                    // delay
                    delay: 0.0,
                    options: [],
                    animations: {
                        self.search.alpha = 0.0
                        self.navigationItem.leftBarButtonItem = nil
                        self.showTitleLogo()
                        self.showMenuButton()
                        self.view.layoutIfNeeded()
                    }, completion: {finished in
                        
                    }
                )
            }
        }

    }
    
    func checkSearchSelection(view: searchViewController) {
        switch segueIdentifier {
            case "buzzToProduct":
                if let productID = view.selectedID! as String? {
                    self.productID = productID
                    performSegueWithIdentifier(segueIdentifier, sender: self)
                }
            case "toUserSegue":
                self.selectedUserID = view.selectedID!
                performSegueWithIdentifier(segueIdentifier, sender: self)
            case "buzzToBrand":
                self.selectedBrandID = view.selectedID!
                self.selectedBrandImage = view.selectedBrandImage!
                performSegueWithIdentifier(segueIdentifier, sender: self)
        default:
            print("error", terminator: "")
        }
    }
    
    
    
    func showLoadingScreen() {
        if feedReviews == nil || feedReviews?.count == 0 {
            loadingViewActive = true
            self.view.addSubview(loadingView)
            activityIndicator.hidden = false
            loadingText.text = "Loading juices"
            loadButton.hidden = true
        }
    }
    func addRefreshButton() {
        loadingText.text = "Check your network connectivity"
        activityIndicator.hidden = true
        loadButton.hidden = false
    }
    
    func removeLoadingScreen() {
        if loadingViewActive == true {
            loadingView.removeFromSuperview()
        }
    }
    
    @IBAction func changeData(sender: AnyObject) {
        let leading = UIScreen.mainScreen().bounds.width/3
        switch controller.selectedSegmentIndex{
        case 0:
            cellIdentifier = "featuredCell"
            segueIdentifier = "toBlogPost"
            self.beginParsing()
            featuredLabel.textColor = UIColor.whiteColor()
            featuredLabel.backgroundColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            juicesLabel.textColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            juicesLabel.backgroundColor = UIColor.whiteColor()
            newLabel.textColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            newLabel.backgroundColor = UIColor.whiteColor()
            UIView.animateWithDuration(
                // duration
                0.2,
                // delay
                delay: 0.1,
                options: [],
                animations: {
                    self.selectionIndicatorLeading.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: {finished in
                }
            )
            mainTable.rowHeight = 200
            mainTable.scrollEnabled = true
            mainTable.reloadData()
        case 1:
            cellIdentifier = "vivrCell"
            featuredLabel.textColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            featuredLabel.backgroundColor = UIColor.whiteColor()
            juicesLabel.textColor = UIColor.whiteColor()
            juicesLabel.backgroundColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            newLabel.textColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            newLabel.backgroundColor = UIColor.whiteColor()
            UIView.animateWithDuration(
                // duration
                0.2,
                // delay
                delay: 0.1,
                options: [],
                animations: {
                    self.selectionIndicatorLeading.constant = leading
                    self.view.layoutIfNeeded()
                }, completion: {finished in
                }
            )
            mainTable.rowHeight = UITableViewAutomaticDimension
            mainTable.scrollEnabled = true
            
            mainTable.reloadData()
        case 2:
            cellIdentifier = "newCell"
            mainTable.separatorStyle = UITableViewCellSeparatorStyle.None
            featuredLabel.textColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            featuredLabel.backgroundColor = UIColor.whiteColor()
            juicesLabel.textColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            juicesLabel.backgroundColor = UIColor.whiteColor()
            newLabel.textColor = UIColor.whiteColor()
            newLabel.backgroundColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            UIView.animateWithDuration(
                // duration
                0.2,
                // delay
                delay: 0.1,
                options: [],
                animations: {
                    self.selectionIndicatorLeading.constant = leading*2
                    self.view.layoutIfNeeded()
                }, completion: {finished in
                }
            )
            mainTable.scrollEnabled = false
            mainTable.reloadData()
        default:
            print("no segment", terminator: "")
            
        }
 
    }
    
    func filterFeed(sender: AnyObject) {
        if filterActive == false {
            filterActive = true
        self.navigationController?.navigationBar.translucent = true
        self.navigationItem.titleView?.alpha = 0.3
        tags!.viewDelegate = self
        tags!.savedTags = filterTags
        tags!.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width, self.view.frame.height - 60)
        tags!.view.layer.zPosition = tagView.layer.zPosition + 2
        self.view.addSubview(self.tags!.view)
        UIView.animateWithDuration(
            // duration
            0.3,
            // delay
            delay: 0.0,
            options: [],
            animations: {
                self.tags!.view.frame = CGRectMake(0, 60, UIScreen.mainScreen().bounds.width, self.view.frame.height - 60)
                self.tabBarController!.tabBar.hidden = true
            }, completion: {finished in
            }
        )
        searchButton.enabled = false
        }
        else {
            filterActive = false 
            self.navigationItem.titleView?.alpha = 1.0
            searchButton.enabled = true
            UIView.animateWithDuration(
                // duration
                0.3,
                // delay
                delay: 0.0,
                options: [],
                animations: {
                    self.tags!.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width, self.view.frame.height - 60)
                    self.tabBarController!.tabBar.hidden = false
                }, completion: {finished in
                    self.tags!.view.removeFromSuperview()
                }
            )
        }
    }
    
    func didSubmit(view: addFlavorTagsView) {
        self.navigationItem.titleView?.alpha = 1.0
        filterTags = []
        filterTags = view.selectedTags
        filterResults(view.selectedTags)
        UIView.animateWithDuration(
            // duration
            0.3,
            // delay
            delay: 0.0,
            options: [],
            animations: {
                self.tags!.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width, self.view.frame.height - 44)
                
            }, completion: {finished in
                self.tags!.view.removeFromSuperview()
                self.tabBarController!.tabBar.hidden = false
                self.filterActive = false
            }
        )
        searchButton.enabled = true
        mainTable.setContentOffset(CGPointZero, animated: true)
    }
    
    func didCancel(view: addFlavorTagsView) {
        self.navigationItem.titleView?.alpha = 1.0
        searchButton.enabled = true
        UIView.animateWithDuration(
            // duration
            0.3,
            // delay
            delay: 0.0,
            options: [],
            animations: {
                self.tags!.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width, self.view.frame.height - 44)
                
            }, completion: {finished in
                self.tags!.view.removeFromSuperview()
                self.tabBarController!.tabBar.hidden = false
                self.filterActive = false
            }
        )
    }
    
    func reload(){
        if filterTags.count == 0 {
        loadFirstActivity()
        }else {
            loadFirstFilteredActivity(filterTagsString!)
        }
        print("refreshing", terminator: "")
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
        selectedFeedReview = feedReviews![cell.cellID!]
        performSegueWithIdentifier(segueIdentifier, sender: cell)
        
    }
    
    func tappedProductButton(cell: vivrCell) {
        self.segueIdentifier = "buzzToProduct"
        productID = cell.productID
        performSegueWithIdentifier(segueIdentifier, sender: cell)
    }
    
    func reloadAPI(cell: vivrCell) {
        if let row = cell.cellID as Int? {
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
        mainTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    func helpfulFalse(cell: vivrCell) {
        if let reviewID = cell.cellID as Int? {
            feedReviews![reviewID].currentHelpful = false
            feedReviews![reviewID].helpfulCount = feedReviews![reviewID].helpfulCount! - 1
            let review = self.feedReviews![reviewID]
            if let helpfullCount = review.helpfulCount {
                switch helpfullCount {
                case 0:
                    cell.helpfullLabel.text = "Was this helpful?"
                default:
                    cell.helpfullLabel.text = "\(helpfullCount) found this helpful"
                }
            }
        }
    }
    
    func helpfulTrue(cell: vivrCell) {
        if let reviewID = cell.cellID as Int? {
            feedReviews![reviewID].currentHelpful = true
            feedReviews![reviewID].helpfulCount = feedReviews![reviewID].helpfulCount! + 1
            let review = self.feedReviews![reviewID]
            if let helpfullCount = review.helpfulCount {
                switch helpfullCount {
                case 0:
                    cell.helpfullLabel.text = "Was this helpful?"
                default:
                    cell.helpfullLabel.text = "\(helpfullCount) found this helpful"
                }
            }
        }
    }
    
    func wishlistFalse(cell: vivrCell) {
        cell.wishlistButton!.enabled = false
        if let reviewID = cell.cellID as Int? {
            feedReviews![reviewID].product?.currentWishlist = true
        }
        activeWishlistContainer = UIView(frame: cell.productImageWrapper.bounds)
        cell.productImageWrapper.addSubview(activeWishlistContainer!)
        activeWishlistContainer?.userInteractionEnabled = false
        let circle = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
        circle.layer.cornerRadius = 25.0
        
        let startingColor = UIColor(red: (118/255.0), green: (48.0/255.0), blue: (157/255.0), alpha: 1.0)
        circle.backgroundColor = startingColor
        
        activeWishlistContainer!.addSubview(circle)
        circle.center = CGPointMake(activeWishlistContainer!.bounds.width/2, activeWishlistContainer!.bounds.height/2)
        activeWishlistContainer!.clipsToBounds = true
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
                                cell.wishlistButton!.enabled = true
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
    func wishlistTrue(cell: vivrCell) {
        cell.wishlistButton!.enabled = false 
        if let reviewID = cell.cellID as Int? {
            feedReviews![reviewID].product?.currentWishlist = true
        }
        activeWishlistContainer = UIView(frame: cell.productImageWrapper.bounds)
        cell.productImageWrapper.addSubview(activeWishlistContainer!)
        activeWishlistContainer?.userInteractionEnabled = false
        let circle = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
        circle.layer.cornerRadius = 25.0
        
        let startingColor = UIColor(red: (118/255.0), green: (48.0/255.0), blue: (157/255.0), alpha: 1.0)
        circle.backgroundColor = startingColor
        
        activeWishlistContainer!.addSubview(circle)
        circle.center = CGPointMake(activeWishlistContainer!.bounds.width/2, activeWishlistContainer!.bounds.height/2)
        activeWishlistContainer!.clipsToBounds = true
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
                        let label = UILabel(frame: CGRectMake(0, 0, 160, 25))
                        label.text = "Added to wishlist"
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
                                label.frame.offsetInPlace(dx: -386, dy: 0)
                                
                            }, completion: {finished in
                                cell.wishlistButton!.enabled = true
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
                                        //self.reloadAPI(cell)
                                    }
                                )
                            }
                        )
                    }
                )
        
            }
        )

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier {
        case "juiceCheckIn":
            let juiceCheckIn: VIVRProductViewController = segue.destinationViewController as! VIVRProductViewController
            juiceCheckIn.selectedProductID = self.productID
            juiceCheckIn.boxOrProduct = "product"
            juiceCheckIn.reviewFlavor()
        case "buzzToComments":
            let reviewVC: VIVRCommentsViewController = segue.destinationViewController as! VIVRCommentsViewController
            reviewVC.reviewID = self.reviewID
            reviewVC.productID = self.productID!
            reviewVC.review = selectedFeedReview
        case "buzzToProduct":
            let productVC: VIVRProductViewController = segue.destinationViewController as! VIVRProductViewController
            productVC.selectedProductID = self.productID
            productVC.boxOrProduct = "product"
        case "toUserSegue":
            let userVC: VIVRUserViewController = segue.destinationViewController as! VIVRUserViewController
            userVC.selectedUserID = self.selectedUserID
            //userVC.automaticallyAdjustsScrollViewInsets = false
        case "buzzToBrand":
            let brandVC: VIVRBrandProductsViewController = segue.destinationViewController as! VIVRBrandProductsViewController
            brandVC.brandImageURL = self.selectedBrandImage
            brandVC.brandID = self.selectedBrandID
        case "toBlogPost":
            print("going to post", terminator: "")
        default:
            print("noSegue", terminator: "")
            
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch cellIdentifier {
        case "vivrCell":
            return self.feedReviews!.count ?? 0
        case "newCell":
            return 1
        case "featuredCell":
            //return posts.count ?? 0
            return 1
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch cellIdentifier {
            case "featuredCell":
                return featuredCellAtIndexPath(indexPath)
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
            let newcell = mainTable.dequeueReusableCellWithIdentifier(cellIdentifier) as! newCell
            newcell.contentView.addSubview(noNewProductsView)
            noNewProductsView.layer.zPosition = noNewProductsView.layer.zPosition + 1
            return newcell
            
        }
    }
    
    
    func featuredCellAtIndexPath(indexPath: NSIndexPath) -> FeaturedCell {
        let cell = mainTable.dequeueReusableCellWithIdentifier("featuredCell", forIndexPath: indexPath) as! FeaturedCell
        if posts.count > 0 {
            //let index = posts[indexPath.row]
            //cell.postTitle.text = index.title!
        }
        return cell
    }

    func vivrCellAtIndexPath(indexPath:NSIndexPath) -> vivrCell {
        let vivrcell = mainTable.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! vivrCell
        if self.feedReviews != nil && self.feedReviews!.count > indexPath.row {
            if let section = indexPath.row as Int? {
                vivrcell.cellID = section
            }
        let review = self.feedReviews![indexPath.row]
            vivrcell.userID = review.userID
            vivrcell.productID = review.productID!
            vivrcell.reviewID = review.reviewID!
            let date = review.createdAt!
                let dateFor:NSDateFormatter = NSDateFormatter()
                dateFor.timeZone = NSTimeZone(abbreviation: "UTC")
                dateFor.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                dateFor.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let theDate:NSDate = dateFor.dateFromString(date)!
                let tempoDate = Tempo(date: theDate)
                let timeStamp = tempoDate.timeAgoNow()
                if let reviewString = review.description {
                    let review = NSMutableAttributedString(string: reviewString + "  -  ")
                    let x = NSAttributedString(string: timeStamp, attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
                    review.appendAttributedString(x)
                    vivrcell.reviewDescription.attributedText = review
                    vivrcell.reviewDescription.sizeToFit()
                    
                }
            vivrcell.userName.text = review.user?.userName
            let urlString = review.user!.image!
            let url = NSURL(string: urlString)!
            vivrcell.userImage!.hnk_setImageFromURL(url)
            vivrcell.userImage.layer.cornerRadius = vivrcell.userImage.frame.size.width/2
            vivrcell.userImage.clipsToBounds = true
            vivrcell.hardwareLabel!.text = review.user?.hardWare
            vivrcell.flavorName.text = review.product?.name
            vivrcell.flavorName.sizeToFit()
            vivrcell.brandName.text = review.brand?.name
            vivrcell.brandName.sizeToFit()
            vivrcell.layoutIfNeeded()
            let productString = review.product!.image!
            let purl = NSURL(string: productString)!
            vivrcell.productImage.hnk_setImageFromURL(purl)
            if let rating = review.score {
                vivrcell.totalScore.text = rating
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
                vivrcell.throat.text = ("\(value!) throat hit")
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
                vivrcell.vapor.text = ("\(value!) vapor production")
            }
            //vivrcell.productDescription.text = review.product?.description
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
                    Alamofire.request(Router.readCommentsAPI(productID, reviewID)).responseJSON { (response) in
                        if response.result.isSuccess {
                            var jsonOBJ = JSON(response.result.value!)
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
            if (!self.isLoadingFeed && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                let totalRows = self.activityWrapper!.count!
                let remainingFeedToLoad = totalRows - rowsLoaded
                if (remainingFeedToLoad > 0) {
                    if filterTags.count != 0 {
                        self.loadMoreFilteredActivity()
                    } else {
                    self.loadMoreActivity()
                    }
                }
            }
        }
        return vivrcell
    }
    
    func toggleTagView() {
        switch filterTags.count {
        case 0:
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.tagViewHeight.constant = 0.0
                self.tagViewIsActive = false
                self.clearTags()
                self.view.layoutIfNeeded()
            })
        default:
            self.tagView.layer.zPosition = self.mainTableWrapper.layer.zPosition + 1
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.tagViewHeight.constant = 20.0
                self.tagViewIsActive = true
                self.addTagsToView()
                self.view.layoutIfNeeded()
            })
        }
        
    }
    func addTagsToView() {
        let viewsToRemove = tagView.subviews
        for view in viewsToRemove {
            view.removeFromSuperview()
        }
        let filterLabel = UILabel(frame: CGRectMake(0, 2, tagView.frame.width, 16))
        filterLabel.text = "filters active"
        filterLabel.font = UIFont(name: "PTSans-Bold", size: 15)
        filterLabel.textColor = UIColor(red: 34.0/255, green: 129.0/255, blue: 30.0/255, alpha: 1.0)
        filterLabel.textAlignment = .Center
        tagView.addSubview(filterLabel)
        /*
        for id in filterTags {
            let indicator = UIImageView(frame: CGRectMake(contentInset, 1, 30, 30))
            indicator.image = UIImage(named: "userImage")
            tagView.addSubview(indicator)
            contentInset = contentInset + 38.0
        }
*/
    }
    
    func clearTags() {
        let viewsToRemove = tagView.subviews
        for view in viewsToRemove {
            view.removeFromSuperview()
        }
    }
    
    func filterResults(tags: NSArray) {
        let stringTags: String = tags.componentsJoinedByString(",")
        filterTagsString = stringTags
        if filterTagsString != nil {
            loadFirstFilteredActivity(filterTagsString!)
        }
        self.toggleTagView()
    }
    func loadFirstFilteredActivity(tags: String) {
        self.feedReviews = []
        isLoadingFeed = true
        ActivityFeedReviews.getFilteredReviews(tags, completionHandler: { (activityWrapper, error) in
            if error != nil {
                self.isLoadingFeed = false
                self.addRefreshButton()
            }
            self.addReviewFromWrapper(activityWrapper)
            self.isLoadingFeed = false
            self.mainTable.reloadData()
        })
    }
    func loadMoreFilteredActivity() {
        isLoadingFeed = true
        if self.feedReviews != nil && self.activityWrapper != nil && self.feedReviews!.count < self.activityWrapper!.count
        {
            ActivityFeedReviews.getMoreFilteredReviews(filterTagsString!, wrapper: self.activityWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingFeed = false
                    let alert = UIAlertController(title: "oops", message: "We couldn't load the data, try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }else {
                self.addReviewFromWrapper(moreWrapper)
                self.isLoadingFeed = false
                self.mainTable.reloadData()
                }
            })
        }
    }
    
    func loadFirstActivity() {
        self.feedReviews = []
        isLoadingFeed = true
        ActivityFeedReviews.getReviews({ (activityWrapper, error) in
            if activityWrapper == nil {
                print(error, terminator: "")
                self.isLoadingFeed = false
                self.showLoadingScreen()
                self.addRefreshButton()
                print("no netowrk", terminator: "")
            }else {
                print("second block executed", terminator: "")
            self.removeLoadingScreen()
            self.addReviewFromWrapper(activityWrapper)
            self.isLoadingFeed = false
            self.mainTable.reloadData()
            }
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
                    let alert = UIAlertController(title: "oops", message: "We couldn't load the data, try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }else {
                self.addReviewFromWrapper(moreWrapper)
                self.isLoadingFeed = false
                self.mainTable.reloadData()
                }
            })
        }
    }
    
    func addReviewFromWrapper(wrapper: ActivityWrapper?) {
        self.activityWrapper = wrapper
        removeLoadingScreen()
        if self.feedReviews == nil {
            self.feedReviews = self.activityWrapper?.ActivityReviews
        }else if self.activityWrapper != nil && self.activityWrapper!.ActivityReviews != nil{
            self.feedReviews = self.feedReviews! + self.activityWrapper!.ActivityReviews!
        }

    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    func reloadSearch() {
        search.becomeFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchView!.searchTextCount = searchText.characters.count
        if searchText.characters.count >= 3 {
        if let searchString = searchBar.text!.stringByReplacingOccurrencesOfString(" ", withString: "_") as String! {
            if searchString.characters.count >= 3 {
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
        if let searchString = searchBar.text!.stringByReplacingOccurrencesOfString(" ", withString: "_") as String! {
            if searchString.characters.count >= 3 {
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

    
    
    //keyboard functions
    
    func hideKeyboard(view: searchViewController) {
        self.becomeFirstResponder()
        self.view.endEditing(true)
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
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.searchView!.bottomConstraint?.constant = keyboardSize.height
                    self.view.layoutIfNeeded()
                    self.keyboardActive = true
                })
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(2, animations: { () -> Void in
            self.searchView!.bottomConstraint?.constant = 0.0
            self.view.layoutIfNeeded()
            self.keyboardActive = false
        })
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
