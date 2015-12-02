//
//  VIVRReviewViewController.swift
//  vivr
//
//  Created by max blessen on 11/30/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import UIKit

class VIVRReviewViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var review: UITextView!
    
    var reviewScoreView:VIVRReviewScoreViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instantiateReviewScoreView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // INSTANTIATE REVIEWSCOREVIEW
    // ADD REVIEW SCORE VIEW
    
    func instantiateReviewScoreView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        reviewScoreView = storyboard.instantiateViewControllerWithIdentifier("reviewScore") as! VIVRReviewScoreViewController
        addChildViewController(reviewScoreView!)
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
            review.alpha = 0.5
            
            
            review.selectedTextRange = review.textRangeFromPosition(review.beginningOfDocument, toPosition: review.beginningOfDocument)
            
            return false
        }
            
        else if review.textColor == UIColor.lightGrayColor() && text.characters.count > 0 {
            review.text = nil
            review.textColor = UIColor.blackColor()
            review.alpha = 1.0
        }
        
        return true
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if review.textColor == UIColor.lightGrayColor() {
            review.selectedTextRange = review.textRangeFromPosition(review.beginningOfDocument, toPosition: review.beginningOfDocument)
        }
        
    }


}
