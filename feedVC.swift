//
//  feedVC.swift

//
//  Created by Simon on 8/17/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit
import Parse

class feedVC: UITableViewController {

    
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var refresher = UIRefreshControl()
    
    //arrays to hold information from server
    var avaArray = [PFFile]()
    var usernameArray = [String]()
    var dateArray = [NSDate?]()
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var titleArray = [String]()
    
    var followArray = [String]()
    
    //page size
    var page : Int = 10
    
    
    //default func
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hhhhhmnvcvxj")
        //title at the top
        self.navigationItem.title = "FEED"
        
        //automatic row height - dynamic cell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        //pull to refresh
        refresher.addTarget(self, action: #selector(feedVC.loadPosts), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        //indicator's center
        indicator.center.x = tableView.center.x
        
        
        //receive notification from upload VC
        NotificationCenter.default.addObserver(self, selector: #selector(feedVC.uploaded(notification:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
        
        // receive notification from postsCell if picture is liked, to update tableView
        NotificationCenter.default.addObserver(self, selector: #selector(feedVC.refresh), name: NSNotification.Name(rawValue: "liked"), object: nil)
        
        
        //load posts
        loadPosts()
    }
    
    //reload func with posts after receive notification
    func uploaded(notification:NSNotification){
        loadPosts()
    }
    
    // refreshign function after like to update degit
    func refresh() {
        tableView.reloadData()
    }
    
   //load posts
    func loadPosts(){
    
        //1.find posts related to people who we are following
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()?.username!)
        followQuery.findObjectsInBackground { (objects, error) in
            if error == nil{
            
                //clean up
                self.followArray.removeAll(keepingCapacity: false)
                //related people
                for object in objects!{
                    self.followArray.append(object.object(forKey: "following") as! String)
                }
                
                self.followArray.append((PFUser.current()?.username!)!)
                
                //2.find posts made bu people append to follow array
                let query = PFQuery(className: "posts")
                query.whereKey("username", containedIn: self.followArray)
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground(block: { (objects, error) in
                    if error == nil{
                    
                        //clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        self.picArray.removeAll(keepingCapacity: false)
                        self.titleArray.removeAll(keepingCapacity: false)
                        self.uuidArray.removeAll(keepingCapacity: false)
                        
                        //find related date
                        for object in objects!{
                            self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                            self.usernameArray.append(object.value(forKey: "username") as! String)
                            self.dateArray.append(object.createdAt as? NSDate)
                            self.picArray.append(object.value(forKey: "pic") as! PFFile)
                            self.uuidArray.append(object.value(forKey: "uuid") as! String)
                            self.titleArray.append(object.value(forKey: "title") as! String)
                            
                        }
                        //reload tableview and end refresher
                        self.tableView.reloadData()
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
    
    //srcoll down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height*2{
            loadMore()
        }
    }
    
    //pagination
    func loadMore(){
    
        //if more posts
        if page <= uuidArray.count{
            //start animating indicator
            indicator.startAnimating()
            
            //increase page size to load +10 posts
            page += 10
            //1.find posts related to people who we are following
            let followQuery = PFQuery(className: "follow")
            followQuery.whereKey("follower", equalTo: PFUser.current()?.username!)
            followQuery.findObjectsInBackground { (objects, error) in
                if error == nil{
                    
                    //clean up
                    self.followArray.removeAll(keepingCapacity: false)
                    //related people
                    for object in objects!{
                        self.followArray.append(object.object(forKey: "following") as! String)
                    }
                    
                    self.followArray.append((PFUser.current()?.username!)!)
                    
                    //2.find posts made bu people append to follow array
                    let query = PFQuery(className: "posts")
                    query.whereKey("username", containedIn: self.followArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) in
                        if error == nil{
                            
                            //clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            self.dateArray.removeAll(keepingCapacity: false)
                            self.picArray.removeAll(keepingCapacity: false)
                            self.titleArray.removeAll(keepingCapacity: false)
                            self.uuidArray.removeAll(keepingCapacity: false)
                            
                            //find related date
                            for object in objects!{
                                self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                                self.usernameArray.append(object.value(forKey: "username") as! String)
                                self.dateArray.append(object.createdAt as? NSDate)
                                self.picArray.append(object.value(forKey: "pic") as! PFFile)
                                self.uuidArray.append(object.value(forKey: "uuid") as! String)
                                self.titleArray.append(object.value(forKey: "title") as! String)
                                
                                
                                
                                
                                print("hhhhh")
                                
                            }
                            //reload tableview and stop animating indicator
                            self.tableView.reloadData()
                            self.indicator.stopAnimating()
                            
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

    

    //number of cell
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return uuidArray.count
    }

    
    
    
    //cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! postCell
        
        cell.sizeToFit()
        
        //connect objects with our information from arrays
        cell.usernamebtn.setTitle(usernameArray[indexPath.row], for: UIControlState.normal)
        cell.uuidLbl.text = uuidArray[indexPath.row]
        cell.titleLbl.text = titleArray[indexPath.row]
        cell.titleLbl.sizeToFit()
        cell.usernamebtn.sizeToFit()
        
        
        //place profile pic
        avaArray[indexPath.row].getDataInBackground { (data, error) in
            cell.avaImg.image = UIImage(data: data!)
        }
        
        //place post pic
        picArray[indexPath.row].getDataInBackground { (data, error) in
            cell.picImg.image = UIImage(data: data!)
        }
        
        //calculate post date
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from! as Date, to: now, options: [])
        
        //logic what to show:seconds, minutes, hours, days, or weeks
        if difference.second! <= 0{
            cell.timeLbl.text = "now"
        }
        if difference.second! > 0 && difference.minute! == 0{
            cell.timeLbl.text = "\(difference.second!)s."
        }
        if difference.minute!>0 && difference.hour!==0{
            cell.timeLbl.text = "\(difference.minute!)m."
        }
        if difference.hour!>0 && difference.day!==0{
            cell.timeLbl.text = "\(difference.hour!)h."
        }
        if difference.day!>0 && difference.weekOfMonth!==0{
            cell.timeLbl.text = "\(difference.day!)d."
        }
        if difference.weekOfMonth! > 0{
            
            cell.timeLbl.text = "\(difference.weekOfMonth!)w."
        }
        
        
        
        
        //manipulate like  button depending on whether we like it or not
        let didLike = PFQuery(className: "likes")
        didLike.whereKey("by", equalTo: PFUser.current()?.username!)
        didLike.whereKey("to", equalTo: cell.uuidLbl.text!)
        didLike.countObjectsInBackground { (count, error) in
            if error == nil{
                if count == 0{
                    cell.likeBtn.setTitle("unlike", for: UIControlState.normal)
                    cell.likeBtn.setBackgroundImage(UIImage(named:"unlike.png"), for: UIControlState.normal)
                }else{
                    cell.likeBtn.setTitle("like", for: UIControlState.normal)
                    cell.likeBtn.setBackgroundImage(UIImage(named:"like.png"), for: UIControlState.normal)
                }
            }else{
                
                print(error!.localizedDescription)
            }
        }
        
        //count total likes of showing post
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("to", equalTo: cell.uuidLbl.text!)
        countLikes.countObjectsInBackground { (count, error) in
            if error == nil{
                cell.likeLbl.text = "\(count)"
            }else{
                
                print(error!.localizedDescription)
            }
        }
        
        //assign index
        cell.usernamebtn.layer.setValue(indexPath, forKey: "index")
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        cell.moreBtn.layer.setValue(indexPath, forKey: "index")
        
        //@is tapped
        cell.titleLbl.userHandleLinkTapHandler = {label, handle, range in
            
            var mention = handle
            mention = String(mention.characters.dropFirst())
            //go home
            if mention == PFUser.current()?.username{
                let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
                self.navigationController?.pushViewController(home, animated: true)
                
            }else{
                guestName.append(mention)
                let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
                self.navigationController?.pushViewController(guest, animated: true)
                
            }
            
            
        }
        //hashtag is taped
        cell.titleLbl.hashtagLinkTapHandler = {label, handle, range in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercased())
            let hash = self.storyboard?.instantiateViewController(withIdentifier: "hashtagsVC") as! hashtagsVC
            self.navigationController?.pushViewController(hash, animated: true)
        }
        
        
        return cell
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //click username button
    @IBAction func usernameBtn_click(_ sender: Any) {
        //call index of button
        let i = (sender as AnyObject).layer.value(forKey: "index") as! NSIndexPath
        
        //call cell to call further cell data
        let cell = tableView.cellForRow(at: i as IndexPath) as! postCell
        
        //tap himself, go home
        if cell.usernamebtn.titleLabel?.text! == (PFUser.current()?.username)!{
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
            
        }else{
            
            //go guest
            guestName.append((cell.usernamebtn.titleLabel?.text!)!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as!guestVC
            self.navigationController?.pushViewController(guest, animated: true)
            
        }
        
    }
    
    //click comment button
    @IBAction func commentBtn_click(_ sender: Any) {
        //call index of button
        let i = (sender as AnyObject).layer.value(forKey: "index") as! NSIndexPath
        //call cell to call further cell data
        let cell = tableView.cellForRow(at: i as IndexPath) as! postCell
        //send related data to global var
        commentuuid.append(cell.uuidLbl.text!)
        commentowner.append(cell.usernamebtn.titleLabel!.text!)
        
        //go to comments
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
        self.navigationController?.pushViewController(comment, animated: true)
        
    }
    
    
    //click more button
    @IBAction func moreBtn_click(_ sender: Any) {
        
        //call index of button
        let i = (sender as AnyObject).layer.value(forKey: "index") as! NSIndexPath
        //call cell to call further cell date
        let cell = tableView.cellForRow(at: i as IndexPath) as! postCell
        //delete action
        let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) { (UIAlertAction) in
            //1.delete row from tableView
            self.usernameArray.remove(at: i.row)
            self.avaArray.remove(at: i.row)
            self.dateArray.remove(at: i.row)
            self.picArray.remove(at: i.row)
            self.titleArray.remove(at: i.row)
            self.uuidArray.remove(at: i.row)
            
            //2.delete from server
            let postQuery = PFQuery(className: "posts")
            postQuery.whereKey("uuid", equalTo: cell.uuidLbl.text!)
            postQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    for object in objects!{
                        object.deleteInBackground(block: { (success, error) in
                            
                            if success{
                                //send notification to rootViewcontroller to update posts
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                                //push back
                                self.navigationController?.popViewController(animated: true)
                                
                            }else{
                                
                                print(error!.localizedDescription)
                            }
                            
                        })
                    }
                    
                    
                }else{
                    print(error!.localizedDescription)
                }
            })
            
            
            
            //2.delete likes of posts from server
            let likeQuery = PFQuery(className: "likes")
            likeQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            likeQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    for object in objects!{
                        object.deleteEventually()
                        
                    }
                    
                }
            })
            
            //3.delete comment from the server
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            commentQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    for object in objects!{
                        object.deleteEventually()
                        
                    }
                }
            })
            
            //4.delete hashtag of posts from server
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            hashtagQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    for object in objects!{
                        object.deleteEventually()
                    }
                    
                }
            })
            
        }
        
        //complain action
        let complain =  UIAlertAction(title: "Complian", style: UIAlertActionStyle.default) { (UIAlertAction) in
            //send complain to server
            let complainObj = PFObject(className: "complain")
            complainObj["by"] = PFUser.current()?.username
            complainObj["to"] = cell.uuidLbl.text
            complainObj["owner"] = cell.usernamebtn.titleLabel?.text
            
            complainObj.saveInBackground(block: { (success, error) in
                if success{
                    self.alert(title: "Complain has been made successfully", message: "Thank you! We will consider your complain.")
                }else{
                    self.alert(title: "ERROR", message: error!.localizedDescription)
                }
                
            })
        }
        
        //cancel action
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        //create menu controller
        let menu = UIAlertController(title: "Menu", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        //if post belongs to user, he can delete post, else he cant
        if cell.usernamebtn.titleLabel?.text == PFUser.current()?.username{
            menu.addAction(delete)
            menu.addAction(cancel)
        }else{
            
            menu.addAction(complain)
            menu.addAction(cancel)
        }
        
        //show menu
        self.present(menu, animated: true, completion: nil)
    }
    
    
    //alter func
    func alert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "ok", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        
    }

}
