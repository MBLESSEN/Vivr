//
//  ReviewScoreViewController.swift
//  vivr v4
//
//  Created by max blessen on 7/14/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class VIVRReviewScoreViewController: UIViewController {



    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var shadowView: UIButton!
    @IBOutlet weak var scoreBubble: UIView!
    @IBOutlet weak var scoreText: UILabel!
    @IBOutlet weak var scoreSlider: UISlider!
    @IBOutlet weak var vaporController: UISegmentedControl!
    @IBOutlet weak var throatController: UISegmentedControl!
    var reviewScore: String = "2.5"
    var viewDelegate: VIVRProductReviewProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideShadowView()
        self.scoreBubble.alpha = 0.0
        let minImage = UIImage(named: "minTrackImage")
        let maxImage = UIImage(named: "maxTrackImage")
        scoreSlider.minimumValue = 0
        scoreSlider.maximumValue = 5
        scoreSlider.continuous = true
        scoreSlider.tintColor = UIColor(red: 30/255, green: 129/255, blue: 31/255, alpha: 1.0)
        scoreSlider.maximumTrackTintColor = UIColor(red: 30/255, green: 129/255, blue: 31/255, alpha: 0.4)
        scoreSlider.value = 2.5
        scoreSlider.addTarget(self, action: "sliderValueDidChange:", forControlEvents: .ValueChanged)
        scoreSlider.setMinimumTrackImage(minImage, forState: UIControlState.Normal)
        scoreSlider.setMaximumTrackImage(maxImage, forState: UIControlState.Normal)
        self.view.layoutIfNeeded()
        let sliderView = UIView(frame: CGRectMake(0, 0, self.scoreSlider.frame.width, 25))
        sliderView.userInteractionEnabled = false
        sliderView.alpha = 0.4
        sliderView.layer.zPosition = self.scoreSlider.layer.zPosition + 3
        let width = sliderView.frame.width/5 - 3
        var xMarker = CGFloat(0.0)
        for var i = 0; i < 5; i++
        {
            let view = UIView(frame: CGRectMake(xMarker, 0, width, 25))
            view.backgroundColor = UIColor.clearColor()
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.whiteColor().CGColor
            sliderView.addSubview(view)
            xMarker = xMarker + width
        }
        self.scoreSlider.addSubview(sliderView)
        // Do any additional setup after loading the view.
    }
    
    
    func addSliderOverlay() {
        let sliderView = UIView(frame: CGRectMake(0, 0, self.scoreSlider.frame.width, 25))
        sliderView.layer.zPosition = self.scoreSlider.layer.zPosition + 3
        let width = sliderView.frame.width/5
        var xMarker = CGFloat(0.0)
        for var i = 0; i < 5; i++
        {
            let view = UIView(frame: CGRectMake(xMarker, 0, width, 25))
            view.backgroundColor = UIColor.clearColor()
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.whiteColor().CGColor
            sliderView.addSubview(view)
            xMarker = xMarker + width
        }
        self.scoreSlider.addSubview(sliderView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sliderValueDidChange(sender:UISlider!)
    {
        
        let f = sender.value
        
        let nf = NSNumberFormatter()
        nf.numberStyle = .DecimalStyle
        nf.maximumFractionDigits = 1
        // Configure the number formatter to your liking
        let s2 = nf.stringFromNumber(f)
        reviewScore = s2!
        scoreText.text = s2!
        
        let trackRect = self.scoreSlider.trackRectForBounds(self.scoreSlider.bounds)
        let thumbRect = self.scoreSlider.thumbRectForBounds(self.scoreSlider.bounds, trackRect: trackRect, value: self.scoreSlider.value)
        
        
        scoreBubble.center.x = thumbRect.origin.x + self.scoreSlider.frame.origin.x + 16
    }
    
    @IBAction func sliderTouchdown(sender: AnyObject) {
        UIView.animateWithDuration(
            // duration
            0.1,
            // delay
            delay: 0.0,
            options: [],
            animations: {
                let scaleTransform = CGAffineTransformMakeScale(1.3, 1.3)
                self.scoreBubble.transform = scaleTransform
                self.scoreBubble.alpha = 1.0
            }, completion: {finished in
                UIView.animateWithDuration(
                    // duration
                    0.2,
                    // delay
                    delay: 0.0,
                    options: [],
                    animations: {
                        let scaleTransform = CGAffineTransformMakeScale(1, 1)
                        self.scoreBubble.transform = scaleTransform
                    }, completion: {finished in
                        
                    }
                )
            }
        )
    }
    
    @IBAction func sliderTouchup(sender: AnyObject) {
        UIView.animateWithDuration(
            // duration
            0.1,
            // delay
            delay: 0.0,
            options: [],
            animations: {
                self.scoreBubble.alpha = 0.0
            }, completion: {finished in
            }
        )
    }
    @IBAction func sliderTouchUpOutside(sender: AnyObject) {
        UIView.animateWithDuration(
            // duration
            0.1,
            // delay
            delay: 0.0,
            options: [],
            animations: {
                self.scoreBubble.alpha = 0.0
            }, completion: {finished in
            }
        )
    }
    
    func showShadowView(){
        shadowView.hidden = false
        shadowView.userInteractionEnabled = true
    }
    
    func hideShadowView() {
        shadowView.hidden = true
        shadowView.userInteractionEnabled = false
    }
    @IBAction func shadowViewPressed(sender: AnyObject) {
        hideShadowView()
        let parent = parentViewController as! VIVRReviewViewController
        parent.hideKeyboard()
    }
    @IBAction func submitPressed(sender: AnyObject) {
        let parent = parentViewController as? VIVRReviewViewController
        let reviewTextView = parent!.review
        let productId = parent!.product!.productID
        guard let reviewText = reviewTextView.text where reviewText != "What did it taste like?" else {
            
            return
        }
        let parameters: [String:AnyObject!] = [
            "description": reviewText,
            "throat": throatController.selectedSegmentIndex,
            "vapor": vaporController.selectedSegmentIndex,
            "score": scoreSlider.value
        ]
        showActivityIndicatorInButton()
        ActivityFeedReviews.createNewReview("\(productId!)", parameters: parameters, completionHandler: { (reviewWrapper, error) in
            if error != nil {
                self.didNotCompleteReview()
            }else {
                self.completeReview(reviewWrapper!)
            }
        })
        
    }
    
    func completeReview(reviewWrapper: ActivityWrapper) {
        let review = reviewWrapper.ActivityReviews?.first
            self.reviewSuccessInButton()
            NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2), target: self, selector: "callViewDelegateIsReviewSuccessfull", userInfo: nil, repeats: false)
        
    }
    
    func didNotCompleteReview() {
        
    }
    
    func showActivityIndicatorInButton() {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.tag = 1
        submitButton.titleLabel!.text = ""
        activityIndicator.center = submitButton.center
        activityIndicator.center.y = submitButton.frame.minY
        submitButton.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
    }
    
    func reviewSuccessInButton() {
        let checkMark = UIImage(named: "checkmark")
        submitButton.viewWithTag(1)?.removeFromSuperview()
        submitButton.setImage(checkMark, forState: .Normal)
        submitButton.setTitle("Rating submitted!", forState: .Normal)
    }
    
    func callViewDelegateIsReviewSuccessfull() {
        self.viewDelegate?.isReviewSuccessfull!(true)
    }

}
