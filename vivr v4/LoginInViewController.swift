//
//  LoginInViewController.swift
//  vivr
//
//  Created by max blessen on 8/3/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginInViewController: UIViewController {

    @IBOutlet weak var email: B68UIFloatLabelTextField!
    @IBOutlet weak var password: B68UIFloatLabelTextField!
    
    @IBOutlet weak var loginButtonBottomConstraint: NSLayoutConstraint!
    var keyboardActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObservingKeyboardEvents()
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false 
        navigationController?.navigationBar.hidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        email.becomeFirstResponder()
    }
    
    private func startObservingKeyboardEvents() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:Selector("keyboardWillShow:"),
            name:UIKeyboardWillShowNotification,
            object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:Selector("keyboardWillHide:"),
            name:UIKeyboardWillHideNotification,
            object:nil)
    }
    
    private func stopObservingKeyboardEvents() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.loginButtonBottomConstraint.constant = keyboardSize.height
                    self.view.layoutIfNeeded()
                    self.keyboardActive = true
                })
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    self.keyboardActive = false
                })
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        let parameters: [String:AnyObject] = [
            "grant_type" : "password",
            "client_id" : "1",
            "client_secret" : "vapordelivery2015",
            "username" : email.text!,
            "password" : password.text!
        ]
        Alamofire.request(Router.requestAccessToken(parameters)).validate().responseJSON { (response) in
            if response.response?.statusCode != 200 {
                let emptyAlert = UIAlertController(title: "User credentials are invalid", message: "check to make sure your credentials are entered correctly", preferredStyle: UIAlertControllerStyle.Alert)
                emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(emptyAlert, animated: true, completion: nil)
            }else {
                if response.data != nil {
                    let json = response.result.value
                    print(json)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
