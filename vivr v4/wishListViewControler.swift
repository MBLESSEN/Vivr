//
//  wishListViewControler.swift
//  vivr v4
//
//  Created by max blessen on 5/15/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

class wishListViewControler: UIViewController, UITableViewDataSource, productCellDelegate {
    
    var wishlist:[JSON]? = []
    var wishCount:Int = 0
    var cellIdentifier:String = "myEmptyWishList"
    var userNameLabel:UILabel?
    var segueIdentifier:String?
    var selectedProductID:String?
    
    @IBOutlet weak var wishlistTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        wishlistTable.contentInset = UIEdgeInsetsZero
        wishlistTable.rowHeight = 220
        self.automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        configureNavBar()
    }

    func configureNavBar(){
        userNameLabel = UILabel(frame: CGRectMake(0, 0, 60, 20))
        userNameLabel!.text = "Wish list"
        userNameLabel!.textColor = UIColor.whiteColor()
        userNameLabel!.font = UIFont(name: "PTSans-Bold", size: 17)
        self.navigationItem.titleView = userNameLabel 
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var userID:String? {
        didSet{
            loadWishlist()
        }
    }
    
    func toProduct(cell: ProductTableViewCell) {
        segueIdentifier = "wishToProduct"
        selectedProductID = cell.productID
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch wishCount {
        case 0:
            let cell = wishlistTable.dequeueReusableCellWithIdentifier("myEmptyWishlist") as! UITableViewCell
            return cell
        default:
            return loadWishListCell(indexPath)
        }

    }
    
    func loadWishListCell(indexPath:NSIndexPath) -> ProductTableViewCell {
        let cell = wishlistTable.dequeueReusableCellWithIdentifier("wishListCell") as! ProductTableViewCell
        if (wishlist != nil){
        let wishIndex = wishlist![indexPath.row]
        cell.productLabel.text = wishIndex["product"]["name"].stringValue
        cell.productBrandName!.text = wishIndex["product"]["brand"]["name"].stringValue
        cell.productID = wishIndex["product"]["id"].stringValue
        cell.cellDelegate = self
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.wishCount = wishlist?.count ?? 1
        return self.wishCount
    }
    
    func loadWishlist() {
        Alamofire.request(Router.readWishlist(userID!)).responseJSON {(request, response, json, error) in
            if (json != nil) {
                let jsonOBJ = JSON(json!)
                if let data = jsonOBJ["data"].arrayValue as [JSON]? {
                    self.wishlist = data
                    self.wishlistTable.reloadData()
                }
                
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier!{
        case "wishToProduct":
            let productVC:brandFlavorViewController = segue.destinationViewController as! brandFlavorViewController
            productVC.selectedProductID = selectedProductID
        default:
            println("no segue")
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
