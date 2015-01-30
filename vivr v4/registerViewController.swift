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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
