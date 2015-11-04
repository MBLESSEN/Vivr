//
//  MyBoxController.swift
//  vivr
//
//  Created by max blessen on 8/24/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

protocol MyBoxControllerDelegate {
    func boxSelected(view: MyBoxController)
}

class MyBoxController: UIViewController, createNewBoxDelegate, UITableViewDataSource, UITableViewDelegate, BoxesCellDelegate {

    @IBOutlet weak var boxTable: UITableView!
    var blurView: UIView?
    var createBoxView: CreateNewBoxController?
    var boxes: Array<Boxes>?
    var boxWrapper: BoxesWrapper?
    var isLoadingBoxes = false
    var createBoxButton: UIBarButtonItem?
    var closeButton: UIBarButtonItem?
    var segueIdentifier: String?
    var selectedBox: Int?
    var selectedProductID: Int?
    var productActive = false
    var viewDelegate: MyBoxControllerDelegate? = nil
    var selectedIndexPath: NSIndexPath?
    var productTableView: boxProductTableView?
    var products: Array<Product>?
    @IBOutlet weak var boxCount: UILabel!
    var titleLabel: UILabel!
    var userName: String?
    var selectedUserID: Int? {
        didSet {
            loadFirstBoxes()
            configureNavBar()
            createCloseButton()
        }
    }
    
    var isMyUser = false {
        didSet {
            switch isMyUser {
            case true:
                createAddBoxButton()
            default:
                print("", terminator: "")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blurView = UIView(frame: CGRectMake(0, -64, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height + 64))
        blurView!.backgroundColor = UIColor.blackColor()
        blurView!.alpha = 0.5
        instantiateNewBoxView()
        titleLabel = UILabel()
        titleLabel.font = UIFont(name: "PTSans-Bold", size: 16)
        titleLabel.textColor = UIColor.whiteColor()
        self.navigationItem.titleView = titleLabel
        
        // Do any additional setup after loading the view.
    }
    
    func createTitleLabel(name: String) {
        userName = "\(name)'s boxes"
    }
    
    override func viewWillAppear(animated: Bool) {
        configureNavBar()
        titleLabel.text = userName
        titleLabel.sizeToFit()
    }
    
    func instantiateboxProductView() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        productTableView = storyboard.instantiateViewControllerWithIdentifier("boxProductTable") as? boxProductTableView
        self.addChildViewController(self.productTableView!)
        
        
        
    }
    
    func boxCreated() {
        loadFirstBoxes()
    }
    
    func createCloseButton() {
        closeButton = UIBarButtonItem(title: "close", style: .Plain, target: self, action: "dimissView")
        self.navigationItem.leftBarButtonItem = closeButton
    }
    
    func dimissView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func instantiateNewBoxView() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        createBoxView = storyboard.instantiateViewControllerWithIdentifier("createBoxView") as? CreateNewBoxController
        createBoxView!.viewDelegate = self
    }
    
    func createAddBoxButton() {
        let plusImage = UIImage(named: "plusGrey")?.imageWithRenderingMode(.AlwaysTemplate)
        let button = UIButton(type: .System)
        button.frame = CGRectMake(0, 0, 25, 25)
        button.setImage(plusImage, forState: .Normal)
        button.addTarget(self, action: "createBox", forControlEvents: .TouchUpInside)
        createBoxButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: "createBox")
        createBoxButton?.customView = button
        self.navigationItem.rightBarButtonItem = createBoxButton
    }
    
    func configureNavBar(){
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showBlurView() {
        self.view.addSubview(blurView!)
        self.navigationController?.view.addSubview(blurView!)
        
    }
    
    func hideBlurView(view: CreateNewBoxController) {
        self.blurView!.removeFromSuperview()
        self.loadFirstBoxes()
    }
    
    func createBox() {
        showBlurView()
        self.presentViewController(createBoxView!, animated: true, completion: nil)
        createBoxView!.prepareToCreate()
        createBoxView!.editActive = false
    }
    
    func addProduct(cell: BoxesCell) {
        if isMyUser == true && productActive == false {
            self.presentViewController(createBoxView!, animated: true, completion: nil)
            createBoxView!.prepareToEdit()
            createBoxView!.editActive = true
            createBoxView!.selectedBoxID = cell.boxID
            createBoxView!.boxName.text = cell.boxName.text
            createBoxView!.boxDescription.text = cell.descriptionLabel!.text
            createBoxView!.viewTitle.text = "Edit your box"
            showBlurView()
        }else {
        let alert = UIAlertController(title: "Add juice to a box", message: "Would you like to add the juice to this box?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {action in
                Boxes.addProductToBox(cell.boxID!, productID: self.selectedProductID!, completionHandler: { (error) in
                    if error != nil {
                        let alert = UIAlertController(title: "Error", message: "could not add product to your box", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }else {
                        let alert = UIAlertController(title: "Success!", message: "Juice was added to your box", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {action in self.dismissViewControllerAnimated(true, completion: {
                        })}))
                        self.presentViewController(alert, animated: true, completion: nil)

                    }
                })

            
            }))
            alert.addAction(UIAlertAction(title: "CANCEL", style: .Default, handler:nil
            ))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func goToBox(cell: BoxesCell) {
        selectedBox = cell.boxID!
        self.dismissViewControllerAnimated(true, completion: {
            viewDelegate?.boxSelected(self)
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = boxTable.dequeueReusableCellWithIdentifier("box") as! BoxesCell
        if boxes != nil {
            let boxIndex = boxes![indexPath.row]
            cell.boxID = boxIndex.boxID
            cell.descriptionLabel!.text = boxIndex.description
            if cell.descriptionLabel!.text == "" {
                cell.descriptionLabel!.text = "This box does not have a description"
                cell.descriptionLabel!.sizeToFit()
            }
            if let tableHeight = 98 + (70 * boxIndex.productCount!) as Int? {
                if boxIndex.productCount == 1 {
                    cell.expandedHeight = CGFloat(168)
                }else{
                cell.expandedHeight = CGFloat(tableHeight)
                }
            }
            cell.boxName.text = boxIndex.name
            cell.juiceCount.text = "\(boxIndex.productCount!) Juices"
            cell.cellDelegate = self
            cell.indexPath? = indexPath
            if isMyUser == true {
                cell.rightButton.hidden = false
                cell.rightButton.userInteractionEnabled = true
                let editImage = UIImage(named: "edit")?.imageWithRenderingMode(.AlwaysTemplate)
                cell.rightButton.setImage(editImage, forState: .Normal)
                if productActive == true {
                    cell.rightButton.userInteractionEnabled = true
                    let addImage = UIImage(named: "plusGrey")?.imageWithRenderingMode(.AlwaysTemplate)
                    cell.rightButton.setImage(addImage, forState: .Normal)
                }
            }
            let rowsToLoadFromBottom = 5
            let rowsLoaded = self.boxes!.count
            if (!self.isLoadingBoxes && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                let totalRows = self.boxWrapper!.count!
                let remainingFeedToLoad = totalRows - rowsLoaded
                if (remainingFeedToLoad > 0) {
                    self.loadMoreBoxes()
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boxes?.count ?? 0
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        segueIdentifier = "toBox"
            //self.dismissViewControllerAnimated(true, completion: { viewDelegate?.boxSelected(self)})
            let previousIndexPath = selectedIndexPath
            if indexPath == selectedIndexPath {
                selectedIndexPath = nil
            } else {
                selectedIndexPath = indexPath
            }
        if selectedIndexPath != nil {
            let cell = boxTable.cellForRowAtIndexPath(selectedIndexPath!) as! BoxesCell
            let height = cell.expandedHeight
            RowHeight.tableHeight = height!
            
        }
        
            var indexPaths : Array<NSIndexPath> = []
            if let previous = previousIndexPath {
                indexPaths += [previous]
            }
            if let current = selectedIndexPath {
                indexPaths += [current]
                
            }
           
            if indexPaths.count > 0 {
                self.boxTable.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! BoxesCell).watchFrameChanges()
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! BoxesCell).ignoreFrameChanges()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == selectedIndexPath {
            return BoxesCell.expandedHeight
        } else {
            return BoxesCell.defaultHeight
        }
    }

    func loadBoxProducts(boxID: Int, completionHandler: (products: Array<Product>?) -> Void) {
        self.products = nil
        Boxes.getBoxProducts(boxID, completionHandler: { (productWrapper, error) in
            if error != nil {
                print(error, terminator: "")
            }
            completionHandler(products: productWrapper!.Products)
        })
        
    }
    
    
    func loadFirstBoxes() {
        self.boxes = []
        isLoadingBoxes = true
        Boxes.getAllUserBoxes(selectedUserID!, completionHandler: { (boxesWrapper, error) in
            if error != nil {
                self.isLoadingBoxes = false
                let alert = UIAlertController(title: "Error", message: "could not load first activity", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.addBoxFromWrapper(boxesWrapper)
            self.isLoadingBoxes = false
            self.boxTable.reloadData()
        
        })
    }
    
    func loadMoreBoxes() {
        isLoadingBoxes = true
        if self.boxes != nil && self.boxWrapper != nil && self.boxes!.count < self.boxWrapper!.count
        {

            Boxes.getMoreUserBoxes(selectedUserID!, wrapper: self.boxWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingBoxes = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more activity", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                print("got More", terminator: "")
                self.addBoxFromWrapper(moreWrapper)
                self.isLoadingBoxes = false
                self.boxTable.reloadData()
            })
        }

    }
    
    
    func addBoxFromWrapper(wrapper: BoxesWrapper?) {
        self.boxWrapper = wrapper
        if self.boxes == nil {
            self.boxes = self.boxWrapper!.Box
            self.boxCount.text = "\(wrapper!.count!)"
        }else if self.boxWrapper != nil && self.boxWrapper!.Box != nil {
            self.boxes = self.boxes! + self.boxWrapper!.Box!
            self.boxCount.text = "\(wrapper!.count!)"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier!{
        case "toBox":
            let boxVC: brandFlavorViewController = segue.destinationViewController as! brandFlavorViewController
            boxVC.boxOrProduct = "box"
            boxVC.selectedBoxID = self.selectedBox!
        default:
            print("no segue", terminator: "")
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
