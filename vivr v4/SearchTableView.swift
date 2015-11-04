//
//  SearchTableView.swift
//  vivr v4
//
//  Created by max blessen on 6/2/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//
/*
import UIKit
import Alamofire

class SearchTableView: UITableViewController  {
    
    var viewDelegate: searchDelegate? = nil
    var productResults:[JSON]?
    var brandResults:[JSON]?
    var userResults:[JSON]?
    var didLoadSearch = false
    var segueIdentifier:String?
    var selectedID:String?
    var selectedView: UIView = UIView()
    var juiceSearch:Bool?
    
    var endKeyboardRecongnizer = UITapGestureRecognizer()
    var keyboardActive: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObservingKeyboardEvents()
        endKeyboardRecongnizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        endKeyboardRecongnizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(endKeyboardRecongnizer)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        didLoadSearch = false
    }
    
    func hideKeyboard() {
        if keyboardActive == true {
            viewDelegate?.hideKeyboard(self)
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
                    self.view.layoutIfNeeded()
                    self.keyboardActive = false
                })
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! searchResultCell
        cell.productLabel.textColor = UIColor.whiteColor()
        cell.contentView.backgroundColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        cell.backgroundColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
    }
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! searchResultCell
        cell.productLabel.textColor = UIColor.blackColor()
        cell.contentView.backgroundColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.whiteColor()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if didLoadSearch == false {
            return 0
        }
        else {
            if juiceSearch == true {
                return 1
            }else {
                return 3
            }
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 22))
        headerView.backgroundColor = UIColor.whiteColor()
        let headerLabel = UILabel(frame: headerView.frame)
        headerLabel.font = UIFont(name: "PTSans-Bold", size: 15)
        headerLabel.textColor = UIColor(red: 75/255, green: 151/255, blue: 66/255, alpha: 1.0)
        headerLabel.textAlignment = .Center
        headerView.addSubview(headerLabel)
        if didLoadSearch == false {
            return UIView(frame: CGRectZero)
        }else {
        switch section {
        case 0:
            if didLoadSearch == false {
                headerLabel.text = ""
            }else {
            headerLabel.text = "Juices"
            }
        case 1:
            if didLoadSearch == false {
                headerLabel.text = ""
            }else {
            headerLabel.text = "Brands"
            }
        case 2:
            if didLoadSearch == false {
                headerLabel.text = ""
            }else {
            headerLabel.text = "Users"
                }
        default:
            println("error")
        }
        return headerView
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if self.productResults?.count != 0 {
                return self.productResults?.count ?? 1
            }else {
                return 1
            }
        case 1:
            if self.brandResults?.count != 0 {
                return self.brandResults?.count ?? 1
            }else {
                return 1
            }
        case 2:
            if self.userResults?.count != 0 {
                return self.userResults?.count ?? 1
            }else {
                return 1
            }
        default:
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return productCellAtIndexPath(indexPath)
        case 1:
            return brandCellAtIndexPath(indexPath)
        case 2:
            return userCellAtIndexPath(indexPath)
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("productCell") as! searchResultCell
            return cell
        }
    }
    
    func productCellAtIndexPath(indexPath: NSIndexPath) -> searchResultCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("productCell") as! searchResultCell
        cell.productLabel.highlightedTextColor = UIColor.whiteColor()
        if productResults != nil && productResults?.count != 0 {
            cell.productLabel.text = productResults![indexPath.row]["name"].stringValue
            cell.productID = productResults![indexPath.row]["id"].stringValue
            cell.brandImage.clipsToBounds = true
            cell.brandImage.hidden = false
        }else {
            if didLoadSearch == false {
                cell.productLabel.text = ""
                cell.brandImage.hidden = true
            }else {
            cell.productLabel.text = "We found no juices matching your search"
            cell.brandImage.hidden = true
            }
        }
        return cell
    }
    
    func brandCellAtIndexPath(indexPath: NSIndexPath) -> searchResultCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("productCell") as! searchResultCell
        if brandResults != nil && brandResults?.count != 0 {
            cell.productLabel.text = brandResults![indexPath.row]["name"].stringValue
            cell.brandID = brandResults![indexPath.row]["id"].stringValue
            cell.brandImage.clipsToBounds = true
            cell.brandImage.hidden = false
        }else {
            if didLoadSearch == false {
                cell.productLabel.text = ""
                cell.brandImage.hidden = true
            }else {
            cell.productLabel.text = "We found no brands matching your search"
            cell.brandImage.hidden = true
            }
        }
        return cell
    }
    func userCellAtIndexPath(indexPath: NSIndexPath) -> searchResultCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("productCell") as! searchResultCell
        if userResults != nil && userResults?.count != 0{
            cell.productLabel.text = userResults![indexPath.row]["username"].stringValue
            cell.userID = userResults![indexPath.row]["id"].stringValue
            cell.brandImage.hidden = false
            cell.brandImage.layer.cornerRadius = cell.brandImage.frame.size.width / 2
            cell.brandImage.clipsToBounds = true
            if let urlString = userResults![indexPath.row]["image"].stringValue as String? {
                let url = NSURL(string: urlString)
                cell.brandImage.hnk_setImageFromURL(url!)
            }
        }else {
            if didLoadSearch == false {
                cell.productLabel.text = ""
                cell.brandImage.hidden = true
            }else {
            cell.productLabel.text = "No users matching your search"
            cell.brandImage.hidden = true
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! searchResultCell
        switch indexPath.section {
        case 0:
            segueIdentifier = "buzzToProduct"
            selectedID = cell.productID!
            viewDelegate?.dismissSearch(self)
        case 1:
            if let id = cell.brandID as String? {
                if id.isEmpty {
                    
                }else {
                    segueIdentifier = "buzzToBrand"
                    selectedID = cell.brandID!
                    viewDelegate?.dismissSearch(self)
                }
            }
        case 2:
            segueIdentifier = "toUserSegue"
            selectedID = cell.userID!
            viewDelegate?.dismissSearch(self)
        default:
            println("error")
        }
    }
    
    
    
    func loadSearchResults(string: String) {
        println("searching")
        Alamofire.request(Router.search(string)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                let jsonOBJ = JSON(json!)
                if let productData = jsonOBJ["products"]["data"].arrayValue as [JSON]? {
                    self.productResults = productData
                    self.didLoadSearch = true
                    self.tableView.reloadData()
                }
                if let brandData = jsonOBJ["brands"]["data"].arrayValue as [JSON]? {
                    self.brandResults = brandData
                    self.didLoadSearch = true
                    self.tableView.reloadData()
                }
                if let userData = jsonOBJ["users"]["data"].arrayValue as [JSON]? {
                    self.userResults = userData
                    self.didLoadSearch = true
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func loadJuiceSearchResults(string: String) {
        Alamofire.request(Router.search(string)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                let jsonOBJ = JSON(json!)
                if let productData = jsonOBJ["products"]["data"].arrayValue as [JSON]? {
                    self.productResults = productData
                    self.didLoadSearch = true
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func clearSearch() {
        self.productResults = []
        self.brandResults = []
        self.userResults = []
        self.didLoadSearch = false 
        tableView.reloadData()
    }
    
}*/
