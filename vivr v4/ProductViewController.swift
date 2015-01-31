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


class ProductViewController: UIViewController, UITableViewDataSource {
    
    var productID: String = "0"
    var selectedProduct: String = ""
    var selectedDescription: String = ""
    var selectedBrand:String = ""
    var selectedImage:String = ""
    var selectedProductID:String = ""
    var selectedBrandName:String = ""
    var productResults:[JSON]? = []
    var brandImageURL: String = ""
    var brandLogoURL:String = ""
    var brandDescription:String = ""
   
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var brandImage: UIImageView!
    @IBOutlet weak var brandLogo: UIImageView!
    @IBOutlet weak var brandAbout: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedBrandName
        var myImage = UIImage(named: "back.png");
        brandAbout.text = brandDescription
       // UIBarButtonItem.appearance().setBackButtonBackgroundImage(myImage, forState: .Normal, barMetrics: .Default);
        //var backButtonLabel = ""
        //UIBarItem.appearance().title = backButtonLabel
        println(productID)
        loadImages()
        loadProductData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func loadImages() {
        let imageURL = NSURL(string: brandImageURL)
        self.brandImage.hnk_setImageFromURL(imageURL!)
        let logoURL = NSURL(string: brandLogoURL)
        self.brandLogo.hnk_setImageFromURL(logoURL!)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = productTableView.dequeueReusableCellWithIdentifier("productCell") as ProductTableViewCell
        cell.products = self.productResults?[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productResults?.count ?? 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var rowSelected = indexPath.row as Int
        var rowData = productResults![rowSelected]
        selectedProduct = rowData["name"].stringValue
        selectedImage = rowData["image"].stringValue
        selectedDescription = rowData["description"].stringValue
        selectedProductID = rowData["id"].stringValue
        println(selectedProduct)
        println(selectedDescription)
        performSegueWithIdentifier("selectedProduct", sender: self)
        /*
        
        var alert: UIAlertView = UIAlertView()
        alert.title = name
        alert.addButtonWithTitle("Ok")
        alert.show()
        */
    }
    
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("prepare for segue:\(selectedBrand)")
        var productVC: brandFlavorViewController = segue.destinationViewController as brandFlavorViewController
        productVC.selectedProduct = selectedProduct
        productVC.selectedImage = selectedImage
        productVC.selectedDescription = selectedDescription
        productVC.selectedBrand = selectedBrandName
        productVC.selectedProductID = selectedProductID
    }


    
    func loadProductData() {
        let accessToken = KeychainService.loadToken()
        let url = "http://mickeyschwab.com/vivr/public/brands/\(productID)/products?access_token=\(accessToken!)"
        
        Alamofire.request(.GET, url).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let data = jsonOBJ.arrayValue as [JSON]? {
                    self.productResults = data
                    self.productTableView?.reloadData()
                    println(self.productResults)
                    
                }
            }
    }
}
}