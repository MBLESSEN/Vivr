//
//  reviewViewController.swift
//  vivr v4
//
//  Created by max blessen on 12/22/14.
//  Copyright (c) 2014 max blessen. All rights reserved.
//

import UIKit
import Alamofire

class reviewViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, flavorTagsDelegate {

    var lastTasteStep: Float!
    var stepValue: Float!
    var productID:String = ""
    var blurView:UIView = UIView()
    
    
    @IBOutlet weak var reviewNavBar: UINavigationBar!
    @IBOutlet weak var reviewText: UITextView!
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var vaporControl: UISegmentedControl!
    @IBOutlet weak var throatControl: UISegmentedControl!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        self.view.preservesSuperviewLayoutMargins = true
        configureNavBar()
        println(productID)
        super.viewDidLoad()
        stepValue = 1
        clearButton.enabled = false
        clearButton.title = ""
        reviewText.text = "Write a comment..."
        reviewText.textColor = UIColor.lightGrayColor()
        var endKeyboardRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        var endKeyboardRecognizer2 = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        var endKeyboardRecognizer3 = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        var endKeyboardRecognizer4 = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        topView.addGestureRecognizer(endKeyboardRecognizer)
        floatRatingView.addGestureRecognizer(endKeyboardRecognizer2)
        middleView.addGestureRecognizer(endKeyboardRecognizer3)
        //lastTasteStep = tasteSlider.value / stepValue
        

        // Do any additional setup after loading the view.
    }
    
    func configureNavBar() {
    }

    func hideKeyboard() {
        reviewText.becomeFirstResponder()
        reviewText.endEditing(true)
        self.clearButton.title = ""
        self.clearButton.enabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.clearButton.enabled = true
        self.clearButton.title = "clear"
        if reviewText.textColor == UIColor.lightGrayColor() {
            reviewText.text = nil
            reviewText.textColor = UIColor.blackColor()
        }
    }
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            reviewText.text = "Write a comment..."
            reviewText.textColor = UIColor.lightGrayColor()
        }
    }
    
    func didSubmit(view: addFlavorTagsView) {
        blurView.removeFromSuperview()
    }
    
    func didCancel(view: addFlavorTagsView) {
        blurView.removeFromSuperview()
    }
    

    
    @IBAction func addTags(sender: AnyObject) {
        var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        blurView.frame = self.view.bounds
        blurView.backgroundColor = UIColor.blackColor()
        blurView.alpha = 0.8
        self.view.addSubview(blurView)
        var tags: addFlavorTagsView = storyboard.instantiateViewControllerWithIdentifier("tags") as! addFlavorTagsView
        tags.viewDelegate = self
        self.presentViewController(tags, animated: true, completion: nil)
    }
    @IBAction func clearText(sender: AnyObject) {
        reviewText.text = ""
        reviewText.textColor = UIColor.lightGrayColor()
    }
    
    
    @IBAction func submitPressed(sender: AnyObject) {
        if reviewText.text.isEmpty {
            let emptyAlert = UIAlertController(title: "oops!", message: "Please enter a review", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        }
        switch reviewText.text {
        case nil:
            let emptyAlert = UIAlertController(title: "oops!", message: "Please enter a review", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        case "Write a comment...":
            let emptyAlert = UIAlertController(title: "oops!", message: "Please enter a review", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        default:
            let vapor = (vaporControl.selectedSegmentIndex + 1)
            let throat = (throatControl.selectedSegmentIndex + 1)
            let score = self.floatRatingView.rating + 1
            
            let parameters: [ String : AnyObject] = [
                "throat": throat,
                "vapor": vapor,
                "description": reviewText.text,
                "score": score
                
            ]
            
            
            Alamofire.request(Router.AddReview(productID, parameters)).responseJSON { (request, response, json, error) in
                println(request)
                println(response)
                println(json)
                println(error)
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
            
        }
    }
    
    
}
    
    
    
    /*
    @IBAction func flavorChanged(sender: AnyObject) {
        var newStep:Float = roundf((flavorSlider.value) / stepValue)
        
        flavorSlider.value = newStep * stepValue
        dump(flavorSlider.value)
    }
    @IBAction func hitChanged(sender: AnyObject) {
        var newStep:Float = roundf((hitSlider.value) / stepValue)
        
        hitSlider.value = newStep * stepValue
        dump(hitSlider.value)
    }
    @IBAction func vaporChanged(sender: AnyObject) {
        var newStep:Float = roundf((vaporSlider.value) / stepValue)
        
        vaporSlider.value = newStep * stepValue
        dump(vaporSlider.value)
    }
    @IBAction func tasteChanged(sender: AnyObject) {
        

        var newStep:Float = roundf((tasteSlider.value) / stepValue)
        
        tasteSlider.value = newStep * stepValue
        dump(tasteSlider.value)
        
        
    }

    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func submitReview(sender: AnyObject) {
        
        let flavor = flavorSlider.value
        let taste = tasteSlider.value
        let vapor = vaporSlider.value
        let throat = hitSlider.value
        
        
        let parameters: [ String : AnyObject] = [
        "throat": throat,
        "vapor": vapor,
        "taste": taste,
        "flavor": flavor,
        "description": reviewContent.text
        
        ]

        Alamofire.request(Router.AddReview(productID, parameters)).responseJSON { (request, response, json, error) in
            println(request)
            println(response)
            println(json)
            println(error)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


