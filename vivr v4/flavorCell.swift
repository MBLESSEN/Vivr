//
//  flavorCell.swift
//  vivr v4
//
//  Created by max blessen on 4/6/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class flavorCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var flavors:JSON? {
        didSet {
           loadData()
        }
    }

    func loadData() {
        var viewsDictionary: NSMutableDictionary = [:]
        let count: Int?  = flavors!["tags"].array?.count
        let frameWidth = self.frame.width
        let frameHeight:CGFloat = 16
        var padding:CGFloat = 32.0
        var labelFrameHeight:CGFloat = 16
        var labelFrame = UIView()
        if let ct = count {
            for index in 0...ct-1 {
                if let fTag = self.flavors!["tags"][index]["name"].string {
                    println(fTag)
                    var label = UILabel()
                    label.text = fTag
                    label.font = UIFont.systemFontOfSize(14.0)
                    label.frame = CGRectMake(16, padding, frameWidth-16, frameHeight)
                    var labelName = "label"+String(index)
                    viewsDictionary.setValue(label, forKey: labelName)
                    labelFrame.addSubview(label)
                    padding = padding+frameHeight+2
                    labelFrameHeight = labelFrameHeight+frameHeight
                }
            }
            labelFrame.frame = CGRectMake(0, 0, frameWidth, labelFrameHeight+8)
            self.contentView.addSubview(labelFrame)
            let views:NSDictionary = ["view": labelFrame]
            for (labelKey, labelObject) in views {
                contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-24-[\(labelKey)]-16-|", options: .allZeros, metrics: nil, views: views as [NSObject : AnyObject]))
                contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-16-[\(labelKey)]-16-|", options: .allZeros, metrics: nil, views: views as [NSObject : AnyObject]))
            }
        }
        /*
        for (labelKey, label) in viewsDictionary {
            println(label)
            var spacing = 20
            var labelSize = label.width
            var currentLabelNumber = 0
            var nextLabelNumber = 1
            var currentLabel: AnyObject? = viewsDictionary[currentLabelNumber]
            var nextLabel: AnyObject? = viewsDictionary[nextLabelNumber]
            if labelKey as String == "0" {
                contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(spacing)-[\(label)]", options: .allZeros, metrics: nil, views: viewsDictionary))
            }
            else {
                contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[\(currentLabel)]-\(spacing)-[\(nextLabel)]", options: .allZeros, metrics: nil, views: viewsDictionary))
                currentLabelNumber++
                nextLabelNumber++
            }
        }
*/
    }

}
