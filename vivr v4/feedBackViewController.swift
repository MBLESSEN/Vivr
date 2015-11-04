//
//  feedBackViewController.swift
//  vivr v4
//
//  Created by max blessen on 5/20/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

class feedBackViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var submitbottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var form: UITextView!
    
    var keyboardActive: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let keyboardRecongnizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        self.view.addGestureRecognizer(keyboardRecongnizer)
        startObservingKeyboardEvents()

    }

    override func viewWillAppear(animated: Bool) {
        form.becomeFirstResponder()
    }
    func hideKeyboard() {
        if(keyboardActive == true) {
            self.becomeFirstResponder()
            self.view.endEditing(true)
        }
    }
    
    private func startObservingKeyboardEvents() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func stopObservingKeyboardEvents() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.submitbottomConstraint.constant = keyboardSize.height
                    self.view.layoutIfNeeded()
                    self.keyboardActive = true
                })
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.submitbottomConstraint.constant = -150
                    self.view.layoutIfNeeded()
                    self.keyboardActive = false
                })
    }
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitPressed(sender: AnyObject) {
        if form.text.isEmpty {
            let emptyAlert = UIAlertController(title: "oops!", message: "Please enter your feedback", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        }else {
            let feedBackText = form.text
            let parameters: [String : AnyObject] = [
                "description" : feedBackText
            ]
            
            Alamofire.request(Router.submitFeedback(parameters)).responseJSON { (response) in
                if response.result.isFailure {
                    let emptyAlert = UIAlertController(title: "oops!", message: "You're feedback failed to submit, please try again", preferredStyle: UIAlertControllerStyle.Alert)
                    emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(emptyAlert, animated: true, completion: nil)
                }else {
                    let emptyAlert = UIAlertController(title: "Success!", message: "Thank you for your feedback", preferredStyle: UIAlertControllerStyle.Alert)
                    emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
                    self.dismissViewControllerAnimated(true, completion: nil)}))
                    self.presentViewController(emptyAlert, animated: true, completion: nil)
                }
            }
        }
    }
}
