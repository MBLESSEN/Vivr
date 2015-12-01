//
//  AddNewJuiceView.swift
//  vivr
//
//  Created by max blessen on 9/10/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

protocol AddNewJuiceViewDelegate {
    func submit()
}

class AddNewJuiceView: UIViewController, UISearchBarDelegate, BrowseViewDelegate, UITextFieldDelegate {
    
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
    @IBOutlet weak var newBrandButton: UIButton!
    
    @IBOutlet weak var brandName: B68UIFloatLabelTextField!
    
    
    
    @IBOutlet weak var juiceName: B68UIFloatLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instantiateSearchView()
        newBrandButton.contentHorizontalAlignment = .Right
        juiceName.returnKeyType = .Done
        brandName.returnKeyType = .Done
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        juiceName.becomeFirstResponder()
        configureNavBar()
    }
    
    //CONFIGURE NAV BAR
    
    func configureNavBar() {
        self.navigationController?.navigationBarHidden = true
    }
    
    func brandSelected(brandID: Int, brandName: String) {
        selectedBrandID = brandID
        selectedBrandName = brandName
        self.selectBrandButton.setTitle(selectedBrandName, forState: .Normal)
        tableActive = false
        searchHeight!.constant = 0
        brandSearch!.view.removeFromSuperview()
        
    }
    
    func instantiateSearchView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        brandSearch = storyboard.instantiateViewControllerWithIdentifier("browseView") as? VIVRBrowseViewController
        brandSearch!.brandViewDelegate = self
        brandSearch!.segueActive = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addJuicePressed(sender: AnyObject) {
        self.juiceName.endEditing(true)
        if juiceName.text!.isEmpty || selectedBrandName == nil {
            let emptyAlert = UIAlertController(title: "oops!", message: "Please complete all fields", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        }else{
        viewDelegate?.submit()
        self.dismissViewControllerAnimated(false, completion: nil)
        }
    }

    @IBAction func cancelPressed(sender: AnyObject) {
        self.juiceName.text = ""
        self.brandName.text = ""
        self.selectedBrandName = nil
        self.selectedBrandID = nil
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func selectBrandPressed(sender: AnyObject) {
        self.juiceName.endEditing(true)
        if tableActive == false {
            tableActive = true
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
        }else {
            tableActive = false
            searchHeight!.constant = 0
            brandSearch!.view.removeFromSuperview()
        }
    }
    @IBAction func enterNewBrandPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("addNewBrandSegue", sender: self)
        
        
        /*
        if tableActive == true {
            tableActive = false
            searchHeight!.constant = 0
            brandSearch!.view.removeFromSuperview()
        }
        if newBrandActive == false {
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                self.selectBrandButton.alpha = 0
                self.selectBrandButton.userInteractionEnabled = false
            }, completion: { finished in
                UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                        self.brandName.alpha = 1.0
                        self.brandName.userInteractionEnabled = true
                        self.brandName.becomeFirstResponder()
                    }, completion: { finished in
                        self.newBrandButton.setTitle("cancel", forState: .Normal)
                        self.newBrandActive = true
                        
                })
        })
        }else {
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                self.selectBrandButton.alpha = 1
                self.selectBrandButton.userInteractionEnabled = true
                }, completion: { finished in
                    UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                        self.brandName.alpha = 0.0
                        self.brandName.userInteractionEnabled = false
                        }, completion: { finished in
                           self.newBrandButton.setTitle("Enter new brand", forState: .Normal)
                            self.newBrandActive = false
                    })
            })
            
            
        }*/
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
    

}
