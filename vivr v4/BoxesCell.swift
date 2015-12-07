//
//  BoxesCell.swift
//  vivr v4
//
//  Created by max blessen on 7/22/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

@objc protocol BoxesCellDelegate {
    optional func addProduct(cell: BoxesCell)
    optional func goToBox(cell: BoxesCell)
    optional func goToUser(userID: Int)
}

struct RowHeight {
    static var tableHeight: CGFloat = 128
}

class BoxesCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var productsTable: UITableView!
    @IBOutlet weak var boxName: UILabel!
    var boxID: Int?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var juiceCount: UILabel!
    var cellDelegate: BoxesCellDelegate? = nil
    @IBOutlet weak var productTableHeight: NSLayoutConstraint!
    @IBOutlet weak var productTableView: UIView!
    var indexPath: NSIndexPath?
    @IBOutlet weak var rightButton: UIButton!
    
    var expandedHeight:CGFloat?
    var userID: Int?
    var boxProductWrapper: ProductWrapper?
    var arrowImage = UIImage(named: "down")?.imageWithRenderingMode(.AlwaysTemplate)
    class var expandedHeight: CGFloat { get { return RowHeight.tableHeight }}
    class var defaultHeight: CGFloat  { get { return 100.0  } }
    var products: Array<Product>?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewButton?.tintColor = UIColor.lightGrayColor()
        setArrowButton()
        productsTable?.delegate = self
        productsTable?.dataSource = self
        userImage?.layer.cornerRadius = userImage.frame.width/2
        userImage?.clipsToBounds = true
        self.userImage?.layer.borderWidth = 3.0
        self.userImage?.layer.borderColor = UIColor(white: 1.0, alpha: 0.5).CGColor
        
    }
    
    deinit {
        self.ignoreFrameChanges()
    }
    
    
    func setArrowButton() {
        viewButton?.setImage(arrowImage, forState: UIControlState.Normal)
        viewButton?.userInteractionEnabled = false
        viewButton?.setTitle("", forState: .Normal)
    }
    func setViewText() {
        viewButton?.setImage(nil, forState: .Normal)
        viewButton?.setTitle("view box", forState: .Normal)
        viewButton?.userInteractionEnabled = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func addProductPressed(sender: AnyObject) {
        cellDelegate?.addProduct!(self)
    }
    @IBAction func goToBoxPressed(sender: AnyObject) {
        cellDelegate?.goToBox!(self)
    }
    
    func checkHeight() {
        productTableView.hidden = (frame.size.height < self.expandedHeight)
        if productTableView.hidden == true {
            setArrowButton()
        }else {
            loadBoxProducts(boxID!, completionHandler: { (products) -> Void in
                let tableHeight = 98 + (70 * products!.count)
                RowHeight.tableHeight = CGFloat(tableHeight)
            })
            setViewText()
        }
    }
    
    func watchFrameChanges() {
        addObserver(self, forKeyPath: "frame", options: [NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Initial], context: nil)
    }
    
    func ignoreFrameChanges() {
        //removeObserver(self, forKeyPath: "frame")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "frame" {
            checkHeight()
        }
    }
    @IBAction func userTapped(sender: AnyObject) {
        cellDelegate?.goToUser!(self.userID!)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = productsTable.dequeueReusableCellWithIdentifier("productCell") as! ProductTableViewCell
        if products != nil {
            let index = products![indexPath.row]
            cell.productLabel.text = index.name
            if let urlString = index.image {
                let url = NSURL(string: urlString)
                cell.productImage?.hnk_setImageFromURL(url!, placeholder: UIImage(named: "VivrLogo"))
            }
        }
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.products == nil {
            return 0
        }else {
            return products!.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
    func loadBoxProducts(boxID: Int, completionHandler: (products: Array<Product>?) -> Void) {
        self.products = nil
        Boxes.getBoxProducts(boxID, completionHandler: { (productWrapper, error) in
            if error != nil {
                print(error, terminator: "")
            }
            self.addBoxProductsFromWrapper(productWrapper)
            completionHandler(products: productWrapper!.Products)
            self.productsTable.reloadData()
        })
        
    }
    
    func addBoxProductsFromWrapper(wrapper: ProductWrapper?) {
        self.boxProductWrapper = wrapper
        if self.products == nil {
            self.products = self.boxProductWrapper?.Products
        }
    }

}
