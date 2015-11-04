//
//  UserLogin.swift
//  vivr v4
//
//  Created by max blessen on 6/10/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

class UserLogin: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        var endKeyboardRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        self.view.addGestureRecognizer(endKeyboardRecognizer)
        
        
        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
    }
    
    
    func hideKeyboard() {
            password.becomeFirstResponder()
            password.endEditing(true)
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
            "username" : email.text,
            "password" : password.text
        ]
        Alamofire.request(Router.requestAccessToken(parameters)).validate().responseJSON { (request, response, json, error) in
            if json != nil {
                let jsonOBJ = JSON(json!)
                myData.authToken = jsonOBJ["access_token"].stringValue
                myData.refreshToken = jsonOBJ["refresh_token"].stringValue
                KeychainWrapper.setString(myData.authToken!, forKey: "authToken")
                KeychainWrapper.setString(myData.refreshToken!, forKey: "refreshToken")
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.loadProfileData()
                self.loginButton.clipsToBounds = true
                UIView.animateWithDuration(
                    // duration
                    0.3,
                    // delay
                    delay: 0.0,
                    options: nil,
                    animations: {
                            self.loginButton.layer.frame = CGRectMake(0, 0, 50, 50)
                    }, completion: {finished in
                        UIView.animateWithDuration(
                            // duration
                            1.0,
                            // delay
                            delay: 0.0,
                            options: nil,
                            animations: {
                            }, completion: {finished in
                                    appDelegate.login()
                                
                            }
                        )
                    }
                )
                UIView.animateWithDuration(
                    // duration
                    1.0,
                    // delay
                    delay: 0.3,
                    options: nil,
                    animations: {
                        self.loginButton.backgroundColor = UIColor.whiteColor()
                    }, completion: {finished in
                    }
                )
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
