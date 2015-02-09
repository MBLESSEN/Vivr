//
//  loginViewController.swift
//  vivr v4
//
//  Created by max blessen on 1/30/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire


class loginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(KeychainService.loadToken())
        if (KeychainService.loadToken() != nil){
            self.performSegueWithIdentifier("loginSuccess", sender: self)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        
   
        if (KeychainService.loadToken() != nil) {
            println(KeychainService.loadToken())
            
            self.performSegueWithIdentifier("loginSuccess", sender: self)
            
        }
        
        else {
        let parameters  : [ String : AnyObject] = [
            "grant_type": "password",
            "client_id": "1",
            "client_secret": "vapordelivery2015",
            "username": username.text,
            "password": password.text
        ]
        
        Alamofire.request(.POST, "http://mickeyschwab.com/vivr/public/oauth/access-token", parameters: parameters).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                    KeychainService.saveToken(jsonOBJ["access_token"].stringValue)
                    self.performSegueWithIdentifier("loginSuccess", sender: self)
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
