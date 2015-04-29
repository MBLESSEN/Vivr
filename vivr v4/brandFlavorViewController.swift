//
//  brandFlavorViewController.swift
//  vivr v4
//
//  Created by max blessen on 12/21/14.
//  Copyright (c) 2014 max blessen. All rights reserved.
//

import UIKit
import Alamofire


class brandFlavorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, VivrHeaderCellDelegate {
    
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
    
    var reviewButton = UIBarButtonItem(image: UIImage(named: "addReview"), style: .Plain, target: nil, action: "addReview")
    let likeButtonEmpty:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "likeEmpty"), style: .Plain, target: nil, action: "favoritePressed")
    let likeButtonFilled:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "likeFilled"), style: .Plain, target: nil, action: "favoritePressed")
    
    @IBOutlet weak var mainTable: UITableView!


    var selectedProductID:String? {
        didSet {
            self.loadProductData()
        }
    }
    
    override func viewDidLoad() {
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        super.viewDidLoad()
        println("id is \(selectedProductID)")
        mainTable.estimatedRowHeight = 100.0
        mainTable.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        checkFavorites()
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController?.navigationBar.tintColor = UIColor(red: 43.0/255, green: 169.0/255, blue: 41.0/255, alpha: 1.0)
        navigationController?.navigationBar.translucent = false
        loadProductData()
        loadReviews()
        loadTags()
        self.navigationItem.rightBarButtonItems = [reviewButton]
        self.mainTable.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        //productDescription.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addReview() {
        segueIdentifier = "reviewSegue"
        self.performSegueWithIdentifier("reviewSegue", sender: self)
    }
    
    func favoritePressed() {
        if (currentLikeButton == likeButtonEmpty){
            Alamofire.request(Router.Favorite(selectedProductID!))
            currentLikeButton = likeButtonFilled
            
        }else {
            Alamofire.request(Router.unFavorite(selectedProductID!))
            currentLikeButton = likeButtonEmpty
            
        }
        self.currentLikeButton!.target = self
        self.navigationItem.rightBarButtonItems = [reviewButton, currentLikeButton!]
    }
    
    func setFavorite() {
        switch isFavorite {
        case true:
            currentLikeButton = likeButtonFilled
        default:
            currentLikeButton = likeButtonEmpty
        }
        self.currentLikeButton!.target = self
        self.reviewButton.target = self
        self.navigationItem.rightBarButtonItems = [reviewButton, currentLikeButton!]

    }
    func checkFavorites() {
        Alamofire.request(Router.readCurrentUser()).responseJSON { (request, response, json, error) in
            if (json != nil) {
                let userJson = JSON(json!)
                if let id = userJson["id"].stringValue as String? {
                    self.userID = id
                    Alamofire.request(Router.readUserFavorites(self.userID!)).responseJSON { (request, response, json, error) in
                        if (json != nil) {
                            let jsonOBJ = JSON(json!)
                            if let data = jsonOBJ.arrayValue as [JSON]? {
                                self.favoritesList = data
                                for (index: String, subJson: JSON) in jsonOBJ {
                                    if let favoriteID = self.favoritesList?[index.toInt()!]["product"]["id"].stringValue {
                                        self.favoritesIDList.append(favoriteID)
                                        
                                    }
                                }
                                println(self.favoritesIDList)
                                for id in self.favoritesIDList {
                                    if (self.selectedProductID! == id as String) {
                                        self.isFavorite = true
                                    }
                                }
                                self.setFavorite()
                            }
                        }
                    }

                }
            }
        }
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
    
    func tappedUser(cell: vivrHeaderCell) {
        self.segueIdentifier = "flavorToUser"
        selectedUserID = cell.userID
        performSegueWithIdentifier(segueIdentifier, sender: cell)
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
            let product: productCell = mainTable.dequeueReusableCellWithIdentifier("productCell") as productCell
            product.product = productData
            product.reviewCount.text = ("(\(revCount) reviews)")
            return product
        case 1:
            let attribute: attributesCell = mainTable.dequeueReusableCellWithIdentifier("Attributes") as attributesCell
            attribute.product = productData
            return attribute
        case 2:
            let flavor: flavorCell = mainTable.dequeueReusableCellWithIdentifier("flavorCell") as flavorCell
            flavor.flavors = productData
            return flavor
        case 3:
            let reviewHeader: UITableViewCell = mainTable.dequeueReusableCellWithIdentifier("Reviews") as UITableViewCell
            return reviewHeader
        default:
            let review: reviewTableViewCell = mainTable.dequeueReusableCellWithIdentifier("reviewCell") as reviewTableViewCell
            review.review = reviewResults?[indexPath.section - 4]
            review.helpfullState = "notLiked"
            mainTable.rowHeight = UITableViewAutomaticDimension
            return review
        }
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerCell = tableView.dequeueReusableCellWithIdentifier("ReviewHeaderCell") as vivrHeaderCell
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
                var reviewVC: reviewViewController = segue.destinationViewController as reviewViewController
                reviewVC.productID = self.selectedProductID!
            case "flavorToUser":
                var userVC: anyUserViewController = segue.destinationViewController as anyUserViewController
                userVC.userID = self.selectedUserID
        default:
            println("no segue")
            
        }

    }

}
    


