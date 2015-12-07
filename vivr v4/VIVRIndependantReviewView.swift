//
//  independantReviewView.swift
//  
//
//  Created by max blessen on 10/8/15.
//
//
/*
import UIKit

class VIVRIndependantReviewView: UIViewController {

    @IBOutlet weak var topPanel: UIView!
    @IBOutlet weak var bottomPanel: UIView!
    var reviewScoreView: VIVRReviewScoreViewController?
    @IBOutlet weak var actionPanelView: UIView!
    @IBOutlet weak var actionPanelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var actionScoreButton: UIButton!
    @IBOutlet weak var actionReviewButton: UIButton!
    @IBOutlet weak var topPanelHeightconstraint: UIView!
    @IBOutlet weak var reviewText: UITextView!
    
    var keyboardActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addScoreView()
        startObservingKeyboardEvents()
        reviewText.autocorrectionType = UITextAutocorrectionType.No
        // Do any additional setup after loading the view.
    }
    
    func addScoreView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        reviewScoreView = storyboard.instantiateViewControllerWithIdentifier("reviewScore") as? VIVRReviewScoreViewController
        reviewScoreView!.view.frame = CGRectMake(0, 0, self.bottomPanel.frame.width, bottomPanel.frame.height)
        reviewScoreView!.didMoveToParentViewController(self)
        self.bottomPanel.addSubview(reviewScoreView!.view)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        if keyboardActive != true {
            UIView.animateWithDuration(
                // duration
                2.0,
                // delay
                delay: 0.0,
                options: [],
                animations: {
                    self.actionPanelBottomConstraint.constant = keyboardFrame.height
                    self.keyboardActive = true
                    self.view.layoutIfNeeded()
                }, completion: {finished in
                }
            )
            
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        if keyboardActive != false {
            UIView.animateWithDuration(2, animations: { () -> Void in
                self.actionPanelBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
                self.keyboardActive = false
            })
        }
        
    }

    @IBAction func reviewPressed(sender: AnyObject) {
        self.reviewText.becomeFirstResponder()
        UIView.animateWithDuration(
            // duration
            0.2,
            // delay
            delay: 0.0,
            options: [],
            animations: {
                self.bottomPanel.alpha = 0
            }, completion: {finished in
            }
        )
        actionReviewButton.backgroundColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        actionReviewButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        actionScoreButton.backgroundColor = UIColor.whiteColor()
        actionScoreButton.setTitleColor(UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9), forState: .Normal)
        
    }
    
    @IBAction func scorePressed(sender: AnyObject) {
        self.reviewText.resignFirstResponder()
        UIView.animateWithDuration(
            // duration
            0.2,
            // delay
            delay: 0.0,
            options: [],
            animations: {
                self.bottomPanel.alpha = 1
            }, completion: {finished in
            }
        )
        actionReviewButton.backgroundColor = UIColor.whiteColor()
        actionReviewButton.setTitleColor(UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9), forState: .Normal)
        actionScoreButton.backgroundColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        actionScoreButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    

}
*/