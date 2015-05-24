//
//  brandFlavorViewController.swift
//  vivr v4
//
//  Created by max blessen on 12/21/14.
//  Copyright (c) 2014 max blessen. All rights reserved.
//

import UIKit
import Alamofire


class brandFlavorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, VivrHeaderCellDelegate, ReviewCellDelegate, brandFlavorDelegate {
    
    var userID:String?
    var revCount:String = ""
    var reviewResults:[JSON]? = []
    var productData:JSON? = ""
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
    
    
    @IBOutlet weak var mainTable: UITableView!


    var selectedProductID:String? {
        didSet {
            self.loadProductData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("id is \(selectedProductID)")
        mainTable.estimatedRowHeight = 100.0
        mainTable.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        configureNavBar()
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        loadProductData()
        loadReviews()
        loadTags()
        self.navigationItem.rightBarButtonItems = []
        self.mainTable.reloadData()
    }
    
    func configureNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController?.navigationBar.tintColor = UIColor(red: 43.0/255, green: 169.0/255, blue: 41.0/255, alpha: 1.0)
        navigationController?.navigationBar.translucent = false
    }
    
    override func viewDidLayoutSubviews() {
        //productDescription.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func favoriteSelected(sender: AnyObject) {
        
        Alamofire.request(Router.Favorite(selectedProductID!)).responseJSON { (request, response, json, error) in
            println(request)
            println(response)
            println(json)
            println(error)
        }
        
        
        
    }
    
    func loadProductData() {
        Alamofire.request(Router.ReadProductData(selectedProductID!)).responseJSON { (request, response, json, error) in
            if  (json != nil) {
                var jsonOBJ = JSON(json!)
                if let data = jsonOBJ as JSON? {
                    self.productData = data
                    if let pt = self.productData?["scores"]["throat"].int as Int? {
                    self.productThroat = pt
                    }
                    if let pv = self.productData?["scores"]["vapor"].int as Int? {
                    self.productVapor = pv
                    }
                }
                }
        

            }
        }
    
    func loadReviews() {
        Alamofire.request(Router.ReadReviews(selectedProductID!)).responseJSON { (request, response, json, error) in
            if  (json != nil) {
                var jsonOBJ = JSON(json!)
                if let data = jsonOBJ["data"].arrayValue as [JSON]? {
                    self.reviewResults = data
                    self.mainTable.reloadData()
                }
                
                if let count = jsonOBJ["total"].stringValue as String? {
                    self.revCount = count
                    
                }
            }
        }
    }
    
    func loadTags() {
        Alamofire.request(Router.ReadProductTags(selectedProductID!)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let data = jsonOBJ as JSON? {
                    self.tags = data
                }
            }
            
        }
    }

    @IBAction func loadMore(sender: AnyObject) {

    }
    
    func toReview(cell: productCell) {
        segueIdentifier = "reviewSegue"
        self.performSegueWithIdentifier("reviewSegue", sender: self)
    }
    
    func tappedUser(cell: vivrHeaderCell) {
        self.segueIdentifier = "flavorToUser"
        selectedUserID = cell.userID
        performSegueWithIdentifier(segueIdentifier, sender: cell)
    }
    
    func tappedProductButton(cell: vivrHeaderCell) {
    }
    
    func reloadAPI(cell: reviewTableViewCell) {
        loadReviews()
    }
    func tappedFlavorReviewCommentbutton(cell: reviewTableViewCell) {
        self.segueIdentifier = "flavorToComments"
        selectedReviewID = cell.reviewID
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let count = self.reviewResults?.count
        finalCell = 5 + count!
                return 4 + count!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let product: productCell = mainTable.dequeueReusableCellWithIdentifier("productCell") as! productCell
            product.productID = productData!["id"].stringValue
            product.product = productData
            product.reviewCount.text = ("(\(revCount) reviews)")
            product.favoriteState = productData!["current_favorite"].boolValue
            product.wishState = productData!["current_wishlist"].boolValue
            product.reviewState = false
            product.cellDelegate = self
            product.preservesSuperviewLayoutMargins = false
            return product
        case 1:
            let attribute: attributesCell = mainTable.dequeueReusableCellWithIdentifier("Attributes") as! attributesCell
            attribute.product = productData
            attribute.preservesSuperviewLayoutMargins = false
            return attribute
        case 2:
            let flavor: flavorCell = mainTable.dequeueReusableCellWithIdentifier("flavorCell") as! flavorCell
            flavor.flavors = productData
            flavor.preservesSuperviewLayoutMargins = false
            return flavor
        case 3:
            let reviewHeader: UITableViewCell = mainTable.dequeueReusableCellWithIdentifier("Reviews") as! UITableViewCell
            reviewHeader.preservesSuperviewLayoutMargins = false
            return reviewHeader
        default:
            let review: reviewTableViewCell = mainTable.dequeueReusableCellWithIdentifier("reviewCell") as! reviewTableViewCell
            review.productID = reviewResults![indexPath.section - 4]["product_id"].stringValue
            review.review = reviewResults?[indexPath.section - 4]
            if let state = self.reviewResults![indexPath.section - 4]["current_helpful"].boolValue as Bool?{
                review.helpfullState = state
            }
            mainTable.rowHeight = UITableViewAutomaticDimension
            review.cellDelegate = self
            review.preservesSuperviewLayoutMargins = false 
            return review
        }
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerCell = tableView.dequeueReusableCellWithIdentifier("ReviewHeaderCell") as! vivrHeaderCell
            headerCell.userInfo = reviewResults?[section - 4]
            headerCell.rating = reviewResults?[section-4]["score"].stringValue
            headerCell.backgroundColor = UIColor.whiteColor()
            headerCell.cellDelegate = self
            return headerCell
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return 0
        case 2:
            return 0
        case 3:
            return 0
        default:
            return 40.0
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier {
            case "reviewSegue":
                var reviewVC: reviewViewController = segue.destinationViewController as! reviewViewController
                reviewVC.productID = self.selectedProductID!
            case "flavorToUser":
                var userVC: anyUserProfileView = segue.destinationViewController as! anyUserProfileView
                userVC.selectedUserID = self.selectedUserID
            case "flavorToComments":
                var commentVC: commentsViewController = segue.destinationViewController as! commentsViewController
                commentVC.reviewID = selectedReviewID!
                commentVC.productID = selectedProductID!
        default:
            println("no segue")
            
        }

    }

}
    


