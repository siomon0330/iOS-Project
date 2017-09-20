//
//  commentVC.swift

//
//  Created by Simon on 8/15/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit
import Parse

var commentuuid = [String]()
var commentowner = [String]()

class commentVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

    //UI objects
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    var refresher = UIRefreshControl()
    
    //values for reseting UI to default
    var tableViewHeight:CGFloat = 0
    var commentY:CGFloat = 0
    var commentHeight:CGFloat = 0
    
    //arrays to hold server data
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var commentArray = [String]()
    var dateArray = [NSDate?]()
    
    //keyboard fram
    var keyboard = CGRect()
    
    //page size
    var page:Int32 = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.white
        
        //title at the top
        self.navigationItem.title = "Comments"
        
        //new back button
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "back.png") , style: UIBarButtonItemStyle.plain, target: self, action: #selector(commentVC.back(sender:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        //catch notification if the keyboard is shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(commentVC.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(commentVC.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //disable button from begining
        sendBtn.isEnabled = false
        
        //pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(commentVC.loadMore), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresher)
        
        //swip to go back
        let backSwip = UISwipeGestureRecognizer(target: self, action: #selector(commentVC.back(sender:)))
        backSwip.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwip)
        
        //call alignment func
        alignment()
        
        //load comments
        loadComments()
        
    }
    
    //function loading when keyboard is shown
    func keyboardWillShow(notification:NSNotification){
    
        //define keyboard frame size
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        //move it up
        UIView.animate(withDuration: 0.4) { 
            self.tableView.frame.size.height = self.tableViewHeight-self.keyboard.height-self.commentTxt.frame.size.height+50
            self.commentTxt.frame.origin.y = self.commentY-self.keyboard.height-self.commentTxt.frame.size.height+self.commentHeight
            self.sendBtn.frame.origin.y = self.commentTxt.frame.origin.y
        }
        
    }
    
    //func load when keyboard is hidden
    func keyboardWillHide(notification:NSNotification){
    
        //move it down
        UIView.animate(withDuration: 0.4) { 
            self.tableView.frame.size.height = self.tableViewHeight
            self.commentTxt.frame.origin.y = self.commentY
            self.sendBtn.frame.origin.y = self.commentY
            
        }
    
    }
    
    
    
    //reload func
    override func viewWillAppear(_ animated: Bool) {
        //hide bottom bar
        self.tabBarController?.tabBar.isHidden = true
        //call keyboard
        commentTxt.becomeFirstResponder()
    }
    
    //postload func
    override func viewDidDisappear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    //alignment func
    func alignment(){
    
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height/1.1 - (self.navigationController?.navigationBar.frame.size.height)!-30)
        tableView.estimatedRowHeight = width/6
        tableView.rowHeight = UITableViewAutomaticDimension
       
        commentTxt.frame = CGRect(x: 10, y: tableView.frame.size.height+height/25, width: width/1.4, height: 35)
        commentTxt.layer.cornerRadius = commentTxt.frame.size.width/50
        commentTxt.clipsToBounds = true
        
        sendBtn.frame = CGRect(x: commentTxt.frame.origin.x+commentTxt.frame.size.width+width/33, y: commentTxt.frame.origin.y, width: width-(commentTxt.frame.origin.x+commentTxt.frame.size.width)-(width/32)*2, height: commentTxt.frame.size.height)
    
        //delegate
        commentTxt.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        //assign reseting values
        tableViewHeight = tableView.frame.size.height
        commentHeight = commentTxt.frame.size.height
        commentY = commentTxt.frame.origin.y
    
    }
    //while writing something
    func textViewDidChange(_ textView: UITextView) {
        //diable button if no text entered
        let spacing = NSCharacterSet.whitespacesAndNewlines
        if commentTxt.text.trimmingCharacters(in: spacing).isEmpty{
            sendBtn.isEnabled = false
        }else{
            sendBtn.isEnabled = true
        }
        
        //+paragraph
        if textView.contentSize.height > textView.frame.size.height && textView.frame.height < 130{
        
            //redifine frame of commenTxt
            let difference = textView.contentSize.height - textView.frame.size.height
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            
            //move up table view
            
            if textView.contentSize.height + keyboard.height + commentY >= tableView.frame.size.height{
                tableView.frame.size.height = tableView.frame.size.height - difference
            
            }
        }
        
        //-paragraph
        else if textView.contentSize.height < textView.frame.size.height{
        
            //redefine frame of commentTxt
            let difference = textView.frame.size.height - textView.contentSize.height
            textView.frame.origin.y = textView.frame.origin.y+difference
            textView.frame.size.height = textView.contentSize.height
        
            //move down tableview
            if textView.contentSize.height+keyboard.height + commentY > tableView.frame.size.height{
            
                tableView.frame.size.height = tableView.frame.size.height+difference
            }
        
        
        }
        
    }
    
    //load comments func
    func loadComments(){
    
        //step1.count total comments in order to skip all except (page size = 15)
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground { (count, error) in
            
            //if comments on the server for current post are more than (page size 15), implement pull to refresh
            if self.page < count{
                self.refresher.addTarget(self, action: #selector(commentVC.loadMore), for: UIControlEvents.valueChanged)
                self.tableView.addSubview(self.refresher)
            }
            
            //step2.request last (page size 15) comments
            let query = PFQuery(className: "comments")
            query.whereKey("to", equalTo: commentuuid.last!)
            query.skip = count - self.page
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    //clean up
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.avaArray.removeAll(keepingCapacity: false)
                    self.commentArray.removeAll(keepingCapacity: false)
                    self.dateArray.removeAll(keepingCapacity: false)
                    
                    //find related data
                    for object in objects!{
                    
                        self.usernameArray.append(object.object(forKey: "username") as! String)
                        self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                        self.commentArray.append(object.object(forKey: "comment") as! String)
                        self.dateArray.append(object.createdAt as? NSDate)
                        self.tableView.reloadData()
                        
                        //scroll to btm
                        let index = NSIndexPath(row: self.commentArray.count-1, section: 0)
                        self.tableView.scrollToRow(at: index as IndexPath, at: UITableViewScrollPosition.bottom, animated: false)
                    
                    }
                }else{
                
                    print(error!.localizedDescription)
                
                }
            })
            
        }
    }
    
    
    //pagination
    func loadMore(){
    
        //step1.count total comments in order to skip all except (page size = 15)
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground { (count, error) in
            
            //self refresher
            self.refresher.endRefreshing()
            
            //remove refresher if loaded all comments
            if self.page>=count{
                self.refresher.removeFromSuperview()
            }
            
            //load more comments
            if self.page < count{
            
                //increase page to load 30 as first paging
                self.page += 15
                let query  = PFQuery(className: "comments")
                query.whereKey("to", equalTo: commentuuid.last!)
                query.skip = count - self.page
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackground(block: { (objects, error) in
                    
                    if error == nil{
                        //clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.commentArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        
                        //find related objects
                        for object in objects!{
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                            self.commentArray.append(object.object(forKey: "comment") as! String)
                            self.dateArray.append(object.createdAt as? NSDate)
                            
                            self.tableView.reloadData()
                        }
                    
                    }else{
                    
                        print(error!.localizedDescription)
                    }
                })
            
            }
        }

    }
    
    
    
    
    //click send button
    @IBAction func sendBtn_click(_ sender: Any) {
        //1.add row in table view
        usernameArray.append((PFUser.current()?.username!)!)
        avaArray.append(PFUser.current()?.object(forKey: "profileImage") as! PFFile)
        dateArray.append(NSDate())
        commentArray.append(commentTxt.text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines))
        tableView.reloadData()
        
        //2.send comment to server
        let commentObj = PFObject(className: "comments")
        commentObj["to"] = commentuuid.last
        commentObj["username"] = PFUser.current()?.username
        commentObj["ava"] = PFUser.current()?.value(forKey: "profileImage")
        commentObj["comment"] = commentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        commentObj.saveEventually()
        
        //3.send #hashtag to server
        let words:[String] = commentTxt.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        //define taged word
        for var word in words{
        
            //save #hashtag in server
            if word.hasPrefix("#"){
            
                //cut symbol
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let hashTagObj = PFObject(className: "hashtags")
                hashTagObj["to"] = commentuuid.last
                hashTagObj["by"] = PFUser.current()?.username
                hashTagObj["hashtag"] = word
                hashTagObj["comment"] = commentTxt.text
                hashTagObj.saveInBackground(block: { (success, error) in
                    if success{
                         print("hashtag is created")
                    
                    }else{
                    
                        print(error!.localizedDescription)
                    
                    }
                })
            
            }
        }
        
        
        
        //4.send notification as @
        var mentionCreated = Bool()
        for var word in words{
            //check mentions@ for user
            if word.hasPrefix("@"){
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
            
                let newsObj = PFObject(className: "news")
                newsObj["by"] = PFUser.current()?.username
                newsObj["to"] = word
                newsObj["ava"] = PFUser.current()?.object(forKey: "profileImage")
                newsObj["owner"] = commentowner.last
                newsObj["uuid"] = commentuuid.last
                newsObj["type"] = "mention"
                newsObj["checked"] = "no"
                newsObj.saveEventually()
                mentionCreated = true
                //send notification
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "news"), object: nil)

                
            }
        }
        //5.send notification as comment
        if commentowner.last != PFUser.current()?.username && mentionCreated == false{
            let newsObj = PFObject(className: "news")
            newsObj["by"] = PFUser.current()?.username
            newsObj["to"] = commentowner.last
            newsObj["ava"] = PFUser.current()?.object(forKey: "profileImage")
            newsObj["owner"] = commentowner.last
            newsObj["uuid"] = commentuuid.last
            newsObj["type"] = "comment"
            newsObj["checked"] = "no"
            newsObj.saveEventually()
                       
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "news"), object: nil)

        }
        
        
        //scroll to btm
        let index = NSIndexPath(row: self.commentArray.count-1, section: 0)
        self.tableView.scrollToRow(at: index as IndexPath, at: UITableViewScrollPosition.bottom, animated: false)
        
        //6.reset UI
        self.sendBtn.isEnabled = false
        commentTxt.text = ""
        commentTxt.frame.size.height = commentHeight
        commentTxt.frame.origin.y = sendBtn.frame.origin.y
        self.tableView.frame.size.height = self.tableViewHeight-self.keyboard.height-self.commentTxt.frame.size.height+50
        
        
    }
    

    
    //TableView
    //cell num
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    //cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    //cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //declare cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! commentCell
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: UIControlState.normal)
        cell.usernameBtn.sizeToFit()
        cell.commentLbl.text = commentArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil{
                cell.avaImg.image = UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        }
        
        //calculate comment date
       
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from! as Date, to: now, options: [])
        
        
        //logic what to show:seconds, minutes, hours, days, or weeks
        if difference.second! <= 0{
            cell.dateLbl.text = "now"
        }
        if difference.second! > 0 && difference.minute! == 0{
            cell.dateLbl.text = "\(difference.second!)s."
        }
        if difference.minute!>0 && difference.hour!==0{
            cell.dateLbl.text = "\(difference.minute!)m."
        }
        if difference.hour!>0 && difference.day!==0{
            cell.dateLbl.text = "\(difference.hour!)h."
        }
        if difference.day!>0 && difference.weekOfMonth!==0{
            cell.dateLbl.text = "\(difference.day!)d."
        }
        if difference.weekOfMonth! > 0{
            cell.dateLbl.text = "\(difference.weekOfMonth!)w."
        }
        
        //@is tapped
        cell.commentLbl.userHandleLinkTapHandler = {label, handle, range in
            
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
        cell.commentLbl.hashtagLinkTapHandler = {label, handle, range in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercased())
            let hash = self.storyboard?.instantiateViewController(withIdentifier: "hashtagsVC") as! hashtagsVC
            self.navigationController?.pushViewController(hash, animated: true)
        }
        
        

        //assign index of buttons
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        return cell
        
        
    }
    
    
    
    //click username button
    @IBAction func usernameBtn_click(_ sender: Any) {
        //call index of current button
        let i = (sender as AnyObject).layer.value(forKey: "index") as! NSIndexPath
        
        //call cell to call further cell
        let cell = tableView.cellForRow(at: i as IndexPath) as! commentCell
        
        //tap himself
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username{
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        
        }else{
            //tap others
            guestName.append((cell.usernameBtn.titleLabel?.text)!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        
        }
        
    }
    
    //cell editability
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //call cell for calling further cell data
        let cell = tableView.cellForRow(at: indexPath) as! commentCell
        //action1.delete
        let delete =  UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: " ") { (action, indexPath) in
            
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: commentuuid.last!)
            commentQuery.whereKey("comment", equalTo: cell.commentLbl.text!)
            commentQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                
                    for object in objects!{
                    
                        object.deleteEventually()
                    }
                
                }else{
                
                    print(error!.localizedDescription)
                
                }
            })
            
            //2.delete hashTag from server
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("to", equalTo: commentuuid.last)
            hashtagQuery.whereKey("by", equalTo: cell.usernameBtn.titleLabel?.text)
            hashtagQuery.whereKey("comment", equalTo: cell.commentLbl.text)
            hashtagQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    for object in objects!{
                        object.deleteEventually()
                    }
                }
            })
            
            //3.delete notification:mention and @
            let newsQuery = PFQuery(className: "news")
            newsQuery.whereKey("by", equalTo: cell.usernameBtn.titleLabel!.text!)
           
            //newsQuery.whereKey("to", equalTo: commentowner.last!)
            
            newsQuery.whereKey("uuid", equalTo: commentuuid.last!)
            newsQuery.whereKey("type", containedIn: ["comment", "mention"])
            newsQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    for object in objects!{
                        object.deleteEventually()
                    }
                
                
                }
            })
            
            
            
            
            
            
            //close cell
            tableView.setEditing(false, animated: true)
            
            //delete comment row from tableview
            self.commentArray.remove(at: indexPath.row)
            self.dateArray.remove(at: indexPath.row)
            self.usernameArray.remove(at: indexPath.row)
            self.avaArray.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
        }
        
        //action2.mention someone
        let address = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "  ") { (action, indexPath) in
            
            //include username in textview
            self.commentTxt.text = "\(self.commentTxt.text + "@" + self.usernameArray[indexPath.row] + " ")"
            //enable button
            self.sendBtn.isEnabled = true
            //close cell
            tableView.setEditing(false, animated: true)
        }
        
        //action 3.compliant
        let complain = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "  ") { (action, index) in
            
            //send complain to server regarding selected comment
            let complainObj = PFObject(className: "complain")
            complainObj["by"] = PFUser.current()?.username
            complainObj["post"] = commentuuid.last
            complainObj["to"] = cell.commentLbl.text
            complainObj["owner"] = cell.usernameBtn.titleLabel?.text
            complainObj.saveInBackground(block: { (success, error) in
                if success{
                
                   self.alert(title: "Complain has been made successfully", message: "Thank you! We will consider your complain.")
                
                }else{
                
                    self.alert(title: "ERROR", message: error!.localizedDescription)
                }
            })
            tableView.setEditing(false, animated: true)
            
        }
        
        //button background
        
        delete.backgroundColor = UIColor(patternImage: UIImage(named: "delete.png")!)
        address.backgroundColor = UIColor(patternImage: UIImage(named: "address.png")!)
        complain.backgroundColor = UIColor(patternImage: UIImage(named: "complain.png")!)
        
        //comment belongs to user
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username{
            return [delete,address]
        
        }
        //post belong to user
        else if commentowner.last == PFUser.current()?.username{
        
            return [delete, address, complain]
        }
        
        //post belong to another user
        else{
        
            return [address, complain]
        }
        
    }
    
    //alter func
    func alert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "ok", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    //go back
    func back(sender : UIBarButtonItem){
    
        //push back
         self.navigationController?.popViewController(animated: true)
        //clean comment uuid from last holding information
        if !commentuuid.isEmpty{
        
            commentuuid.removeLast()
        }
    
        //clean comment owner from last holding information
        if !commentowner.isEmpty{
        
            commentowner.removeLast()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    

}
