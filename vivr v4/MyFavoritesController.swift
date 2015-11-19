//
//  MyFavoritesController.swift
//  vivr v4
//
//  Created by max blessen on 3/9/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
import UIKit
import Alamofire



class MyFavoritesController: UICollectionViewController, UICollectionViewDelegateFlowLayout, favoritesCellDelegate {
    
    @IBOutlet var favoriteCollection: UICollectionView!
        var userID:String = ""
        var myFavorites:[JSON]? = []
        var segueIdentifier:String = ""
        var productID:String = ""
        let reuseIdentifier = "cell"
    
    
        override func viewDidLoad() {
            super.viewDidLoad()
            self.navigationItem.title = "My Favorites"
            
            
        }
        override func viewWillAppear(animated: Bool) {
            loadFavorites()
            configureNavigation()
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    
    func configureNavigation(){
        navigationController?.navigationBarHidden = false
        navigationController?.navigationBar.barTintColor = UIColor(red: 31.0/255, green: 124.0/255, blue: 29.0/255, alpha: 0.9)
        navigationController?.navigationBar.translucent = false
    }

    
        override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
            //#warning Incomplete method implementation -- Return the number of sections
            return 1
        }
        
        
        override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            //#warning Incomplete method implementation -- Return the number of items in the section
            return self.myFavorites?.count ?? 0
        }
        
        override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FavoriteCollectionCell
            cell.favorite = self.myFavorites?[indexPath.row]
            cell.cellDelegate = self
            return cell
            
            
        }
    
        func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
            return CGSize(width: 110, height: 200)
        }
    

        private let sectionInsets = UIEdgeInsets(top: 20.0, left: 5.0, bottom: 20.0, right: 5.0)
    
        func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
        }
        
        func loadFavorites(){
            
            Alamofire.request(Router.readUserFavorites(userID)).responseJSON { (request, response, json, error) in
                if (json != nil) {
                    println(request)
                    println(response)
                    println(json)
                    var jsonOBJ = JSON(json!)
                    if let data = jsonOBJ["data"].arrayValue as [JSON]? {
                        self.myFavorites = data
                        println(self.myFavorites)
                        self.favoriteCollection.reloadData()
                    }
                }
            }
            // MARK: UICollectionViewDelegate
            
            /*
            // Uncomment this method to specify if the specified item should be highlighted during tracking
            override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            return true
            }
            */
            
            /*
            // Uncomment this method to specify if the specified item should be selected
            override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            return true
            }
            */
            
            /*
            // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
            override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            return false
            }
            
            override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
            return false
            }
            
            override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
            
            }
            */
            
        }
    
    func tappedProductButton(cell: FavoriteCollectionCell) {
        self.segueIdentifier = "myFavoritesToProduct"
        productID = cell.productID
        performSegueWithIdentifier(segueIdentifier, sender: cell)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var productVC: brandFlavorViewController = segue.destinationViewController as! brandFlavorViewController
        productVC.selectedProductID = self.productID
    }
}

