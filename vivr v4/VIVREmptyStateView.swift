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
    
    
    enum emptyStateType {
        case juiceCheckIn;
        case emptyUserReviews;
        case emptyActivityWithFilters;
        case emptyUserFavorites;
        case emptyUserWishlist;
        
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
            self.label.text = "\(stringContext!) has no juices checked in"
        case .juiceCheckIn:
            self.image.image = UIImage(named: "search100")
            self.label.text = "Tap the search bar to check in your first juice"
        case .emptyActivityWithFilters:
            self.image.image = UIImage(named: "vivrLogo")
            self.label.text = "There are no juices being checked in with your filters"
        case .emptyUserFavorites:
            self.image.image = UIImage(named: "like100")
            self.label.text = "\(stringContext!) has no favorites"
        case .emptyUserWishlist:
            self.image.image = UIImage(named: "plus100")
            self.label.text = "\(stringContext!) has no juices wishlisted"
        }
    }

    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
