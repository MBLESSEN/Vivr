//
//  BrowseViewController.swift
//  vivr v4
//
//  Created by max blessen on 12/17/14.
//  Copyright (c) 2014 max blessen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol ProductViewDelegate {
    func productSelected(product: Product)
}

protocol BrowseViewDelegate {
    func brandSelected(brandID: Int, brandName: String)
}


class VIVRBrowseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, flavorTagsDelegate, UISearchBarDelegate, searchDelegate, BoxesCellDelegate {
    var viewDelegate:searchDelegate?
    let screenSize = UIScreen.mainScreen().bounds
    var results:[SwiftyJSON.JSON]? = []
    var data = NSMutableData()
    var selectedBrandImage:String?
    var selectedBrandLogo:String = ""
    var selectedBrand:String?  = ""
    var selectedBrandName:String = ""
    var brandDescription:String = ""
    var cellIdentifier = "boxesCell"
    var selectedProductID:Int?
    var selectedUserID:Int?
    var selectedBoxID: Int?
    var segueIdentifier:String?
    var tags: addFlavorTagsView?
    var searchView: VIVRSearchViewController?
    var tagViewIsActive = false
    var products:Array<Product>?
    var productWrapper:ProductWrapper?
    var brand:Array<Brand>?
    var brandWrapper:BrandWrapper?
    var boxes:Array<Boxes>?
    var boxWrapper: BoxesWrapper?
    var isLoadingProducts = false {
        didSet {
            if isLoadingProducts == true {
                showLoadingScreen(2)
            }else {
                removeLoadingScreen(2)
            }
        }
    }
    var isLoadingBrands = false
    var isLoadingBoxes = false
    var filterTags:NSMutableArray = []
    var filterTagsString:String?
    var filterActive = false
    var segueActive = true
    lazy var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var controllerView: UIView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    
    var searchActive = false {
        didSet {
            if searchActive == true {
                filterButton.customView?.hidden = true
            }else {
                filterButton.customView?.hidden = false
            }
        }
    }
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    var filterButton: UIBarButtonItem = UIBarButtonItem()
    @IBOutlet weak var searchViewBackgroundHeight: NSLayoutConstraint!
    @IBOutlet weak var searchViewBackground: UIView!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var tagViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var featuredLabel: UILabel!
    @IBOutlet weak var juicesLabel: UILabel!
    @IBOutlet weak var newLabel: UILabel!
    
    @IBOutlet weak var selectionIndicatorLeading: NSLayoutConstraint!
    
    @IBOutlet weak var controller: UISegmentedControl!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var menuCopy: UIBarButtonItem = UIBarButtonItem()
    @IBOutlet weak var brandsTableView: UITableView!
    
    lazy   var search:UISearchBar = UISearchBar()
    
    var brandTextOnly = false
    var brandViewDelegate: BrowseViewDelegate? = nil
    var productViewDelegate: ProductViewDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLoadingScreen()
        setNavBarTitle()
        configureNavBar()
        loadTagsView()
        instantiateSearchView()
        let filterImage = UIImage(named: "filter")?.imageWithRenderingMode(.AlwaysTemplate)
        let button   = UIButton(type: UIButtonType.System)
        button.frame = CGRectMake(0, 0, 22, 22)
        button.setImage(filterImage, forState: .Normal)
        button.addTarget(self, action: "filterFeed:", forControlEvents: UIControlEvents.TouchUpInside)
        filterButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "filterFeed:")
        filterButton.customView = button
        brandsTableView.estimatedRowHeight = 300
        brandsTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationItem.setRightBarButtonItems([searchButton], animated: true )
        selectionIndicatorLeading.constant = UIScreen.mainScreen().bounds.width/3
    }

    func createLoadingScreen() {
        activityIndicator.color = UIColor.lightGrayColor()
        activityIndicator.startAnimating()
        activityIndicator.frame = CGRectMake(0, 0, 50, 50)
        activityIndicator.center = self.view.center
    }
    
    func showLoadingScreen(segment: Int) {
        switch segment {
        case 0:
            print("0")
        case 1:
            print("1")
        case 2:
            if products == nil {
                self.view.addSubview(activityIndicator)
            }
        default:
            print("default")
        }
    }
    
    func removeLoadingScreen(segment: Int) {
        switch segment {
        case 0:
            print("0")
        case 1:
            print("1")
        case 2:
            if products != nil {
                self.activityIndicator.removeFromSuperview()
            }
        default:
            print("default")
        }
    }
    
    func instantiateSearchView() {
        self.search.delegate = self
        let textField = search.valueForKey("searchField") as! UITextField
        textField.backgroundColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 1.0)
        textField.textColor = UIColor.whiteColor()
        let attributedString = NSAttributedString(string: "Find your juice", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        textField.attributedPlaceholder = attributedString
        let iconView:UIImageView = textField.leftView as! UIImageView
        //Make the icon to a template which you can edit
        iconView.image = iconView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        //Set the color of the icon
        iconView.tintColor = UIColor.whiteColor()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        searchView = storyboard.instantiateViewControllerWithIdentifier("searchTable") as? VIVRSearchViewController
        searchView!.viewDelegate = self
        searchViewBackground.clipsToBounds = true
    }
    
    func reloadSearch() {
        
        
    }
    
    func goToUser(userID: Int) {
        segueIdentifier = "toUserSegue"
        self.selectedUserID = userID
        self.performSegueWithIdentifier(segueIdentifier!, sender: self)
    }
    
    func showTitleLogo(){
        let logo = UIImage(named: "vivrTitleLogo")?.imageWithRenderingMode(.AlwaysOriginal)
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
    }
    func hideTitleLogo() {
        self.navigationItem.titleView = nil
    }
    
    func showMenuButton() {
        self.navigationItem.leftBarButtonItem = menuCopy
    }
    
    func hideKeyboard(view: VIVRSearchViewController) {
        
        
    }
    
    func setNavBarTitle() {
        let logo = UIImage(named: "vivrTitleLogo")?.imageWithRenderingMode(.AlwaysOriginal)
        let imageView = UIImageView(image: logo)
        navigationItem.titleView = imageView
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func configureNavBar() {
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.tintColor = UIColor(red: 43.0/255, green: 169.0/255, blue: 41.0/255, alpha: 1.0)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.layoutIfNeeded()
        if products == nil {
            if filterTags.count != 0 {
                loadFirstFilteredProduct(filterTagsString!)
            }else {
                loadFirstProduct()
            }
        }
        if brand == nil {
            loadFirstBrand()
            print("loading brands", terminator: "")
        }
        if boxes == nil {
            loadFirstBoxes()
            print("loading brands", terminator: "")
        }
        configureNavBar()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)
    }
    
    func filterFeed(sender: AnyObject) {
        if filterActive == false {
            filterActive = true
            self.navigationItem.titleView?.alpha = 0.3
            tags!.viewDelegate = self
            tags!.savedTags = filterTags
            tags!.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width, self.view.frame.height)
            tags!.view.layer.zPosition = tagView.layer.zPosition + 2
            self.view.addSubview(self.tags!.view)
            UIView.animateWithDuration(
                // duration
                0.3,
                // delay
                delay: 0.0,
                options: [],
                animations: {
                    self.tags!.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, self.view.frame.height)
                    
                }, completion: {finished in
                }
            )
            searchButton.enabled = false
        }
        else {
            filterActive = false
            self.navigationItem.titleView?.alpha = 1.0
            searchButton.enabled = true
            UIView.animateWithDuration(
                // duration
                0.3,
                // delay
                delay: 0.0,
                options: [],
                animations: {
                    self.tags!.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width, self.view.frame.height)
                    
                }, completion: {finished in
                    self.tags!.view.removeFromSuperview()
                }
            )
        }
    }
    
    @IBAction func searchPressed(sender: AnyObject) {
        switch searchActive {
        case false:
            searchActive = true
            hideTitleLogo()
            let leftNavBarButton = UIBarButtonItem(customView:search)
            search.frame = CGRectMake(0, 0, 0, 20)
            self.navigationItem.leftBarButtonItem = leftNavBarButton
            let searchWidth = self.view.frame.width - 64
            self.addChildViewController(self.searchView!)
            self.searchView!.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
            searchViewBackground.autoresizesSubviews = false
            self.searchViewBackground.addSubview(self.searchView!.view)
            self.searchView!.view.layer.zPosition = self.searchViewBackground.layer.zPosition + 1
            self.searchView!.didMoveToParentViewController(self)
            UIView.animateWithDuration(
                // duration
                0.5,
                // delay
                delay: 0.0,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    self.search.frame = CGRectMake(0, self.search.frame.origin.y, searchWidth, 20)
                    self.view.layoutIfNeeded()
                    
                }, completion: {finished in
                }
                
            )
            UIView.animateWithDuration(
                // duration
                0.3,
                // delay
                delay: 0.1,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    self.searchViewBackgroundHeight.constant = self.view.frame.height
                    self.view.layoutIfNeeded()
                    
                }, completion: {finished in
                    
                }
            )

        case true:
            searchActive = false
            UIView.animateWithDuration(
                // duration
                0.2,
                // delay
                delay: 0.0,
                options: [],
                animations: {
                    
                    self.searchViewBackgroundHeight.constant = 0.0
                    self.view.layoutIfNeeded()
                }, completion: {finished in
                    self.searchView!.removeFromParentViewController()
                    
                }
            )
            UIView.animateWithDuration(
                // duration
                0.5,
                // delay
                delay: 0.0,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    self.search.alpha = 0.0
                    self.navigationItem.leftBarButtonItem = nil
                    self.showTitleLogo()
                    self.showMenuButton()
                    
                }, completion: {finished in
                    
                }
            )
            
        }
    }
    
    
    func dismissSearch(view: VIVRSearchViewController, cell: ProductTableViewCell?) {
        if let segueString = view.segueIdentifier as String? {
            if segueString.isEmpty {
                
            }else {
                segueIdentifier = view.segueIdentifier!
                searchActive = false
                search.resignFirstResponder()
                UIView.animateWithDuration(
                    // duration
                    0.2,
                    // delay
                    delay: 0.0,
                    options: [],
                    animations: {
                        self.searchViewBackgroundHeight.constant = 0.0
                    }, completion: {finished in
                        self.searchView!.removeFromParentViewController()
                        self.checkSearchSelection(view)
                        
                    }
                )
                UIView.animateWithDuration(
                    // duration
                    0.5,
                    // delay
                    delay: 0.0,
                    options: [],
                    animations: {
                        self.search.alpha = 0.0
                        self.navigationItem.leftBarButtonItem = nil
                        self.showTitleLogo()
                        self.showMenuButton()
                        self.view.layoutIfNeeded()
                    }, completion: {finished in
                        
                    }
                )
            }
        }
        
    }
    
    func checkSearchSelection(view: VIVRSearchViewController) {
        switch segueIdentifier! {
        case "buzzToProduct":
            self.selectedProductID = Int(view.selectedID!)
        case "toUserSegue":
            self.selectedUserID = Int(view.selectedID!)
        default:
            print("error", terminator: "")
        }
        performSegueWithIdentifier(segueIdentifier!, sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func changeData(sender: AnyObject) {
        let leading = UIScreen.mainScreen().bounds.width/3
        switch controller.selectedSegmentIndex{
        case 0:
            cellIdentifier = "brandCell"
            featuredLabel.textColor = UIColor.whiteColor()
            featuredLabel.backgroundColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            juicesLabel.textColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            juicesLabel.backgroundColor = UIColor.whiteColor()
            newLabel.textColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            newLabel.backgroundColor = UIColor.whiteColor()
            UIView.animateWithDuration(
                // duration
                0.2,
                // delay
                delay: 0.1,
                options: [],
                animations: {
                    self.selectionIndicatorLeading.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: {finished in
                }
            )
            if (screenSize.width < 370) {
                brandsTableView.rowHeight = 75
            }else{
                brandsTableView.rowHeight = 100
            }
            brandsTableView.reloadData()
        case 1:
            cellIdentifier = "boxesCell"
            featuredLabel.textColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            featuredLabel.backgroundColor = UIColor.whiteColor()
            juicesLabel.textColor = UIColor.whiteColor()
            juicesLabel.backgroundColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            newLabel.textColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            newLabel.backgroundColor = UIColor.whiteColor()
            UIView.animateWithDuration(
                // duration
                0.2,
                // delay
                delay: 0.1,
                options: [],
                animations: {
                    self.selectionIndicatorLeading.constant = leading
                    self.view.layoutIfNeeded()
                }, completion: {finished in
                }
            )
            brandsTableView.estimatedRowHeight = 200
            brandsTableView.rowHeight = UITableViewAutomaticDimension
            brandsTableView.reloadData()
        case 2:
            cellIdentifier = "productCell"
            featuredLabel.textColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            featuredLabel.backgroundColor = UIColor.whiteColor()
            juicesLabel.textColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            juicesLabel.backgroundColor = UIColor.whiteColor()
            newLabel.textColor = UIColor.whiteColor()
            newLabel.backgroundColor = UIColor(red: 39/255, green: 129/255, blue: 30/255, alpha: 1.0)
            UIView.animateWithDuration(
                // duration
                0.2,
                // delay
                delay: 0.1,
                options: [],
                animations: {
                    self.selectionIndicatorLeading.constant = leading*2
                    self.view.layoutIfNeeded()
                }, completion: {finished in
                }
            )
            brandsTableView.rowHeight = 40.0
            brandsTableView.reloadData()
        default:
            print("no segment", terminator: "")
            
        }
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch cellIdentifier {
            case "brandCell":
                if self.brand == nil {
                    return 0
                }
                return self.brand!.count
            case "productCell":
                if self.products == nil {
                    return 0
            }
            return self.products!.count
            case "boxesCell":
                if self.boxes == nil {
                    return 0
                }
                return self.boxes!.count
        default:
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch cellIdentifier {
            case "brandCell":
                if brandTextOnly == true {
                    return brandTextCellForIndexPath(indexPath)
                }else {
                return brandCellForIndexPath(indexPath)
            }
            case "boxesCell":
                return boxesCellForIndexPath(indexPath)
        default:
                return productCellForIndexPath(indexPath)
            
        }
    }
    
    func brandTextCellForIndexPath(indexPath:NSIndexPath) -> BrandTableViewCell {
        let cell = brandsTableView.dequeueReusableCellWithIdentifier("brandCell") as! BrandTableViewCell
        if self.brand != nil && self.brand!.count >= indexPath.row {
            let brandAtIndex = brand![indexPath.row]
            cell.brandID = brandAtIndex.id
            cell.brandLabel.text = brandAtIndex.name
            cell.flavorsLabel?.removeFromSuperview()
            cell.flavorCount?.removeFromSuperview()
            cell.averageRatingLabel?.removeFromSuperview()
            cell.averageRating?.removeFromSuperview()
            cell.brandImage?.frame = CGRectMake(0, 0, 0, 0)
            let rowsToLoadFromBottom = 5
            let rowsLoaded = self.brand!.count
            if (!self.isLoadingBrands && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                let totalRows = self.brandWrapper!.count!
                let remainingFeedToLoad = totalRows - rowsLoaded
                print(remainingFeedToLoad, terminator: "")
                if (remainingFeedToLoad > 0) {
                    self.loadMoreBrands()
                }
            }
        }
        cell.preservesSuperviewLayoutMargins = false
        return cell
        
    }
    
    
    func boxesCellForIndexPath(indexPath:NSIndexPath) -> BoxesCell {
        let cell = brandsTableView.dequeueReusableCellWithIdentifier("boxesCell") as! BoxesCell
        if self.boxes != nil && self.boxes!.count >= indexPath.row {
            let boxAtIndex = boxes![indexPath.row]
            cell.cellDelegate = self
            cell.descriptionLabel!.text = boxAtIndex.description
            cell.boxID = boxAtIndex.boxID
            cell.boxName.text = boxAtIndex.name
            cell.userName.text = boxAtIndex.user?.userName
            if let urlString = boxAtIndex.user?.image as String? {
                let url = NSURL(string: urlString)
                cell.userImage.hnk_setImageFromURL(url!)
            }
            cell.juiceCount.text = "\(boxAtIndex.productCount!) Juices"
            cell.userID = boxAtIndex.user?.ID
            let rowsToLoadFromBottom = 5
            let rowsLoaded = self.brand!.count
            if (!self.isLoadingBoxes && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                let totalRows = self.boxWrapper!.count!
                let remainingFeedToLoad = totalRows - rowsLoaded
                print(remainingFeedToLoad, terminator: "")
                if (remainingFeedToLoad > 0) {
                    self.loadMoreBoxes()
                }
            }
        }
        cell.preservesSuperviewLayoutMargins = false
        return cell
        
    }
    
    func brandCellForIndexPath(indexPath:NSIndexPath) -> BrandTableViewCell {
        let cell = brandsTableView.dequeueReusableCellWithIdentifier("brandCell") as! BrandTableViewCell
        if self.brand != nil && self.brand!.count >= indexPath.row {
            let brandAtIndex = brand![indexPath.row]
            cell.brandID = brandAtIndex.id
            cell.brandLabel.text = brandAtIndex.name
            cell.flavorCount.text = "\(brandAtIndex.productCount!)"
            if let urlString = brandAtIndex.image as String? {
                print(urlString, terminator: "")
                if urlString != "NA" {
                let url = NSURL(string: urlString)
                    print("image is being set", terminator: "")
                cell.brandImage.hnk_setImageFromURL(url!)
                }else {
                let placeHolderImage = UIImage(named: "vivrHomeLogo")?.imageWithRenderingMode(.AlwaysTemplate)
                cell.brandImage.image = placeHolderImage
                    cell.brandImage.tintColor = UIColor.blackColor()
                }
                
            }
        let rowsToLoadFromBottom = 5
        let rowsLoaded = self.brand!.count
        if (!self.isLoadingBrands && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
            let totalRows = self.brandWrapper!.count!
            let remainingFeedToLoad = totalRows - rowsLoaded
            print(remainingFeedToLoad, terminator: "")
            if (remainingFeedToLoad > 0) {
                self.loadMoreBrands()
            }
        }
        }
        cell.preservesSuperviewLayoutMargins = false
        return cell
        
    }
    
    func productCellForIndexPath(indexPath:NSIndexPath) -> ProductTableViewCell {
        let cell = brandsTableView.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath) as! ProductTableViewCell
        if self.products != nil && self.products!.count >= indexPath.row && self.isLoadingProducts == false {
            let product = self.products![indexPath.row]
            cell.product = product
            cell.productLabel.text = product.name
            
            let rowsToLoadFromBottom = 5
            let rowsLoaded = self.products!.count
            if (!self.isLoadingProducts && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                let totalRows = self.productWrapper!.count!
                let remainingFeedToLoad = totalRows - rowsLoaded
                if (remainingFeedToLoad > 0) {
                    if filterTags.count != 0 {
                        self.loadMorefilteredProducts()
                    } else {
                        self.loadMoreProducts()
                    }
                }
            }
        }
        cell.preservesSuperviewLayoutMargins = false
        return cell
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (controller.selectedSegmentIndex == 0) {
        let rowSelected = indexPath.row as Int
        let rowData = brand![rowSelected]
            print(rowData.name, terminator: "")
            print(rowData.id, terminator: "")
        selectedBrand! = "\(rowData.id!)"
        selectedBrandImage = rowData.image!
        selectedBrandName = rowData.name!
        brandDescription = rowData.description!
        segueIdentifier = "brandProductSegue"
            if segueActive == true {
                performSegueWithIdentifier(segueIdentifier!, sender: self)
            }else {
                brandViewDelegate?.brandSelected(rowData.id!, brandName: rowData.name!)
            }
        }
        if (controller.selectedSegmentIndex == 1){
            let rowSelected = indexPath.row as Int
            let rowData = boxes![rowSelected]
            selectedBoxID = rowData.boxID
            segueIdentifier = "browseToBox"
            performSegueWithIdentifier(segueIdentifier!, sender: self)
        }
        if controller.selectedSegmentIndex == 2 {
            let rowSelected = indexPath.row as Int
            let rowData = products![rowSelected]
            if segueActive == true {
            selectedProductID = rowData.productID
            segueIdentifier = "browseToProduct"
            performSegueWithIdentifier(segueIdentifier!, sender: self)
            }else {
                productViewDelegate?.productSelected(rowData)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier!{
            case "brandProductSegue":
                let productVC: VIVRBrandProductsViewController = segue.destinationViewController as! VIVRBrandProductsViewController
                productVC.brandID = selectedBrand!
                productVC.brandImageURL = selectedBrandImage!
                productVC.selectedBrandName = selectedBrandName
                productVC.brandDescription = brandDescription
            case "browseToProduct":
                let brandFlavorVC: VIVRProductViewController = segue.destinationViewController as! VIVRProductViewController
                if let stringID = String(stringInterpolationSegment: selectedProductID!) as String? {
                brandFlavorVC.selectedProductID = stringID
                brandFlavorVC.boxOrProduct = "product"
                }
            case "toUserSegue":
                let userVC: VIVRUserViewController = segue.destinationViewController as! VIVRUserViewController
                userVC.selectedUserID = "\(self.selectedUserID!)"
            case "buzzToProduct":
                let brandFlavorVC: VIVRProductViewController = segue.destinationViewController as! VIVRProductViewController
                if let stringID = String(stringInterpolationSegment: selectedProductID!) as String? {
                    brandFlavorVC.selectedProductID = stringID
                }
            case "browseToBox":
                let boxVC: VIVRProductViewController = segue.destinationViewController as! VIVRProductViewController
                boxVC.boxOrProduct = "box"
                boxVC.selectedBoxID = self.selectedBoxID!
        default:
            print("no segue", terminator: "")
        }
    }
    
    func findBrand(searchText: String) {
        self.brand = []
        isLoadingBrands = true
        Brand.findBrands(searchText, completionHandler: { (brandWrapper, error) in
            if error != nil {
                self.isLoadingBrands = false
                let alert = UIAlertController(title: "Error", message: "Could not load brands", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            self.addBrandFromWrapper(brandWrapper)
            self.isLoadingBrands = false
            self.brandsTableView.reloadData()
        })
    }
    
    func findJuice(searchText: String) {
        self.products = []
        isLoadingProducts = true
        Product.findProducts(searchText, completionHandler: { (productWrapper, error) in
            if error != nil {
                self.isLoadingProducts = false
                let alert = UIAlertController(title: "Error", message: "Could not load brands", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            self.addProductFromWrapper(productWrapper)
            self.isLoadingProducts = false
            self.brandsTableView.reloadData()
        })
    }
    
    func loadFirstBrand() {
        self.brand = []
        isLoadingBrands = true
        Brand.getBrands({ (brandWrapper, error) in
            if error != nil {
                print(error, terminator: "")
                self.isLoadingBrands = false
                let alert = UIAlertController(title: "Error", message: "could not load first Products", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            print(brandWrapper, terminator: "")
            self.addBrandFromWrapper(brandWrapper)
            self.isLoadingBrands = false
            self.brandsTableView.reloadData()
        })
    }
    func loadMoreBrands() {
        isLoadingBrands = true
        if self.brand != nil && self.brandWrapper != nil && self.brand!.count < self.brandWrapper!.count
        {
            Brand.getMoreBrands(self.brandWrapper, completionHandler: { (moreBrandWrapper, error) in
                if error != nil
                {
                    self.isLoadingBrands = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more Products", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                print("got More", terminator: "")
                self.addBrandFromWrapper(moreBrandWrapper)
                self.isLoadingBrands = false
                self.brandsTableView.reloadData()
            })
        }
    }
    
    func loadFirstProduct() {
        self.products = []
        isLoadingProducts = true
        Product.getProducts({ (productWrapper, error) in
            if error != nil {
                self.isLoadingProducts = false
                let alert = UIAlertController(title: "Error", message: "could not load first Products", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.addProductFromWrapper(productWrapper)
            self.isLoadingProducts = false
            self.brandsTableView.reloadData()
        })
    }
    func loadMoreProducts() {
        isLoadingProducts = true
        if self.products != nil && self.productWrapper != nil && self.products!.count < self.productWrapper!.count
        {
            Product.getMoreProducts(self.productWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingProducts = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more Products", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                print("got More", terminator: "")
                self.addProductFromWrapper(moreWrapper)
                self.isLoadingProducts = false
                self.brandsTableView.reloadData()
            })
        }
    }
    func loadFirstBoxes() {
        self.boxes = []
        isLoadingBoxes = true
        Boxes.getAllBoxes({ (boxWrapper, error) in
            if error != nil {
                self.isLoadingBoxes = false
                let alert = UIAlertController(title: "Error", message: "could not load first Products", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.addBoxFromWrapper(boxWrapper)
            self.isLoadingBoxes = false
            self.brandsTableView.reloadData()
        })
    }
    func loadMoreBoxes() {
        isLoadingBoxes = true
        if self.boxes != nil && self.boxWrapper != nil && self.boxes!.count < self.boxWrapper!.count
        {
            Boxes.getMoreBoxes(self.boxWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingBoxes = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more Products", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                print("got More", terminator: "")
                self.addBoxFromWrapper(moreWrapper)
                self.isLoadingBoxes = false
                self.brandsTableView.reloadData()
            })
        }
    }
    
    func addBoxFromWrapper(wrapper: BoxesWrapper?) {
        self.boxWrapper = wrapper
        if self.boxes == nil {
            self.boxes = self.boxWrapper?.Box
        }else if self.boxWrapper != nil && self.boxWrapper!.Box != nil{
            self.boxes = self.boxes! + self.boxWrapper!.Box!
        }
    }
    
    func addProductFromWrapper(wrapper: ProductWrapper?) {
        self.productWrapper = wrapper
        if self.products == nil {
            self.products = self.productWrapper?.Products
        }else if self.productWrapper != nil && self.productWrapper!.Products != nil{
            self.products = self.products! + self.productWrapper!.Products!
        }
    }
    func addBrandFromWrapper(wrapper: BrandWrapper?) {
        self.brandWrapper = wrapper
        if self.brand == nil {
            self.brand = self.brandWrapper?.Brands
        }else if self.brandWrapper != nil && self.brandWrapper!.Brands != nil{
            self.brand = self.brand! + self.brandWrapper!.Brands!
        }
    }
    
    func loadTagsView() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        tags = storyboard.instantiateViewControllerWithIdentifier("tags") as? addFlavorTagsView
    }
    
    
    @IBAction func filterProducts(sender: AnyObject) {
        navigationController?.navigationBar.hidden = true
        tags!.viewDelegate = self
        tags!.savedTags = filterTags
        self.presentViewController(tags!, animated: true, completion: nil)
    }
    
    func didSubmit(view: addFlavorTagsView) {
        self.navigationItem.titleView?.alpha = 1.0
        filterTags = []
        filterTags = view.selectedTags
        filterResults(view.selectedTags)
        UIView.animateWithDuration(
            // duration
            0.3,
            // delay
            delay: 0.0,
            options: [],
            animations: {
                self.tags!.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width, self.view.frame.height - 44)
                
            }, completion: {finished in
                self.tags!.view.removeFromSuperview()
            }
        )
        searchButton.enabled = true
    }
    
    func didCancel(view: addFlavorTagsView) {
        self.navigationItem.titleView?.alpha = 1.0
        searchButton.enabled = true
        UIView.animateWithDuration(
            // duration
            0.3,
            // delay
            delay: 0.0,
            options: [],
            animations: {
                self.tags!.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width, self.view.frame.height - 44)
                
            }, completion: {finished in
                self.tags!.view.removeFromSuperview()
            }
        )
    }
    func toggleTagView() {
        switch filterTags.count {
        case 0:
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.tagViewHeight.constant = 0.0
                self.tagViewIsActive = false
                self.clearTags()
                self.view.layoutIfNeeded()
            })
        default:
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.tagViewHeight.constant = 40.0
                self.tagViewIsActive = true
                self.addTagsToView()
                self.view.layoutIfNeeded()
            })
        }
        
    }
    func addTagsToView() {
        var contentInset = CGFloat(16.0)
        let viewsToRemove = tagView.subviews
        for view in viewsToRemove {
            view.removeFromSuperview()
        }
        for _ in filterTags {
            let indicator = UIImageView(frame: CGRectMake(contentInset, 7, 25, 25))
            indicator.image = UIImage(named: "userImage")
            tagView.addSubview(indicator)
            contentInset = contentInset + 33.0
        }
    }
    
    func clearTags() {
        let viewsToRemove = tagView.subviews
        for view in viewsToRemove {
            view.removeFromSuperview()
        }
    }
    
    func filterResults(tags: NSArray) {
        let stringTags: String = tags.componentsJoinedByString(",")
        filterTagsString = stringTags
        if filterTagsString != nil {
            loadFirstFilteredProduct(filterTagsString!)
        }
        self.toggleTagView()
    }
    
    func loadFirstFilteredProduct(tags: String) {
        self.products = []
        isLoadingProducts = true
        Product.getFilteredProducts(tags, completionHandler: { (productWrapper, error) in
            if error != nil {
                self.isLoadingProducts = false
                let alert = UIAlertController(title: "Error", message: "could not load first Filtered Products", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.addProductFromWrapper(productWrapper)
            self.isLoadingProducts = false
            self.brandsTableView.reloadData()
        })
    }
    func loadMorefilteredProducts() {
        isLoadingProducts = true
        if self.products != nil && self.productWrapper != nil && self.products!.count < self.productWrapper!.count
        {
            Product.getMoreFilteredProducts(filterTagsString!, wrapper: self.productWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingProducts = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more Filtered Products", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                print("got More", terminator: "")
                self.addProductFromWrapper(moreWrapper)
                self.isLoadingProducts = false
                self.brandsTableView.reloadData()
            })
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchView!.searchTextCount = searchText.characters.count
        if searchText.characters.count >= 3 {
            print("search text is \(searchText)")
            if let searchString = searchBar.text!.stringByReplacingOccurrencesOfString(" ", withString: "_") as String! {
                if searchString.characters.count >= 3 {
                    searchView!.loadFirstSearch(searchString)
                }else {
                    let emptyAlert = UIAlertController(title: "oops!", message: "search must be atleast 3 letters long", preferredStyle: UIAlertControllerStyle.Alert)
                    emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(emptyAlert, animated: true, completion: nil)
                }
            }
        }
        if searchText.characters.count == 0 {
            print("search text count is 0")
            searchView!.clearSearch()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchString = searchBar.text!.stringByReplacingOccurrencesOfString(" ", withString: "_") as String! {
            if searchString.characters.count >= 3 {
                searchView!.loadFirstSearch(searchString)
            }else {
                let emptyAlert = UIAlertController(title: "oops!", message: "search must be atleast 3 letters long", preferredStyle: UIAlertControllerStyle.Alert)
                emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(emptyAlert, animated: true, completion: nil)
            }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchView!.clearSearch()
    }

    
}



