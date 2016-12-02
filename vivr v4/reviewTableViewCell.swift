
//
//  reviewTableViewCell.swift
//  vivr v4
//
//  Created by max blessen on 1/26/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol ReviewCellDelegate {
    func reloadAPI(cell: reviewTableViewCell)
    func tappedFlavorReviewCommentbutton(cell: reviewTableViewCell)
    func helpfulTrue(cell: reviewTableViewCell)
    func helpfulFalse(cell: reviewTableViewCell)
}

class reviewTableViewCell: UITableViewCell {
    @IBOutlet weak var reviewContent: UILabel!
    @IBOutlet weak var userTaste: UILabel!
    @IBOutlet weak var userFlavor: UILabel!
    @IBOutlet weak var userThroat: UILabel!
    @IBOutlet weak var userVapor: UILabel!
    @IBOutlet weak var reputation: UILabel!
    @IBOutlet weak var helpfulLabel: UILabel!
    @IBOutlet weak var helpfull: VIVRHelpfulButton!
    @IBOutlet weak var throat: UILabel!
    @IBOutlet weak var vapor: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    
    var cellID:Int?
    var cellDelegate:ReviewCellDelegate? = nil
    var productID:String?
    var reviewID:String?
    var likeImage = UIImage(named: "likeFilled")?.imageWithRenderingMode(.AlwaysTemplate)
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var review:ActivityFeedReviews?
    
    var helpfullState:Bool? {
        didSet {
            self.helpfull?.currentHelpful = helpfullState!
        }
    }
    
    @IBAction func helpfullPressed(sender: AnyObject) {
        switch helpfullState! {
        case true:
            helpfullState = false
            Alamofire.request(Router.notHelpful(productID!, reviewID!))
            cellDelegate?.helpfulFalse(self)
        case false:
            helpfullState = true
            Alamofire.request(Router.isHelpful(productID!, reviewID!))
            cellDelegate?.helpfulTrue(self)
        default:
            print("error", terminator: "")
        }
        self.cellDelegate?.reloadAPI(self)
    }
    
    @IBAction func commentPressed(sender: AnyObject) {
        cellDelegate?.tappedFlavorReviewCommentbutton(self)
    }
    
//    func loadReviews() {
//        if let rid = self.review?["id"].stringValue as String? {
//            reviewID = rid
//            Alamofire.request(Router.readCommentsAPI(productID!, reviewID!)).responseJSON { (response) in
//                if (response.result.isSuccess) {
//                    let json = response.data
//                    var jsonOBJ = JSON(json!)
//                    if let commentsCount = jsonOBJ["total"].stringValue as String? {
//                        self.commentButton.setTitle("\(commentsCount) comments", forState: .Normal)
//                        self.commentButton.sizeToFit()
//                    }
//                }
//            }
//        }
//        if let date = self.review?["created_at"].stringValue as String?{
//            let dateFor:NSDateFormatter = NSDateFormatter()
//            dateFor.timeZone = NSTimeZone(abbreviation: "UTC")
//            dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//            let theDate:NSDate = dateFor.dateFromString(date)!
//            let tempoDate = Tempo(date: theDate)
//            let timeStamp = tempoDate.timeAgoNow()
//            if let reviewString = self.review?["description"].stringValue as String? {
//                let review = NSMutableAttributedString(string: reviewString + "  -  ")
//                let x = NSAttributedString(string: timeStamp, attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
//                review.appendAttributedString(x)
//                self.reviewContent.attributedText = review
//                
//            }
//        }
//        if let throatHit = self.review?["throat"].int {
//            var value:String?
//            switch throatHit {
//            case 0:
//                value = "Light"
//            case 1:
//                value = "Mild"
//            case 2:
//                value = "Harsh"
//            default:
//                value = "invalid"
//            }
//            self.throat.text = ("\(value!) throat hit")
//        }
//        if let vaporProduction = self.review?["vapor"].int {
//            var value:String?
//            switch vaporProduction {
//            case 0:
//                value = "Low"
//            case 1:
//                value = "Average"
//            case 2:
//                value = "Cloudy"
//            default:
//                value = "invalid"
//            }
//            self.vapor.text = ("\(value!) vapor production")
//        }
//        
//        
//    }
    
    @IBAction func up(sender: AnyObject) {
        
    }

    @IBAction func down(sender: AnyObject) {
    }
}
