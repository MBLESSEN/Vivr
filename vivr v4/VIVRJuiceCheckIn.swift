//
//  VIVRJuiceCheckIn.swift
//  vivr
//
//  Created by max blessen on 11/27/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import UIKit

class VIVRJuiceCheckIn: UIViewController, searchDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cancelButtonWidthConstraint: NSLayoutConstraint!
    
    
    var searchView: VIVRSearchViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        instantiateSearchView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        showTitleLogo()
        configureNavBar()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //NAVIGATION AND VIEW CUSTOMIZATION
    
    func configureNavBar() {
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func showTitleLogo(){
        let logo = UIImage(named: "vivrTitleLogo")?.imageWithRenderingMode(.AlwaysOriginal)
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
    }
    
    //IB  ACTION OUTLETS
    //CANCEL BUTTON
    @IBAction func cancelPressed(sender: AnyObject) {
        hideSearchView()
        hideCancelButton()
        searchBar.resignFirstResponder()
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
    //SHOW/HIDE SEARCH VIEW
    
    func instantiateSearchView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        searchView = storyboard.instantiateViewControllerWithIdentifier("searchTable") as! VIVRSearchViewController
        addChildViewController(searchView!)
        searchView!.viewDelegate = self
        searchView!.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, bottomView.frame.height)
        searchView!.topViewHeightConstraint.constant = 0
        searchView!.view.layoutSubviews()
    }
    
    func showSearchView() {
        if searchView != nil {
            bottomView.addSubview(searchView!.view)
            searchView!.didMoveToParentViewController(self)
        }
    }
    
    func hideSearchView() {
        if searchView != nil {
            searchView!.view.removeFromSuperview()
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
        presentViewController(navigation, animated: true, completion: nil)
    }
    
    func hideKeyboard(view: VIVRSearchViewController) {
        
        
    }
    
    func reloadSearch() {
        
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
