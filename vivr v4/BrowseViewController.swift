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
    var productResults:[JSON]? = []
    var data = NSMutableData()
    var selectedBrandImage:String = ""
    var selectedBrandLogo:String = ""
    var selectedBrand:String?  = ""
    var selectedBrandName:String = ""
    var brandDescription:String = ""
    var cellIdentifier = "brandCell"
    var selectedProductID:String?
    var segueIdentifier:String?
    
    
    @IBOutlet weak var controller: UISegmentedControl!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var brandsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        loadData()
        loadProducts()
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
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
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
                return self.productResults?.count ?? 0
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
        var cell = brandsTableView.dequeueReusableCellWithIdentifier("brandCell") as BrandTableViewCell
        cell.brand = self.results?[indexPath.row]
        return cell
        
    }
    
    func productCellForIndexPath(indexPath:NSIndexPath) -> ProductTableViewCell {
        let cell = brandsTableView.dequeueReusableCellWithIdentifier("productCell") as ProductTableViewCell
        if (productResults != nil) {
            let productIndex = productResults![indexPath.row]
            cell.productLabel.text = productIndex["name"].stringValue
        }
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
            var rowData = productResults![rowSelected]
            selectedProductID = rowData["id"].stringValue
            segueIdentifier = "browseToProduct"
            performSegueWithIdentifier(segueIdentifier, sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier!{
            case "brandProductSegue":
                var productVC: ProductViewController = segue.destinationViewController as ProductViewController
                productVC.productID = selectedBrand!
                productVC.brandImageURL = selectedBrandImage
                productVC.brandLogoURL = selectedBrandLogo
                productVC.selectedBrandName = selectedBrandName
                productVC.brandDescription = brandDescription
            case "browseToProduct":
                let brandFlavorVC: brandFlavorViewController = segue.destinationViewController as brandFlavorViewController
                brandFlavorVC.selectedProductID = selectedProductID
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
    
    func loadProducts() {
        Alamofire.request(Router.readAllProducts()).responseJSON { (request, response, json, error) in
            if (json != nil) {
                let jsonOBJ = JSON(json!)
                if let data = jsonOBJ["data"].arrayValue as [JSON]? {
                    self.productResults = data
                    self.brandsTableView.reloadData()
                }
            }
    }
}
}



