//
//  tagCollectionCell.swift
//  vivr v4
//
//  Created by max blessen on 6/23/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class tagCollectionCell: UICollectionViewCell {
    var tagID:String?
    @IBOutlet weak var tagName: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selected = false
    }
    
    override var selected : Bool {
        didSet {
            switch selected {
            case true:
                self.colorView.alpha = 1.0
            case false:
                self.colorView.alpha = 0.5
            default:
                print("error", terminator: "")
            }
        }
    }
}

