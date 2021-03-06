//
//  VIVRJuiceCheckIn.swift
//  vivr
//
//  Created by max blessen on 11/27/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import UIKit

class VIVRJuiceCheckIn: UIViewController, searchDelegate, UISearchBarDelegate, VIVRReviewProtocol {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cancelButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkInButton: UIButton!
    
    var searchView: VIVRSearchViewController?
    var myReviewsView: VIVRUserReviewsViewController?

    override func viewDidLoad() {
        instantiateMyReviewsView()
        instantiateSearchView()
        hideSearchView()
        showMyReviewsView()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        showTitleLogo()
        configureNavBar()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewDidLayoutSubviews() {
        setSearchViewFrame()
        setMyReviewsViewFrame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadReviews() {
        myReviewsView!.selectedUserID = myData.user!.ID!
        myReviewsView!.loadFirstReviews()
    }
    
    //NAVIGATION AND VIEW CUSTOMIZATION
    
    func configureNavBar() {
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)
    }
    
    func showTitleLogo(){
        if self.navigationItem.titleView == nil {
            let logo = UIImage(named: "vivrTitleLogo")?.imageWithRenderingMode(.AlwaysOriginal)
            let imageView = UIImageView(image: logo)
            self.navigationItem.titleView = imageView
        }
    }
    
    
    //IB  ACTION OUTLETS
    //CANCEL BUTTON
    @IBAction func cancelPressed(sender: AnyObject) {
        hideSearchView()
        hideCancelButton()
        searchBar.resignFirstResponder()
        hideSearchView()
        showMyReviewsView()
        showCheckInButton()
    }
    
    //CANCEL BUTTON FUNCTIONS
    
    func showCancelButton() {
        UIView.animateWithDuration(0.2, animations: {
            self.cancelButtonWidthConstraint.constant = 60.0
            self.view.layoutIfNeeded()
        })
    }
    
    func hideCancelButton() {
        UIView.animateWithDuration(0.2, animations: {
            self.cancelButtonWidthConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        })
    }
    
    
    
    //CHILD VIEW CONTROLLERS
    //INSTANTIATE SEARCHVIEW
    //INSTANTIATE MYREVIEWSVIEW
    //SHOW/HIDE SEARCH VIEW
    
    func instantiateSearchView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        searchView = storyboard.instantiateViewControllerWithIdentifier("searchTable") as! VIVRSearchViewController
        addChildViewController(searchView!)
        searchView!.viewDelegate = self
    }
    
    func instantiateMyReviewsView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        myReviewsView = storyboard.instantiateViewControllerWithIdentifier("myUserReviews") as! VIVRUserReviewsViewController
        myReviewsView?.selectedUserID = myData.user?.ID!
        addChildViewController(myReviewsView!)
        myReviewsView?.didMoveToParentViewController(self)
        myReviewsView?.loadFirstReviews()
    }
    
    
    func setSearchViewFrame() {
        searchView!.view.frame = CGRectMake(0, 0,
            bottomView.frame.width, bottomView.frame.height)
        searchView!.topViewHeightConstraint.constant = 0
        searchView!.view.layoutIfNeeded()
    }
    
    func setMyReviewsViewFrame() {
        myReviewsView!.view.frame = CGRectMake(0, 0,
            bottomView.frame.width, bottomView.frame.height)
        myReviewsView!.view.layoutIfNeeded()
    }
    
    func showSearchView() {
        hideMyReviewsView()
        if searchView != nil {
            bottomView.addSubview(searchView!.view)
            searchView!.didMoveToParentViewController(self)
        }
    }
    
    func hideSearchView() {
        if searchView != nil {
            searchView!.view.removeFromSuperview()
        }
        showMyReviewsView()
    }
    
    func showMyReviewsView() {
        if myReviewsView != nil {
            bottomView.addSubview(myReviewsView!.view)
            myReviewsView?.didMoveToParentViewController(self)
        }
    }
    
    func hideMyReviewsView() {
        if myReviewsView != nil {
            myReviewsView!.view.removeFromSuperview()
        }
    }

    
    //VIVRSEARCHVIEWCONTROLLER DELEGATE FUNCTIONS
    //DISMISS SEARCH MEANS PRODUCT WAS SELECTED RROM SEARCH TABLE, SEGUE TO PRODUCT 
    //HIDE KEYBOARD 
    //RELOAD SEARCH
    
    func dismissSearch(view: VIVRSearchViewController, cell: ProductTableViewCell?) {
        hideSearchView()
        if cell?.product != nil {
            presentModalReviewProductViewController((cell?.product)!)
        }
        
    }
    
    func presentModalReviewProductViewController(product: Product) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigation = storyboard.instantiateViewControllerWithIdentifier("reviewViewControllerNavigationController") as! UINavigationController
        let reviewVC = navigation.viewControllers.first as! VIVRReviewViewController
        reviewVC.delegate = self
        reviewVC.product = product
        presentViewController(navigation, animated: true, completion: nil)
    }
    
    func hideKeyboard(view: VIVRSearchViewController) {
        
        
    }
    
    func reloadSearch() {
        print("reload search called")
        searchView!.loadFirstSearch(searchBar.text!)
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        showSearchView()
        showCancelButton()
        return true
    }
    
    //UISEARCHBAR DELEGATE FUNCTIONS
    //SEARCH BAR TEXT FUNCTIONS
    //CLEAR SEARCH BAR
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchView!.searchTextCount = searchText.characters.count
        if searchText.characters.count >= 3 {
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
    
    func clearSearch() {
        searchBar.text = ""
    }
    
    @IBAction func checkInJuiceTapped(sender: AnyObject) {
        self.hideCheckInButton()
    }
    
    func hideCheckInButton() {
        self.checkInButton.hidden = true
        self.checkInButton.userInteractionEnabled = false
        self.searchBar.becomeFirstResponder()
    }
    
    func showCheckInButton() {
        self.checkInButton.hidden = false
        self.checkInButton.userInteractionEnabled = true
    }
    
    func reviewAddedSuccess() {
        self.loadReviews()
    }


}
