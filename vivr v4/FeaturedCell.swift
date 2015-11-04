//
//  FeaturedCell.swift
//  vivr
//
//  Created by max blessen on 9/12/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class FeaturedCell: UITableViewCell {

    @IBOutlet weak var gradiantView: UIView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        createGradiant()
    }

    func createGradiant() {
        self.gradiantView.backgroundColor = UIColor.clearColor()
        gradientLayer.frame = self.gradiantView.bounds
        let color1 = UIColor.clearColor().CGColor
        let color2 = UIColor.blackColor().CGColor
        self.gradiantView.alpha = 0.6
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 0.6]
        self.gradiantView.layer.addSublayer(gradientLayer)
        self.bringSubviewToFront(postTitle)
        self.bringSubviewToFront(postDescription)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
