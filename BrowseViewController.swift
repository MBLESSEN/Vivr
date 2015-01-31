//
//  BrowseViewController.swift
//  vivr v4
//
//  Created by max blessen on 12/17/14.
//  Copyright (c) 2014 max blessen. All rights reserved.
//

import UIKit
import Alamofire



class BrowseViewController: UIViewController, UITableViewDataSource {
    
    var results:[JSON]? = []
    var data = NSMutableData()
    var selectedBrandImage:String = ""
    var selectedBrandLogo:String = ""
    var selectedBrand:String?  = ""
    var selectedBrandName:String = ""
    var brandDescription:String = ""
    
    @IBOutlet weak var brandsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var logo = UIImage(named: "vivrTitleLogo")
        var imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
        

        tabBarController?.tabBar.backgroundColor = UIColor.whiteColor()
        tabBarController?.tabBar.translucent = false
        
        //navigationController?.navigationBar.translucent = false
      
        
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results?.count ?? 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = brandsTableView.dequeueReusableCellWithIdentifier("brandCell") as BrandTableViewCell
        cell.brand = self.results?[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var rowSelected = indexPath.row as Int
        var rowData = results![rowSelected]
        selectedBrand! = rowData["id"].stringValue
        selectedBrandImage = rowData["image"].stringValue
        selectedBrandLogo = rowData["logo"].stringValue
        selectedBrandName = rowData["name"].stringValue
        brandDescription = rowData["description"].stringValue
        println("the selected brand id is:\(selectedBrand)")
        performSegueWithIdentifier("brandProductSegue", sender: self)
        println(rowData)
        
        /*
        var alert: UIAlertView = UIAlertView()
        alert.title = name
        alert.addButtonWithTitle("Ok")
        alert.show()
        */
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var productVC: ProductViewController = segue.destinationViewController as ProductViewController
        productVC.productID = selectedBrand!
        productVC.brandImageURL = selectedBrandImage
        productVC.brandLogoURL = selectedBrandLogo
        productVC.selectedBrandName = selectedBrandName
        productVC.brandDescription = brandDescription   
    }
    
    func loadData(){
        let accessToken = KeychainService.loadToken()
        println(accessToken)
        let url = "http://mickeyschwab.com/vivr/public/brands?access_token=\(accessToken!)"
        
        Alamofire.request(.GET, url).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let data = jsonOBJ.arrayValue as [JSON]? {
                    self.results = data
                    self.brandsTableView?.reloadData()
                }
            }
        }
    }
}



