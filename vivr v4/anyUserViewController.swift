import UIKit
import Alamofire

class anyUserViewController: UIViewController, reviewCellDelegate {
    var myFavorites:[JSON]? = []
    var myReviews:[JSON]? = []
    var userID: String = ""
    var segueIdentifier: String = ""
    var collectionReuseIdentifier = "cell"
    var userName:String?
    var userImage:String = ""
    var reviewsCount:String?
    var favoritesCount:String?
    var commentsCount:String?
    var selectedProductID:String?
    var reviewID:String?

    @IBOutlet weak var profileTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileTable.contentInset = UIEdgeInsetsMake(-44,0,0,0);
        //automaticallyAdjustsScrollViewInsets = false
        
    }
    
    override func viewWillAppear(animated: Bool) {
        loadProfile()
        loadMyReviews()
        configureNavigation()
        profileTable.estimatedRowHeight = 400
        profileTable.rowHeight = UITableViewAutomaticDimension
        profileTable.reloadData()
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    func configureNavigation() {
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        //automaticallyAdjustsScrollViewInsets = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func favoritesTapped(sender: AnyObject) {
        self.segueIdentifier = "anyUserToFavorites"
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    func tappedProductbutton(cell: myReviewsCell) {
        self.segueIdentifier = "anyUserToFlavor"
        self.selectedProductID = cell.productID
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    func tappedCommentButton(cell: myReviewsCell) {
        self.segueIdentifier = "anyUserToComments"
        self.selectedProductID = cell.productID
        self.reviewID = cell.reviewID
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier {
        case "anyUserToFavorites":
            var favoritesVC: anyFavoritesController = segue.destinationViewController as anyFavoritesController
            favoritesVC.userID = self.userID
            favoritesVC.userName = self.userName!
        case "anyUserToFlavor":
            var productVC: brandFlavorViewController = segue.destinationViewController as brandFlavorViewController
            productVC.selectedProductID = selectedProductID
        case "anyUserToComments":
            var commentsVC: commentsViewController = segue.destinationViewController as commentsViewController
            commentsVC.productID = selectedProductID!
            commentsVC.reviewID = reviewID!
        default:
            println("no segue")
        }
    }
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return self.myReviews?.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 0:
            var profile = self.profileTable.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as profileCell
            profile.favoritesCount.text =  "0"
            profile.reviewsCount.text = self.reviewsCount ?? "0"
            profile.profile = self.userID
            return profile
        default:
            var cell = profileTable.dequeueReusableCellWithIdentifier("myReviews", forIndexPath: indexPath) as myReviewsCell
            cell.review = self.myReviews?[indexPath.row]
            cell.cellDelegate = self
            return cell
        }
    }


    func loadProfile(){
        
        Alamofire.request(Router.readUser(userID)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let name = jsonOBJ["username"].stringValue as String? {
                    self.userName = name
                }
            }
        }
    }



    func loadMyReviews(){
        
        Alamofire.request(Router.readUserReviews(self.userID)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let reviewCount = jsonOBJ["total"].stringValue as String? {
                    self.reviewsCount = reviewCount
                }
                if let data = jsonOBJ["data"].arrayValue as [JSON]? {
                    self.myReviews = data
                    self.profileTable.reloadData()
                   
                }
                
            }
    }
    Alamofire.request(Router.readUserFavorites(self.userID)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let favoriteCount = jsonOBJ["total"].stringValue as String? {
                    self.favoritesCount = favoriteCount
                }
            }
        }
    Alamofire.request(Router.readUserComments(self.userID)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                var jsonOBJ = JSON(json!)
                if let commentCount = jsonOBJ["total"].stringValue as String? {
                    self.commentsCount = commentCount
                }
            }
        }
    }
}


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */


