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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
