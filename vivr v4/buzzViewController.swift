//
//  buzzViewController.swift
//  vivr v4
//
//  Created by max blessen on 12/21/14.
//  Copyright (c) 2014 max blessen. All rights reserved.
//

import UIKit
import Alamofire

class buzzViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mainTable: UITableView!
    @IBOutlet weak var controller: UISegmentedControl!
    
    var cellIdentifier: String = "vivrCell"
    var whatsHot:[JSON]? = []
    var feedReviewResults:[JSON]? = []
    var feedProductResults:[JSON]? = []
    var feedUserResults:[JSON]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var logo = UIImage(named: "logoWhiteBorder")?.imageWithRenderingMode(.AlwaysOriginal)
        var imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        mainTable.estimatedRowHeight = 200.0
        mainTable.rowHeight = UITableViewAutomaticDimension
        loadFeed()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeData(sender: AnyObject) {
        switch controller.selectedSegmentIndex{
        case 0:
            cellIdentifier = "buzzCell"
            mainTable.rowHeight = 200
            mainTable.reloadData()
        case 1:
            cellIdentifier = "vivrCell"
            mainTable.rowHeight = UITableViewAutomaticDimension
            mainTable.reloadData()
        case 2:
            cellIdentifier = "newCell"
            mainTable.reloadData()
        default:
            println("no segment")
            
        }
 
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (cellIdentifier == "vivrCell") {
            return 40.0
        }
        else {
            return 0.0
        }
        
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (cellIdentifier == "vivrCell") {
            let headerCell = mainTable.dequeueReusableCellWithIdentifier("HeaderCell") as vivrHeaderCell
            headerCell.backgroundColor = UIColor.whiteColor()
            return headerCell
        }
        return nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.feedReviewResults?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }

    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch cellIdentifier{
            case "buzzCell":
                var buzzcell = mainTable.dequeueReusableCellWithIdentifier(cellIdentifier) as buzzCell
                return buzzcell
            case "vivrCell":
                var vivrcell = mainTable.dequeueReusableCellWithIdentifier(cellIdentifier) as vivrCell
                vivrcell.review = self.feedReviewResults![indexPath.section]
                return vivrcell
            default:
                var newcell = mainTable.dequeueReusableCellWithIdentifier(cellIdentifier) as newCell
                return newcell

            
            
        }
    }
    
    func loadFeed() {
        Alamofire.request(Router.readFeed()).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let reviewData = jsonOBJ["reviews"].arrayValue as [JSON]? {
                    self.feedReviewResults = reviewData
                }
                if let productData = jsonOBJ["products"].arrayValue as [JSON]? {
                    self.feedProductResults = productData
                }
                if let userData = jsonOBJ["users"].arrayValue as [JSON]? {
                    self.feedUserResults = userData
                }
                self.mainTable.reloadData()
                
            }
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
