//
//  BrowseViewController.swift
//  vivr v4
//
//  Created by max blessen on 12/17/14.
//  Copyright (c) 2014 max blessen. All rights reserved.
//

import UIKit
import Alamofire



class BrowseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let screenSize = UIScreen.mainScreen().bounds
    var results:[JSON]? = []
    var data = NSMutableData()
    var selectedBrandImage:String = ""
    var selectedBrandLogo:String = ""
    var selectedBrand:String?  = ""
    var selectedBrandName:String = ""
    var brandDescription:String = ""
    var cellIdentifier = "brandCell"
    var selectedProductID:Int?
    var segueIdentifier:String?
    
    
    var products:Array<Product>?
    var productWrapper:ProductWrapper?
    var isLoadingProducts = false
    
    
    
    @IBOutlet weak var controller: UISegmentedControl!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var brandsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        loadData()
    }
    func configureNavBar() {
        var logo = UIImage(named: "logoWhiteBorder")?.imageWithRenderingMode(.AlwaysOriginal)
        var imageView = UIImageView(image: logo)
        navigationItem.titleView = imageView
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController?.navigationBar.translucent = false 
        
    }
    
    override func viewWillAppear(animated: Bool) {
        loadFirstProduct()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func changeData(sender: AnyObject) {
        switch controller.selectedSegmentIndex{
        case 0:
            cellIdentifier = "brandCell"
            brandsTableView.reloadData()
        case 1:
            cellIdentifier = "productCell"
            brandsTableView.rowHeight = UITableViewAutomaticDimension
            brandsTableView.reloadData()
        default:
            println("no segment")
            
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (cellIdentifier == "brandCell") {
            println(screenSize.width)
            if (screenSize.width < 370) {
                return 75
            }else{
                return 100
            }
            
        }else {
            return 40
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch cellIdentifier {
            case "brandCell":
                return self.results?.count ?? 0
            case "productCell":
                if self.products == nil {
                    return 0
            }
            return self.products!.count
        default:
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch cellIdentifier {
            case "brandCell":
                return brandCellForIndexPath(indexPath)
        default:
                return productCellForIndexPath(indexPath)
            
        }
    }
    
    func brandCellForIndexPath(indexPath:NSIndexPath) -> BrandTableViewCell {
        var cell = brandsTableView.dequeueReusableCellWithIdentifier("brandCell") as! BrandTableViewCell
        cell.brand = self.results?[indexPath.row]
        cell.preservesSuperviewLayoutMargins = false
        return cell
        
    }
    
    func productCellForIndexPath(indexPath:NSIndexPath) -> ProductTableViewCell {
        let cell = brandsTableView.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath) as! ProductTableViewCell
        if self.products != nil && self.products!.count >= indexPath.row {
            let product = self.products![indexPath.row]
            cell.productLabel.text = product.name
            
            let rowsToLoadFromBottom = 5
            let rowsLoaded = self.products!.count
            if (!self.isLoadingProducts && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                let totalRows = self.productWrapper!.count!
                let remainingFeedToLoad = totalRows - rowsLoaded
                if (remainingFeedToLoad > 0) {
                    self.loadMoreProducts()
                }
            }
        }
        cell.preservesSuperviewLayoutMargins = false
        return cell
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (controller.selectedSegmentIndex == 0) {
        var rowSelected = indexPath.row as Int
        var rowData = results![rowSelected]
        selectedBrand! = rowData["id"].stringValue
        selectedBrandImage = rowData["image"].stringValue
        selectedBrandLogo = rowData["logo"].stringValue
        selectedBrandName = rowData["name"].stringValue
        brandDescription = rowData["description"].stringValue
        segueIdentifier = "brandProductSegue"
        performSegueWithIdentifier(segueIdentifier, sender: self)
        }
        if (controller.selectedSegmentIndex == 1){
            var rowSelected = indexPath.row as Int
            var rowData = products![rowSelected]
            selectedProductID = rowData.productID
            segueIdentifier = "browseToProduct"
            performSegueWithIdentifier(segueIdentifier, sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier!{
            case "brandProductSegue":
                var productVC: ProductViewController = segue.destinationViewController as! ProductViewController
                productVC.productID = selectedBrand!
                productVC.brandImageURL = selectedBrandImage
                productVC.brandLogoURL = selectedBrandLogo
                productVC.selectedBrandName = selectedBrandName
                productVC.brandDescription = brandDescription
            case "browseToProduct":
                let brandFlavorVC: brandFlavorViewController = segue.destinationViewController as! brandFlavorViewController
                if let stringID = String(stringInterpolationSegment: selectedProductID!) as String? {
                brandFlavorVC.selectedProductID = stringID
                }
        default:
            println("no segue")
        }
    }
    
    func loadData(){
        
        Alamofire.request(Router.ReadBrands()).responseJSON { (request, response, json, error) in
            println(request)
            println(response)
            println(error)
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let data = jsonOBJ["data"].arrayValue as [JSON]? {
                    self.results = data
                    self.brandsTableView.reloadData()
                }
            }
        }
    }
    
    func loadFirstProduct() {
        self.products = []
        isLoadingProducts = true
        Product.getProducts({ (productWrapper, error) in
            if error != nil {
                self.isLoadingProducts = false
                var alert = UIAlertController(title: "Error", message: "could not load first Products", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.addProductFromWrapper(productWrapper)
            self.isLoadingProducts = false
            self.brandsTableView.reloadData()
        })
    }
    func loadMoreProducts() {
        isLoadingProducts = true
        if self.products != nil && self.productWrapper != nil && self.products!.count < self.productWrapper!.count
        {
            Product.getMoreProducts(self.productWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingProducts = false
                    var alert = UIAlertController(title: "Error", message: "Could not load more Products", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                println("got More")
                self.addProductFromWrapper(moreWrapper)
                self.isLoadingProducts = false
                self.brandsTableView.reloadData()
            })
        }
    }
    
    func addProductFromWrapper(wrapper: ProductWrapper?) {
        self.productWrapper = wrapper
        if self.products == nil {
            self.products = self.productWrapper?.Products
        }else if self.productWrapper != nil && self.productWrapper!.Products != nil{
            self.products = self.products! + self.productWrapper!.Products!
        }
    }

    
}



