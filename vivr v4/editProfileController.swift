//
//  SettingsTableController.swift
//  vivr v4
//
//  Created by max blessen on 5/10/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

class editProfileController: UITableViewController {
    @IBOutlet weak var fullName: B68UIFloatLabelTextField!
    @IBOutlet weak var hardWare: B68UIFloatLabelTextField!
    @IBOutlet weak var bio: B68UIFloatLabelTextField!
    @IBOutlet weak var website: B68UIFloatLabelTextField!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var parameters: Dictionary <String,AnyObject> = [:]
    var nameData:Bool = false
    var hardWareData:Bool = false
    var bioData:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        readProfile()
        self.tableView.contentInset = UIEdgeInsetsMake(-40, 0 ,0, 0)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func configureTextFields() {
        fullName.borderStyle = UITextBorderStyle.None
        hardWare.borderStyle = UITextBorderStyle.None
        bio.borderStyle = UITextBorderStyle.None
        //website.borderStyle = UITextBorderStyle.None
    }

    @IBAction func cancelEdit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
        return 5
        
    }
    func readProfile() {
        if let bioText = myData.bio as String? {
            self.bio.text = bioText
        }
        if let hardwareText = myData.hardWare as String? {
            self.hardWare.text = hardwareText
        }
        if let userNameText = myData.myProfileName as String? {
            self.fullName.text = userNameText
        }
        
    }
    
    func checkName(){
        if (fullName.text.isEmpty) {
            nameData = false
        }else if (fullName.text == nil) {
            nameData = false
        }else if (fullName.text == myData.myProfileName) {
            nameData = false
        }else {
            nameData = true
            parameters.updateValue(fullName.text, forKey: "username")
        }
    }
    func checkHardWare(){
        if (hardWare.text.isEmpty) {
            hardWareData = false
        }else if (hardWare.text == nil) {
            hardWareData = false
        }else if (hardWare.text == myData.hardWare) {
            hardWareData = false
        }else {
            hardWareData = true
            parameters.updateValue(hardWare.text, forKey: "hardware")
        }
        
    }
    func checkBio(){
        if (bio.text.isEmpty) {
            bioData = false
        }else if (bio.text == nil) {
            bioData = false
        }else if (bio.text == myData.bio) {
            bioData = false
        }else {
            bioData = true
            parameters.updateValue(bio.text, forKey: "bio")
        }
        
    }
    @IBAction func submit(sender: AnyObject) {
        checkName()
        checkHardWare()
        checkBio()
        
        Alamofire.request(Router.editProfile(parameters)).responseJSON { (request, response, json, error) in
            println(request)
            println(response)
            println(json)
            println(error)
            if (json != nil){
                let jsonOBJ = JSON(json!)
                if let data = jsonOBJ["username"].arrayValue as [JSON]?{
                    if let error = data[0].stringValue as String?{
                    let emptyAlert = UIAlertController(title: "oops!", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(emptyAlert, animated: true, completion: nil)
                }
                }
            }else {
                let emptyAlert = UIAlertController(title: "submitted", message: "Your profile was updated", preferredStyle: UIAlertControllerStyle.Alert)
                emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(emptyAlert, animated: true, completion: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            
        }
    }
    
}


    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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


