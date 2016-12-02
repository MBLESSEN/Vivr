//
//  commentsViewController.swift
//  vivr v4
//
//  Created by max blessen on 2/24/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NextGrowingTextView

class VIVRCommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, VivrCellDelegate, CommentCellDelegate, VIVRJuiceTaggerProtocol, UITextViewDelegate{
    

    @IBOutlet weak var flavorName: UILabel!
    @IBOutlet weak var commentsTable: UITableView!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var keyBoardViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commetTextView: NextGrowingTextView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    var selectedUserID:String?
    var reviewID: String = ""
    var productID: String = ""
    var commentResults:[SwiftyJSON.JSON]? = []
    var results:SwiftyJSON.JSON? = ""
    var productResults:SwiftyJSON.JSON? = ""
    var segueIdentifier:String = ""
    var commentcount:Int?
    var bottomOfReviewPoint:CGPoint?
    var keyboardActive:Bool?
    var titleLabel:UILabel?
    var activeWishlistContainer:UIView?
    var review: ActivityFeedReviews?
    var juiceTagger: VIVRSearchViewController?
    var tagger = VIVRTagger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let endKeyboardRecongnizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        self.view.addGestureRecognizer(endKeyboardRecongnizer)
        startObservingKeyboardEvents()
        configureNavBarTitle()
        tagger.delegate = self
        commetTextView.maxNumberOfLines = 4
        commetTextView.textContainer.maximumNumberOfLines = 4
        self.commetTextView.delegates.shouldChangeTextInRange = { (textView, range, text) -> Bool in
            self.watchForTagger(textView, text: text, range: range)
            return textView.text.characters.count + (text.characters.count - range.length) <= 140
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        configureNavBar()
        loadData()
        configureTableView()
        self.tabBarController!.tabBar.hidden = true
    }
    
    func configureNavBarTitle() {
        titleLabel = UILabel(frame: CGRectMake(0, 0, 60, 20))
        titleLabel!.text = "Comments"
        titleLabel!.textColor = UIColor.whiteColor()
        titleLabel!.font = UIFont(name: "PTSans-Bold", size: 17)
        self.navigationItem.titleView = titleLabel
    }
    
    func configureNavBar() {
    navigationController?.navigationBar.translucent = false
    navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.whiteColor()
    navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyboard() {
        if(keyboardActive == true) {
        }
    }
    
    func configureTableView() {
        commentsTable.estimatedRowHeight = 700 
        commentsTable.rowHeight = UITableViewAutomaticDimension
    }
    
    func watchForTagger(textView: UITextView, text: String, range: NSRange) {
        print(text)
        print(range)
        tagger.watchForJuiceTag(textView, text: text, range: range, completion: { (taggerActive) in
            if taggerActive == true {
                self.presentJuiceTaggerView()
            }else {
                self.hideTaggerView()
            }
            
        })
    }
    
//    func textViewDidChange(textView: UITextView) {
//        tagger.watchForJuiceTag(textView, completion: { (juiceTaggerActive) in
//            if juiceTaggerActive == true {
//                let searchText = textView.text.stringByReplacingOccurrencesOfString("@", withString: "")
//                print(searchText)
//                self.juiceTagger!.searchTextCount = searchText.characters.count
//                if searchText.characters.count >= 3 {
//                    if let searchString = textView.text!.stringByReplacingOccurrencesOfString(" ", withString: "_") as String! {
//                        if searchString.characters.count >= 3 {
//                            self.juiceTagger!.loadFirstSearch(searchString)
//                        }else {
//                            let emptyAlert = UIAlertController(title: "oops!", message: "search must be atleast 3 letters long", preferredStyle: UIAlertControllerStyle.Alert)
//                            emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//                            self.presentViewController(emptyAlert, animated: true, completion: nil)
//                        }
//                    }
//                }
//                if searchText == "@" {
//                    self.juiceTagger!.clearSearch()
//                }else if searchText.characters.count == 0 {
//                    self.juiceTagger!.clearSearch()
//                }
//            }
//        })
//        
//    }

    func presentJuiceTaggerView() {
        if self.juiceTagger == nil {
            self.juiceTagger = VIVRTagger.createJuiceTaggerView()
        }
        self.addChildViewController(juiceTagger!)
        self.commentsTable.addSubview((juiceTagger?.view)!)
    }
    
    func hideTaggerView() {
        self.juiceTagger?.view.removeFromSuperview()
        self.juiceTagger?.removeFromParentViewController()
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
                    self.keyBoardViewBottomConstraint.constant = keyboardSize.height
                    self.tableViewBottomConstraint.constant = 48 + keyboardSize.height
                    self.view.layoutIfNeeded()
                    self.keyboardActive = true
                })
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.keyBoardViewBottomConstraint.constant = 0
                    self.tableViewBottomConstraint.constant = 48
                    self.view.layoutIfNeeded()
                    self.keyboardActive = false
                })
    }
    
    func tappedProductButton(cell: vivrCell) {
        self.segueIdentifier = "commentsToProduct"
        productID = cell.productID
        performSegueWithIdentifier(segueIdentifier, sender: cell)
    }
    
    func tappedCommentButton(cell: vivrCell) {
        
    }
    
    func tappedMoreButton(cell: vivrCell) {
        
        
    }
    
    func helpfulTrue(cell: vivrCell) {
        cell.helpfullState = true
        review!.currentHelpful = true
        review!.helpfulCount = review!.helpfulCount! + 1
        if let helpfulCount = self.review!.helpfulCount {
        switch helpfulCount {
        case 0:
            cell.helpfullLabel.text = "Was this helpful?"
        default:
            cell.helpfullLabel.text = "\(helpfulCount) found this helpful"
        }
        }
        
    }
    func helpfulFalse(cell: vivrCell) {
        cell.helpfullState = false
        review!.currentHelpful = false
        review!.helpfulCount = review!.helpfulCount! - 1
        if let helpfulCount = self.review!.helpfulCount {
        switch helpfulCount {
        case 0:
            cell.helpfullLabel.text = "Was this helpful?"
        default:
            cell.helpfullLabel.text = "\(helpfulCount) found this helpful"
        }
        }
        
    }
    
    func wishlistTrue(cell: vivrCell) {
        activeWishlistContainer = UIView(frame: cell.productImageWrapper.bounds)
        cell.productImageWrapper.addSubview(activeWishlistContainer!)
        activeWishlistContainer?.userInteractionEnabled = false
        let circle = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
        circle.layer.cornerRadius = 25.0
        
        let startingColor = UIColor(red: (118/255.0), green: (48.0/255.0), blue: (157/255.0), alpha: 1.0)
        circle.backgroundColor = startingColor
        
        activeWishlistContainer!.addSubview(circle)
        circle.center = CGPointMake(activeWishlistContainer!.bounds.width/2, activeWishlistContainer!.bounds.height/2)
        activeWishlistContainer!.clipsToBounds = true
        print(circle.frame, terminator: "")
        let plus = UIImage(named: "plusWhite")
        let plusImage = UIImageView(image: plus)
        plusImage.frame = CGRectMake(0, 0, 25, 25)
        self.activeWishlistContainer!.addSubview(plusImage)
        plusImage.center = circle.center
        UIView.animateWithDuration(
            // duration
            0.15,
            // delay
            delay: 0.3,
            options: [],
            animations: {
                
                let scaleTransform = CGAffineTransformMakeScale(10.0, 10.0)
                
                circle.transform = scaleTransform
                
            }, completion: {finished in
                UIView.animateWithDuration(
                    // duration
                    0.2,
                    // delay
                    delay: 0.1,
                    options: [],
                    animations: {
                        plusImage.frame.offsetInPlace(dx: -80, dy: 0)
                        
                    }, completion: {finished in
                        let label = UILabel(frame: CGRectMake(0, 0, 160, 25))
                        label.text = "Added to wishlist"
                        label.font = UIFont(name: "PTSans-Bold", size: 20)
                        label.textColor = UIColor.whiteColor()
                        self.activeWishlistContainer!.addSubview(label)
                        label.center = circle.center
                        label.frame.offsetInPlace(dx: 400, dy: 0)
                        UIView.animateWithDuration(
                            // duration
                            0.1,
                            // delay
                            delay: 0,
                            options: [],
                            animations: {
                                label.frame.offsetInPlace(dx: -386, dy: 0)
                                
                            }, completion: {finished in
                                UIView.animateWithDuration(
                                    // duration
                                    1.2,
                                    // delay
                                    delay: 0.1,
                                    options: [],
                                    animations: {
                                        circle.alpha = 0.0
                                        label.alpha = 0.0
                                        plusImage.alpha = 0.0
                                        
                                    }, completion: {finished in
                                        //self.reloadAPI(cell)
                                    }
                                )
                            }
                        )
                    }
                )
                
            }
        )
        

        
    }
    func wishlistFalse(cell: vivrCell) {
        activeWishlistContainer = UIView(frame: cell.productImageWrapper.bounds)
        cell.productImageWrapper.addSubview(activeWishlistContainer!)
        activeWishlistContainer?.userInteractionEnabled = false
        let circle = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
        circle.layer.cornerRadius = 25.0
        
        let startingColor = UIColor(red: (118/255.0), green: (48.0/255.0), blue: (157/255.0), alpha: 1.0)
        circle.backgroundColor = startingColor
        
        activeWishlistContainer!.addSubview(circle)
        circle.center = CGPointMake(activeWishlistContainer!.bounds.width/2, activeWishlistContainer!.bounds.height/2)
        activeWishlistContainer!.clipsToBounds = true
        print(circle.frame, terminator: "")
        let plus = UIImage(named: "minusWhite")
        let plusImage = UIImageView(image: plus)
        plusImage.frame = CGRectMake(0, 0, 25, 25)
        self.activeWishlistContainer!.addSubview(plusImage)
        plusImage.center = circle.center
        UIView.animateWithDuration(
            // duration
            0.15,
            // delay
            delay: 0.3,
            options: [],
            animations: {
                
                let scaleTransform = CGAffineTransformMakeScale(10.0, 10.0)
                
                circle.transform = scaleTransform
                
            }, completion: {finished in
                UIView.animateWithDuration(
                    // duration
                    0.2,
                    // delay
                    delay: 0.1,
                    options: [],
                    animations: {
                        plusImage.frame.offsetInPlace(dx: -100, dy: 0)
                        
                    }, completion: {finished in
                        let label = UILabel(frame: CGRectMake(0, 0, 200, 25))
                        label.text = "Removed from wishlist"
                        label.font = UIFont(name: "PTSans-Bold", size: 20)
                        label.textColor = UIColor.whiteColor()
                        self.activeWishlistContainer!.addSubview(label)
                        label.center = circle.center
                        label.frame.offsetInPlace(dx: 400, dy: 0)
                        UIView.animateWithDuration(
                            // duration
                            0.1,
                            // delay
                            delay: 0,
                            options: [],
                            animations: {
                                label.frame.offsetInPlace(dx: -386, dy: 0)
                                
                            }, completion: {finished in
                                UIView.animateWithDuration(
                                    // duration
                                    1.2,
                                    // delay
                                    delay: 0.1,
                                    options: [],
                                    animations: {
                                        circle.alpha = 0.0
                                        label.alpha = 0.0
                                        plusImage.alpha = 0.0
                                        
                                    }, completion: {finished in
                                        //self.reloadAPI(cell)
                                    }
                                )
                            }
                        )
                    }
                )
                
            }
        )
      
        
    }
    
    func tappedUserButton(cell: vivrCell) {
        self.segueIdentifier = "toUserSegue"
        selectedUserID = cell.userID!
        performSegueWithIdentifier(segueIdentifier, sender: cell)
    }
    
   func tappedCommentUserButton(cell: commentCell) {
        self.segueIdentifier = "toUserSegue"
        selectedUserID = cell.userID!
        performSegueWithIdentifier(segueIdentifier, sender: cell)
    }
    
    func reloadAPI(cell: vivrCell) {
        self.loadData()
    }
    
    
    
    @IBAction func submitCommentTapped(sender: AnyObject) {
        let text = commentField.text
        if (text != nil) {
        let parameters: [String : AnyObject] = [
            "description": text!
        ]
        
        Alamofire.request(Router.PostComment(productID, reviewID, parameters)).responseJSON { (response) in
            if (response.result.isFailure) {
                print("error")
            }else{
                self.commentField.text = ""
                self.hideKeyboard()
                self.loadData()
                print("success")
            }
            
        }

        }
        else {
            let emptyTextAlert = UIAlertController(title: "oops!", message: "You didnt enter a comment", preferredStyle: UIAlertControllerStyle.Alert)
            emptyTextAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyTextAlert, animated: true, completion: nil)
        }
        
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
            let theReview = commentsTable.dequeueReusableCellWithIdentifier("review") as! vivrCell
            if review != nil {
            theReview.review = review
            theReview.cellDelegate = self
            theReview.preservesSuperviewLayoutMargins = false
            }
            return theReview
        default:
            switch commentcount! {
            case 0:
                let emptyCell = commentsTable.dequeueReusableCellWithIdentifier("noCommentCell") as UITableViewCell!
                
                return emptyCell
            default:
                let comment = commentsTable.dequeueReusableCellWithIdentifier("comment") as! commentCell
                comment.comment = commentResults?[indexPath.row]
                comment.cellDelegate = self 
                comment.preservesSuperviewLayoutMargins = false 
                return comment
            }
        }
        
    }
    
    func loadData(){
        Alamofire.request(Router.readComments(productID, reviewID)).responseJSON { (response) in
            print(response.response?.statusCode)
            if (response.response?.statusCode == 200) {
                let json = response.result.value
                var jsonOBJ = JSON(json!)
                if let commentData = jsonOBJ["data"].arrayValue as [JSON]? {
                    self.commentResults = commentData
                }
                self.commentsTable.reloadData()
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier {
        case "commentsToProduct":
            let productVC: VIVRProductViewController = segue.destinationViewController as! VIVRProductViewController
            productVC.selectedProductID = self.productID
        case "toUserSegue":
            let userVC: VIVRUserViewController = segue.destinationViewController as! VIVRUserViewController
            userVC.selectedUserID = self.selectedUserID
        default:
            print("noSegue", terminator: "")
            
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
