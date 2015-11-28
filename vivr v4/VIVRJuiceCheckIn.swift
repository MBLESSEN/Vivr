//
//  VIVRJuiceCheckIn.swift
//  vivr
//
//  Created by max blessen on 11/27/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import UIKit

class VIVRJuiceCheckIn: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        showTitleLogo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //NAVIGATION AND VIEW CUSTOMIZATION
    
    func showTitleLogo(){
        let logo = UIImage(named: "vivrTitleLogo")?.imageWithRenderingMode(.AlwaysOriginal)
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
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
