//
//  LoadingScreenViewController.swift
//  vivr
//
//  Created by max blessen on 12/3/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import UIKit

class LoadingScreenViewController: UIViewController {

    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    
    var viewDelegate: VIVRActivityIndicatorProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        showActivityIndicator()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showRefreshButton() {
        self.refreshButton.hidden = false
        self.refreshButton.userInteractionEnabled = true
        self.activityIndicator.hidden = true
        self.activityIndicator.stopAnimating()
    }
    
    func showActivityIndicator() {
        self.refreshButton.hidden = true
        self.refreshButton.userInteractionEnabled = false
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        viewDelegate?.reloadViewControllerData!()
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
