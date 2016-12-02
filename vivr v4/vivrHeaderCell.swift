//
//  vivrHeaderCell.swift
//  vivr v4
//
//  Created by max blessen on 2/11/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

protocol VivrHeaderCellDelegate {
    
    func tappedUser(cell: vivrHeaderCell)
    
}


class vivrHeaderCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var userNameButton: UIButton?
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var helpfullButton: UIButton!
    @IBOutlet weak var wishListButton: UIButton!
    @IBOutlet weak var userHardware: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    

    var productID:String?
    var cellDelegate: VivrHeaderCellDelegate?
    var userID:String = ""
    var userName:String = "" 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func toUser(sender: AnyObject) {
        cellDelegate?.tappedUser(self)
    }
    var rating:String? {
        didSet {
                self.scoreLabel.text = rating
            }
    }

}
