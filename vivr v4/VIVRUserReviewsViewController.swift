//
//  VIVRUserReviewsViewController.swift
//  vivr
//
//  Created by max blessen on 12/1/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import UIKit

class VIVRUserReviewsViewController: UIViewController, reviewCellDelegate, UIScrollViewDelegate, VIVREmptyStateProtocol {

    @IBOutlet weak var reviewTable: UITableView!
    var userReviews:Array<ActivityFeedReviews>?
    var isLoadingReviews = false
    var userReviewsWrapper:ActivityWrapper?
    var selectedUserID:Int?
    var selectedProductId: String?
    
    var topPanelActive = true
    @IBOutlet weak var topPanel: UIView!
    @IBOutlet weak var topPanelHeightConstraint: NSLayoutConstraint!
    //SCROLLVIEW DATA VARIABLES
    var initialPoint: CGPoint?
    var emptyStateView: VIVREmptyStateView?
    
    @IBOutlet weak var juiceCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instantiateEmptyStateView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        setEmptyStateView()
    }
    
    func setUserStats() {
        self.juiceCountLabel.text = "\(userReviewsWrapper!.count!)"
    }
    
    //UITABLEVIEW DATASOURCE & DELEGATE FUNCTIONS
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userReviews?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return reviewCellAtIndexPath(indexPath)
    }
    
    
    func reviewCellAtIndexPath(indexPath:NSIndexPath) -> myReviewsCell {
        let cell = self.reviewTable.dequeueReusableCellWithIdentifier("myReviews") as! myReviewsCell
        if self.userReviews != nil && self.userReviews!.count >= indexPath.row {
            if let cID = indexPath.row as Int? {
                cell.cellID = cID
            }
            setImageForReview(cell, indexPath: indexPath)
            setReviewForCell(cell, indexPath: indexPath)

            let rowsToLoadFromBottom = 5
            let rowsLoaded = self.userReviews!.count
            if (!self.isLoadingReviews && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                let totalRows = self.userReviewsWrapper!.count!
                let remainingFeedToLoad = totalRows - rowsLoaded
                if (remainingFeedToLoad > 0) {
                    self.loadMoreReviews()
                }
            }
        }
        cell.cellDelegate = self
        cell.preservesSuperviewLayoutMargins = false
        return cell
    }
    
    
    func setImageForReview(cell:myReviewsCell, indexPath:NSIndexPath) {
        if userReviews != nil && self.reviewTable != nil {
            let review = userReviews![indexPath.row]
            if let imageString = review.product?.image {
                let url = NSURL(string: imageString)
                cell.productImage.hnk_setImageFromURL(url!, placeholder: UIImage(named: "vivrLogo"))
            }
        }
    }
    func setReviewForCell(cell:myReviewsCell, indexPath:NSIndexPath) {
        let review = userReviews![indexPath.row]
        cell.review = review
        cell.state = review.currentHelpful
        cell.productID = review.productID
        cell.reviewID = review.reviewID
        cell.productName.text = review.product?.name
        cell.brandName.text = review.brand?.name
        cell.scoreLabel.text = "\(review.score!)"
        if let throatHit = review.throat {
            var value:String?
            switch throatHit {
            case 0:
                value = "Light"
            case 1:
                value = "Mild"
            case 2:
                value = "Harsh"
            default:
                value = "invalid"
            }
            cell.throat?.text = ("\(value!) throat hit")
        }
        if let vaporProduction = review.vapor {
            var value:String?
            switch vaporProduction {
            case 0:
                value = "Low"
            case 1:
                value = "Average"
            case 2:
                value = "Cloudy"
            default:
                value = "invalid"
            }
            cell.vapor?.text = ("\(value!) vapor production")
        }
        if let helpfullCount = review.helpfulCount {
            switch helpfullCount {
            case 0:
                cell.helpfullLabel.text = "0 people found this helpful"
            default:
                cell.helpfullLabel.text = "\(helpfullCount) people found this helpful"
            }
        }
        
        
    }

    
    //NETWORKING FUNCTIONS
    //LOAD FIRST REVIEWS
    //LOAD MORE REVIews
    
    func loadFirstReviews() {
        if selectedUserID != nil {
            self.userReviews = []
            isLoadingReviews = true
            ActivityFeedReviews.getUserReviews(Int(selectedUserID!), completionHandler: { (activityWrapper, error) in
                if error != nil {
                    self.isLoadingReviews = false
                    let alert = UIAlertController(title: "Error", message: "could not load first activity", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                self.addReviewFromWrapper(activityWrapper)
                self.isLoadingReviews = false
                self.reviewTable.reloadData()
            })
        }
    }
    
    func loadMoreReviews() {
        isLoadingReviews = true
        if self.userReviews != nil && self.userReviewsWrapper != nil && self.userReviews!.count < self.userReviewsWrapper!.count
        {
            ActivityFeedReviews.getMoreUserReviews(Int(selectedUserID!), wrapper: self.userReviewsWrapper, completionHandler: { (moreWrapper, error) in
                if error != nil
                {
                    self.isLoadingReviews = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more activity", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                print("got More")
                self.addReviewFromWrapper(moreWrapper)
                self.isLoadingReviews = false
                self.reviewTable.reloadData()
            })
        }
    }
    
    func addReviewFromWrapper(wrapper: ActivityWrapper?) {
        self.userReviewsWrapper = wrapper
        if wrapper != nil {
            setUserStats()
        }
        if wrapper?.count == 0 {
            showEmptyStateView()
            reviewTable.separatorStyle = UITableViewCellSeparatorStyle.None
        }else {
            hideEmptyStateView()
            reviewTable.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }
        if self.userReviews == nil {
            self.userReviews = self.userReviewsWrapper?.ActivityReviews
        }else if self.userReviewsWrapper != nil && self.userReviewsWrapper!.ActivityReviews != nil{
            self.userReviews = self.userReviews! + self.userReviewsWrapper!.ActivityReviews!
        }
    }
    
    
    
    //REVIEW CELL DELEGATE FUNCTIONS
    //TAPPED PRODUCT
    //RELOAD API
    
    func tappedProductbutton(cell: myReviewsCell) {
        self.selectedProductId = cell.productID!
        self.performSegueWithIdentifier("userReviewToProduct", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let productVC = segue.destinationViewController as! VIVRProductViewController
        productVC.selectedProductID = self.selectedProductId
    }
    

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let newPoint = reviewTable.contentOffset
        print(newPoint.y)
        if newPoint.y == 0.0 {
            if topPanelActive == false{
                UIView.animateWithDuration(0.3, animations: {
                    self.topPanelHeightConstraint.constant = 0
                    self.topPanelActive = true
                    self.view.layoutIfNeeded()
                })
            }

        }
            if (newPoint.y - self.initialPoint!.y) > 25.0 {
                if topPanelActive == true{
                UIView.animateWithDuration(0.3, animations: {
                    self.topPanelHeightConstraint.constant = 0 - self.topPanel.frame.height
                    self.topPanelActive = false
                    self.view.layoutIfNeeded()
                })
                }
            }else if (newPoint.y - self.initialPoint!.y) < -25 {
                if topPanelActive == false{
                UIView.animateWithDuration(0.3, animations: {
                    self.topPanelHeightConstraint.constant = 0
                    self.topPanelActive = true
                    self.view.layoutIfNeeded()
                })
                }
            }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.initialPoint = reviewTable.contentOffset
        print("------ INITAL POINT SET TO \(self.initialPoint)")
    }
    
    
    //INSTATIATE CHILD VIEWS
    //SHOW HIDE CHILD VIEWS
    
    func instantiateEmptyStateView() {
        self.emptyStateView = VIVREmptyStateView.instanceFromNib(VIVREmptyStateView.emptyStateType.juiceCheckIn, stringContext: nil)
        emptyStateView!.emptyStateDelegate = self
    }
    
    func setEmptyStateView() {
        emptyStateView!.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
    }
    
    func showEmptyStateView() {
        if emptyStateView != nil {
            self.reviewTable.backgroundView = emptyStateView!
        }
    }
    
    func hideEmptyStateView() {
            self.reviewTable.backgroundView = nil
        
    }
    
    //VIVR EMPTY STATE PROTOCOL DELEGATE FUNCTIONS
    //EMPTY STATE BUTTON PRESSED
    
    func buttonPressed() {
        let parent = parentViewController as! VIVRJuiceCheckIn
        parent.searchBar.becomeFirstResponder()
    }

}
