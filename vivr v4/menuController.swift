 //
//  menuController.swift
//  vivr v4
//
//  Created by max blessen on 4/25/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

class menuController: UITableViewController {
    
    @IBOutlet weak var wishListCount: UILabel!
    @IBOutlet weak var reviewsCount: UILabel!
    @IBOutlet weak var favoritesCount: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var favoritesCell: UITableViewCell!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var profile: UITableViewCell!
    
    @IBOutlet weak var boxesCount: UILabel!
    @IBOutlet weak var juicesCount: UILabel!
    @IBOutlet weak var homeLogo: UIImageView!
    @IBOutlet weak var exploreLogo: UIImageView!
    @IBOutlet weak var profileLogo: UIImageView!
    @IBOutlet weak var cartLogo: UIImageView!
    @IBOutlet weak var settingsLogo: UIImageView!
    @IBOutlet weak var aboutLogo: UIImageView!
    @IBOutlet weak var feedBackLogo: UIImageView!
    
    @IBOutlet weak var boxesCheckInButton: UIButton!
    @IBOutlet weak var juicesCheckInButton: UIButton!
    
    @IBOutlet weak var juiceCheckInLabel: UILabel!
    var segueIdentifier:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layoutMargins = UIEdgeInsetsMake(0, -32, 0, 0)
        tableView.preservesSuperviewLayoutMargins = false
        tableView.separatorColor = UIColor.clearColor()
        colorLogos()
        let backgroundImage = UIImage(named: "mobileBackground")
        let imageView = UIImageView(image: backgroundImage)
        imageView.alpha = 0.5
        self.tableView.backgroundView = imageView
    }
    
    func colorLogos() {
        let home = UIImage(named: "vivrHomeLogo")?.imageWithRenderingMode(.AlwaysTemplate)
        let explore = UIImage(named: "thumbUp")?.imageWithRenderingMode(.AlwaysTemplate)
        let profile = UIImage(named: "user_50")?.imageWithRenderingMode(.AlwaysTemplate)
        let cart = UIImage(named: "shopping_cart_empty_50")?.imageWithRenderingMode(.AlwaysTemplate)
        let settings = UIImage(named: "settings-50")?.imageWithRenderingMode(.AlwaysTemplate)
        let about = UIImage(named: "info-50")?.imageWithRenderingMode(.AlwaysTemplate)
        let feedback = UIImage(named: "help-50.png")?.imageWithRenderingMode(.AlwaysTemplate)
        homeLogo.image = home
        exploreLogo.image = explore
        profileLogo.image = profile
        //cartLogo.image = cart
        aboutLogo.image = about
        feedBackLogo.image = feedback
        homeLogo.tintColor = UIColor.lightGrayColor()
        exploreLogo.tintColor = UIColor.lightGrayColor()
        profileLogo.tintColor = UIColor.lightGrayColor()
        //cartLogo.tintColor = UIColor.lightGrayColor()
        aboutLogo.tintColor = UIColor.lightGrayColor()
        feedBackLogo.tintColor = UIColor.lightGrayColor()
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.userName.text = myData.myProfileName
        let userPlaceholderImage = UIImage(named: "user_100")
        self.userImage.image = myData.userImage
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
        self.userImage.clipsToBounds = true
        self.userImage.layer.borderWidth = 3.0
        self.userImage.layer.borderColor = UIColor(white: 1.0, alpha: 0.5).CGColor
        setCountData()
        
        
    }
    
    func setCountData() {
        if let rCount = myData.reviewsCount as Int? {
            juicesCount?.text = "\(rCount)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 7
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let height = UIScreen.mainScreen().bounds.height
        let x = height*0.20
        let rowHeight = height - x
        if indexPath.row == 0 {
            return x
        }
        return rowHeight/6
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    @IBAction func settingsPressed(sender: AnyObject) {
        performSegueWithIdentifier("menuToSettings", sender: self)
    }

    
    @IBAction func juiceCheckInPressed(sender: AnyObject) {
        segueIdentifier = "juiceCheckInSegue"
        performSegueWithIdentifier("juiceCheckInSegue", sender: self)
    }

    @IBAction func juiceCheckInTouchDown(sender: AnyObject) {
        juicesCheckInButton.tintColor = UIColor.whiteColor()
        
    }
    
    @IBAction func juiceCheckInTouchUp(sender: AnyObject) {
        juicesCheckInButton.alpha = 1.0
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

}
