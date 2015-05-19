
//
//  reviewTableViewCell.swift
//  vivr v4
//
//  Created by max blessen on 1/26/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

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
    var helpfullState:String? {
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
        case "isLiked":
            helpfull!.titleEdgeInsets = UIEdgeInsetsMake(5, -2.5, 5, 0)
            helpfull!.layer.borderColor = (UIColor.purpleColor()).CGColor
            helpfull!.tintColor = UIColor.whiteColor()
            helpfull!.backgroundColor = UIColor.purpleColor()
            helpfull!.setTitle("Helpful", forState: .Normal)
        case "notLiked":
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
        case "isLiked":
            helpfullState = "notLiked"
        case "notLiked":
            helpfullState = "isLiked"
        default:
            println("error")
        }
        self.buttonState()
    }
    
    func loadReviews() {
        self.reviewContent.text = self.review?["description"].string
        self.reviewContent.sizeToFit()
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
