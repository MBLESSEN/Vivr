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
    @IBOutlet weak var noNetworkImage: UIImageView!
    @IBOutlet weak var noNetworkButton: UIButton!
    @IBOutlet weak var noNetworkLabel: UILabel!
    
    var viewDelegate: VIVRActivityIndicatorProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
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
        self.view.backgroundColor = UIColor.whiteColor()
        self.refreshButton.hidden = true
        self.refreshButton.userInteractionEnabled = false
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        viewDelegate?.reloadViewControllerData!()
    }
    
    @IBAction func tryAgainPressed(sender: AnyObject) {
        viewDelegate?.reloadViewControllerData!()
    }
    
    class func createNoNetworkLoadingScreen() -> LoadingScreenViewController {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewControllerWithIdentifier("activityIndicator") as! LoadingScreenViewController
        controller.setupControllerForNoNetwork()
        return controller

    }
    
    func setupControllerForNoNetwork() {
        self.view.backgroundColor = VIVRConstants.vivrGreen
        self.noNetworkImage.tintColor = UIColor.whiteColor()
        self.noNetworkImage.hidden = false
        self.noNetworkButton.hidden = false
        self.noNetworkLabel.hidden = false
        self.activityIndicator.hidden = true
        self.refreshButton.hidden = true
    }
    
    func setupControllerForLoading() {
        self.noNetworkImage.hidden = true
        self.noNetworkButton.hidden = true
        self.showActivityIndicator()
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
