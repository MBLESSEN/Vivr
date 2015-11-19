//
//  myFavoritesCell.swift
//  vivr v4
//
//  Created by max blessen on 3/30/15.
//  Copyright (c) 2015 max blessen. All rights reserved.
//

import UIKit
import Alamofire

class myFavoritesCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var myFavorites:[JSON]? = []
    var collectionReuseIdentifier = "cell"
    var myUserID:String = "2"
    var cellDelegate: VivrCellDelegate? = nil
    
    @IBOutlet weak var favoritesCollection: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadFavorites()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return self.myFavorites?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = favoritesCollection.dequeueReusableCellWithReuseIdentifier(collectionReuseIdentifier, forIndexPath: indexPath) as! FavoriteCollectionCell
        cell.favorite = self.myFavorites?[indexPath.row]
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
        
        Alamofire.request(Router.readUserFavorites(myUserID)).responseJSON { (request, response, json, error) in
            if (json != nil) {
                println(request)
                println(response)
                println(json)
                var jsonOBJ = JSON(json!)
                if let data = jsonOBJ.arrayValue as [JSON]? {
                    self.myFavorites = data
                    println(self.myFavorites)
                    self.favoritesCollection.reloadData()
                }
            }
        }
}
}

    
    



