//
//  followersVC.swift

//
//  Created by Simon on 8/12/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit
import Parse


var user = String()
var showing = String()

class followersVC: UITableViewController {
    
    //array to hold the username and their profile image
    var usernameArray = [String]()
    var avaImageArray = [PFFile]()
    
    //arr to hold the followers or followings
    var followArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(guestVC.back(sender:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(followersVC.back(sender:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        
        self.navigationItem.title = showing.uppercased()
        
        if showing == "followers"{
            loadFollowers()
        }
        
        if showing == "followings"{
        
            loadFollowing()
        }

    }
    
    func loadFollowers(){
    
        //find people who follow us
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: user)
        followers.findObjectsInBackground { (objects, error) in
            if error == nil{
            
                //add their name to the follow array
                self.followArray.removeAll(keepingCapacity: false)
                for object in objects!{
                    self.followArray.append(object.value(forKey: "follower") as! String)
                }
                
                //find them in the User
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.followArray)
                query?.addDescendingOrder("createAt")
                query?.findObjectsInBackground(block: { (objects, error) in
                    if error == nil{
                        
                        //add their name and ava iamge to the two array
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaImageArray.removeAll(keepingCapacity: false)
                        for object in objects!{
                            self.usernameArray.append(object.value(forKey: "username") as! String)
                            self.avaImageArray.append(object.value(forKey: "profileImage") as! PFFile)
                            self.tableView.reloadData()
                        }
                
                    }else{
                         print(error!.localizedDescription)
                    }
                })
                
            }else{
                print(error!.localizedDescription)
            }
            
        }
    }
    
    //find people who we are following
    func loadFollowing(){
    
        
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: user)
        followings.findObjectsInBackground { (objects, error) in
            if error == nil{
                self.followArray.removeAll(keepingCapacity: false)
                for object in objects!{
                    self.followArray.append(object.value(forKey: "following") as! String)
                }
                
                //find them in User
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.followArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackground(block: { (objects, erroe) in
                    if error == nil{
                    
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaImageArray.removeAll(keepingCapacity: false)
                        for object in objects!{
                        
                            self.usernameArray.append(object.value(forKey: "username") as! String)
                            self.avaImageArray.append(object.value(forKey: "profileImage") as! PFFile)
                            self.tableView.reloadData()
                        }
                    }else{
                        print(error!.localizedDescription)
                    
                    }
                })
            
            }else{
                print(error!.localizedDescription)
            
            }
        }
    
    }
    
    //cell num
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }
    
    
    //config cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //find the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! followersCell
        cell.usernameLbl.text = usernameArray[indexPath.row]
        avaImageArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil{
               cell.avaImg.image = UIImage(data: data!)
            }else{
            
                print(error!.localizedDescription)
            
            }
        }
        
        
        //check whether we are following the user or not
        let query = PFQuery(className: "follow")
        query.whereKey("follower", equalTo: user)
        query.whereKey("following", equalTo: cell.usernameLbl.text!)
        query.findObjectsInBackground { (objects, error) in
            if error == nil{
            
                if objects?.count == 0{
                
                    cell.followingBtn.setTitle("FOLLOW", for: UIControlState.normal)
                    cell.followingBtn.backgroundColor = UIColor(colorLiteralRed: 15/255.0, green: 99.0/255.0, blue: 164.0/255.0, alpha: 1)
                }else{
                
                    cell.followingBtn.setTitle("FOLLOWING", for: UIControlState.normal)
                    cell.followingBtn.backgroundColor = UIColor.gray
                }
            }
        }
        
        
        //hide the follow button for yourself( you can't follow yourself)
        if cell.usernameLbl.text == PFUser.current()?.username{
            
            cell.followingBtn.isHidden = true
        
        }
        
        
        return cell
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! followersCell
        
        if cell.usernameLbl.text! == PFUser.current()!.username!{
        
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
            
        }else{
        
            guestName.append(cell.usernameLbl.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
            
        }
        
        
        
    }
    
    //go back
    func back(sender: UITabBarItem){
    
        self.navigationController?.popViewController(animated: true)
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
