//
//  guestVC.swift

//
//  Created by Simon on 8/13/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit
import Parse

var guestName = [String]()

class guestVC: UICollectionViewController {
    
    var refresher:UIRefreshControl!
    var page:Int = 12
    
    //UI objects
    var uuidArray = [String]()
    var picArray = [PFFile]()

    //default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //allow vertical scroll
        self.collectionView?.alwaysBounceVertical = true
        
        //top title
        self.navigationItem.title = guestName.last?.uppercased()
        
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
        refresher.addTarget(self, action: #selector(guestVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        loadPosts()
        

    }
    
    
    //push back
    func back(sender: UIBarButtonItem){
    
        self.navigationController?.popViewController(animated: true)
        if !guestName.isEmpty{
            guestName.removeLast()
        }
    }
    
    //refresh function
    func refresh(){
        collectionView?.reloadData()
        refresher.endRefreshing()
        
    }
    
    
    //Posts loading function
    func loadPosts(){
    
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: guestName.last!)
        query.limit = page
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground { (objects, error) in
            if error == nil{
                
                //clean up
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                //find related objects
                for object in objects!{
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                }
                self.collectionView?.reloadData()
            
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    
    //load more while scrolling down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height{
            self.loadMore()
        }
        
    }
    
    //paging
    func loadMore(){
        
        // if there are more objects
        if page <= picArray.count{
            
            //increase page size
            page = page + 12
            
            //load more posts
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: guestName.last!)
            query.limit = page
            query.addDescendingOrder("createdAt")
            query.findObjectsInBackground(block: { (objects, error) in
                
                if error == nil{
                    
                    //clean up
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    
                    //find objects
                    for object in objects!{
                        self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        self.picArray.append(object.value(forKey: "pic") as! PFFile)
                        
                    }
                    
                    self.collectionView?.reloadData()
                    
                }else{
                    
                    print(error!.localizedDescription)
                }
            })
        }
        
    }

    
    
    //cell number
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    
    //header config
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! headerVC
        
        //set the user data
        let query = PFUser.query()
        query?.whereKey("username", equalTo: guestName.last!)
        query?.findObjectsInBackground(block: { (objects, error) in
            if error == nil{
                
                if objects?.count == 0{
                    //call altert
                    let alert = UIAlertController(title: "\(guestName.last!)", message: "not existing", preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }else{
                    
                    for object in objects!{
                        
                        header.fullnameTxt.text = object.value(forKey: "fullname") as! String
                        header.bioLbl.text = object.value(forKey: "bio") as! String
                        
                        header.bioLbl.sizeToFit()
                                                let avaFile = object.value(forKey: "profileImage") as! PFFile
                        avaFile.getDataInBackground(block: { (data, error) in
                            if error == nil{
                                header.profileImage.image = UIImage(data: data!)
                            }else{
                                print(error!.localizedDescription)
                            }
                        })
                    }
                    
                }
                
            }else{
                print(error!.localizedDescription)
            }
            
        })
            
        
        //set the follow button
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followQuery.whereKey("following", equalTo: guestName.last!)
        followQuery.countObjectsInBackground { (count, error) in
            if error == nil{
                if count == 0{
                
                    header.editProfileBtn.setTitle("FOLLOW", for: UIControlState.normal)
                    header.editProfileBtn.backgroundColor = UIColor(colorLiteralRed: 15/255.0, green: 99.0/255.0, blue: 164.0/255.0, alpha: 1)
                }else{
                
                    header.editProfileBtn.setTitle("FOLLOWING", for: UIControlState.normal)
                    header.editProfileBtn.backgroundColor = UIColor.gray
                }
            
            }else{
                print(error!.localizedDescription)
            }
        }
        
        //count posts
        let postsQuery = PFQuery(className: "posts")
        postsQuery.whereKey("username", equalTo: guestName.last!)
        postsQuery.countObjectsInBackground { (count, error) in
            if error == nil{
                header.posts.text = "\(count)"
            }else{
                print(error!.localizedDescription)
            }
        }
        
        //count followers
        let followersQuery = PFQuery(className: "follow")
        followersQuery.whereKey("following", equalTo: guestName.last!)
        followersQuery.countObjectsInBackground { (count, error) in
            if error == nil{
            
                header.followers.text = "\(count)"
            }else{
            
                print(error!.localizedDescription)
            }
        }
        
        //count followings
        let followingQuery = PFQuery(className: "follow")
        followingQuery.whereKey("follower", equalTo: guestName.last!)
        followingQuery.countObjectsInBackground { (count, error) in
            if error == nil{
            
                header.following.text = "\(count)"
            }else{
            
                print(error!.localizedDescription)
            }
        }
        
            
            
        //Posts tap
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        //Follower tap
        let followerTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.followerTap))
        followerTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followerTap)
        
        //Following tap
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.followingTap))
        followingTap.numberOfTapsRequired = 1
        header.following.isUserInteractionEnabled = true
        header.following.addGestureRecognizer(followingTap)
 
 
        return header
        
        
    }
    
    //tap posts
    
    func postsTap(){
            
            if !picArray.isEmpty{
            let index = NSIndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index as IndexPath, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
 
      //tap followers
    func followerTap(){
        
        user = guestName.last!
        showing = "followers"
        
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        self.navigationController?.pushViewController(followers, animated: true)
    
    }
    
    //tap followings
    func followingTap(){
    
        user = guestName.last!
        showing = "followings"
        
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        self.navigationController?.pushViewController(followings, animated: true)
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















