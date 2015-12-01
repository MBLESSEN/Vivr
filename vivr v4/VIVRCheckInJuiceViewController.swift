//
//  checkInJuiceView.swift
//  
//
//  Created by max blessen on 10/5/15.
//
//

import UIKit
import AVFoundation
import QuartzCore
import Alamofire


class VIVRCheckInJuiceViewController: UIViewController, ProductViewDelegate, BrowseViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var firstPanel: UIView!
    @IBOutlet weak var secondPanel: UIView!
    @IBOutlet weak var actionPanel: UIView!
    @IBOutlet weak var juiceResultsView: UIView!
    @IBOutlet weak var juiceNameTextField: UITextField!
    @IBOutlet weak var reviewPanel: UIView!
    
    @IBOutlet weak var juiceImage: UIImageView!
    @IBOutlet weak var findJuiceView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var actionPanelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstPanelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var juiceNameLabel: UILabel!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var instructionDetailLabel: UILabel!

    @IBOutlet weak var submitButton: UIButton!
    
    var reviewActive = false
    var keyboardActive = false
    var topPanelMultiplier: CGFloat?
    var firstPanelHeight: CGFloat?
    var juiceSearch: VIVRBrowseViewController?
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var error: NSError?
    var currentView: Int = 0
    var previousView: Int?
    
    
    var juiceName: String?
    var brandName: String?
    var brandID: Int?
    var juiceID: Int?
    
    //data variables
    var selectedProduct: Product?
    var selectedProductID: Int?
    var selectedBrandID: Int?
    var screenAdjustedHeight:CGFloat?
    var reviewView: VIVRIndependantReviewView?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var addingProduct = false
    var addingBrand = false
    
    //gesture recognizer
    var panGesture = UIPanGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkScreenSize()
        juiceNameTextField.delegate = self
        startObservingKeyboardEvents()
        instantiateSearchView()
        firstPanelHeight = firstPanel.frame.height
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldTextChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cameraDidFinishLoading:", name: AVCaptureSessionDidStartRunningNotification, object: nil)
        instantiateReviewView()
        panGesture.addTarget(self, action: "draggedView:")
        panGesture.enabled = false
        self.view.addGestureRecognizer(panGesture)
    }
    
    func draggedView(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(self.view)
        let segmentHeight = (self.view.frame.height - 50.0)/8
        self.firstPanelHeightConstraint.constant = 0.0 - (self.topPanelMultiplier! * segmentHeight) + (0.8 * translation.y)
        print(firstPanelHeightConstraint.constant)
        if panGesture.state == UIGestureRecognizerState.Ended {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.firstPanelHeightConstraint.constant = 0.0 - (self.topPanelMultiplier! * segmentHeight)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.Back }
        if let captureDevice = devices.first as! AVCaptureDevice!  {
            do {
                try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            } catch {
                print("error")
            }
            captureSession.sessionPreset = AVCaptureSessionPresetPhoto
            captureSession.startRunning()
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer!.frame = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, firstPanel.bounds.size.height)
            previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            let cameraPreview = UIView(frame: CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, firstPanel.bounds.size.height))
            cameraPreview.layer.addSublayer(previewLayer!)
            cameraPreview.tag = 101
            firstPanel.addSubview(cameraPreview)
            
        }
    }

    
    func startCameraSession() {
        captureSession.startRunning()
        self.firstPanel.viewWithTag(101)?.hidden = false
        juiceImage.image = nil
    }
    
    
    func checkScreenSize() {
        if (UIScreen.mainScreen().bounds.width < 370) {
            topPanelMultiplier = 4.0
        }else {
            topPanelMultiplier = 3.0
        }
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    private func startObservingKeyboardEvents() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:Selector("keyboardWillShow:"),
            name:UIKeyboardWillShowNotification,
            object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:Selector("keyboardWillHide:"),
            name:UIKeyboardWillHideNotification,
            object:nil)
    }
    
    private func stopObservingKeyboardEvents() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.actionPanelBottomConstraint.constant = keyboardSize.height
                    self.view.layoutIfNeeded()
                    self.keyboardActive = true
                })
            }
        }
    }
    func keyboardWillHide(notification: NSNotification) {
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.actionPanelBottomConstraint.constant = 0
                    self.view.layoutIfNeeded()
                    self.keyboardActive = false
                })
    }
    
    func instantiateReviewView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let segmentHeight = (self.view.frame.height - 50.0)/4.0
        reviewView = storyboard.instantiateViewControllerWithIdentifier("indieReviewView") as? VIVRIndependantReviewView
        reviewView!.view.frame = CGRectMake(0, self.view.frame.height, self.view.frame.width, self.view.frame.height - segmentHeight)
        self.addChildViewController(self.reviewView!)
        reviewView!.didMoveToParentViewController(self)
        self.view.addSubview(reviewView!.view)
    }
    
    
    func instantiateSearchView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        juiceSearch = storyboard.instantiateViewControllerWithIdentifier("browseView") as? VIVRBrowseViewController
        juiceSearch!.productViewDelegate = self
        juiceSearch!.brandViewDelegate = self
        juiceSearch!.segueActive = false
        juiceSearch!.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 0)
        self.addChildViewController(self.juiceSearch!)
        self.juiceSearch!.didMoveToParentViewController(self)
        juiceSearch!.brandsTableView.rowHeight = 44.0
        juiceSearch!.brandTextOnly = true
        juiceSearch!.controller.selectedSegmentIndex = 2
        juiceSearch!.controller.sendActionsForControlEvents(.ValueChanged)
        juiceSearch!.tableViewTopConstraint.constant = -46.0
        juiceSearch!.controllerView.hidden = true
        juiceSearch!.controller.userInteractionEnabled = false
        juiceResultsView.addSubview(juiceSearch!.view)
        juiceSearch!.products = []
        self.view.layoutIfNeeded()
    }
    
    func productSelected(product: Product) {
        juiceNameTextField.text = product.name!
        selectedProduct = product
        self.selectedProductID = selectedProduct!.productID
        self.juiceNameLabel.text = product.name!
        previousView = currentView
        changeView(2)
    }
    
    func brandSelected(brandID: Int, brandName: String) {
        brandNameLabel.text = brandName
        self.selectedBrandID = brandID
        previousView = currentView
        changeView(2)
    }
    
    
    func saveToCamera() {
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                var takenImage = UIImage(data: imageData)
                let outputRect = self.previewLayer!.metadataOutputRectOfInterestForRect(self.previewLayer!.bounds)
                let takenCGImage = takenImage!.CGImage
                let width = CGFloat(CGImageGetWidth(takenCGImage!))
                let height = CGFloat(CGImageGetHeight(takenCGImage))
                let cropRect = CGRectMake(outputRect.origin.x * width, outputRect.origin.y * height, outputRect.size.width * width, outputRect.size.height * height)
                
                let cropCGImage = CGImageCreateWithImageInRect(takenCGImage, cropRect)
                takenImage = UIImage(CGImage: cropCGImage!, scale: 1, orientation: takenImage!.imageOrientation)
                self.firstPanel.viewWithTag(101)!.hidden = true
                self.captureSession.stopRunning()
                self.juiceSet(takenImage!)
            }
        }
    }
    
    func juiceSet(image: UIImage) {
        juiceImage.image = image
        
    }
    @IBAction func cancelCheckIN(sender: AnyObject) {
        if currentView == 2 {
            changeView(previousView!)
        }else {
        self.captureSession.stopRunning()
        self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    //SUBMIT BUTTON IS PRESSED
    //CHECK IF ADDING BRAND 
    //CHECK IF ADDING PRODUCT
    //CHECK IN JUICE
    
    @IBAction func submitPressed(sender: AnyObject) {
        if addingBrand == true {
        }else if addingProduct == true {
            self.addProduct(self.juiceName!, brandID: brandID!, completion: { (product, err) in
                
            })
        }else {
            checkInJuice(selectedProductID!)
        }
    }
    
    // SUBMIT REVIEW AND CHECK IN JUICE
    // CHECKS FOR ERRORS THEN POSTS TO API
    
    func checkInJuice(productID: Int) {
        
        let reviewText = reviewView!.reviewText!.text
        switch reviewText {
        case nil:
            let emptyAlert = UIAlertController(title: "oops!", message: "Please enter a review", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        case "Write a comment...":
            let emptyAlert = UIAlertController(title: "oops!", message: "Please enter a review", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        default:
            if let vapor = reviewView!.reviewScoreView!.vaporController.selectedSegmentIndex as Int?{
                if let throat = reviewView!.reviewScoreView!.throatController.selectedSegmentIndex as Int? {
                    let score = "\(reviewView!.reviewScoreView!.reviewScore)"
                    
                    let parameters: [String: AnyObject] = [
                        "throat": throat,
                        "vapor": vapor,
                        "score": score,
                        "description": reviewText
                    ]
                    
                    Alamofire.request(Router.AddReview("\(productID)", parameters)).responseJSON { (response) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    
                }else {
                    let emptyAlert = UIAlertController(title: "oops!", message: "How was the throat hit?", preferredStyle: UIAlertControllerStyle.Alert)
                    emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(emptyAlert, animated: true, completion: nil)
                }
            }else {
                let emptyAlert = UIAlertController(title: "oops!", message: "How was the vapor production?", preferredStyle: UIAlertControllerStyle.Alert)
                emptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(emptyAlert, animated: true, completion: nil)
            }
            
            
        }
        
    }
    
    // ADD PRODUCT TO DATABASE
    
    func addProduct(name: String, brandID: Int, completion: (product: Product, error: NSError?) -> Void) {
        let parameters: [String: AnyObject] = [
            "name": name,
            "brandID": brandID
        ]
        
        Product.addProductToBrand(brandID, parameters: parameters, completionHandler: { (productWrapper, error) in
            if error != nil {
                
            }else {
                if productWrapper != nil {
                    let product: Product = (productWrapper?.Products?.first)!
                    self.selectedProductID = product.productID
                    completion(product: product, error: nil)
                }
            }
            
        })
    }
    
    func hideKeyboard() {
        if(keyboardActive == true) {
            juiceNameTextField.becomeFirstResponder()
            juiceNameTextField.endEditing(true)
            keyboardActive = false
        }
    }
    
    func changeView(view: Int) {
        switch view {
        case 0:
            panGesture.enabled = false
            currentView = 0
            cameraView.userInteractionEnabled = true
            cameraView.hidden = false
            startCameraSession()
            cancelButton.hidden = true
            cancelButton.userInteractionEnabled = false
            submitButton.userInteractionEnabled = false
            submitButton.hidden = true
            self.juiceNameLabel.text = ""
            self.brandNameLabel.text = ""
            self.juiceNameTextField.text = ""
            hideKeyboard()
            UIView.animateWithDuration(
                // duration
                0.5,
                // delay
                delay: 0.0,
                options: [],
                animations: {
                    if self.reviewActive == true {
                        self.reviewView!.view.frame = CGRectMake(0, self.view.frame.height, self.view.frame.width, self.view.frame.height)
                    }
                    self.firstPanelHeightConstraint.constant = 0
                    self.actionPanelBottomConstraint.constant = -50.0
                    self.titleLabel.alpha = 0.0
                    self.view.layoutIfNeeded()
                }, completion: {finished in
                }
            )

        case 1:
            panGesture.enabled = true
            currentView = 1
            self.instructionLabel.text = "What is the name of this E-Liquid?"
            self.instructionDetailLabel.text = "WHEN YOU FINISH PRESS NEXT"
            self.juiceNameLabel.text = ""
            juiceSearch!.controller.selectedSegmentIndex = 2
            juiceSearch!.controller.sendActionsForControlEvents(.ValueChanged)
            cameraView.userInteractionEnabled = false
            cameraView.hidden = true
            cancelButton.hidden = false
            cancelButton.userInteractionEnabled = true
            submitButton.userInteractionEnabled = false
            submitButton.hidden = true
            let segmentHeight = (self.view.frame.height - 50.0)/8
            UIView.animateWithDuration(
                // duration
                0.5,
                // delay
                delay: 0.0,
                options: [],
                animations: {
                    self.firstPanelHeightConstraint.constant = 0.0 - (self.topPanelMultiplier! * segmentHeight)
                    if self.keyboardActive == false {
                        self.actionPanelBottomConstraint.constant = 0
                    }
                    self.titleLabel.text = "Add juice"
                    self.titleLabel.alpha = 1.0
                    if self.reviewActive == true {
                        self.reviewView!.view.frame = CGRectMake(0, self.view.frame.height, self.view.frame.width, self.view.frame.height)
                    }
                    self.view.layoutIfNeeded()
                }, completion: {finished in
                    self.juiceNameTextField.becomeFirstResponder()
                    self.keyboardActive = true
                    self.juiceSearch!.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, self.secondPanel.frame.height - 66.0)
                    self.juiceSearch!.activityIndicator.center = self.juiceSearch!.view.center
                    self.juiceSearch!.brandsTableView.rowHeight = 28.0
                }
            )
        case 2:
            currentView = 2
            self.panGesture.enabled = false
            self.instructionLabel.text = "What did it taste like?"
            cancelButton.hidden = false
            cancelButton.userInteractionEnabled = true
            submitButton.userInteractionEnabled = true
            submitButton.hidden = false
            let reviewHeight = self.view.frame.height - self.firstPanel.frame.height - 56
            UIView.animateWithDuration(
                // duration
                0.3,
                // delay
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.1,
                options: [],
                animations: {
                    self.reviewView!.view.frame = CGRectMake(0, self.firstPanel.frame.height + 56.0, self.view.frame.width, reviewHeight)
                    self.view.layoutIfNeeded()
                }, completion: {finished in
                    self.reviewActive = true
                    self.reviewView!.reviewText.becomeFirstResponder()
                    
                }
            )
        case 3:
            currentView = 3
            self.juiceNameTextField.becomeFirstResponder()
            self.instructionLabel.text = "What is the brand name"
            self.instructionDetailLabel.text = "WHEN YOU FINISH PRESS NEXT"
            self.brandNameLabel.text = ""
            self.juiceNameTextField.text = ""
            juiceSearch!.controller.selectedSegmentIndex = 0
            juiceSearch!.controller.sendActionsForControlEvents(.ValueChanged)
            juiceSearch!.brandsTableView.rowHeight = 44.0
            cancelButton.hidden = false
            cancelButton.userInteractionEnabled = true
            submitButton.userInteractionEnabled = false
            submitButton.hidden = true
            UIView.animateWithDuration(
                // duration
                0.5,
                // delay
                delay: 0.0,
                options: [],
                animations: {
                    if self.reviewActive == true {
                        self.reviewView!.view.frame = CGRectMake(0, self.view.frame.height, self.view.frame.width, self.view.frame.height)
                        self.reviewActive = false
                    }
                    self.view.layoutIfNeeded()
                }, completion: {finished in
                    
                }
            )
        default:
            print("nothing", terminator: "")
        }
    }
    @IBAction func nextPressed(sender: AnyObject) {
        if currentView == 1 {
            if juiceNameTextField.text == "" {
                
            }else {
                self.juiceNameLabel.text = juiceNameTextField.text
                self.juiceName = juiceNameTextField.text!
                addingProduct = true
                previousView = 1
                changeView(3)
            }
        }else if currentView == 3 {
            if juiceNameTextField.text == "" {
                
            }else {
                self.brandNameLabel.text = juiceNameTextField.text
                addingBrand = true
                previousView = 3
                changeView(2)
            }
        }
    }
    
    @IBAction func backPressed(sender: AnyObject) {
        switch currentView {
        case 1:
            changeView(0)
        case 3:
            changeView(1)
        default:
            print("error", terminator: "")
            
        }
        
    }
    @IBAction func cameraPressed(sender: AnyObject) {
        print("camera pressed", terminator: "")
        saveToCamera()
        changeView(1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldTextChanged(sender: AnyObject) {
        let searchText = juiceNameTextField.text
        switch currentView {
        case 1:
            if searchText!.characters.count >= 1 {
                if let searchString = juiceNameTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "_") as String! {
                    if searchString.characters.count >= 1 {
                        juiceSearch!.findJuice(searchString)
                    }
                }
            }
            if searchText!.characters.count == 0 {
                juiceSearch!.products = nil
            }
        case 3:
            if searchText!.characters.count >= 1 {
                if let searchString = juiceNameTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "_") as String! {
                    if searchString.characters.count >= 1 {
                        juiceSearch!.findBrand(searchString)
                    }
                }
            }
            if searchText!.characters.count == 0 {
                juiceSearch!.brand = nil
            }
        
        default:
            print("no view")
        }
    }
    
    func cameraDidFinishLoading(sender: AnyObject) {
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if status == .Authorized {
            self.cameraButton.userInteractionEnabled = true
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
