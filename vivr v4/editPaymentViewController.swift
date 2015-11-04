//
//  editPaymentViewController.swift
//  vivr v4
//
//  Created by max blessen on 5/11/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class editPaymentViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var paymentTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit payment"
    }

    override func viewWillAppear(animated: Bool) {
        configureNavBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavBar() {
        let navbarFont = UIFont(name: "PTSans-Bold", size: 17) ?? UIFont.systemFontOfSize(17)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain , target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor(red: 43.0/255, green: 169.0/255, blue: 41.0/255, alpha: 1.0)
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: navbarFont, NSForegroundColorAttributeName:UIColor.whiteColor()]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = paymentTable.dequeueReusableCellWithIdentifier("card") as UITableViewCell!
        
        return cell
        
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
