//
//  headerVC.swift

//
//  Created by Simon on 8/12/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit
import Parse

class headerVC: UICollectionReusableView{
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var fullnameTxt: UILabel!
    
    @IBOutlet weak var bioLbl: UILabel!
    @IBOutlet weak var webTxt: UITextView!
    
    @IBOutlet weak var editProfileBtn: UIButton!
    

    @IBOutlet weak var posts: UILabel!
    
   
    @IBOutlet weak var followers: UILabel!
    
    @IBOutlet weak var following: UILabel!
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var followersTitle: UILabel!
    @IBOutlet weak var followingsTitle: UILabel!

    override func awakeFromNib() {
        editProfileBtn.layer.cornerRadius = editProfileBtn.frame.size.width/50
        
        // alignment
        let width = UIScreen.main.bounds.width
        
        profileImage.frame = CGRect(x: width / 16, y: width / 16, width: width / 4, height: width / 4)
        
        posts.frame = CGRect(x: width / 2.5, y: profileImage.frame.origin.y, width: 50, height: 30)
        followers.frame = CGRect(x: width / 1.7, y: profileImage.frame.origin.y, width: 50, height: 30)
        following.frame = CGRect(x: width / 1.25, y: profileImage.frame.origin.y, width: 50, height: 30)
        
        postTitle.center = CGPoint(x: posts.center.x, y: posts.center.y + 20)
        followersTitle.center = CGPoint(x: followers.center.x, y: followers.center.y + 20)
        followingsTitle.center = CGPoint(x: following.center.x, y: following.center.y + 20)
        
        editProfileBtn.frame = CGRect(x: postTitle.frame.origin.x, y: postTitle.center.y + 20, width: width - postTitle.frame.origin.x - 10, height: 30)
        editProfileBtn.layer.cornerRadius = editProfileBtn.frame.size.width / 50
        
        fullnameTxt.frame = CGRect(x: profileImage.frame.origin.x, y: profileImage.frame.origin.y + profileImage.frame.size.height+10, width: width - 30, height: 30)
        
        /*
        webTxt.frame = CGRect(x: fullnameTxt.frame.origin.x, y: fullnameTxt.frame.origin.y+fullnameTxt.frame.size.height, width: width - 30, height: 30)
 */
        bioLbl.frame = CGRect(x: profileImage.frame.origin.x, y: fullnameTxt.frame.origin.y + fullnameTxt.frame.size.height, width: width-30, height: width/5)
        
        //bioLbl.sizeToFit()
        
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
        editProfileBtn.backgroundColor = UIColor(colorLiteralRed: 15/255.0, green: 99.0/255.0, blue: 164.0/255.0, alpha: 1)
        


    }
    
    
    
    @IBAction func button_click(_ sender: Any) {
       
        let title = editProfileBtn.title(for: .normal)
        if title == "FOLLOW"{
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = guestName.last!
            object.saveInBackground(block: { (success, error) in
                if success {
                    self.editProfileBtn.setTitle("FOLLOWING", for: UIControlState.normal)
                    self.editProfileBtn.backgroundColor = UIColor.gray
                    
                    //send follow notification
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.current()?.username
                    newsObj["to"] = guestName.last
                    newsObj["ava"] = PFUser.current()?.object(forKey: "profileImage")
                    newsObj["owner"] = ""
                    newsObj["uuid"] = ""
                    newsObj["type"] = "follow"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                    
                    
                }else{
                    print(error!.localizedDescription)
                }
            })
        }else{
            
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.current()!.username!)
            query.whereKey("following", equalTo: guestName.last!)
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    for object in objects!{
                        object.deleteInBackground(block: { (success, error) in
                            if success{
                                self.editProfileBtn.setTitle("FOLLOW", for: UIControlState.normal)
                                self.editProfileBtn.backgroundColor = UIColor(colorLiteralRed: 15/255.0, green: 99.0/255.0, blue: 164.0/255.0, alpha: 1)
                                
                                //delete follow notification
                                let newsQuery = PFQuery(className: "news")
                                newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                newsQuery.whereKey("to", equalTo: guestName.last!)
                                newsQuery.whereKey("type", equalTo: "follow")
                                newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    }
                                })

                                
                            }else{
                                print(error!.localizedDescription)
                                
                            }
                        })
                    }
                    
                }else{
                    
                    print(error!.localizedDescription)
                }
            })
            
            
        }

    }
    
        
}
