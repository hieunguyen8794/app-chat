//
//  AuthVC.swift
//  app-chat
//
//  Created by hieungq on 4/18/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class AuthVC: UIViewController {

    @IBOutlet weak var loginFBBTN: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginByMailWasPressed(_ sender: Any) {
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC") else { return }
        present(loginVC, animated: true, completion: nil)
    }
   
    @IBAction func loginFbWasPressed(_ sender: Any) {
        AuthService.instance.loginUserByFacebook(uiviewController: self) { (result, error) in
            if result {
                let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
                self.present(mainVC!, animated: true, completion: nil)
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
}
