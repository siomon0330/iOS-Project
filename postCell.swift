//
//  postCell.swift

//
//  Created by Simon on 8/14/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit
import Parse

class postCell: UITableViewCell {

    
    @IBOutlet weak var avaImg: UIImageView!
    
    @IBOutlet weak var usernamebtn: UIButton!
    @IBOutlet weak var timeLbl: UILabel!
    
    @IBOutlet weak var picImg: UIImageView!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!

    @IBOutlet weak var moreBtn: UIButton!
    
    @IBOutlet weak var uuidLbl: UILabel!
    @IBOutlet weak var likeLbl: UILabel!
    
    @IBOutlet weak var titleLbl: KILabel!
    
    
    @IBAction func likeBtn_click(_ sender: Any) {
        
        //declare title of button
        let title = (sender as AnyObject).title(for:.normal)
        
        
        //to like
        if title == "unlike"{
            let object = PFObject(className: "likes")
            object["by"] = PFUser.current()?.username
            object["to"] = uuidLbl.text
            object.saveInBackground(block: { (success, error) in
                if success{
                    print("liked")
                    self.likeBtn.setTitle("like", for: UIControlState.normal)
                    self.likeBtn.setBackgroundImage(UIImage(named: "liked.png"), for: UIControlState.normal)
                
                    //send notification if we liked to refresh tableview
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                    
                    //send like NSNotification
                    //send like NSNotification
                    if self.usernamebtn.titleLabel?.text != PFUser.current()?.username{
                        let newsObj = PFObject(className: "news")
                        newsObj["by"] = PFUser.current()?.username
                        newsObj["to"] = self.usernamebtn.titleLabel?.text
                        newsObj["ava"] = PFUser.current()?.object(forKey: "profileImage")
                        newsObj["owner"] = self.usernamebtn.titleLabel?.text
                        newsObj["uuid"] = self.uuidLbl.text
                        newsObj["type"] = "like"
                        newsObj["checked"] = "no"
                        newsObj.saveEventually()
                    }

                }
            })
        
        }else{
        
            //remove existing likes of current user to show posts
            let query = PFQuery(className: "likes")
            query.whereKey("by", equalTo: PFUser.current()?.username)
            query.whereKey("to", equalTo: uuidLbl.text)
            query.findObjectsInBackground(block: { (objects, error) in
                
                //find likes
                for object in objects!{
                
                    //delete likes
                    object.deleteInBackground(block: { (success, error) in
                        if success{
                        
                            print("disliked")
                            self.likeBtn.setTitle("unlike", for: UIControlState.normal)
                            self.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState.normal)
                            
                            //send notification if we liked to refresh tableview
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                            // delete like notification
                            let newsQuery = PFQuery(className: "news")
                            newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                            newsQuery.whereKey("to", equalTo: self.usernamebtn.titleLabel!.text!)
                            newsQuery.whereKey("uuid", equalTo: self.uuidLbl.text!)
                            newsQuery.whereKey("type", equalTo: "like")
                            newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                if error == nil {
                                    for object in objects! {
                                        object.deleteEventually()
                                    }
                                }
                            })

                            
                        }
                    })
                
                }
            })
        
        
        }

    }
    
    //double tap to liek or unlike
    func likeTap(){
    
        print("tapped")
        //create a large like heart
        let likePicture = UIImageView(image: UIImage(named: "unlike.png"))
        likePicture.frame.size.width = picImg.frame.size.width/2
        likePicture.frame.size.height = picImg.frame.size.height/2
        likePicture.center = picImg.center
        likePicture.alpha = 0.8
        self.addSubview(likePicture)
        
        //hide like pic with animation and transfer to be smaller
        UIView.animate(withDuration: 0.4) {
           likePicture.alpha = 0
           likePicture.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
        //declare title of button
        let title = likeBtn.title(for: UIControlState.normal)
        //to like
        if title == "unlike"{
            let object = PFObject(className: "likes")
            object["by"] = PFUser.current()?.username
            object["to"] = uuidLbl.text
            object.saveInBackground(block: { (success, error) in
                if success{
                    print("liked")
                    self.likeBtn.setTitle("like", for: UIControlState.normal)
                    self.likeBtn.setBackgroundImage(UIImage(named: "liked.png"), for: UIControlState.normal)
                    
                    //send notification if we liked to refresh tableview
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                    
                    //send like NSNotification
                    if self.usernamebtn.titleLabel?.text != PFUser.current()?.username{
                     let newsObj = PFObject(className: "news")
                     newsObj["by"] = PFUser.current()?.username
                     newsObj["to"] = self.usernamebtn.titleLabel?.text
                     newsObj["ava"] = PFUser.current()?.object(forKey: "profileImage")
                     newsObj["owner"] = self.usernamebtn.titleLabel?.text
                     newsObj["uuid"] = self.uuidLbl.text
                     newsObj["type"] = "like"
                     newsObj["checked"] = "no"
                     newsObj.saveEventually()
                    }
                }
              })
            
        }else{
            
            //remove existing likes of current user to show posts
            let query = PFQuery(className: "likes")
            query.whereKey("by", equalTo: PFUser.current()?.username)
            query.whereKey("to", equalTo: uuidLbl.text)
            query.findObjectsInBackground(block: { (objects, error) in
                
                //find likes
                for object in objects!{
                    
                    //delete likes
                    object.deleteInBackground(block: { (success, error) in
                        if success{
                            
                            print("disliked")
                            self.likeBtn.setTitle("unlike", for: UIControlState.normal)
                            self.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState.normal)
                            
                            //send notification if we liked to refresh tableview
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                            
                            
                            //delete notification:like
                            let newsQuery = PFQuery(className: "news")
                            newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                            newsQuery.whereKey("to", equalTo: self.usernamebtn.titleLabel!.text!)
                            newsQuery.whereKey("uuid", equalTo: self.uuidLbl.text)
                            newsQuery.whereKey("type", equalTo: "like")
                            newsQuery.findObjectsInBackground(block: { (objects, error) in
                                if error == nil{
                                    for object in objects!{
                                        object.deleteEventually()
                                    }
                                    
                                    
                                }
                            })
                            
                        }
                    })
                    
                }
            })
        }
        
    
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //clear button title color
        likeBtn.setTitleColor(UIColor.clear, for: UIControlState.normal)
        
        //double tap to like
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(postCell.likeTap))
        likeTap.numberOfTapsRequired = 2
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(likeTap)
        
        let width = UIScreen.main.bounds.width
        
        //allow constrains
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernamebtn.translatesAutoresizingMaskIntoConstraints = false
        timeLbl.translatesAutoresizingMaskIntoConstraints = false
        picImg.translatesAutoresizingMaskIntoConstraints = false
        likeBtn.translatesAutoresizingMaskIntoConstraints = false
        commentBtn.translatesAutoresizingMaskIntoConstraints = false
        moreBtn.translatesAutoresizingMaskIntoConstraints = false
        likeLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        uuidLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let pictureWidth = width-20
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-5-[ava(30)]-10-[pic(\(pictureWidth))]-5-[like(30)]",
            options: [], metrics: nil, views: ["ava":avaImg, "pic":picImg, "like":likeBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-5-[username]", options: [], metrics: nil, views: ["username":usernamebtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[pic]-5-[comment(30)]", options: [], metrics: nil, views: ["pic":picImg, "comment":commentBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[date]", options: [], metrics: nil, views: ["date":timeLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[like]-5-[title]-5-|", options: [], metrics: nil, views: ["like":likeBtn, "title":titleLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[pic]-5-[more(30)]", options: [], metrics: nil, views: ["pic":picImg, "more":moreBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[pic]-10-[likes]", options: [], metrics: nil , views: ["pic":picImg, "likes":likeLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-10-[ava(30)]-10-[username]", options: [], metrics: nil, views: ["ava":avaImg, "username":usernamebtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-10-[pic]-10-|", options: [], metrics: nil, views: ["pic":picImg]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-15-[like(30)]-10-[likes]-20-[comment(30)]", options: [], metrics: nil, views: ["like":likeBtn, "likes":likeLbl, "comment":commentBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:[more(30)]-15-|", options: [], metrics: nil, views: ["more":moreBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-15-[title]-15-|", options: [], metrics: nil, views: ["title":titleLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[date]-10-|", options: [], metrics: nil, views: ["date":timeLbl]))
   
    
        //round image
        
        avaImg.layer.cornerRadius = avaImg.frame.size.width/3.2
        avaImg.clipsToBounds = true
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}















