//
//  uploadVC.swift

//
//  Created by Simon on 8/13/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit
import Parse

class uploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

   
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var publishBtn: UIButton!
    
    //remove btn click
    @IBAction func removeBtn_click(_ sender: Any) {
        self.viewDidLoad()
    }
    
    //click publish button
    @IBAction func makePost_click(_ sender: Any) {
        
        //dismiss keyboard
        self.view.endEditing(true)
        
        //send data to server to posts class in Parse
        let objetct = PFObject(className: "posts")
        objetct["username"] = PFUser.current()?.username
        objetct["ava"] = PFUser.current()?.value(forKey: "profileImage") as! PFFile
       
        let uuid = "\(String(describing: PFUser.current()?.username)) \(NSUUID().uuidString)"
        objetct["uuid"] = uuid
        if titleTxt.text!.isEmpty{
        
            objetct["title"] = ""
        
        }else{
        
            objetct["title"] = titleTxt.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        }
        
        
 
        
        //send pic to server after converting to PFFile and compression
        let imageData = UIImageJPEGRepresentation(picImg.image!, 0.5)
        let imageFile = PFFile(name: "post.jpg", data: imageData!)
        objetct["pic"] = imageFile
        
        //send #hashtag to server
        let words:[String] = titleTxt.text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        //define taged word
        for var word in words{
            
            //save #hashtag in server
            if word.hasPrefix("#"){
                
                //cut symbol
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let hashTagObj = PFObject(className: "hashtags")
                hashTagObj["to"] = uuid
                hashTagObj["by"] = PFUser.current()?.username
                hashTagObj["hashtag"] = word
                hashTagObj["comment"] = titleTxt.text
                hashTagObj.saveInBackground(block: { (success, error) in
                    if success{
                        print("hashtag is created")
                        
                    }else{
                        print(error!.localizedDescription)
                        
                    }
                })
                
            }
        }

        //save
        objetct.saveInBackground(block: { (success, error) in
                
            if error == nil{
                
                    //send notification with name uploaded
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                    //switch to another view controller at 0 index of tabbar
                    self.tabBarController?.selectedIndex = 0
                
                //reset everything
                self.viewDidLoad()
                self.titleTxt.text = ""
                
                }
            })
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //diable publish button
        publishBtn.isEnabled = false
        publishBtn.backgroundColor = UIColor.lightGray
        
        //hide remove button
        removeBtn.isHidden = true
        
        //standard UI containt
        picImg.image = UIImage(named: "camera.png")
        
        
        
        //hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //select image tap
        let picTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.selectImage))
        picTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(picTap)
        
    }
    
    //preload func
    override func viewWillAppear(_ animated: Bool) {
        
        //make alognment
        alignment()
    }
    
    //hide keyboard func
    func hideKeyboardTap(){
      self.view.endEditing(true)
    }
    
    func selectImage(){
    
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        //enable publish button
        publishBtn.isEnabled = true
        publishBtn.backgroundColor = UIColor(colorLiteralRed: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        //unhide remove btn
        removeBtn.isHidden = false
        
        
        //implement second tap for zooming image
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.zoomImg))
        zoomTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }
    
    //zooming in and out func
    func zoomImg(){
    
        let zoomed = CGRect(x: 0, y: self.view.center.y-self.view.center.x-(self.tabBarController?.tabBar.frame.size.height)!, width: self.view.frame.size.width, height: self.view.frame.size.width)
        let unzoomed = CGRect(x: 15, y: 15, width: self.view.frame.size.width/5, height: self.view.frame.size.width/5)
        
        if picImg.frame == unzoomed{
             UIView.animate(withDuration: 0.3, animations: { 
                self.picImg.frame = zoomed
                
                self.view.backgroundColor = UIColor.black
                self.titleTxt.alpha = 0
                self.publishBtn.alpha = 0
                self.removeBtn.isHidden = true
             })
        }else{
        
            UIView.animate(withDuration: 0.3, animations: { 
                
                self.picImg.frame = unzoomed
                self.view.backgroundColor = UIColor.white
                self.titleTxt.alpha = 1
                self.publishBtn.alpha = 1
                self.removeBtn.isHidden = false
            })
        
        
        }
        
    
    }
    
    
    
    
    
    //make alignment
    func alignment(){
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        picImg.frame = CGRect(x: 15, y: 15, width: width/5, height: width/5)
        titleTxt.frame = CGRect(x: picImg.frame.size.width+25, y: picImg.frame.origin.y, width: width/1.5, height: picImg.frame.size.height)
        publishBtn.frame = CGRect(x: 0, y: height/1.1, width: width, height: width/8)
        removeBtn.frame = CGRect(x: picImg.frame.origin.x, y: picImg.frame.origin.y+picImg.frame.size.height, width: picImg.frame.size.width, height: 30)
    }

}



















