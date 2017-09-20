//
//  editVC.swift

//
//  Created by Simon on 8/13/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit
import Parse

class editVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var infoLbl: UILabel!
    
    //UI objects
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var avaImage: UIImageView!
    
    @IBOutlet weak var fullnameTxt: UITextField!
    
    
    @IBOutlet weak var usernameTxt: UITextField!
    
    
    //@IBOutlet weak var webTxt: UITextField!
    
   
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var bioTxt: UITextView!
    
    @IBOutlet weak var emailTxt: UITextField!
    
    @IBOutlet weak var telephoneTxt: UITextField!
    
    @IBOutlet weak var genderTxt: UITextField!
    
    //picker View and picker data
    var genderPicker:UIPickerView!
    let genders = ["male", "female"]
    
    //value to hold keyboard frame size
    var keyboard = CGRect()
    
    //click cancel button
    @IBAction func cancelBtn_click(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    //validate email
    func validateEmail(email:String) ->Bool{
        
        let regex = "[A-Z0-9a-z._%+-]{4}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2}"
        let range = email.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
        
    }
    
    //validate web
    func validateWeb(web:String) ->Bool{
        
        let regex = "www.+[A-Z0-9a-z._%+-]+.[A-Za-z]{2}"
        let range = web.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func alert(error:String, message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "ok", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    
    }

    
    //click save button
    @IBAction func saveBtn_click(_ sender: Any) {
        if !validateEmail(email: emailTxt.text!){
            alert(error: "Incorrect email", message: "please provide correct email address")
            return
        }
        /*
        if webTxt.text != "" && !validateWeb(web: webTxt.text!){
           alert(error: "Incorrect web", message: "please provide correct web address")
        }
 */
        
        let user = PFUser.current()!
        user.username = usernameTxt.text
        user.email = emailTxt.text
        user["fullname"] = fullnameTxt.text
        user["web"] = ""
        user["bio"] = bioTxt.text
        
        if telephoneTxt.text == ""{
        
            user["telephone"] = ""
        }else{
        
            user["telephone"] = telephoneTxt.text
        }
        
        if genderTxt.text == ""{
        
            user["gender"] = ""
        }else{
        
            user["gender"] = genderTxt.text
        }
        
        let avaData = UIImageJPEGRepresentation(avaImage.image!, 0.5)
        let avaFile = PFFile(name: "ava.jpg", data: avaData!)
        user["profileImage"] = avaFile
        
        user.saveInBackground { (success, error) in
            if success{
                //hide keyboard
                self.view.endEditing(true)
                //dismiss view controller
                self.dismiss(animated: true, completion: nil)
                //send notification to homwVC to be loaded
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
                
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //make alignment
        alignment()
        
        //call user information
        information()
        
        //create picker
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        genderTxt.inputView = genderPicker
        
        //check notifications of keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(editVC.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editVC.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)

        //tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(editVC.hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //tap to choose image
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(editVC.loadImage(recognizer:)))
        avaTap.numberOfTapsRequired = 1
        avaImage.isUserInteractionEnabled = true
        avaImage.addGestureRecognizer(avaTap)
    
    }
    
    //method to choode an image
    func loadImage(recognizer:UITapGestureRecognizer){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    
    }
    //when choosing image is done
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avaImage.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    

    //hide keyboard
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    //when keyboard is showing
    func keyboardWillShow(notification:Notification){
        keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as! CGRect)
        UIView.animate(withDuration: 0.4) { 
            self.scrollView.contentSize.height = self.view.frame.size.height+self.keyboard.height/2
            
        }
    }
    
    //when keyboard is hiding
    func keyboardWillHide(){
    
        UIView.animate(withDuration:0.4) { 
            self.scrollView.contentSize.height = 0
        }
    }
    
    //alignment functions
    func alignment(){
    
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        avaImage.frame = CGRect(x: width-80-10, y: 15, width: 80, height: 80)
        avaImage.layer.cornerRadius = avaImage.frame.size.width/2
        avaImage.clipsToBounds = true
        
        infoLbl.frame = CGRect(x: 10, y: avaImage.frame.origin.y, width: width-avaImage.frame.width-30, height: 60)
        
        usernameTxt.frame = CGRect(x: 10, y: infoLbl.frame.origin.y + 60, width: width-avaImage.frame.width-30, height: 30)
        fullnameTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y+40 , width: width-avaImage.frame.width-30, height: 30)
        //webTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y+40 , width: width-20, height: 30)
        
        bioTxt.frame = CGRect(x: 10, y: fullnameTxt.frame.origin.y+40, width: width-20, height: 60)
        bioTxt.layer.borderWidth = 1
        bioTxt.layer.borderColor = UIColor(colorLiteralRed: 230/255.5, green: 230/255.5, blue: 230/255.5, alpha: 1).cgColor
        bioTxt.layer.cornerRadius = bioTxt.frame.size.width/50
        bioTxt.clipsToBounds = true
        
        
        emailTxt.frame = CGRect(x: 10, y: bioTxt.frame.origin.y+100, width: width-20, height: 30)
        telephoneTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y+40, width: width-20, height: 30)
        genderTxt.frame = CGRect(x: 10, y: telephoneTxt.frame.origin.y+40, width: width-20, height: 30)
        
        titleLbl.frame = CGRect(x: 15, y: emailTxt.frame.origin.y-30, width: width-20, height: 30)
    
    }
    
    
    //picker view methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTxt.text = genders[row]
        self.view.endEditing(true)
    }
    
    
    //user information function
    func information(){
        let ava = PFUser.current()?.object(forKey: "profileImage") as! PFFile
        ava.getDataInBackground { (data, error) in
            if error == nil{
            self.avaImage.image = UIImage(data: data!)
            }
        }
        usernameTxt.text = PFUser.current()?.username
        fullnameTxt.text = PFUser.current()?.object(forKey: "fullname") as? String
        bioTxt.text = PFUser.current()?.object(forKey: "bio") as? String
        //webTxt.text = PFUser.current()?.object(forKey: "web") as? String
        
        emailTxt.text = PFUser.current()?.email
        telephoneTxt.text = PFUser.current()?.object(forKey: "telephone") as? String
        genderTxt.text = PFUser.current()?.object(forKey: "gender") as? String
    }
    
}
















