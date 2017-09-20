//
//  SignUpVC.swift

//  Created by Simon on 8/11/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit
import Parse

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var emailTxt: UITextField!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var usernameTxt: UITextField!
    
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var repeatpasswordTxt: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextField!
    @IBOutlet weak var webTxt: UITextField!
    
    var scrollViewHeight:CGFloat = 0
    var keyBoard = CGRect()
    
    
    
    @IBAction func signup_click(_ sender: Any) {
        
        self.view.endEditing(true)
        
        //alter message to check fill in all fields
        if (usernameTxt.text?.isEmpty)! || (passwordTxt.text?.isEmpty)! || (repeatpasswordTxt.text?.isEmpty)! || (emailTxt.text?.isEmpty)! || (fullnameTxt.text?.isEmpty)! || (bioTxt.text?.isEmpty)!{
        
            let alert = UIAlertController(title: "Please", message: "fill all fields", preferredStyle: UIAlertControllerStyle.alert)
            
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            
            alert.addAction(ok)
            
            present(alert, animated: true, completion: nil)
            return
        
        }
        
        //check if password matches
        if passwordTxt.text != repeatpasswordTxt.text{
        
            let alert = UIAlertController(title: "Password", message: "mismatches", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "fine", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return 
        
        }
        
        //send data to server
        let user = PFUser()
        user.username = usernameTxt.text
        user.email = emailTxt.text
        user.password = passwordTxt.text
        user["fullname"] = fullnameTxt.text
        user["bio"] = bioTxt.text
        user["web"] = ""
        
        //in edit profile it will be assigned
        user["telephone"] = ""
        user["gender"] = ""
        
        let profileImageData = UIImageJPEGRepresentation(profileImage.image!, 0.5)
        let profileImageFile = PFFile(name: "profileImage.jpg", data: profileImageData!)
        user["profileImage"] = profileImageFile

        user.signUpInBackground(block: { (success, error) in
            
            if success{
                
                print("user saved")
                
                //remember the loged in user
                
                UserDefaults.standard.set(user.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                //call log in func from appdelegate
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
                
                
                
                
            }else{
                
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "ok", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                
            }
        })
        
        
        
        
        
    }
    
    @IBAction func cancel_click(_ sender: Any) {
       self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //set the size of the scroll view
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = scrollView.frame.size.height
        
    
        //add notofication when the keyboard shows or disappears
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpVC.showKeyBoard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpVC.hideKeyBoard), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
        //tap to hide the keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.hideKeyBoardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //tap profile image to choose an image
        let changeImageTap = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.loadImage))
        changeImageTap.numberOfTapsRequired = 1
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(changeImageTap)
        
        //make the profile image square
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
        
    }
    
    //picker to pick an image
    func loadImage(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    
    //what to do when picked an image
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]){
        profileImage.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    
    }
    
    
    func hideKeyBoardTap(){
        self.view.endEditing(true)
    }
    
    func showKeyBoard(notification:NSNotification){
         keyBoard = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.4, animations:{
        
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyBoard.height
        }
        
        )
    }
    
    func hideKeyBoard(){
      self.scrollView.frame.size.height = self.scrollViewHeight
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
