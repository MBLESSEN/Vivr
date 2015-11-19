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
        configureNavBar()
        showWalkthrough()
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
    
    func showWalkthrough() {
        let stb = UIStoryboard(name: "Walkthrough", bundle: nil)
        let master = stb.instantiateViewControllerWithIdentifier("master") as! BWWalkthroughViewController
        master.viewDelegate = self
        let pageOne = stb.instantiateViewControllerWithIdentifier("page1") 
        let pageTwo = stb.instantiateViewControllerWithIdentifier("page2") 
        let pageThree = stb.instantiateViewControllerWithIdentifier("page3") 
        let pageFour = stb.instantiateViewControllerWithIdentifier("page4") 
        master.delegate = self
        
        //master.addViewController(pageOne)
        //master.addViewController(pageTwo)
        //master.addViewController(pageThree)
        //master.addViewController(pageFour)
        
        
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
        performSegueWithIdentifier("toLogin", sender: self)
    }
    
    func tappedRegisterButton(view: BWWalkthroughViewController) {
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