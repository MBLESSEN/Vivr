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
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var productImage: UIImageView!
    
    var keyboardActive = false
    var product:Product?
    var reviewScoreView:VIVRReviewScoreViewController?
    var delegate: VIVRReviewProtocol? = nil
    var review: ActivityFeedReviews?
    var isEditingReview: Bool = false
    
    class func editReviewViewWithReview(review: ActivityFeedReviews) -> UINavigationController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigation = storyboard.instantiateViewControllerWithIdentifier("reviewViewControllerNavigationController") as! UINavigationController
        let reviewVC = navigation.viewControllers.first as! VIVRReviewViewController
        reviewVC.review = review
        reviewVC.product = review.product!
        reviewVC.isEditingReview = true
        return navigation
    }
    
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
        switch isEditingReview {
        case true:
            self.reviewTextView.text = self.review!.description!
        case false:
            reviewTextView.textColor = UIColor.lightGrayColor()
            reviewTextView.text = "What did it taste like?"
            reviewTextView.selectedTextRange = reviewTextView.textRangeFromPosition(reviewTextView.beginningOfDocument, toPosition: reviewTextView.beginningOfDocument)
            reviewTextView.becomeFirstResponder()
        }
        if product != nil {
            let url = NSURL(string: product!.image!)
            self.productImage.hnk_setImageFromURL(url!, placeholder: UIImage(named: "vivrLogo"))
        }
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
        reviewScoreView = storyboard.instantiateViewControllerWithIdentifier("reviewScore") as? VIVRReviewScoreViewController
        addChildViewController(reviewScoreView!)
        reviewScoreView!.viewDelegate = self
        reviewScoreView!.view.frame = CGRectMake(0, 0, self.bottomView.frame.width, bottomView.frame.height)
        bottomView.addSubview(reviewScoreView!.view)
        reviewScoreView?.didMoveToParentViewController(self)
        if self.isEditingReview == true {
            self.reviewScoreView?.scoreSlider.setValue(Float((self.review?.score)!), animated: true)
            self.reviewScoreView?.vaporController.selectedSegmentIndex = (self.review?.vapor!)!
            self.reviewScoreView?.throatController.selectedSegmentIndex = (self.review?.throat!)!
        }
    }


    // REVIEW TEXT VIEW DELEGATE FUNCTIONS
    //SET PLACEHOLDER TEXT
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let currentText:NSString = reviewTextView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        if updatedText.characters.count == 0 {
            
            reviewTextView.text = "What did it taste like?"
            reviewTextView.textColor = UIColor.lightGrayColor()
            
            
            reviewTextView.selectedTextRange = reviewTextView.textRangeFromPosition(reviewTextView.beginningOfDocument, toPosition: reviewTextView.beginningOfDocument)
            
            return false
        }
            
        else if reviewTextView.textColor == UIColor.lightGrayColor() && text.characters.count > 0 {
            reviewTextView.text = nil
            reviewTextView.textColor = UIColor.blackColor()
        }
        
        return true
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if reviewTextView.textColor == UIColor.lightGrayColor() {
            reviewTextView.selectedTextRange = reviewTextView.textRangeFromPosition(reviewTextView.beginningOfDocument, toPosition: reviewTextView.beginningOfDocument)
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
            reviewTextView.becomeFirstResponder()
            reviewTextView.endEditing(true)
        }
    }
    
    //VIVRPRODUCT REVIEW PROTOCOL FUNCTIONS
    
    func isReviewSuccessfull(success: Bool) {
        if success == true {
            self.dismissViewControllerAnimated(true, completion: nil)
            self.delegate?.reviewAddedSuccess()
        }
        
    }


}
