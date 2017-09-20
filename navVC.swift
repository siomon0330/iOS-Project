//
//  navVC.swift

//
//  Created by Simon on 8/15/17.
//  Copyright © 2017 Simon. All rights reserved.
//

import UIKit

class navVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //color of title at top
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        //color of buttons in nav controller
        self.navigationBar.tintColor = UIColor.white
        
        //color of background of nav controller
        self.navigationBar.barTintColor = UIColor(colorLiteralRed: 15/255.0, green: 99.0/255.0, blue: 164.0/255.0, alpha: 1)
        
        //unable translucent
        self.navigationBar.isTranslucent = false
        
    }

    //while status bar functions
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }










}
