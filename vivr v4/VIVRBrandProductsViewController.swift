//
//  ProductViewController.swift
//  vivr v4
//
//  Created by max blessen on 1/12/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire
import Haneke


class VIVRBrandProductsViewController: UIViewController, UITableViewDataSource {
    
    var selectedProduct: String = ""
    var selectedDescription: String = ""
    var selectedBrand:String = ""
    var selectedImage:String = ""
    var selectedProductID:String?
    var selectedBrandName:String = ""
    var products: Array<Product>?
    var productWrapper: ProductWrapper?
    var brandLogoURL:String = ""
    var brandDescription:String = ""
    var isLoadingProducts = true
   
    @IBOutlet weak var topImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var brandLogo: UIImageView!
    @IBOutlet weak var brandAbout: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedBrandName
        brandAbout.text = brandDescription
        let url = NSURL(string: brandImageURL!)
        self.brandLogo.hnk_setImageFromURL(url!)
    }
    var brandID:String? {
        didSet {
            loadBrandProducts(brandID!)
        }
    }
    
    var brandImageURL: String? {
        didSet {
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        configureNavBar()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureNavBar() {
        print("configuring", terminator: "")
        let navbarFont = UIFont(name: "PTSans-Bold", size: 17) ?? UIFont.systemFontOfSize(17)
        self.navigationController?.navigationBar.translucent = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: navbarFont, NSForegroundColorAttributeName:UIColor.whiteColor()]
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = productTableView.dequeueReusableCellWithIdentifier("productCell") as! ProductTableViewCell
        cell.products = products![indexPath.row]
        cell.preservesSuperviewLayoutMargins = false 
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products!.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let rowSelected = indexPath.row as Int
        let rowData = products![rowSelected]
        selectedProductID = "\(rowData.productID!)"
        performSegueWithIdentifier("selectedProduct", sender: self)
        /*
        
        var alert: UIAlertView = UIAlertView()
        alert.title = name
        alert.addButtonWithTitle("Ok")
        alert.show()
        */
    }
    
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prepare for segue:\(selectedBrand)", terminator: "")
        let productVC: VIVRProductViewController = segue.destinationViewController as! VIVRProductViewController
        productVC.selectedProductID = selectedProductID
        productVC.boxOrProduct = "product"
    }


    

    func loadBrandProducts(brandID: String) {
        self.products = []
        isLoadingProducts = true
        Product.getBrandProducts(brandID, completionHandler: { (productWrapper, error) in
            if error != nil {
                self.isLoadingProducts = false
                let alert = UIAlertController(title: "Error", message: "could not load first Products", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.addProductFromWrapper(productWrapper)
            self.isLoadingProducts = false
            self.productTableView.reloadData()
        })
    }
    /*
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
    }*/
    
    func addProductFromWrapper(wrapper: ProductWrapper?) {
        self.productWrapper = wrapper
        if self.products == nil {
            self.products = self.productWrapper?.Products
        }else if self.productWrapper != nil && self.productWrapper!.Products != nil{
            self.products = self.products! + self.productWrapper!.Products!
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let cellOffset = productTableView.contentOffset.y
        print(cellOffset, terminator: "")
            if cellOffset < 0 {
                topImageTopConstraint.constant = cellOffset
            }
        if cellOffset > 44 {
            let transition = 44 - cellOffset
            topImageBottomConstraint.constant = transition
        }
    }
    
    
    
}