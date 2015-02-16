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
        self.title = selectedBrand
        loadReviews()
        loadProductData()
        reviewTableView.estimatedRowHeight = 60.0
        reviewTableView.rowHeight = UITableViewAutomaticDimension
        

    }
    
    override func viewDidAppear(animated: Bool) {
    
        self.reviewTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        //productDescription.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func favoriteSelected(sender: AnyObject) {
        
        Alamofire.request(Router.Favorite(selectedProductID))
        
    }
    
    func loadProductData() {
        Alamofire.request(Router.ReadProductData(selectedProductID)).responseJSON { (request, response, json, error) in
            if  (json != nil) {
                var jsonOBJ = JSON(json!)
                println(jsonOBJ)
                self.taste.text = String(format: "%.1f", jsonOBJ["scores"]["taste"].floatValue)
                self.flavor.text = String(format: "%.1f", jsonOBJ["scores"]["flavor"].floatValue)

                self.vapor.text = String(format: "%.1f", jsonOBJ["scores"]["vapor"].floatValue)

                self.throat.text = String(format: "%.1f", jsonOBJ["scores"]["throat"].floatValue)
                
            }
        }
        productDescription.text = selectedDescription
        productName.text = selectedProduct
        let url = NSURL(string: selectedImage)
        productImage.hnk_setImageFromURL(url!)
        
        
    }
    
    func loadReviews() {
        Alamofire.request(Router.ReadReviews(selectedProductID)).responseJSON { (request, response, json, error) in
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
        return self.reviewResults?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: reviewTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as reviewTableViewCell
        cell.review = self.reviewResults?[indexPath.section]
        return cell
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerCell = tableView.dequeueReusableCellWithIdentifier("ReviewHeaderCell") as vivrHeaderCell
            headerCell.userInfo = reviewResults?[section]
            headerCell.backgroundColor = UIColor.whiteColor()
            return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var reviewVC: reviewViewController = segue.destinationViewController as reviewViewController
        reviewVC.productID = selectedProductID
    }

}
