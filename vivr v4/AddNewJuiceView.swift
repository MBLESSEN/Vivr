//
//  AddNewJuiceView.swift
//  vivr
//
//  Created by max blessen on 9/10/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

protocol AddNewJuiceViewDelegate {
    func addNewJuiceSuccess()
}

class AddNewJuiceView: UIViewController, UISearchBarDelegate, BrowseViewDelegate, UITextFieldDelegate, VIVRDidAddNewBrandProtocol {
    
    @IBOutlet weak var brandView: UIView!
    var viewDelegate: AddNewJuiceViewDelegate? = nil
    var brandSearch: VIVRBrowseViewController?
    var allBrands: Array<Brand>?
    var brands: Array<Brand>?
    @IBOutlet weak var searchHeight: NSLayoutConstraint!
    var selectedBrandName: String?
    var selectedBrandID: Int?
    @IBOutlet weak var selectBrandButton: UIButton!
    var tableActive = false
    var newBrandActive = false
    var keyboardActive = false
    @IBOutlet weak var newBrandButton: UIButton!
    
    @IBOutlet weak var brandSearchBar: UISearchBar!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var juiceName: B68UIFloatLabelTextField!
    @IBOutlet weak var actionBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addJuiceLeadingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instantiateSearchView()
        newBrandButton.contentHorizontalAlignment = .Right
        juiceName.returnKeyType = .Done
        hideCantFindBrandButton()
        startObservingKeyboardEvents()
    }
    
    override func viewWillAppear(animated: Bool) {
        juiceName.becomeFirstResponder()
        configureNavBar()
        hideBrandSearchView()
    }
    
    //CONFIGURE NAV BAR
    
    func configureNavBar() {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    func brandSelected(brandID: Int, brandName: String) {
        setSelectBrandButtonForBrand(brandName, brandID: brandID)
        
    }
    
    //selectBrandButton functions
    
    func setSelectBrandButtonForBrand(brandName: String, brandID: Int) {
        selectedBrandID = brandID
        selectedBrandName = brandName
        hideBrandSearchView()
        animateBrandLabel()
    }
    
    func instantiateSearchView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        brandSearch = storyboard.instantiateViewControllerWithIdentifier("browseView") as? VIVRBrowseViewController
        brandSearch!.brandViewDelegate = self
        brandSearch!.segueActive = false
    }
    
    func resetView() {
        resetButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addJuicePressed(sender: AnyObject) {
        self.juiceName.endEditing(true)
        if juiceName.text!.isEmpty || selectedBrandID == nil{
            let emptyAlert = UIAlertController(title: "oops!", message: "Please complete all fields", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        }else{
            showActivityIndicatorInButton()
            let parameters: [String : AnyObject!] = [
                "name": self.juiceName.text!,
                "brand_id": selectedBrandID!
            ]
            Product.addProductToBrand(parameters, completionHandler: { (productWrapper, error) in
                if error == nil {
                    self.completeAddProduct()
                }
            })
        }
    }
    
    func completeAddProduct() {
        self.reviewSuccessInButton()
        self.cancelButton.enabled = false 
        UIView.animateWithDuration(0.3, animations: {
            self.addJuiceLeadingConstraint.constant = 0 - UIScreen.mainScreen().bounds.width
            self.view.layoutIfNeeded()
        })
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2), target: self, selector: "callViewDelegateAddNewJuiceSuccess", userInfo: nil, repeats: false)
        
    }

    @IBAction func cancelPressed(sender: AnyObject) {
        self.juiceName.text = ""
        self.selectedBrandName = nil
        self.selectedBrandID = nil
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func callViewDelegateAddNewJuiceSuccess() {
        self.dismissViewControllerAnimated(false, completion: nil)
        self.viewDelegate?.addNewJuiceSuccess()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func checkIfBrandsAreLoaded() {
        self.brandSearch?.checkIfDataIsLoaded()
    }
    
    @IBAction func selectBrandPressed(sender: AnyObject) {
        self.juiceName.endEditing(true)
        self.checkIfBrandsAreLoaded()
        if tableActive == false {
            showBrandSearchView()
        }else {
            hideBrandSearchView()
        }
    }
    
    func showBrandSearchView() {
        self.selectBrandButton.setTitle("Cancel brand search", forState: .Normal)
        self.selectBrandButton.layoutIfNeeded()
        showCantFindBrandButton()
        searchHeight.constant = 44.0
        brandSearch!.view.frame = CGRectMake(0, 0, brandView.frame.width, brandView.frame.height)
        self.addChildViewController(self.brandSearch!)
        
        self.brandSearch!.didMoveToParentViewController(self)
        brandSearch!.brandsTableView.rowHeight = 50.0
        brandSearch!.controller.selectedSegmentIndex = 0
        brandSearch!.controller.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        brandSearch!.tableViewTopConstraint.constant = -46.0
        brandSearch!.controllerView.hidden = true
        brandSearch!.controller.userInteractionEnabled = false
        brandSearch!.controller.hidden = true
        brandView.addSubview(brandSearch!.view)
        self.view.layoutIfNeeded()
        tableActive = true
    }
    
    func hideBrandSearchView() {
        hideCantFindBrandButton()
        tableActive = false
        searchHeight!.constant = 0
        brandSearch!.view.removeFromSuperview()
        if selectedBrandName != nil {
            self.selectBrandButton.setTitle("\(selectedBrandName!)", forState: .Normal)
        }else {
            self.selectBrandButton.setTitle("Who makes it?", forState: .Normal)
        }
        self.selectBrandButton.layoutIfNeeded()
        self.brandSearchBar.endEditing(true)
    }
    
    @IBAction func enterNewBrandPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("addNewBrandSegue", sender: self)
    }
    
    //PREPARE FOR SEGUE 
    //ASIGN BRAND DELEGATE TO SELF
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let addBrandVCNavController = segue.destinationViewController as! UINavigationController
        let addBrandVC = addBrandVCNavController.viewControllers.first as! VIVRAddNewBrandViewController
        addBrandVC.addNewBrandDelegate = self
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count >= 1 {
            if let searchString = searchBar.text!.stringByReplacingOccurrencesOfString(" ", withString: "_") as String! {
                if searchString.characters.count >= 1 {
                    brandSearch!.findBrand(searchString)
                }else {
                    let emptyAlert = UIAlertController(title: "oops!", message: "search must be atleast 3 letters long", preferredStyle: UIAlertControllerStyle.Alert)
                    emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(emptyAlert, animated: true, completion: nil)
                }
            }
        }
        if searchText.characters.count == 0 {
            brandSearch!.loadFirstBrand()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //VIVR DID ADD NEW BRAND PROTOCOL FUNCTIONS
    
    func brandCreated(brandName: String, brandID: Int) {
        brandSelected(brandID, brandName: brandName)
    }
    
    func animateBrandLabel() {
        UIView.animateWithDuration(
            // duration
            0.2,
            // delay
            delay: 0.3,
            options: [],
            animations: {
                self.selectBrandButton.transform = CGAffineTransformMakeScale(2.0, 2.0)
            }, completion: {finished in
                UIView.animateWithDuration(
                    // duration
                    0.1,
                    // delay
                    delay: 0.1,
                    options: [],
                    animations: {
                        self.selectBrandButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    }, completion: {finished in
                        
                    }
                )
            }
        )
    }
    
    func checkInAnotherJuice() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    //ACTIVITY INDICATOR FUNCTIONS
    func showActivityIndicatorInButton() {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.tag = 1
        submitButton.titleLabel!.text = ""
        activityIndicator.center = submitButton.center
        activityIndicator.center.y = submitButton.frame.minY
        submitButton.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
    }
    
    func reviewSuccessInButton() {
        let checkMark = UIImage(named: "checkmark")
        submitButton.viewWithTag(1)?.removeFromSuperview()
        submitButton.setImage(checkMark, forState: .Normal)
        submitButton.setTitle("New E-liquid added!", forState: .Normal)
    }
    
    func resetButtons() {
        submitButton.setTitle("Submit", forState: .Normal)
        submitButton.viewWithTag(1)?.removeFromSuperview()
        selectBrandButton.setTitle("Who makes it?", forState: .Normal)
        selectBrandButton.layoutIfNeeded()
        hideBrandSearchView()
        submitButton.setImage(nil, forState: .Normal)
        self.view.layoutIfNeeded()
    }
    
    //Cant Find brand Show/Hide functions
    
    func showCantFindBrandButton() {
        newBrandButton.hidden = false
        newBrandButton.userInteractionEnabled = true
    }
    
    func hideCantFindBrandButton() {
        newBrandButton.hidden = true
        newBrandButton.userInteractionEnabled = false
    }

    //KEYBOARD FUNCTIONS
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
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.actionBarBottomConstraint.constant = keyboardSize.height
                    self.view.layoutIfNeeded()
                    self.keyboardActive = true
                })
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.actionBarBottomConstraint.constant = 0
                    self.view.layoutIfNeeded()
                    self.keyboardActive = false
                })
            }
        }
    }

}
