//
//  attributesCell.swift
//  vivr v4
//
//  Created by max blessen on 4/7/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class attributesCell: UITableViewCell {

    @IBOutlet weak var throat: UISegmentedControl!
    @IBOutlet weak var vapor: UISegmentedControl!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var product:JSON? {
        didSet {
            loadData()
        }
    }
    
    func loadData(){
        if let throatValue = product?["scores"]["throat"].int as Int? {
            throat.selectedSegmentIndex = throatValue - 1
        }
        if let vaporValue = product?["scores"]["vapor"].int as Int? {
            vapor.selectedSegmentIndex = vaporValue - 1
        }

    }

}
