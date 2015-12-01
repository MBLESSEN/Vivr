//
//  VIVRAddNewBrandViewController.swift
//  vivr
//
//  Created by max blessen on 11/30/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import UIKit

class VIVRAddNewBrandViewController: UIViewController {

    @IBOutlet weak var newBrandTextField: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var submitButtonBottomConstraint: NSLayoutConstraint!
    
    var keyboardActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObservingKeyboardEvents()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        newBrandTextField.becomeFirstResponder()
        configureNavBar()
        self.view.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //NAVIGATION AND VIEW CUSTOMIZATION
    
    func configureNavBar() {
        navigationBar.translucent = true
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationBar.shadowImage = UIImage()    }
    
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
                UIView.animateWithDuration(2, animations: { () -> Void in
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
                UIView.animateWithDuration(2, animations: { () -> Void in
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
                    
                }else {
                    let alert = UIAlertController(title: "Something went wrong", message: "You didnt enter a brand name", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                }
            })
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
