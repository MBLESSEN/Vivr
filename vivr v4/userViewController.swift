//
//  userTableViewController.swift
//  vivr v4
//
//  Created by max blessen on 2/21/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//
import UIKit
import Alamofire

class userViewController: UIViewController, reviewCellDelegate {

    var myFavorites:[JSON]? = []
    var myReviews:[JSON]? = []
    var myUserID: String = ""
    var segueIdentifier: String = ""
    var dataIdentifier:String = "Reviews"
    var reviewsCount:String?
    var favoritesCount:String?
    var commentsCount:String?
    var selectedProductID:String?
    
    @IBOutlet weak var profileTable: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!


    override func viewDidLoad() {
        menuButton.tintColor = UIColor.whiteColor()
        super.viewDidLoad()
        navigationController?.navigationBarHidden = false
        loadProfile()
        profileTable.estimatedRowHeight = 300
        profileTable.rowHeight = UITableViewAutomaticDimension

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    override func viewWillAppear(animated: Bool) {
        profileTable.reloadData()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func favoritesTapped(sender: AnyObject) {
        self.segueIdentifier = "favoriteSegue"
        performSegueWithIdentifier("favoriteSegue", sender: self)
        
    }
    
    func tappedProductbutton(cell: myReviewsCell) {
        self.segueIdentifier = "myUserToFlavor"
        selectedProductID = cell.productID!
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier {
        case "favoriteSegue":
            var favoritesVC: MyFavoritesController = segue.destinationViewController as MyFavoritesController
            favoritesVC.userID = self.myUserID
        case "myUserToFlavor":
            var productVC: brandFlavorViewController = segue.destinationViewController as brandFlavorViewController
            productVC.selectedProductID = self.selectedProductID
        default:
            println("no segue")
            
        }
    }
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            switch section {
                case 0:
                    return 1
                default:
                    return self.myReviews?.count ?? 0
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            var myProfile = profileTable.dequeueReusableCellWithIdentifier("profileCell") as profileCell
            myProfile.favoritesCount.text = "0"
            myProfile.reviewsCount.text = self.reviewsCount ?? "0"
            myProfile.commentsCount.text = self.commentsCount ?? "0"
            return myProfile
        default:
            var reviewCell = profileTable.dequeueReusableCellWithIdentifier("myReviews") as myReviewsCell
            reviewCell.review = self.myReviews?[indexPath.row]
            reviewCell.cellDelegate = self 
            reviewCell.state = "notLiked"
            return reviewCell
        }
    }
    
    
    func loadProfile(){
        
        Alamofire.request(Router.readCurrentUser()).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                    self.myUserID = jsonOBJ["id"].stringValue
                println("your user id is \(self.myUserID)")
                }
            self.loadMyReviews()
            }
        }
        




    func loadMyReviews(){
        
        Alamofire.request(Router.readUserReviews(self.myUserID)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let reviewCount = jsonOBJ["total"].stringValue as String? {
                    self.reviewsCount = reviewCount
                }
                if let data = jsonOBJ["data"].arrayValue as [JSON]? {
                    self.myReviews = data
                    self.profileTable.reloadData()
                   
                }
                
            }
        }
        Alamofire.request(Router.readUserFavorites(self.myUserID)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let favoriteCount = jsonOBJ["total"].stringValue as String? {
                    self.favoritesCount = favoriteCount
                }
            }
        }
        Alamofire.request(Router.readUserComments(self.myUserID)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let commentCount = jsonOBJ["total"].stringValue as String? {
                    self.commentsCount = commentCount
                }
            }
        }
    }
    
}


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

