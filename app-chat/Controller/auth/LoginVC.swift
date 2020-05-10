//
//  LoginVC.swift
//  app-chat
//
//  Created by hieungq on 4/18/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailField: InsetTextField!
    @IBOutlet weak var passwordField: InsetTextField!
    @IBOutlet weak var errorLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
    }
    @IBAction func signInBtnWasPressed(_ sender: Any) {
        if emailField.text != nil && passwordField.text != nil {
            AuthService.instance.loginUserByMail(withEmail: emailField.text!, andPassword: passwordField.text!) { (loginUser, error) in
                if loginUser {
                    let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
                    self.present(mainVC!, animated: true, completion: nil)
                    print("Successfully login user")
                    return
                } else {
                    self.errorLable.isHidden = false
                    self.errorLable.text = error?.localizedDescription

                    self.emailField.endEditing(true)
                    self.passwordField.endEditing(true)
                    print(error?.localizedDescription as Any)
                }
            }
        }
    }
}

extension LoginVC: UITextFieldDelegate{
    
}
