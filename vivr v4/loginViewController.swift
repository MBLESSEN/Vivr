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
    @IBOutlet weak var walkthroughContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        navigationController?.navigationBar.hidden = true
    }
    
    func configureNavBar(){
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
            performSegueWithIdentifier("toLogin", sender: self)
    }
    @IBAction func signupPressed(sender: AnyObject) {
        performSegueWithIdentifier("toRegister", sender: self)
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