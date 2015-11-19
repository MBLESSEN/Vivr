//
//  registerViewController.swift
//  vivr v4
//
//  Created by max blessen on 1/29/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

class registerViewController: UIViewController {

    @IBOutlet weak var emailEntered: UITextField!
    @IBOutlet weak var userNameEntered: UITextField!
    @IBOutlet weak var passwordEntered: UITextField!
    @IBOutlet weak var confirmPasswordEntered: UITextField!
    @IBOutlet weak var DOBEntered: UITextField!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var createButton: UIButton!
    
    var registerLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailEntered.borderStyle = UITextBorderStyle.None
        userNameEntered.borderStyle = UITextBorderStyle.None
        passwordEntered.borderStyle = UITextBorderStyle.None
        confirmPasswordEntered.borderStyle = UITextBorderStyle.None
        configurePlaceHolderText()
    }
    
    override func viewWillAppear(animated: Bool) {
        configureNavBar()
    }

    override func didReceiveMemoryWarning() {
        self.navigationController?.navigationBarHidden = false 
        super.didReceiveMemoryWarning()
    }
    func configureNavBar() {
        registerLabel = UILabel(frame: CGRectMake(0, 0, 60, 20))
        registerLabel.text = "Sign Up"
        registerLabel.textColor = UIColor.whiteColor()
        registerLabel.font = UIFont(name: "PTSans-Bold", size: 17)
        self.navigationItem.titleView = registerLabel
        navigationController?.navigationBar.hidden = false
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.translucent = true
    }
    
    func configurePlaceHolderText() {
        emailEntered.font = UIFont(name: emailEntered.font.fontName, size: 15)
        userNameEntered.font = UIFont(name: userNameEntered.font.fontName, size: 15)
        passwordEntered.font = UIFont(name: passwordEntered.font.fontName, size: 15)
        confirmPasswordEntered.font = UIFont(name: confirmPasswordEntered.font.fontName, size: 15)
        
    
    }
    
    @IBAction func submitAccount(sender: AnyObject) {
        let parameters: [ String : AnyObject] = [
            "email": emailEntered.text,
            "username": userNameEntered.text,
            "password": passwordEntered.text,
            "password_confirmation": confirmPasswordEntered.text
        ]
        let ageAlert = UIAlertController(title: "Verify your Age", message: "Are you over 18?", preferredStyle: UIAlertControllerStyle.Alert)
            ageAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: nil))
            ageAlert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        //self.presentViewController(ageAlert, animated: true, completion: nil)
        self.dismissViewControllerAnimated(true , completion: nil)

    }
    
    
    @IBAction func submit(sender: AnyObject) {
        
        let parameters: [ String : AnyObject] = [
            "email": emailEntered.text,
            "username": userNameEntered.text,
            "password": passwordEntered.text,
            "password_confirmation": confirmPasswordEntered.text
        ]
        
        Alamofire.request(Router.registerNewUser(parameters)).validate().responseJSON { (request, response, json, error) in
            println(request)
            println(response)
            println(json)
            if json != nil {
                let data = JSON(json!)
                let username = data["email"].stringValue
                let password = self.passwordEntered.text
                let tokenParameters: [String:AnyObject] = [
                    "grant_type": "password",
                    "client_id": "1",
                    "client_secret": "vapordelivery2015",
                    "username": username,
                    "password": password
                ]
                
                Alamofire.request(Router.requestAccessToken(tokenParameters)).validate().responseJSON { (request, response, json, error) in
                    println(request)
                    println(response)
                    println(json)
                    if json != nil {
                        let jsonOBJ = JSON(json!)
                        myData.authToken = jsonOBJ["access_token"].stringValue
                        myData.refreshToken = jsonOBJ["refresh_token"].stringValue
                        KeychainWrapper.setString(myData.authToken!, forKey: "authToken")
                        KeychainWrapper.setString(myData.refreshToken!, forKey: "refreshToken")
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.loadProfileData()
                        appDelegate.login()
                        
                    }
                }
                
                    
            }

        }
        
    }

    

}
