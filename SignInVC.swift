//
//  SignInVC.swift

//
//  Created by Simon on 8/11/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit
import Parse

class SignInVC: UIViewController {

    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var usernametxt: UITextField!
    @IBOutlet weak var forgotBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    
    @IBAction func forgetpassword_btn(_ sender: Any) {
    }
    
   
    @IBAction func signin_btn(_ sender: Any) {
    
        self.view.endEditing(true)
        
        //check if entered both username and password
        if (usernametxt.text?.isEmpty)! || (passwordTxt.text?.isEmpty)!{
            let alert = UIAlertController(title: "Please", message: "fill in all fields", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "ok", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        
        
        PFUser.logInWithUsername(inBackground: usernametxt.text!, password: passwordTxt.text!) { (user, error) in
            if error == nil{
            
                //remeber user or save the user in tha app
                UserDefaults.standard.set(self.usernametxt.text, forKey: "username")
                UserDefaults.standard.synchronize()
                
                let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            
            }else{
            
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "ok", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            
            }
            
        }
    }
    
    
    @IBAction func signup_btn(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
                label.font = UIFont(name: "Pacifico", size: 25)

        // alignment
        label.frame = CGRect(x: self.view.frame.size.width/3, y: 80, width: self.view.frame.size.width - 20, height: 50)
        usernametxt.frame = CGRect(x: 10, y: label.frame.origin.y + 70, width: self.view.frame.size.width - 20, height: 30)
        passwordTxt.frame = CGRect(x: 10, y: usernametxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        forgotBtn.frame = CGRect(x: 10, y: passwordTxt.frame.origin.y + 30, width: self.view.frame.size.width - 20, height: 30)
        
        signInBtn.frame = CGRect(x: 20, y: forgotBtn.frame.origin.y + 40, width: self.view.frame.size.width / 4, height: 30)
        signInBtn.layer.cornerRadius = signInBtn.frame.size.width / 20
        
        signUpBtn.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 4 - 20, y: signInBtn.frame.origin.y, width: self.view.frame.size.width / 4, height: 30)
        signUpBtn.layer.cornerRadius = signUpBtn.frame.size.width / 20
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(SignInVC.hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // background
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
    }

       // hide keyboard func
    func hideKeyboard(recognizer : UITapGestureRecognizer) {
        self.view.endEditing(true)
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
