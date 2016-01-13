//
//  VIVRReviewViewController.swift
//  vivr
//
//  Created by max blessen on 11/30/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import UIKit

class VIVRReviewViewController: UIViewController, UITextViewDelegate, VIVRProductReviewProtocol {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var review: UITextView!
    @IBOutlet weak var productImage: UIImageView!
    
    var keyboardActive = false
    var product:Product?
    var reviewScoreView:VIVRReviewScoreViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instantiateReviewScoreView()
        startObservingKeyboardEvents()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        setupViewController()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViewController() {
        if product != nil {
            let url = NSURL(string: product!.image!)
            self.productImage.hnk_setImageFromURL(url!, placeholder: UIImage(named: "vivrLogo"))
        }
        review.textColor = UIColor.lightGrayColor()
        review.text = "What did it taste like?"
        review.selectedTextRange = review.textRangeFromPosition(review.beginningOfDocument, toPosition: review.beginningOfDocument)
        review.becomeFirstResponder()
    }
    
    
    //IB OUTLET FUNCTIONS
    //CANCEL REVIEWVIEW
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    // INSTANTIATE REVIEWSCOREVIEW
    // ADD REVIEW SCORE VIEW
    
    func instantiateReviewScoreView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        reviewScoreView = storyboard.instantiateViewControllerWithIdentifier("reviewScore") as! VIVRReviewScoreViewController
        addChildViewController(reviewScoreView!)
        reviewScoreView!.viewDelegate = self
        reviewScoreView!.view.frame = CGRectMake(0, 0, self.bottomView.frame.width, bottomView.frame.height)
        bottomView.addSubview(reviewScoreView!.view)
        reviewScoreView?.didMoveToParentViewController(self)
    }


    // REVIEW TEXT VIEW DELEGATE FUNCTIONS
    //SET PLACEHOLDER TEXT
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let currentText:NSString = review.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        if updatedText.characters.count == 0 {
            
            review.text = "What did it taste like?"
            review.textColor = UIColor.lightGrayColor()
            
            
            review.selectedTextRange = review.textRangeFromPosition(review.beginningOfDocument, toPosition: review.beginningOfDocument)
            
            return false
        }
            
        else if review.textColor == UIColor.lightGrayColor() && text.characters.count > 0 {
            review.text = nil
            review.textColor = UIColor.blackColor()
        }
        
        return true
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if review.textColor == UIColor.lightGrayColor() {
            review.selectedTextRange = review.textRangeFromPosition(review.beginningOfDocument, toPosition: review.beginningOfDocument)
        }
        
    }
    
    //KEYBOARD DELEGATE FUNCTIONS
    
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
        reviewScoreView?.showShadowView()
        keyboardActive = true
    }
    func keyboardWillHide(notification: NSNotification) {
        reviewScoreView?.hideShadowView()
        keyboardActive = false
    }
    
    func hideKeyboard() {
        if(keyboardActive == true) {
            review.becomeFirstResponder()
            review.endEditing(true)
        }
    }
    
    //VIVRPRODUCT REVIEW PROTOCOL FUNCTIONS
    
    func isReviewSuccessfull(success: Bool) {
        if success == true {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }


}
