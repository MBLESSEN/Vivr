//
//  VIVRShoppingCartViewController.swift
//  vivr
//
//  Created by max blessen on 11/19/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import UIKit

class VIVRShoppingCartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        var frame:CGRect = self.view.frame
        let frontviewWidth = self.view.frame.width - self.revealViewController().rightViewRevealWidth
        frame.size.width = self.view.frame.width - frontviewWidth
        frame.origin.x = frame.origin.x + frontviewWidth
        self.view.frame = frame
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
