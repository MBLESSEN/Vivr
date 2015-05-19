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
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        configurePlaceHolderText()
    }
    
    override func viewWillAppear(animated: Bool) {
        configureNavBar()
    }

    override func didReceiveMemoryWarning() {
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
    }
    
    func configurePlaceHolderText() {
        emailEntered.font = UIFont(name: emailEntered.font.fontName, size: 30)
        userNameEntered.font = UIFont(name: userNameEntered.font.fontName, size: 30)
        passwordEntered.font = UIFont(name: passwordEntered.font.fontName, size: 30)
        confirmPasswordEntered.font = UIFont(name: confirmPasswordEntered.font.fontName, size: 30)
        
    
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
        
        Alamofire.request(.POST, "http://mickeyschwab.com/vivr/public/users", parameters: parameters, encoding: .JSON) 
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
    

}
