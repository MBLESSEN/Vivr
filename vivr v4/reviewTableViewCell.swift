
//
//  reviewTableViewCell.swift
//  vivr v4
//
//  Created by max blessen on 1/26/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

protocol ReviewCellDelegate {
    func reloadAPI(cell: reviewTableViewCell)
    func tappedFlavorReviewCommentbutton(cell: reviewTableViewCell)
}

class reviewTableViewCell: UITableViewCell {
    @IBOutlet weak var reviewContent: UILabel!
    @IBOutlet weak var userTaste: UILabel!
    @IBOutlet weak var userFlavor: UILabel!
    @IBOutlet weak var userThroat: UILabel!
    @IBOutlet weak var userVapor: UILabel!
    @IBOutlet weak var reputation: UILabel!
    @IBOutlet weak var helpfulLabel: UILabel!
    @IBOutlet weak var helpfull: UIButton!
    @IBOutlet weak var throat: UILabel!
    @IBOutlet weak var vapor: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
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
    
    var review:JSON? {
        didSet {
            self.loadReviews()
            
        }
    
    }
    var vivrFeed: JSON? {
        didSet {
            self.loadReviews()
        }
    }
    var helpfullState:Bool? {
        didSet {
            helpfull!.layer.borderWidth = 1
            helpfull!.layer.cornerRadius = 4
            helpfull!.setImage(likeImage, forState: .Normal)
            helpfull!.imageEdgeInsets = UIEdgeInsetsMake(5,7.5, 5, 47.5)
            buttonState()
        }
    }
    func buttonState() {
        switch helpfullState! {
        case true:
            helpfull!.titleEdgeInsets = UIEdgeInsetsMake(5, -2.5, 5, 0)
            helpfull!.layer.borderColor = (UIColor.purpleColor()).CGColor
            helpfull!.tintColor = UIColor.whiteColor()
            helpfull!.backgroundColor = UIColor.purpleColor()
            helpfull!.setTitle("Helpful", forState: .Normal)
        case false:
            helpfull!.titleEdgeInsets = UIEdgeInsetsMake(5, -2.5, 5, 0)
            helpfull!.layer.borderColor = (UIColor.lightGrayColor()).CGColor
            helpfull!.tintColor = UIColor.lightGrayColor()
            helpfull!.backgroundColor = UIColor.whiteColor()
            helpfull!.setTitle("Helpful", forState: .Normal)
        default:
            println("error")
            
        }
    }
    
    @IBAction func helpfullPressed(sender: AnyObject) {
        switch helpfullState! {
        case true:
            helpfullState = false
            Alamofire.request(Router.notHelpful(productID!, reviewID!))
        case false:
            helpfullState = true
            Alamofire.request(Router.isHelpful(productID!, reviewID!))
        default:
            println("error")
        }
        self.buttonState()
        cellDelegate?.reloadAPI(self)
    }
    
    @IBAction func commentPressed(sender: AnyObject) {
        cellDelegate?.tappedFlavorReviewCommentbutton(self)
    }
    
    func loadReviews() {
        if let rid = self.review?["id"].stringValue as String? {
            reviewID = rid
            Alamofire.request(Router.readCommentsAPI(productID!, reviewID!)).responseJSON { (request, response, json, error) in
                if (json != nil) {
                    var jsonOBJ = JSON(json!)
                    if let commentsCount = jsonOBJ["total"].stringValue as String? {
                        self.commentButton.setTitle("\(commentsCount) comments", forState: .Normal)
                        self.commentButton.sizeToFit()
                    }
                }
            }
        }
        if let date = self.review?["created_at"].stringValue as String?{
            let dateFor:NSDateFormatter = NSDateFormatter()
            dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let theDate:NSDate = dateFor.dateFromString(date)!
            let tempoDate = Tempo(date: theDate)
            let timeStamp = tempoDate.timeAgoNow()
            if let reviewString = self.review?["description"].stringValue as String? {
                var review = NSMutableAttributedString(string: reviewString + "  -  ")
                let x = NSAttributedString(string: timeStamp, attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
                review.appendAttributedString(x)
                self.reviewContent.attributedText = review
                
            }
        }
        if let helpfullCount = self.review?["helpful_count"].stringValue {
            switch helpfullCount {
                case "0":
                self.helpfulLabel.text = "Was this helpful?"
            default:
                self.helpfulLabel.text = "\(helpfullCount) found this helpful"
            }
        }
        if let throatHit = self.review?["throat"].int {
            var value:String?
            switch throatHit {
            case 1:
                value = "Feather"
            case 2:
                value = "Light"
            case 3:
                value = "Mild"
            case 4:
                value = "Harsh"
            case 5:
                value = "Very Harsh"
            default:
                value = "invalid"
            }
            self.throat.text = ("\(value!) throat hit")
        }
        if let vaporProduction = self.review?["vapor"].int {
            var value:String?
            switch vaporProduction {
            case 1:
                value = "Very low"
            case 2:
                value = "Low"
            case 3:
                value = "Average"
            case 4:
                value = "High"
            case 5:
                value = "Cloudy"
            default:
                value = "invalid"
            }
            self.vapor.text = ("\(value!) vapor production")
        }
            
        
    }
    
    @IBAction func up(sender: AnyObject) {
        
    }

    @IBAction func down(sender: AnyObject) {
    }
}
