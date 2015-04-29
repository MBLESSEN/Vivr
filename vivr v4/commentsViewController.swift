//
//  commentsViewController.swift
//  vivr v4
//
//  Created by max blessen on 2/24/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

class commentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, VivrCellDelegate {
    

    @IBOutlet weak var flavorName: UILabel!
    @IBOutlet weak var commentsTable: UITableView!
    
    var reviewID: String = ""
    var productID: String = ""
    var commentResults:[JSON]? = []
    var results:JSON? = ""
    var segueIdentifier:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsTable.rowHeight = UITableViewAutomaticDimension

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tappedProductButton(cell: vivrCell) {
        self.segueIdentifier = "commentsToProduct"
        productID = cell.productID
        performSegueWithIdentifier(segueIdentifier, sender: cell)
    }
    
    func tappedCommentButton(cell: vivrCell) {
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return self.commentResults?.count ?? 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 0:
            var theReview = commentsTable.dequeueReusableCellWithIdentifier("review") as vivrCell
            theReview.reviewAndComment = results!
            theReview.cellDelegate = self
            return theReview
        default:
            var comment = commentsTable.dequeueReusableCellWithIdentifier("comment") as commentCell
            comment.comment = commentResults?[indexPath.row]
            return comment
        }
        
    }
    
    func loadData(){
        Alamofire.request(Router.readComments(productID, reviewID)).responseJSON { (request, response, json, error) in
            println(json)
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let commentData = jsonOBJ["comments"].arrayValue as [JSON]? {
                    self.commentResults = commentData
                }
                if let data = jsonOBJ as JSON? {
                    self.results = data
                    
                }
                self.commentsTable.reloadData()
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier {
        case "commentsToProduct":
            var productVC: brandFlavorViewController = segue.destinationViewController as brandFlavorViewController
            productVC.selectedProductID = self.productID
        default:
            println("noSegue")
            
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
