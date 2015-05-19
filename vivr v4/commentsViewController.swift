//
//  commentsViewController.swift
//  vivr v4
//
//  Created by max blessen on 2/24/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

class commentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, VivrCellDelegate {
    

    @IBOutlet weak var flavorName: UILabel!
    @IBOutlet weak var commentsTable: UITableView!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var keyBoardViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentView: UIView!
    
    var reviewID: String = ""
    var productID: String = ""
    var commentResults:[JSON]? = []
    var results:JSON? = ""
    var segueIdentifier:String = ""
    var commentcount:Int?
    var bottomOfReviewPoint:CGPoint?
    var keyboardActive:Bool?
    var titleLabel:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var endKeyboardRecongnizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        self.view.addGestureRecognizer(endKeyboardRecongnizer)
        startObservingKeyboardEvents()
        commentsTable.rowHeight = UITableViewAutomaticDimension

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        configureNavBar()
        loadData()
    }
    
    func configureNavBar() {
    titleLabel = UILabel(frame: CGRectMake(0, 0, 60, 20))
    titleLabel!.text = "Comments"
    titleLabel!.textColor = UIColor.whiteColor()
    titleLabel!.font = UIFont(name: "PTSans-Bold", size: 17)
    self.navigationItem.titleView = titleLabel
    navigationController?.navigationBar.translucent = false
    navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.whiteColor()
    navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyboard() {
        if(keyboardActive == true) {
        commentField.becomeFirstResponder()
        commentField.endEditing(true)
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
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size {
                UIView.animateWithDuration(2, animations: { () -> Void in
                self.keyBoardViewBottomConstraint.constant = keyboardSize.height + 2
                    self.view.layoutIfNeeded()
                    self.keyboardActive = true
                })
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size {
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.keyBoardViewBottomConstraint.constant = 8
                    self.view.layoutIfNeeded()
                    self.keyboardActive = false
                })
            }
        }
    }
    
    func tappedProductButton(cell: vivrCell) {
        self.segueIdentifier = "commentsToProduct"
        productID = cell.productID
        performSegueWithIdentifier(segueIdentifier, sender: cell)
    }
    
    func tappedCommentButton(cell: vivrCell) {
        
    }
    
    func reloadAPI(cell: vivrCell) {
        self.loadData()
    }
    
    @IBAction func submitCommentTapped(sender: AnyObject) {
        let text = commentField.text
        if (text != nil) {
        let parameters: [String : AnyObject] = [
            "description": text
        ]
        
        Alamofire.request(Router.PostComment(productID, reviewID, parameters)).responseJSON { (request, response, json, error) in
            if (error != nil) {
                println("error")
            }
            
        }
            commentField.text = nil
            hideKeyboard()
        }
        else {
            let emptyTextAlert = UIAlertController(title: "oops!", message: "You didnt enter a comment", preferredStyle: UIAlertControllerStyle.Alert)
            emptyTextAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyTextAlert, animated: true, completion: nil)
        }
        loadData()
        commentsTable.reloadData()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            let count = self.commentResults?.count ?? 0
            self.commentcount = count
            switch count {
            case 0:
                return 1
            default:
                return count
                
            }
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 0:
            var theReview = commentsTable.dequeueReusableCellWithIdentifier("review") as vivrCell
            theReview.reviewAndComment = results!
            if let state = results!["current_helpful"].boolValue as Bool? {
                theReview.helpfullState = state 
            }
            theReview.wishlistState = true
            theReview.cellDelegate = self
            return theReview
        default:
            switch commentcount! {
            case 0:
                let emptyCell = commentsTable.dequeueReusableCellWithIdentifier("noCommentCell") as UITableViewCell
                
                return emptyCell
            default:
                var comment = commentsTable.dequeueReusableCellWithIdentifier("comment") as commentCell
                comment.comment = commentResults?[indexPath.row]
                return comment
            }
        }
        
    }
    
    func loadData(){
        Alamofire.request(Router.readComments(productID, reviewID)).responseJSON { (request, response, json, error) in
            println(json)
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let commentData = jsonOBJ["comments"].arrayValue as [JSON]? {
                    self.commentResults = commentData
                }
                if let data = jsonOBJ as JSON? {
                    self.results = data
                    
                }
                self.commentsTable.reloadData()
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier {
        case "commentsToProduct":
            var productVC: brandFlavorViewController = segue.destinationViewController as brandFlavorViewController
            productVC.selectedProductID = self.productID
        default:
            println("noSegue")
            
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
