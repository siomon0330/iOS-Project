//
//  hashtagsVC.swift

//
//  Created by Simon on 8/16/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit
import Parse

var hashtag = [String]()

class hashtagsVC: UICollectionViewController {
    
    //UI objetcs
    var refresher : UIRefreshControl!
    var page : Int = 24
    
    //arrays to hold data from server
    var picArray = [PFFile]()
    var uuidArray = [String]()
    
    var filterArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        //be able to pull down even if few posts
        self.collectionView?.alwaysBounceVertical = true
        
        //title at the top
        self.navigationItem.title = "#" + "\(hashtag.last!.uppercased())"
        
        //new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(guestVC.back(sender:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(guestVC.back(sender:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        //pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(hashtagsVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        //call load hashtag
        loadHashtags()
    }
    
    //push back
    func back(sender: UIBarButtonItem){
        
        self.navigationController?.popViewController(animated: true)
        //clean hashtag or deduct the last guest username from hashtag array
        if !hashtag.isEmpty{
            hashtag.removeLast()
        }
    }
    //refreshing
    func refresh(){
    
        loadHashtags()
    }
    
    //load hashtag func
    func loadHashtags(){
        print("aaa")
        
        //1.find posts related to hashtags
        let hashtagQuery = PFQuery(className: "hashtags")
        hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
        
            hashtagQuery.findObjectsInBackground { (objects, error) in
            if error == nil{
            
                //clean up
                self.filterArray.removeAll(keepingCapacity: false)
                //store related posts in filter array
                for object in objects!{
                    self.filterArray.append(object.value(forKey: "to") as! String)
                }
            
                print(self.filterArray)
                //2. find posts that have uuid appended to filter array
                let query = PFQuery(className: "posts")
                query.whereKey("uuid", containedIn: self.filterArray)
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                
                
                query.findObjectsInBackground(block: { (objects, error) in
                    if error == nil{
                    
                        //clean up
                        self.picArray.removeAll(keepingCapacity: false)
                        self.uuidArray.removeAll(keepingCapacity: false)
                        
                        //find related objects
                        for object in objects!{
                            self.picArray.append(object.value(forKey: "pic") as! PFFile)
                            self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        
                        }
                        
                        //reload
                        self.collectionView?.reloadData()
                        self.refresher.endRefreshing()
                    
                    }else{
                        print(error!.localizedDescription)
                    }
                })
                
                
            }else{
            
                print(error!.localizedDescription)
            
            }
 
 
        }
 
 
    }
    
    
    
    
    
    //scroll down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height/3{
        
            loadMore()
        }
    }
    
//pagination
    func loadMore(){
    
        //if posts on the server are more than showing
        if page <= uuidArray.count{
        
            //increase page size
            page += 15
            
            //load the posts
            //1.find posts related to hashtags
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
            hashtagQuery.findObjectsInBackground { (objects, error) in
                if error == nil{
                    
                    //clean up
                    self.filterArray.removeAll(keepingCapacity: false)
                    //store related posts in filter array
                    for object in objects!{
                        self.filterArray.append(object.value(forKey: "to") as! String)
                    }
                    
                    //2. find posts that have uuid appended to filter array
                    let query = PFQuery(className: "posts")
                    query.whereKey("uuid", containedIn: self.filterArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) in
                        if error == nil{
                            
                            //clean up
                            self.picArray.removeAll(keepingCapacity: false)
                            self.uuidArray.removeAll(keepingCapacity: false)
                            
                            //find related objects
                            for object in objects!{
                                
                                self.picArray.append(object.value(forKey: "pic") as! PFFile)
                                self.uuidArray.append(object.value(forKey: "uuid") as! String)
                                
                            }
                            
                            //reload
                            self.collectionView?.reloadData()
                            self.refresher.endRefreshing()
                            
                        }else{
                            print(error!.localizedDescription)
                        }
                    })
                }else{
                    
                    print(error!.localizedDescription)
                    
                }
            }
        
        }
    
    }
    
    
    
    
    //cell num
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return picArray.count
    }
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }
    
    //cell config
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! pictureCell
        picArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil{
                cell.picImg.image = UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
            
        }
        
        return cell
    }
 
    //go post
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //send post uuid to "postuuid" variable
        postuuid.append(uuidArray[indexPath.row])
        
        //navigate to post view controller
        let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    
    
    

   
}
