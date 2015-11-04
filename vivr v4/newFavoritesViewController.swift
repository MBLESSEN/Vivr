//
//  newFavoritesViewController.swift
//  vivr v4
//
//  Created by max blessen on 5/18/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class newFavoritesViewController: UIViewController, UITableViewDataSource, productCellDelegate {
    
    var wishlist:[SwiftyJSON.JSON]? = []
    var wishCount:Int = 0
    var cellIdentifier:String = "myEmptyWishList"
    var userNameLabel:UILabel?
    var segueIdentifier:String?
    var selectedProductID:String?
    var isLoadingProducts = false
    
    var isUser:Bool? 
    var favorites:Array<Favorite>?
    var favoritesWrapper:FavoriteWrapper?
    
    @IBOutlet weak var favoritesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesTable.contentInset = UIEdgeInsetsZero
        favoritesTable.rowHeight = 100
        self.automaticallyAdjustsScrollViewInsets = false
        configureNavBarTitle()
    }
    
    func configureNavBarTitle() {
        userNameLabel = UILabel(frame: CGRectMake(0, 0, 60, 20))
        userNameLabel!.text = "Favorites"
        userNameLabel!.textColor = UIColor.whiteColor()
        userNameLabel!.font = UIFont(name: "PTSans-Bold", size: 17)
        self.navigationItem.titleView = userNameLabel
    }
    
    override func viewWillAppear(animated: Bool) {
        configureNavBar()
    }
    
    func configureNavBar(){
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var userID:Int? {
        didSet{
            loadFirstFavorite()
        }
    }
    
    func toProduct(cell: ProductTableViewCell) {
        segueIdentifier = "favoriteToProduct"
        selectedProductID = cell.productID
        performSegueWithIdentifier(segueIdentifier!, sender: self)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if isUser == true {
            return true
        }else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = favoritesTable.cellForRowAtIndexPath(indexPath) as! ProductTableViewCell
        selectedProductID = cell.productID
        segueIdentifier = "favoriteToProduct"
        performSegueWithIdentifier(segueIdentifier!, sender: self)
    }

    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let cell = favoritesTable.cellForRowAtIndexPath(indexPath) as! ProductTableViewCell
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            Alamofire.request(Router.unFavorite(cell.productID!))
            if let index = indexPath.row as Int? {
                if let pName = self.favorites![index].product?.name as String? {
                    print("removed \(pName)")
                    self.favorites!.removeAtIndex(index)
                    self.favoritesTable.reloadData()
                }
                
            }
        })
        return [deleteAction]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch wishCount {
        case 0:
            let cell = favoritesTable.dequeueReusableCellWithIdentifier("myEmptyWishlist") as UITableViewCell!
            return cell
        default:
            return loadFavoriteCell(indexPath)
        }
        
    }
    
    func loadFavoriteCell(indexPath:NSIndexPath) -> ProductTableViewCell {
        let cell = favoritesTable.dequeueReusableCellWithIdentifier("favoriteCell") as! ProductTableViewCell
        if self.favorites != nil && self.favorites!.count >= indexPath.row {
            let favorite = self.favorites![indexPath.row]
            cell.productLabel.text = favorite.product?.name
            cell.productBrandName!.text = favorite.brand?.name
            cell.productID = String(stringInterpolationSegment: favorite.productID!)
            cell.cellDelegate = self
            if let urlString = favorite.product?.image as String? {
                let url = NSURL(string: urlString)
                cell.productImage?.hnk_setImageFromURL(url!)
            }
            let rowsToLoadFromBottom = 5
            let rowsLoaded = self.favorites!.count
            if (!self.isLoadingProducts && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                let totalRows = self.favoritesWrapper!.count!
                let remainingFeedToLoad = totalRows - rowsLoaded
                if (remainingFeedToLoad > 0) {
                    self.loadMoreFavorites()
                }
            }
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.favorites == nil {
            return 1
        }
        return self.favorites!.count
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier!{
        case "favoriteToProduct":
            let productVC:brandFlavorViewController = segue.destinationViewController as! brandFlavorViewController
            productVC.selectedProductID = selectedProductID
        default:
            print("no segue", terminator: "")
        }
    }
    func loadFirstFavorite() {
        self.favorites = []
        isLoadingProducts = true
        Favorite.getProducts(userID!, completionHandler: { (productWrapper, error) in
            if error != nil {
                self.isLoadingProducts = false
                let alert = UIAlertController(title: "Error", message: "could not load first favorites", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.addFavoriteFromWrapper(productWrapper)
            self.isLoadingProducts = false
            self.favoritesTable.reloadData()
        })
    }
    func loadMoreFavorites() {
        isLoadingProducts = true
        if self.favorites != nil && self.favoritesWrapper != nil && self.favorites!.count < self.favoritesWrapper!.count
        {
            Favorite.getMoreProducts(userID!, wrapper: self.favoritesWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingProducts = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more favorites", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                print("got More", terminator: "")
                self.addFavoriteFromWrapper(moreWrapper)
                self.isLoadingProducts = false
                self.favoritesTable.reloadData()
            })
        }
    }
    
    func addFavoriteFromWrapper(wrapper: FavoriteWrapper?) {
        self.favoritesWrapper = wrapper
        wishCount = favoritesWrapper!.count!
        if self.favorites == nil {
            self.favorites = self.favoritesWrapper?.Products
        }else if self.favoritesWrapper != nil && self.favoritesWrapper!.Products != nil{
            self.favorites = self.favorites! + self.favoritesWrapper!.Products!
        }
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
