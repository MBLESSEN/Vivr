//
//  VIVRMoreActionSheet.swift
//  vivr
//
//  Created by max blessen on 1/27/16.
//  Copyright © 2016 max blessen. All rights reserved.
//

import UIKit

enum VIVRMoreActionSheetType {
    case VIVRMoreActionSheetTypeOthersReview
    case VIVRMoreActionSheetTypeMyReview
}

class VIVRMoreActionSheet: UIAlertController {
    
    var delegate: VIVRActionSheetProtocol? = nil
    var review:ActivityFeedReviews?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func actionSheetWithType(type: VIVRMoreActionSheetType, object: AnyObject?) -> VIVRMoreActionSheet {
        let actionController = setupActionSheetForType(type, object: object)
        return actionController
    }
    
    
    class func setupActionSheetForType(type: VIVRMoreActionSheetType, object: AnyObject?) -> VIVRMoreActionSheet {
        switch type {
        case .VIVRMoreActionSheetTypeOthersReview:
            return self.actionSheetForTypeOthersReview()
        case .VIVRMoreActionSheetTypeMyReview:
            return self.actionSheetForTypeMyReview(object)
        }
    }
    
    
    class func actionSheetForTypeOthersReview() -> VIVRMoreActionSheet {
        let actionController = VIVRMoreActionSheet(title: nil, message: "What would you like to do", preferredStyle: .ActionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        actionController.addAction(cancelAction)
        
        return actionController
    }
    
    class func actionSheetForTypeMyReview(review: AnyObject?) -> VIVRMoreActionSheet {
        let actionController = VIVRMoreActionSheet(title: "Your review of:", message: "What would you like to do", preferredStyle: .ActionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        let editAction: UIAlertAction = UIAlertAction(title: "Edit", style: .Default) { (action) in
            actionController.delegate?.editReview(actionController.review!)
        }
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            actionController.delegate?.deleteReview(actionController.review!)
        }
        
        actionController.addAction(cancelAction)
        actionController.addAction(editAction)
        actionController.addAction(deleteAction)
        
        if review != nil {
            actionController.review = review as? ActivityFeedReviews
            actionController.message = "\(actionController.review!.product!.name!) by \(actionController.review!.product!.brand!.name!)"
        }
        
        return actionController
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
