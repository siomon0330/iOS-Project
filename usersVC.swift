//
//  usersVC.swift

//
//  Created by Simon on 8/17/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit
import Parse

class usersVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    
    //declare search bar
    var searchBar = UISearchBar()
    
    //table view arrays to hold information from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    
    //collectionView UI
    var collectionView : UICollectionView!
    //collectiob view arrays to hold information
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var page : Int = 15
    
    var refresher = UIRefreshControl()


    //tableview code
    //default func
    override func viewDidLoad() {
        super.viewDidLoad()

        //implement search bar
        searchBar.delegate = self
    
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.size.width-30
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
        
        //call functions
        loadUsers()
        
        //show collection to load post
        collectionViewLauch()
        
    }

    
    //load users
    func loadUsers(){
    
        let userQuery = PFUser.query()
        userQuery?.addDescendingOrder("createdAt")
        userQuery?.limit = 20
        userQuery?.findObjectsInBackground(block: { (objects, error) in
            if error == nil{
            
                //clean up
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                //find related objects
                for object in objects!{
                
                    self.usernameArray.append(object.object(forKey: "username") as! String)
                    self.avaArray.append(object.object(forKey: "profileImage") as! PFFile)
                
                }
                //reload
                self.tableView.reloadData()
                
            
            }else{
            
                print(error!.localizedDescription)
            }
        })
    
    }
    
    //search updated
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let usernameQuery = PFUser.query()
        usernameQuery?.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        usernameQuery?.findObjectsInBackground(block: { (objects, error) in
            if error == nil{
            
                //find by full name
                if objects!.isEmpty{
                
                    let fullnameQuery = PFUser.query()
                    fullnameQuery?.whereKey("fullname", matchesRegex: "(?i)" + self.searchBar.text!)
                    fullnameQuery?.findObjectsInBackground(block: { (objects, error) in
                        if error == nil{
                            //clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            
                            for object in objects!{
                            
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                self.avaArray.append(object.object(forKey: "profileImage") as! PFFile)
                            }
                            
                            //reload
                            self.tableView.reloadData()
                        }
                    })
                }
            
                //clean up
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
            
                for object in objects!{
                
                    self.usernameArray.append(object.object(forKey: "username") as! String)
                    self.avaArray.append(object.object(forKey: "profileImage") as! PFFile)
                
                }
                
                //reload
                self.tableView.reloadData()
                
            
            }
        })
        
        return true
    }
    
    //taped on the searchBar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        //hide collection view when search
        collectionView.isHidden = true
        
        //show cancel button
        searchBar.showsCancelButton = true
    }
    
    //click cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //show collection view
        collectionView.isHidden = false
        //collectionViewLauch()
        
        
        //dismiss keyboard
        searchBar.resignFirstResponder()
        //reset text
        searchBar.text = ""
        
        //hide cancel button
        searchBar.showsCancelButton = false

        //reset showing users
        loadUsers()
    }
    
    
   //cell num
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return usernameArray.count
    }

    //cell height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.width/4
    }
    
    
    
    //cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        //define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! followersCell

        //hide follow button
        cell.followingBtn.isHidden = true
        
        //connect cell's objects with received data
        cell.usernameLbl.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil{
               cell.avaImg.image = UIImage(data: data!)
            
            }
        }

        return cell
    }
    
    
    //selected table view cell-selected user
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
        let cell = tableView.cellForRow(at: indexPath) as! followersCell
        //calling cell again to call cell data
        if cell.usernameLbl.text! == PFUser.current()?.username{
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        
        }else{
           guestName.append(cell.usernameLbl.text!)
           let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
        
    }
    
    
    //collection vew code
    func collectionViewLauch(){
    
        //layout of collection view
        let layout :UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        //item size
        layout.itemSize = CGSize(width: self.view.frame.size.width/3, height: self.view.frame.size.width/3)
        //direction of scrolling
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        //define frame
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - (self.tabBarController?.tabBar.frame.size.height)! - (self.navigationController?.navigationBar.frame.size.height)!-20)
        //declare collectionView
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self as! UICollectionViewDataSource
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.white
        self.view.addSubview(collectionView)
        
        //define cell for collectionView
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        
        //implement autorefresh
        refresher.addTarget(self, action: #selector(usersVC.loadPosts), for: UIControlEvents.valueChanged)
        collectionView.addSubview(refresher)
        
        //call function to load posts
        loadPosts()
        
    }
    
    //cell inter spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //cell line spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //cell num
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    //cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        //create picture imageView to show loaded pic
        let picImg = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        cell.addSubview(picImg)
        
        picArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil{
                
                picImg.image = UIImage(data: data!)
                
            }else{
                
                print(error!.localizedDescription)
                
            }
        }
        return cell
    }
    
    //go to certain post
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        postuuid.append(uuidArray[indexPath.row])
        let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
        
    }
    
   //load posts
    func loadPosts(){
    
    
        let query = PFQuery(className: "posts")
        query.limit = page
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground { (objects, error) in
            if error == nil{
            
                //clean up
                self.picArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.picArray.append(object.object(forKey: "pic") as! PFFile)
                    self.uuidArray.append(object.object(forKey: "uuid") as! String)
                
                }
                self.collectionView.reloadData()
                self.refresher.endRefreshing()
            
            
            }else{
            
                print(error!.localizedDescription)
            
            }
        }
    
    }
    
    //scrolled down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height/6{
        
            self.loadMore()
        }
        
    }
    
    //pagination
    func loadMore(){
    
    
        //if more posts
        if page <= picArray.count{
        
            //increase page size
            self.page += 15
            //load additional posts
            let query = PFQuery(className: "posts")
            query.limit = page
            query.addDescendingOrder("createdAt")
            query.findObjectsInBackground { (objects, error) in
                if error == nil{
                    
                    //clean up
                    self.picArray.removeAll(keepingCapacity: false)
                    self.uuidArray.removeAll(keepingCapacity: false)
                    
                    for object in objects!{
                        self.picArray.append(object.object(forKey: "pic") as! PFFile)
                        self.uuidArray.append(object.object(forKey: "uuid") as! String)
                        
                    }
                    //reload collection view to present loaded image
                    self.collectionView.reloadData()
                    
                    
                }else{
                    
                    print(error!.localizedDescription)
                    
                }
            }

        
        }
    
    }
    
    
    
    
    
    
    
    
}















