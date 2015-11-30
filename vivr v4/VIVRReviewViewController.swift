//
//  VIVRReviewViewController.swift
//  vivr
//
//  Created by max blessen on 11/30/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import UIKit

class VIVRReviewViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    var reviewScoreView:VIVRReviewScoreViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instantiateReviewScoreView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // INSTANTIATE REVIEWSCOREVIEW
    // ADD REVIEW SCORE VIEW
    
    func instantiateReviewScoreView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        reviewScoreView = storyboard.instantiateViewControllerWithIdentifier("reviewScore") as! VIVRReviewScoreViewController
        addChildViewController(reviewScoreView!)
        reviewScoreView!.view.frame = CGRectMake(0, 0, self.bottomView.frame.width, bottomView.frame.height)
        bottomView.addSubview(reviewScoreView!.view)
        reviewScoreView?.didMoveToParentViewController(self)
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
