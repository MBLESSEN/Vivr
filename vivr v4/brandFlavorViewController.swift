//
//  brandFlavorViewController.swift
//  vivr v4
//
//  Created by max blessen on 12/21/14.
//  Copyright (c) 2014 max blessen. All rights reserved.
//

import UIKit
import Alamofire


class brandFlavorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    let cellIdentifier: String = "reviewCell"
    var revCount:String = ""
    var selectedProduct:String = ""
    var selectedImage:String = ""
    var selectedDescription:String = ""
    var selectedBrand:String = ""
    var selectedProductID:String = ""
    var reviewResults:[JSON]? = []
    
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var taste: UILabel!
    @IBOutlet weak var flavor: UILabel!
    @IBOutlet weak var throat: UILabel!
    @IBOutlet weak var vapor: UILabel!
    
    @IBOutlet weak var numberOfReviews: UILabel!
    @IBOutlet weak var numberOfFavorites: UILabel!
    @IBOutlet weak var nunberOfShares: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("id is \(selectedProductID)")
        loadReviews()
        loadProductData()

    }
    
    override func viewDidAppear(animated: Bool) {
    
        self.reviewTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        //productDescription.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func favoriteSelected(sender: AnyObject) {
        
    }
    
    func loadProductData() {
        productDescription.text = selectedDescription
        productName.text = selectedProduct
        let url = NSURL(string: selectedImage)
        productImage.hnk_setImageFromURL(url!)
        brandName.text = selectedBrand
        
       
        
        
        
    }
    
    func loadReviews() {
        
        let url = "http://mickeyschwab.com/vivr/public/products/\(selectedProductID)/reviews"
        Alamofire.request(.GET, url).responseJSON { (request, response, json, error) in
            if  (json != nil) {
                var jsonOBJ = JSON(json!)
                if let data = jsonOBJ.arrayValue as [JSON]? {
                    self.reviewResults = data
                    self.reviewTableView?.reloadData()
                    self.revCount = String(data.count)
                    self.numberOfReviews.text = self.revCount
                    println("results are \(self.reviewResults)")
                }
                
            }
            
            
        
        
        
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.reviewResults?.count ?? 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: reviewTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as reviewTableViewCell
        cell.review = self.reviewResults?[indexPath.row]
        
        
        return cell
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
