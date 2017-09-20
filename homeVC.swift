//
//  homeVC.swift

//
//  Created by Simon on 8/12/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit
import Parse

//private let reuseIdentifier = "Cell"

class homeVC: UICollectionViewController{

    var refresher:UIRefreshControl!
    var page:Int = 12
    
    var uuidArray = [String]()
    var picArray = [PFFile]()

    
    //log out func
    @IBAction func logout(_ sender: Any) {
        PFUser.logOutInBackground { (error) in
            if error == nil{
                
                UserDefaults.standard.removeObject(forKey: "username")
                UserDefaults.standard.synchronize()
                
                 let signINVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
                 let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                 appDelegate.window?.rootViewController = signINVC
            
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.collectionView?.alwaysBounceVertical = true
        
        self.navigationItem.title = PFUser.current()?.username
    
        //add refresher
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(homeVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        //receive notification from editVC
        NotificationCenter.default.addObserver(self, selector: #selector(homeVC.reload(notification:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        //receive notification from upload VC
        NotificationCenter.default.addObserver(self, selector: #selector(homeVC.uploaded(notification:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
        
        
        //load posts
        loadPosts()
        
    }
    
    
    //reload func with posts after receive notification
    func uploaded(notification:NSNotification){
       loadPosts()
    }
    
    //refresh func
    func refresh(){
    
        collectionView?.reloadData()
        refresher.endRefreshing()
    
    }
    
    //reloading func
    func reload(notification:Notification){
    
        collectionView?.reloadData()
    }
    
    //load posts func
    func loadPosts(){
    
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: PFUser.current()!.username!)
        query.limit = page
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground { (objects, error) in
            
            if error == nil{
                
                //clean up
                self.uuidArray.removeAll()
                self.picArray.removeAll()
            
                for object in objects!{
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                }
            }else{
                print(error!.localizedDescription)
            }
            self.collectionView?.reloadData()
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
            query.whereKey("username", equalTo: PFUser.current()?.username!)
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
    
    
    //header config
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // define header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! headerVC
        
        
        //get user data
        header.fullnameTxt.text = PFUser.current()?.object(forKey: "fullname") as? String
        header.bioLbl.text = PFUser.current()?.object(forKey: "bio") as? String
        
        
        let imageQuery = PFUser.current()?.object(forKey: "profileImage") as! PFFile
        imageQuery.getDataInBackground { (data, error) in
            header.profileImage.image = UIImage(data: data!)
        }
 
        //count posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: PFUser.current()!.username!)
        posts.countObjectsInBackground { (count, error) in
            if error == nil{
                header.posts.text = "\(count)"
            }
        }
        
        //count followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: PFUser.current()!.username!)
        followers.countObjectsInBackground { (count, error) in
            if error == nil{
                header.followers.text = "\(count)"
            }
        }
        
        //count following
        let following = PFQuery(className: "follow")
        following.whereKey("follower", equalTo: PFUser.current()!.username!)
        following.countObjectsInBackground { (count, error) in
            if error == nil{
            header.following.text = "\(count)"
            }
        }
        
        
        //implement gesture
        //taps
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        //followers
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        //followings
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.following.isUserInteractionEnabled = true
        header.following.addGestureRecognizer(followingsTap)

        return header

    }
    
    //tap posts label
    func postsTap(){
        if !picArray.isEmpty{
            let index = NSIndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index as IndexPath, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
 
    func followersTap(){
    
        user = PFUser.current()!.username!
        showing = "followers"
        
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    func followingsTap(){
        user = PFUser.current()!.username!
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
    
    
/*
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
/*
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
*/

   
/*
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
*/
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
