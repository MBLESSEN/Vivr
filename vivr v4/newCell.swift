//
//  newCell.swift
//  vivr v4
//
//  Created by max blessen on 2/6/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//


import UIKit
import Haneke
import SwiftyJSON

class newCell: UITableViewCell {
    
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
            self.loadProducts()
        }
    }
    
    func loadProducts() {
        
    }
    
    
    
}
