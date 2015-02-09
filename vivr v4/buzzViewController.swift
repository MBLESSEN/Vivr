//
//  buzzViewController.swift
//  vivr v4
//
//  Created by max blessen on 12/21/14.
//  Copyright (c) 2014 max blessen. All rights reserved.
//

import UIKit
import Alamofire

class buzzViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mainTable: UITableView!
    @IBOutlet weak var controller: UISegmentedControl!
    
    
    var cellIdentifier: String = "vivrCell"
    var whatsHot:[JSON]? = []

    override func viewDidLoad() {
        super.viewDidLoad()
        var logo = UIImage(named: "vivrTitleLogo")
        var imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView


        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeData(sender: AnyObject) {
        
        if controller.selectedSegmentIndex == 0 {
            cellIdentifier = "buzzCell"
            mainTable.rowHeight = 200
            mainTable.reloadData()
        }
        if controller.selectedSegmentIndex == 1 {
            cellIdentifier = "vivrCell"
            mainTable.rowHeight = 400
            mainTable.reloadData()
        }
        if controller.selectedSegmentIndex == 2 {
            cellIdentifier = "newCell"
            mainTable.reloadData()
        }
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (cellIdentifier == "buzzCell"){
        var cell = mainTable.dequeueReusableCellWithIdentifier(cellIdentifier) as buzzCell
        return cell
        }
        else if (cellIdentifier == "vivrCell") {
            var cell = mainTable.dequeueReusableCellWithIdentifier(cellIdentifier) as vivrCell
            return cell
        }
        else {
            var cell = mainTable.dequeueReusableCellWithIdentifier(cellIdentifier) as newCell
            return cell
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
