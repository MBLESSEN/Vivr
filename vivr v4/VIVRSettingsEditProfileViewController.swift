//
//  SettingsTableController.swift
//  vivr v4
//
//  Created by max blessen on 5/10/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire
import AssetsLibrary
import SwiftyJSON

class VIVRSettingsEditProfileViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var fullName: B68UIFloatLabelTextField!
    @IBOutlet weak var hardWare: B68UIFloatLabelTextField!
    @IBOutlet weak var bio: B68UIFloatLabelTextField!
    @IBOutlet weak var website: B68UIFloatLabelTextField!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var userImage: UIImageView!
    
    var parameters: Dictionary <String,AnyObject> = [:]
    var nameData:Bool = false
    var hardWareData:Bool = false
    var bioData:Bool = false
    var isChangingUserImage = false
    var imageData:NSData?
    
    var delegate:VIVREditAccountProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        self.tableView.contentInset = UIEdgeInsetsMake(-40, 0 ,0, 0)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        readProfile()
        configureNavBar()
    }
    
    func configureNavBar() {
        let navbarFont = UIFont(name: "PTSans-Bold", size: 17) ?? UIFont.systemFontOfSize(17)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor(red: 43.0/255, green: 169.0/255, blue: 41.0/255, alpha: 1.0)
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: navbarFont, NSForegroundColorAttributeName:UIColor.whiteColor()]
    }
    
    func configureTextFields() {
        userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
        userImage.clipsToBounds = true
        userImage.layer.borderWidth = 3.0
        userImage.layer.borderColor = UIColor(white: 1.0, alpha: 0.5).CGColor
        fullName.borderStyle = UITextBorderStyle.None
        hardWare.borderStyle = UITextBorderStyle.None
        bio.borderStyle = UITextBorderStyle.None
        website.borderStyle = UITextBorderStyle.None
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
        if let bioText = myData.user!.bio as String? {
            self.bio.text = bioText
        }
        if let hardwareText = myData.user!.hardWare as String? {
            self.hardWare.text = hardwareText
        }
        if let userNameText = myData.user!.userName as String? {
            self.fullName.text = userNameText
        }
        if let image = myData.userImage as UIImage? {
            userImage.image = image
        }
    }
    
    @IBAction func editUserImage(sender: AnyObject) {
        let pickerC = UIImagePickerController()
        pickerC.delegate = self
        self.presentViewController(pickerC, animated: true, completion: nil)
    }
  
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        myData.userImage = image
        userImage.image = image
        isChangingUserImage = true
    }
    
    func checkName(){
        if (fullName.text!.isEmpty) {
            nameData = false
        }else if (fullName.text == nil) {
            nameData = false
        }else if (fullName.text == myData.user!.userName) {
            nameData = false
        }else {
            nameData = true
            parameters.updateValue(fullName.text!, forKey: "username")
        }
    }
    func checkHardWare(){
        if (hardWare.text!.isEmpty) {
            hardWareData = false
        }else if (hardWare.text == nil) {
            hardWareData = false
        }else if (hardWare.text == myData.user!.hardWare) {
            hardWareData = false
        }else {
            hardWareData = true
            parameters.updateValue(hardWare.text!, forKey: "hardware")
        }
        
    }
    func checkBio(){
        if (bio.text!.isEmpty) {
            bioData = false
        }else if (bio.text == nil) {
            bioData = false
        }else if (bio.text == myData.user!.bio) {
            bioData = false
        }else {
            bioData = true
            parameters.updateValue(bio.text!, forKey: "bio")
        }
        
    }
    @IBAction func submit(sender: AnyObject) {
        checkName()
        checkHardWare()
        checkBio()
        
        Alamofire.request(Router.editProfile(parameters)).responseJSON { (response) in
            let error = response.result.error
            if response.result.isFailure {
                print(error)
            }else {
                let emptyAlert = UIAlertController(title: "submitted", message: "Your profile was updated", preferredStyle: UIAlertControllerStyle.Alert)
                emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                    self.delegate?.reloadProfile()
                }))
                self.presentViewController(emptyAlert, animated: true, completion: nil)
            }
            
            
        }
        if isChangingUserImage == true {
            print("attempting to post", terminator: "")
        createMultipart(myData.userImage, callback: { success in
            print("upload function performed", terminator: "")
            if success {
                print("it posted", terminator: "")
            }
        })
        }
        
    }
    
    func createMultipart(image: UIImage, callback: Bool -> Void){
        // use SwiftyJSON to convert a dictionary to JSON
        let parameterJSON = JSON([
            "id_user": "test"
            ])
        // JSON stringify
        let parameterString = parameterJSON.rawString(NSUTF8StringEncoding, options: [])
        let jsonParameterData = parameterString!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        // convert image to binary
        let imageData = UIImageJPEGRepresentation(image, 0.7)
        // upload is part of AlamoFire
        upload(
            Router.uploadProfile(),
            multipartFormData: { multipartFormData in
                // fileData: puts it in "files"
                multipartFormData.appendBodyPart(data: jsonParameterData!, name: "goesIntoFile", fileName: "json.txt", mimeType: "application/json")
                multipartFormData.appendBodyPart(data: imageData!, name: "file", fileName: "iosFile.jpg", mimeType: "image/jpg")
                // data: puts it in "form"
                multipartFormData.appendBodyPart(data: jsonParameterData!, name: "goesIntoForm")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        callback(true)
                    }
                case .Failure(_):
                    callback(false)
                }
            }
        )
    }
    
    
    //CLEAR TEXTFIELD IB OUTLETS
    
    @IBAction func clearNamePressed(sender: AnyObject) {
        self.fullName.text = ""
    }
    
    @IBAction func clearHardwarePressed(sender: AnyObject) {
        self.hardWare.text = ""
    }
    @IBAction func clearBioPressed(sender: AnyObject) {
        self.bio.text = ""
    }
    
    @IBAction func clearWebsitePressed(sender: AnyObject) {
        self.website.text = ""
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


