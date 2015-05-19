//
//  addFlavorTagsView.swift
//  vivr v4
//
//  Created by max blessen on 5/11/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

protocol flavorTagsDelegate {
    func didSubmit(view: addFlavorTagsView)
    func didCancel(view: addFlavorTagsView)
}

class addFlavorTagsView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tagTable: UITableView!
    var viewDelegate:flavorTagsDelegate? = nil
    var tagList:[JSON]? = []
    var selectedTags:NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tagTable.separatorInset = UIEdgeInsetsZero
        configureButtons()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        loadTags()
        configureTableView()
    }
    
    func reloadTableViewContent() {
            self.tagTable.reloadData()
    }
    func configureTableView() {
        tagTable.rowHeight = UITableViewAutomaticDimension
        tagTable.estimatedRowHeight = 75
    }
    func configureButtons() {
        cancelButton.layer.cornerRadius = cancelButton.frame.size.width / 2
        cancelButton.clipsToBounds = true
        cancelButton.layer.borderWidth = 2.0
        cancelButton.layer.borderColor = UIColor.whiteColor().CGColor
        submitButton.layer.cornerRadius = submitButton.frame.size.width / 2
        submitButton.clipsToBounds = true
        submitButton.layer.borderWidth = 2.0
        submitButton.layer.borderColor = UIColor.whiteColor().CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true , completion: nil)
        viewDelegate?.didCancel(self)

    }

    @IBAction func submit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true , completion: nil)
        checkSelectedTags()
        viewDelegate?.didSubmit(self)
    }
    
    func checkSelectedTags() {
        let selectedTagCells:NSArray = tagTable.indexPathsForSelectedRows()!
        for index in selectedTagCells {
            let cell = tagTable.cellForRowAtIndexPath(index as NSIndexPath) as TagCell
            let tagID = cell.tagID!
            selectedTags.addObject(tagID)
        }
        println(self.selectedTags)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tagCellAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagList?.count ?? 0
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as TagCell
    }
    
    func tagCellAtIndexPath(indexPath:NSIndexPath) -> TagCell {
        let cell = tagTable.dequeueReusableCellWithIdentifier("tag") as TagCell
        if (tagList != nil) {
            let tagIndex = tagList![indexPath.row]
            cell.tagName.text = tagIndex["name"].stringValue
            cell.tagID = tagIndex["id"].stringValue
        }
        return cell
    }
    
    func loadTags() {
        Alamofire.request(Router.loadAllTags()).responseJSON { (request, response, json, error) in
            if (json != nil) {
                let jsonOBJ = JSON(json!)
                if let data = jsonOBJ["data"].arrayValue as [JSON]? {
                    self.tagList = data
                    println(self.tagList)
                    self.reloadTableViewContent()
                }
            }
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
