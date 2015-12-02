//
//  searchViewController.swift
//  vivr v4
//
//  Created by max blessen on 7/1/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol searchDelegate {
    func dismissSearch(view: VIVRSearchViewController, cell: ProductTableViewCell?)
    func hideKeyboard(view: VIVRSearchViewController)
    func reloadSearch()
}

class VIVRSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddJuiceCellDelegate, AddNewJuiceViewDelegate {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var controllerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var control: UISegmentedControl!
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    var viewDelegate: searchDelegate? = nil
    var selectedBrandImage: String?
    var searchWrapper: SearchResult?
    var products: Array<Product>?
    var brands: Array<Brand>?
    var users: Array<User>?
    var addJuiceView: AddNewJuiceView?
    var isLoadingFeed = false
    var didLoadSearch = false
    var segueIdentifier:String?
    var selectedID:String?
    var selectedView: UIView = UIView()
    var juiceSearch:Bool?
    var cellIdentifier:String = "juiceCell"
    var endKeyboardRecongnizer = UITapGestureRecognizer()
    var keyboardActive: Bool?
    var noResultsView: UIView = UIView()
    var noResultsLabel: UILabel = UILabel()
    var placeHolderView: UIView = UIView()
    var label: UILabel = UILabel()
    var searchTextCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createNoResultsView()
        startObservingKeyboardEvents()
        endKeyboardRecongnizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        endKeyboardRecongnizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(endKeyboardRecongnizer)
        createPlaceHolderView()
        createAddJuiceView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        didLoadSearch = false
        searchTable.rowHeight = 100
    }
    
    @IBAction func changeData(sender: AnyObject) {
        switch control.selectedSegmentIndex{
        case 0:
            cellIdentifier = "juiceCell"
            searchTable.rowHeight = 120
            searchTable.reloadData()
        case 1:
            cellIdentifier = "brandCell"
            searchTable.rowHeight = 44
            searchTable.reloadData()
        case 2:
            cellIdentifier = "userCell"
            searchTable.rowHeight = 44
            searchTable.reloadData()
        default:
            print("no segment", terminator: "")
            
        }
        
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
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    self.keyboardActive = true
                })
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
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
    
    func createAddJuiceView() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        addJuiceView = storyboard.instantiateViewControllerWithIdentifier("addJuiceView") as! AddNewJuiceView
        
    }
    
    func addJuice() {
        self.presentViewController(addJuiceView!, animated: true, completion: nil)
    }
    
    func submit() {
        viewDelegate?.reloadSearch()
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = searchTable.cellForRowAtIndexPath(indexPath) as? searchResultCell {
        cell.productLabel.textColor = UIColor.whiteColor()
        cell.contentView.backgroundColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        cell.backgroundColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        }
    }
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = searchTable.cellForRowAtIndexPath(indexPath) as? searchResultCell {
        cell.productLabel.textColor = UIColor.blackColor()
        cell.contentView.backgroundColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.whiteColor()
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch cellIdentifier {
        case "juiceCell":
            if searchTextCount != 0 && products?.count != 0 {
                searchTable.separatorStyle = UITableViewCellSeparatorStyle.None
                hidePlaceHolderScreen()
                return 1
                
            }else {
                showPlaceHolderScreen()
                searchTable.separatorStyle = UITableViewCellSeparatorStyle.None
                return 1
            }
        case "brandCell":
            if searchTextCount != 0 && brands?.count != 0{
                searchTable.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                hidePlaceHolderScreen()
                return 1
            }else {
                showPlaceHolderScreen()
                searchTable.separatorStyle = UITableViewCellSeparatorStyle.None
                return 0
            }
        case "userCell":
            if searchTextCount != 0 && users?.count != 0{
                searchTable.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                hidePlaceHolderScreen()
                return 1
            }else {
                showPlaceHolderScreen()
                searchTable.separatorStyle = UITableViewCellSeparatorStyle.None
                return 0
            }
        default:
            return 0
        }
    }
    /*
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
    }*/
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch cellIdentifier {
        case "juiceCell":
            if self.products?.count == 0 {
                return 1
            }
            else if self.products == nil {
                return 0
            }else {
            return self.products!.count + 1
            }
        case "brandCell":
            if self.brands?.count == 0 {
                return 0
            }
            return self.brands!.count
        case "userCell":
            if self.users?.count == 0 {
                return 0
            }
            return self.users!.count
        default:
            return 1
        }
    }
    
    func createNoResultsView() {
        noResultsView = UIView(frame: searchTable.frame)
        noResultsView.backgroundColor = UIColor.redColor()
        noResultsLabel.frame = CGRectMake(16, 64, self.view.frame.width - 32, 50)
        noResultsLabel.numberOfLines = 3
        noResultsLabel.font = UIFont(name: "PTSans-Bold", size: 15)
        noResultsLabel.textAlignment = .Center
        noResultsView.addSubview(noResultsLabel)
        
    }
    
    func createPlaceHolderView() {
        placeHolderView = UIView(frame: searchTable.frame)
        label.frame = CGRectMake(16, 128, self.view.frame.width - 32, 50)
        label.numberOfLines = 3
        label.font = UIFont(name: "PTSans-Bold", size: 15)
        label.textAlignment = .Center
        placeHolderView.addSubview(label)
    }
    
    func showPlaceHolderScreen() {
        switch cellIdentifier {
        case "juiceCell":
            if didLoadSearch == true {
                label.text = "We found no juices matching your search. Add the juice above to contribute to our growing list of juices."
            }else if searchTextCount == 0 {
            label.text = "Find your juice, search with at least 3 letters."
            }
        case "brandCell":
            if didLoadSearch == true {
                label.text = "We found no brands matching your search"
            }else if searchTextCount == 0 {
            label.text = "Find a brand, search with at least 3 letters."
            }
        case "userCell":
            if didLoadSearch == true {
                label.text = "We found no users matching your search"
            }else if searchTextCount == 0 {
            label.text = "Find your friends, search with at least 3 letters."
            }
        default:
            print("error", terminator: "")
        }
        searchTable.backgroundView = placeHolderView
    }
    func hidePlaceHolderScreen() {
        searchTable.backgroundView = nil
    }
    
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch cellIdentifier {
        case "juiceCell":
            if let count = products?.count {
                if indexPath.row == count {
                    return addJuiceAtIndexPath()
                }
            }
            return productCellAtIndexPath(indexPath)
        case "brandCell":
            return brandCellAtIndexPath(indexPath)
        case "userCell":
            return userCellAtIndexPath(indexPath)
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("productCell") as! searchResultCell
            return cell
        }
    }
    
    func addJuiceAtIndexPath() -> AddJuiceCell {
        let cell = searchTable.dequeueReusableCellWithIdentifier("addJuiceCell") as! AddJuiceCell
        cell.cellDelegate = self
        cell.selectionStyle = .None
        return cell
    }
    
    func productCellAtIndexPath(indexPath: NSIndexPath) -> ProductTableViewCell {
        let cell = searchTable.dequeueReusableCellWithIdentifier("juiceCell") as! ProductTableViewCell
        cell.productLabel.highlightedTextColor = UIColor.whiteColor()
        print(products?.count, terminator: "")
        if products?.count != 0 {
            cell.product = products![indexPath.row]
            cell.productLabel.text = products![indexPath.row].name
            cell.productID = "\(products![indexPath.row].productID!)"
            if let urlString = products![indexPath.row].image as String? {
                let url = NSURL(string: urlString)
                cell.productImage!.hnk_setImageFromURL(url!)
            }
        }
        return cell
    }
    
    func brandCellAtIndexPath(indexPath: NSIndexPath) -> searchResultCell {
        let cell = searchTable.dequeueReusableCellWithIdentifier("brandCell") as! searchResultCell
        if brands?.count != 0 {
            cell.backgroundColor = UIColor.whiteColor()
            cell.productLabel.text = brands![indexPath.row].name
            cell.brandID = "\(brands![indexPath.row].id!)"
            if let urlString = brands![indexPath.row].image as String? {
                cell.imageURL = urlString 
                let url = NSURL(string: urlString)
                cell.brandImage.hnk_setImageFromURL(url!)
            }
            cell.brandImage.clipsToBounds = true
            cell.brandImage.hidden = false
        }
        return cell
    }
    func userCellAtIndexPath(indexPath: NSIndexPath) -> searchResultCell {
        let cell = searchTable.dequeueReusableCellWithIdentifier("userCell") as! searchResultCell
        if users != nil && users!.count > indexPath.row {
            cell.backgroundColor = UIColor.whiteColor()
            cell.productLabel.text = users![indexPath.row].userName!
            cell.userID = "\(users![indexPath.row].ID!)"
            cell.brandImage.hidden = false
            cell.brandImage.layer.cornerRadius = cell.brandImage.frame.size.width / 2
            cell.brandImage.clipsToBounds = true
            if let urlString = users![indexPath.row].image as String? {
                let url = NSURL(string: urlString)
                cell.brandImage.hnk_setImageFromURL(url!)
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch cellIdentifier {
        case "juiceCell":
            if let cell = searchTable.cellForRowAtIndexPath(indexPath) as? ProductTableViewCell {
            segueIdentifier = "buzzToProduct"
            selectedID = cell.productID!
            viewDelegate?.dismissSearch(self, cell: cell)
            }
        case "brandCell":
            let cell = searchTable.cellForRowAtIndexPath(indexPath) as! searchResultCell
            if let id = cell.brandID as String? {
                if id.isEmpty {
                    
                }else {
                    segueIdentifier = "buzzToBrand"
                    selectedID = cell.brandID!
                    selectedBrandImage = cell.imageURL!
                    viewDelegate?.dismissSearch(self, cell: nil)
                }
            }
        case "userCell":
            let cell = searchTable.cellForRowAtIndexPath(indexPath) as! searchResultCell
            segueIdentifier = "toUserSegue"
            selectedID = cell.userID!
            viewDelegate?.dismissSearch(self, cell: nil)
        default:
            print("error", terminator: "")
        }
    }
    
    func loadFirstSearch(searchText: String) {
        self.clearSearch()
        isLoadingFeed = true
        SearchResult.getSearchResults(searchText, completionHandler: { (searchWrapper, error) in
            if error != nil {
                self.isLoadingFeed = false
                let alert = UIAlertController(title: "Error", message: "could not load first activity", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.didLoadSearch = true
            self.addSearchResultFromWrapper(searchWrapper)
            self.isLoadingFeed = false
            self.searchTable.reloadData()
        })
    }
    /*
    func loadMoreSearch() {
        isLoadingFeed = true
        if self.reviews != nil && self.reviewsWrapper != nil && self.reviews!.count < self.reviewsWrapper!.count
        {
            ActivityFeedReviews.getMoreProductReviews(selectedProductID!, wrapper: self.reviewsWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingFeed = false
                    var alert = UIAlertController(title: "Error", message: "Could not load more activity", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                println("got More")
                self.addReviewFromWrapper(moreWrapper)
                self.isLoadingFeed = false
                self.mainTable.reloadData()
            })
        }
    }*/
    
    func addSearchResultFromWrapper(wrapper: SearchResult?) {
        self.searchWrapper = wrapper
        if self.products!.count == 0 {
            self.products = self.searchWrapper?.Products.Products
        }else if self.searchWrapper != nil && self.searchWrapper!.Products.Products != nil {
            self.products = self.products! + self.searchWrapper!.Products.Products!
        }
        if self.brands!.count == 0{
            self.brands = self.searchWrapper?.Brands.Brands
        }else if self.searchWrapper != nil && self.searchWrapper!.Brands.Brands != nil {
            self.brands = self.brands! + self.searchWrapper!.Brands.Brands!
        }
        if self.users!.count == 0 {
            self.users = self.searchWrapper?.Users.UserData
        }else if self.searchWrapper != nil && self.searchWrapper!.Users.UserData != nil {
            self.users = self.users! + self.searchWrapper!.Users.UserData!
        }
    }

    
    
    
    func clearSearch() {
        self.products = []
        self.brands = []
        self.users = []
        self.didLoadSearch = false 
        searchTable.reloadData()
    }


}
