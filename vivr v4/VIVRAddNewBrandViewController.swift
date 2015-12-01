//
//  VIVRAddNewBrandViewController.swift
//  vivr
//
//  Created by max blessen on 11/30/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import UIKit

class VIVRAddNewBrandViewController: UIViewController, VIVRDidAddNewBrandProtocol {

    @IBOutlet weak var newBrandTextField: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var submitButtonBottomConstraint: NSLayoutConstraint!
    
    var keyboardActive = false
    var addNewBrandDelegate: VIVRDidAddNewBrandProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObservingKeyboardEvents()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        configureNavBar()
        newBrandTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //NAVIGATION AND VIEW CUSTOMIZATION
    //NAVIGATION IBOUTLET ACTIONS
    //CANCEL VIEW CONTROLLER
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func configureNavBar() {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()    }
    
    //KEYBOARD FUNCTIONS
    //KEYBOARD HANDLER
    
    func hideKeyboard() {
        if keyboardActive == true {
            
        }
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
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.submitButtonBottomConstraint.constant = keyboardSize.height
                    self.view.layoutIfNeeded()
                    self.keyboardActive = true
                })
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.submitButtonBottomConstraint.constant = 0
                    self.view.layoutIfNeeded()
                    self.keyboardActive = false
                })
            }
        }
    }
    
    
    //SUBMIT BUTTON HANDLER
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        if newBrandTextField.text?.isEmpty == false {
            let parameters: [String:AnyObject!] = [
                "name": newBrandTextField.text
            ]
            Brand.createNewBrand(parameters, completionHandler: { (response, error) in
                if response != nil {
                    let alert = UIAlertController(title: "You've created a new brand!", message: "Brand verfication in progress. When your brand is verified you will be able to add products to this brand.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }else {
                    let alert = UIAlertController(title: "Something went wrong", message: "You didnt enter a brand name", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    //PRESENT NEW BRAND CREATED VIEW
    
    func presentNewBrandCreatedView() {
        
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
