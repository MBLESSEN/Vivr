//
//  reviewViewController.swift
//  vivr v4
//
//  Created by max blessen on 12/22/14.
//  Copyright (c) 2014 max blessen. All rights reserved.
//

import UIKit
import Alamofire

class reviewViewController: UIViewController {

    @IBOutlet weak var reviewContent: UITextView!
    @IBOutlet weak var tasteSlider: UISlider!
    @IBOutlet weak var vaporSlider: UISlider!
    @IBOutlet weak var hitSlider: UISlider!
    @IBOutlet weak var flavorSlider: UISlider!
    var lastTasteStep: Float!
    var stepValue: Float!
    var productID:String = ""
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stepValue = 1
        lastTasteStep = tasteSlider.value / stepValue
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func flavorChanged(sender: AnyObject) {
        var newStep:Float = roundf((flavorSlider.value) / stepValue)
        
        flavorSlider.value = newStep * stepValue
        dump(flavorSlider.value)
    }
    @IBAction func hitChanged(sender: AnyObject) {
        var newStep:Float = roundf((hitSlider.value) / stepValue)
        
        hitSlider.value = newStep * stepValue
        dump(hitSlider.value)
    }
    @IBAction func vaporChanged(sender: AnyObject) {
        var newStep:Float = roundf((vaporSlider.value) / stepValue)
        
        vaporSlider.value = newStep * stepValue
        dump(vaporSlider.value)
    }
    @IBAction func tasteChanged(sender: AnyObject) {
        

        var newStep:Float = roundf((tasteSlider.value) / stepValue)
        
        tasteSlider.value = newStep * stepValue
        dump(tasteSlider.value)
        
        
    }

    
    @IBAction func submitReview(sender: AnyObject) {
        
        let flavor = flavorSlider.value
        let taste = tasteSlider.value
        let vapor = vaporSlider.value
        let throat = hitSlider.value
        
        
        let parameters: [ String : AnyObject] = [
        "user_id": "1",
        "throat": throat,
        "vapor": vapor,
        "taste": taste,
        "flavor": flavor,
        "description": reviewContent.text,
        "product_id": "8"
        
        
        ]
        
        Alamofire.request(.POST, "http://mickeyschwab.com/vivr/public/brands/1/products/8/reviews", parameters: parameters, encoding: .JSON).response
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
