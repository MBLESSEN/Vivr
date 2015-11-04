//
//  wishListViewControler.swift
//  vivr v4
//
//  Created by max blessen on 5/15/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class wishListViewControler: UIViewController, UITableViewDataSource, productCellDelegate, UITableViewDelegate {
    
    var wishlist:[SwiftyJSON.JSON]? = []
    var wishCount:Int = 0
    var cellIdentifier:String = "myEmptyWishList"
    var userNameLabel:UILabel?
    var segueIdentifier:String?
    var selectedProductID:String?
    
    var isUser:Bool?
    var isLoadingProducts = false
    var wish:Array<Wish>?
    var wishWrapper: WishWrapper?
    
    @IBOutlet weak var wishlistTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        wishlistTable.contentInset = UIEdgeInsetsZero
        wishlistTable.rowHeight = 100
        self.automaticallyAdjustsScrollViewInsets = false
        configureNavBarTitle()
        // Do any additional setup after loading the view.
    }
    
    func configureNavBarTitle() {
        userNameLabel = UILabel(frame: CGRectMake(0, 0, 60, 20))
        userNameLabel!.text = "Wish list"
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
            loadFirstWish()
        }
    }
    
    func toProduct(cell: ProductTableViewCell) {
        segueIdentifier = "wishToProduct"
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
        let cell = wishlistTable.cellForRowAtIndexPath(indexPath) as! ProductTableViewCell
        selectedProductID = cell.productID
        segueIdentifier = "wishToProduct"
        performSegueWithIdentifier(segueIdentifier!, sender: self)
    }
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let cell = wishlistTable.cellForRowAtIndexPath(indexPath) as! ProductTableViewCell
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            Alamofire.request(Router.removeWish(cell.productID!))
            if let index = indexPath.row as Int? {
                if let pName = self.wish![index].product?.name as String? {
                    print("removed \(pName)")
                    self.wish!.removeAtIndex(index)
                    self.wishlistTable.reloadData()
                }

            }
        })
        return [deleteAction]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch wishCount {
        case 0:
            let cell = wishlistTable.dequeueReusableCellWithIdentifier("myEmptyWishlist") as! ProductTableViewCell
            return cell
        default:
            return loadWishListCell(indexPath)
        }

    }
    
    func loadWishListCell(indexPath:NSIndexPath) -> ProductTableViewCell {
        let cell = wishlistTable.dequeueReusableCellWithIdentifier("wishListCell") as! ProductTableViewCell
        if self.wish != nil && self.wish!.count >= indexPath.row {
        let wish = self.wish![indexPath.row]
        cell.productLabel.text = wish.product?.name
        cell.productBrandName!.text = wish.brand?.name
        cell.productID = String(stringInterpolationSegment: wish.productID!)
        cell.cellDelegate = self
        cell.editingEnabled = true
            if let urlString = wish.product?.image as String? {
                let url = NSURL(string: urlString)
                cell.productImage?.hnk_setImageFromURL(url!)
            }
            let rowsToLoadFromBottom = 5
            let rowsLoaded = self.wish!.count
            if (!self.isLoadingProducts && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                let totalRows = self.wishWrapper!.count!
                let remainingFeedToLoad = totalRows - rowsLoaded
                if (remainingFeedToLoad > 0) {
                    self.loadMoreWish()
                }
            }
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.wish == nil {
            return 1
        }
        return self.wish!.count
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier!{
        case "wishToProduct":
            let productVC:brandFlavorViewController = segue.destinationViewController as! brandFlavorViewController
            productVC.selectedProductID = selectedProductID
        default:
            print("no segue", terminator: "")
        }
    }
    func loadFirstWish() {
        self.wish = []
        isLoadingProducts = true
        Wish.getProducts(userID!, completionHandler: { (wishWrapper, error) in
            if error != nil {
                self.isLoadingProducts = false
                let alert = UIAlertController(title: "Error", message: "could not load first favorites", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.addWishFromWrapper(wishWrapper)
            self.isLoadingProducts = false
            self.wishlistTable.reloadData()
        })
    }
    func loadMoreWish() {
        isLoadingProducts = true
        if self.wish != nil && self.wishWrapper != nil && self.wish!.count < self.wishWrapper!.count
        {
            Wish.getMoreProducts(userID!, wrapper: self.wishWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingProducts = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more favorites", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                print("got More", terminator: "")
                self.addWishFromWrapper(moreWrapper)
                self.isLoadingProducts = false
                self.wishlistTable.reloadData()
            })
        }
    }
    
    func addWishFromWrapper(wrapper: WishWrapper?) {
        self.wishWrapper = wrapper
        wishCount = wishWrapper!.count!
        if self.wish == nil {
            self.wish = self.wishWrapper?.Products
        }else if self.wishWrapper != nil && self.wishWrapper!.Products != nil{
            self.wish = self.wish! + self.wishWrapper!.Products!
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
