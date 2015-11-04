//
//  TagCell.swift
//  vivr v4
//
//  Created by max blessen on 5/12/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class TagCell: UITableViewCell {
    
    @IBOutlet weak var selectedIndicator: UIImageView!
    var selectedTags = []
    var tagID:String?
    let check = UIImage(named: "checkmark")
    
    @IBOutlet weak var tagName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        switch selected {
        case true:
            selectedIndicator.image = check
        default:
            selectedIndicator.image = nil
        }
    }
    

}
