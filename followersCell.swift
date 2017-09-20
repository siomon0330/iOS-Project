//
//  followersCell.swift

//
//  Created by Simon on 8/12/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit
import Parse

class followersCell: UITableViewCell {

    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var followingBtn: UIButton!
    
    //follow button fig
    @IBAction func followBtn_click(_ sender: Any) {
        let title = followingBtn.title(for: .normal)
        if title == "FOLLOW"{
        
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = usernameLbl.text
            object.saveInBackground(block: { (success, error) in
                if success {
                    self.followingBtn.setTitle("FOLLOWING", for: UIControlState.normal)
                    self.followingBtn.backgroundColor = UIColor.gray
                    
                    //send follow notification
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.current()?.username
                    newsObj["to"] = self.usernameLbl.text!
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
            query.whereKey("following", equalTo: usernameLbl.text!)
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    for object in objects!{
                         object.deleteInBackground(block: { (success, error) in
                            if success{
                            
                                self.followingBtn.setTitle("FOLLOW", for: UIControlState.normal)
                                self.followingBtn.backgroundColor = UIColor(colorLiteralRed: 15/255.0, green: 99.0/255.0, blue: 164.0/255.0, alpha: 1)
                                
                                //delete follow notification
                                let newsQuery = PFQuery(className: "news")
                                newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                newsQuery.whereKey("to", equalTo: self.usernameLbl.text!)
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
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // alignment
        let width = UIScreen.main.bounds.width
        
        avaImg.frame = CGRect(x: 10, y: 10, width: width / 5, height: width / 5)
        usernameLbl.frame = CGRect(x: avaImg.frame.size.width + 20, y: width/11, width: width / 3, height: 30)
        followingBtn.frame = CGRect(x: width - width / 3 - 10, y: 30, width: width / 3, height: 30)
        followingBtn.layer.cornerRadius = followingBtn.frame.size.width / 20
        
        //make the image round
        avaImg.layer.cornerRadius = avaImg.frame.size.width/2
        avaImg.clipsToBounds = true
        
        //followingBtn.backgroundColor = UIColor(colorLiteralRed: 15/255.0, green: 99.0/255.0, blue: 164.0/255.0, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
