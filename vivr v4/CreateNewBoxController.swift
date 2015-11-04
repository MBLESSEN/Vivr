//
//  CreateNewBoxController.swift
//  vivr
//
//  Created by max blessen on 8/24/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

protocol createNewBoxDelegate {
    func hideBlurView(view: CreateNewBoxController)
    func boxCreated()
}

class CreateNewBoxController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var boxName: B68UIFloatLabelTextField!
    @IBOutlet weak var boxDescription: UITextView!
    var viewDelegate: createNewBoxDelegate? = nil
    var editActive = false
    var selectedBoxID: Int?
    
    @IBOutlet weak var leftButton: UIButton!
    
    @IBOutlet weak var rightButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        viewDelegate?.hideBlurView(self)
        boxDescription.textColor = UIColor.blackColor()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func prepareToEdit() {
        self.rightButton.setTitle("CONFIRM", forState: .Normal)
    }
    
    func prepareToCreate() {
        self.boxName.text = ""
        self.boxDescription.text = "Talk about your box"
        boxDescription.textColor = UIColor.lightGrayColor()
        boxDescription.selectedTextRange = boxDescription.textRangeFromPosition(boxDescription.beginningOfDocument, toPosition: boxDescription.beginningOfDocument)
        self.rightButton.setTitle("CREATE", forState: .Normal)
    }

    @IBAction func createPressed(sender: AnyObject) {
        if editActive == false {
        if boxName.text!.isEmpty {
            let emptyAlert = UIAlertController(title: "oops!", message: "Please enter a name for your box", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        }else if boxDescription.text.isEmpty || boxDescription.text == "Talk about your box"  {
            let emptyAlert = UIAlertController(title: "oops!", message: "Please enter a description for your box", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        }
        else {
            let parameters: [String: AnyObject] = [
            "name": boxName.text!,
            "description": boxDescription.text!
            ]
            
            Alamofire.request(Router.createBox(parameters)).responseJSON { (response) in
                self.viewDelegate?.hideBlurView(self)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        }else {
            let parameters: [String: AnyObject] = [
                "name": boxName.text!,
                "description": boxDescription.text!
            ]
            Alamofire.request(Router.editBox(selectedBoxID!, parameters)).responseJSON { (response) in
                self.viewDelegate?.hideBlurView(self)
                self.dismissViewControllerAnimated(true, completion: nil)
                self.viewDelegate?.boxCreated()
                
            }
        }
        
    }
    @IBAction func clearName(sender: AnyObject) {
        boxName.text = ""
    }
    
    @IBAction func clearDescription(sender: AnyObject) {
        boxDescription.text = "Talk about your box"
        boxDescription.textColor = UIColor.lightGrayColor()
        if boxDescription?.textColor == UIColor.lightGrayColor() {
            boxDescription.selectedTextRange = boxDescription.textRangeFromPosition(boxDescription.beginningOfDocument, toPosition: boxDescription.beginningOfDocument)
        }
        boxDescription.becomeFirstResponder()
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let currentText:NSString = boxDescription.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        if updatedText.characters.count == 0 {
            
            boxDescription.text = "Talk about your box"
            boxDescription.textColor = UIColor.lightGrayColor()
            
            
            boxDescription.selectedTextRange = boxDescription.textRangeFromPosition(boxDescription.beginningOfDocument, toPosition: boxDescription.beginningOfDocument)
            
            return false
        }
            
        else if boxDescription.textColor == UIColor.lightGrayColor() && text.characters.count > 0 {
            boxDescription.text = nil
            boxDescription.textColor = UIColor.blackColor()
        }
        
        return true
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if boxDescription?.textColor == UIColor.lightGrayColor() {
            boxDescription.selectedTextRange = boxDescription.textRangeFromPosition(boxDescription.beginningOfDocument, toPosition: boxDescription.beginningOfDocument)
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
