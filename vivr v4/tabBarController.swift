//
//  tabBarController.swift
//  
//
//  Created by max blessen on 10/7/15.
//
//

import UIKit

class tabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if viewController.title == "checkInView" {
            return false
        }else if viewController.title == "userNav" {
            let navController = viewController as? UINavigationController
            let userVC = navController?.viewControllers[0] as? VIVRUserViewController
            userVC?.selectedUserID = "\(myData.myProfileID!)"
            return true
        }
        else{
            return true
        }
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item.tag == 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let juiceVC = storyboard.instantiateViewControllerWithIdentifier("checkInJuice") as! VIVRCheckInJuiceViewController
            self.presentViewController(juiceVC, animated: true, completion: nil)
        }
        if item.tag == 2 {
            let userVC = (tabBarController?.viewControllers?.last as? UINavigationController)?.viewControllers[0] as? VIVRUserViewController
            userVC?.selectedUserID = "\(myData.myProfileID)"
        }
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
