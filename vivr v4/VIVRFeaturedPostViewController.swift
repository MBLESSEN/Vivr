//
//  blogPostView.swift
//  vivr
//
//  Created by max blessen on 9/27/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class VIVRFeaturedPostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var comments: Array<ActivityFeedReviews>?
    var blog: BlogPost?
    @IBOutlet weak var blogTable: UITableView!
    @IBOutlet weak var commentBottomConstraint: NSLayoutConstraint!
    var keyboardActive = false
    @IBOutlet weak var commentField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObservingKeyboardEvents()
        let endKeyboardRecongnizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        self.view.addGestureRecognizer(endKeyboardRecongnizer)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        configureNavBar()
    }
    
    func hideKeyboard() {
        if(keyboardActive == true) {
            commentField.becomeFirstResponder()
            commentField.endEditing(true)
        }
    }
    
    func configureNavBar() {
        navigationController?.navigationBar.tintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true

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
                    self.commentBottomConstraint.constant = keyboardSize.height + 2
                    self.view.layoutIfNeeded()
                    self.keyboardActive = true
                })
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.commentBottomConstraint.constant = 0
                    self.view.layoutIfNeeded()
                    self.keyboardActive = false
                })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return blogCellAtIndexPath()
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as UITableViewCell!
            return cell
        }
        
    }
    
    func blogCellAtIndexPath() -> blogCell {
        let cell = blogTable.dequeueReusableCellWithIdentifier("postCell") as! blogCell
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell: vivrHeaderCell = tableView.dequeueReusableCellWithIdentifier("ReviewHeaderCell") as! vivrHeaderCell
        headerCell.frame = CGRectMake(0, 0, self.view.frame.width, 40.0)
        let headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 40.0))
        return headerView
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return UITableViewAutomaticDimension
        case 1:
            return 0
        default:
            return 40.0
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300
        }
        return 40.0
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let topCell = blogTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! blogCell
        let contentOffset = scrollView.contentOffset.y
        print(contentOffset, terminator: "")
        if contentOffset < 0 {
            let deltaY = contentOffset
            topCell.blogImageTopConstraint.constant = deltaY
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
