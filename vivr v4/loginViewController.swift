//
//  loginViewController.swift
//  vivr v4
//
//  Created by max blessen on 1/30/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire


class loginViewController: UIViewController, BWWalkthroughViewControllerDelegate, loginDelegate {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var walkthroughContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(KeychainService.loadToken())
        configureNavBar()
        if (KeychainService.loadToken() != nil){
            self.performSegueWithIdentifier("loginSuccess", sender: self)
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        showWalkthrough()
        navigationController?.navigationBar.hidden = true
    }
    
    func configureNavBar(){
        let backItem = UIBarButtonItem(title: "", style: .Bordered, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    }
    
    func showWalkthrough() {
        let stb = UIStoryboard(name: "Walkthrough", bundle: nil)
        let master = stb.instantiateViewControllerWithIdentifier("master") as BWWalkthroughViewController
        master.viewDelegate = self
        let pageOne = stb.instantiateViewControllerWithIdentifier("page1") as UIViewController
        let pageTwo = stb.instantiateViewControllerWithIdentifier("page2") as UIViewController
        let pageThree = stb.instantiateViewControllerWithIdentifier("page3") as UIViewController
        let pageFour = stb.instantiateViewControllerWithIdentifier("page4") as UIViewController
        let pageFive = stb.instantiateViewControllerWithIdentifier("page5") as UIViewController
        master.delegate = self
        
        master.addViewController(pageOne)
        master.addViewController(pageTwo)
        master.addViewController(pageThree)
        master.addViewController(pageFour)
        master.addViewController(pageFive)
        
        
        self.addChildViewController(master)
        master.view.frame = self.walkthroughContainer.frame
        walkthroughContainer.addSubview(master.view)
        master.didMoveToParentViewController(self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedLoginButton(view: BWWalkthroughViewController) {
        performSegueWithIdentifier("loginSucess", sender: self)
    }
    
    func tappedRegisterButton(view: BWWalkthroughViewController) {
        performSegueWithIdentifier("registerSegue", sender: self)
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
        
        Alamofire.request(.POST, "http://mickeyschwab.com/vivr-dev/public/oauth/access-token", parameters: parameters).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                    KeychainService.saveToken(jsonOBJ["access_token"].stringValue)
                    self.performSegueWithIdentifier("loginSuccess", sender: self)
                    println("the new access token is \(KeychainService.loadToken())")
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