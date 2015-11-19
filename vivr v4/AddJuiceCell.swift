//
//  AddJuiceCell.swift
//  vivr
//
//  Created by max blessen on 9/10/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

protocol AddJuiceCellDelegate {
    func addJuice()
}

class AddJuiceCell: UITableViewCell {
    
    var cellDelegate: AddJuiceCellDelegate? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func addJuicePressed(sender: AnyObject) {
        cellDelegate?.addJuice()
    }

}
