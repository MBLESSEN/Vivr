//
//  VIVREmptyStateView.swift
//  vivr
//
//  Created by max blessen on 12/10/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import UIKit

class VIVREmptyStateView: UIView {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var bottomImage: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var topLeftLabel: UILabel!
    @IBOutlet weak var topMiddleLabel: UILabel!
    @IBOutlet weak var topRightLabel: UILabel!

    
    var emptyStateDelegate: VIVREmptyStateProtocol? = nil
    
    
    enum emptyStateType {
        case juiceCheckIn;
        case emptyUserReviews;
        case emptyMyUserReviews;
        case emptyActivityWithFilters;
        case emptyUserFavorites;
        case emptyUserWishlist;
        case emptyMyUserFavorites;
        case emptyMyUserWishlist;
    }
    
    class func instanceFromNib(state: emptyStateType, stringContext: String?) -> VIVREmptyStateView {
        let view = UINib(nibName: "VIVREmptyStateView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! VIVREmptyStateView
        view.setupViewwithState(state, stringContext: stringContext)
        return view
    }
    
    func setupViewwithState(state: emptyStateType, stringContext: String?) {
        switch state {
        case .emptyUserReviews:
            self.image.image = UIImage(named: "vivrLogo")
            self.label.text = "\(stringContext!) has no E-Liquid checked in"
        case .emptyMyUserReviews:
            self.image.image = UIImage(named: "vivrLogo")
            self.label.text = "You have no E-Liquid checked in"
            self.button.setTitle("Check in your first E-Liquid", forState: .Normal)
            self.topLeftLabel.text = "View your favorites"
            self.topRightLabel.text = "View your wishlist"
        case .juiceCheckIn:
            self.image.image = UIImage(named: "search100")
            self.label.text = "Start checking in your juices now!"
            self.button.setTitle("Check in your first E-Liquid", forState: .Normal)
        case .emptyActivityWithFilters:
            self.image.image = UIImage(named: "vivrLogo")
            self.label.text = "There are no juices being checked in with your flavor filters"
            self.button.setTitle("Clear flavor filters", forState: .Normal)
        case .emptyUserFavorites:
            self.image.image = UIImage(named: "like100")
            self.label.text = "\(stringContext!) has no favorites"
            self.button.hidden = true
        case .emptyUserWishlist:
            self.image.image = UIImage(named: "plus100")
            self.label.text = "\(stringContext!) has no E-Liquid wishlisted"
            self.button.hidden = true
        case .emptyMyUserFavorites:
            self.image.image = UIImage(named: "like100")
            self.label.text = "Add juices you love to your favorites"
            self.bottomImage.image = UIImage(named: "VIVR_IMAGE_TUTORIAL_FAVORITE")
            self.button.setTitle("Discover new E-Liquid", forState: .Normal)
        case .emptyMyUserWishlist:
            self.image.image = UIImage(named: "plus100")
            self.label.text = "Add juices you want to try to your wishlist"
            self.bottomImage.image = UIImage(named: "VIVR_IMAGE_TUTORIAL_WISHLIST")
            self.button.setTitle("Discover new E-Liquid", forState: .Normal)
            
        }
    }

    @IBAction func buttonPressed(sender: AnyObject) {
        emptyStateDelegate?.buttonPressed?()
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
