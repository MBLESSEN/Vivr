//
//  addFlavorTagsView.swift
//  vivr v4
//
//  Created by max blessen on 5/11/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

protocol flavorTagsDelegate {
    func didSubmit(view: addFlavorTagsView)
    func didCancel(view: addFlavorTagsView)
}

class addFlavorTagsView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tagTable: UITableView!
    @IBOutlet weak var cleatTagsButton: UIButton!
    
    
    @IBOutlet weak var tagCount: UILabel!
    var viewDelegate:flavorTagsDelegate? = nil
    var tagList:Array<Tag>?
    var isLoadingTags = false
    var tagWrapper:TagWrapper?
    var selectedTags:NSMutableArray = []
    var keyboardActive: Bool?
    var endKeyboardRecongnizer = UITapGestureRecognizer()
    var savedTags:NSMutableArray? {
        didSet {
            print(" tags reloading, saved tags set", terminator: "")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let textFieldInsideSearchBar = search.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        tagTable.separatorInset = UIEdgeInsetsZero
        configureButtons()
        endKeyboardRecongnizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        endKeyboardRecongnizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(endKeyboardRecongnizer)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        loadFirstTags()
        configureTableView()
        startObservingKeyboardEvents()
        updateTagCount()
    }
    
    func hideKeyboard() {
        if keyboardActive == true {
        search.becomeFirstResponder()
        search.endEditing(true)
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
        endKeyboardRecongnizer.cancelsTouchesInView = true
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.tableViewBottom.constant = keyboardSize.height
                    self.view.layoutIfNeeded()
                    self.keyboardActive = true
                })
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        endKeyboardRecongnizer.cancelsTouchesInView = false
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.tableViewBottom.constant = 114
                    self.view.layoutIfNeeded()
                    self.keyboardActive = false
                })
    }

    
    func reloadTableViewContent() {
            self.tagTable.reloadData()
    }
    func configureTableView() {
        tagTable.rowHeight = UITableViewAutomaticDimension
        tagTable.estimatedRowHeight = 75
    }
    func configureButtons() {
        let cancel = UIImage(named: "delete")?.imageWithRenderingMode(.AlwaysTemplate)
        let submit = UIImage(named: "thumbUp")?.imageWithRenderingMode(.AlwaysTemplate)
        cancelButton.setImage(cancel, forState: .Normal)
        submitButton.setImage(submit, forState: .Normal)
        cancelButton.layer.cornerRadius = cancelButton.frame.size.width / 2
        cancelButton.clipsToBounds = true
        cancelButton.layer.borderWidth = 2.0
        cancelButton.layer.borderColor = UIColor(red: 39.0/255, green: 129.0/255, blue: 30.0/255, alpha: 1.0).CGColor
        submitButton.layer.cornerRadius = submitButton.frame.size.width / 2
        submitButton.clipsToBounds = true
        submitButton.layer.borderWidth = 2.0
        submitButton.layer.borderColor = UIColor(red: 39.0/255, green: 129.0/255, blue: 30.0/255, alpha: 1.0).CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true , completion: nil)
        viewDelegate?.didCancel(self)

    }

    @IBAction func submit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true , completion: nil)
        viewDelegate?.didSubmit(self)
    }
    
    @IBAction func clearButtonPressed(sender: AnyObject) {
        selectedTags = []
        savedTags = []
        for indexPath:NSIndexPath in tagTable.indexPathsForSelectedRows ?? [] {
            tagTable.deselectRowAtIndexPath(indexPath, animated: true)
            tagTable.cellForRowAtIndexPath(indexPath)?.setSelected(false, animated: false)
        }
        tagCount.text = "0/3"
    }
    
    func updateTagCount() {
        let count = tagTable.indexPathsForSelectedRows?.count ?? 0
        tagCount.text = "\(count)/3"
        
    }
    
    func addTagToSelectedTags(id: Int) {
        selectedTags.addObject(id)
    }
    
    func removeTagFromSelectedTags(id: Int) {
        selectedTags.removeObject(id)
    }

    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if tagTable.indexPathsForSelectedRows != nil{
            if tagTable.indexPathsForSelectedRows!.count > 2 {
                return nil
            }
        }
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tagTable.cellForRowAtIndexPath(indexPath) as! TagCell
        let id = Int(cell.tagID!)
        addTagToSelectedTags(id!)
        updateTagCount()
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tagTable.cellForRowAtIndexPath(indexPath) as! TagCell
        let id = Int(cell.tagID!)
        removeTagFromSelectedTags(id!)
        updateTagCount()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tagCellAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagList?.count ?? 0
    }
    
    func tagCellAtIndexPath(indexPath:NSIndexPath) -> TagCell {
        let cell = tagTable.dequeueReusableCellWithIdentifier("tag") as! TagCell
        if (tagList != nil) {
            let tagIndex = tagList![indexPath.row]
            cell.tagName.text = tagIndex.name
            if let tagID = tagIndex.tagID as Int? {
                cell.tagID = "\(tagID)"
                if savedTags != nil {
                for id in savedTags! {
                    print(" id == \(id)", terminator: "")
                    print(" tagID == \(tagID)", terminator: "")
                    if "\(id)"  == "\(tagID)" {
                        self.tagTable.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
                    }else {
                        cell.setSelected(false, animated: false)
                    }
                }
            }
        }
        }
        let rowsToLoadFromBottom = 5
        let rowsLoaded = self.tagList!.count
        if (!self.isLoadingTags && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
            let totalRows = self.tagWrapper!.count!
            let remainingFeedToLoad = totalRows - rowsLoaded
            if (remainingFeedToLoad > 0) {
                self.loadMoreTags()
            }
        }
        return cell
    }
    
    func loadFirstTags() {
        self.tagList = []
        isLoadingTags = true
        Tag.getTags({ (tagWrapper, error) in
            if tagWrapper == nil {
                print(error, terminator: "")
                self.isLoadingTags = false
                print("no netowrk", terminator: "")
            }else {
                print("second block executed", terminator: "")
                self.addTagFromWrapper(tagWrapper)
                self.isLoadingTags = false
                self.reloadTableViewContent()
            }
        })
    }
    
    func loadMoreTags() {
        isLoadingTags = true
        if self.tagList != nil && self.tagWrapper != nil && self.tagList!.count < self.tagWrapper!.count
        {
            Tag.getMoreTags(self.tagWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingTags = false
                    let alert = UIAlertController(title: "oops", message: "We couldn't load the data, try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }else {
                    self.addTagFromWrapper(moreWrapper)
                    self.isLoadingTags = false
                    self.reloadTableViewContent()
                }
            })
        }
    }
    
    func addTagFromWrapper(wrapper: TagWrapper?) {
        self.tagWrapper = wrapper
        if self.tagList == nil {
            self.tagList = self.tagWrapper?.Tags
        }else if self.tagWrapper != nil && self.tagWrapper!.Tags != nil{
            self.tagList = self.tagList! + self.tagWrapper!.Tags!
        }
        
    }
    


}
