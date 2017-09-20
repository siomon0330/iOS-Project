//
//  resetPasswordVC.swift

//
//  Created by Simon on 8/11/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit
import Parse

class resetPasswordVC: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    
    @IBAction func resetbtn_click(_ sender: Any) {
        self.view.endEditing(true)
        if email.text!.isEmpty{
        
           let alert =  UIAlertController(title: "Email", message: "is empty", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "ok", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        
       PFUser.requestPasswordResetForEmail(inBackground: email.text!) { (success, error) in
        
        if success{
        
            let alert = UIAlertController(title: "An email", message: "has been sent to your email address", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "ok", style: UIAlertActionStyle.cancel, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
                
            })
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
        }else{
            print(error ?? "Reset failed")
        }
        
        
        
        }
        
    }
    
    @IBAction func cancelBtn_click(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        self.view.endEditing(true)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(resetPasswordVC.hideKeyBoard))
        tap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tap)
        
    
        // Do any additional setup after loading the view.
    }
    
    
    func hideKeyBoard(){
    
    
        self.view.endEditing(true)
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
