//
//  findFriendsViewViewController.swift
//  vivr v4
//
//  Created by max blessen on 5/11/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit

class findFriendsViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var friendsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTable.contentInset = UIEdgeInsetsZero
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = friendsTable.dequeueReusableCellWithIdentifier("userCell") as UITableViewCell!
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
