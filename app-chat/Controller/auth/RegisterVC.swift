//
//  RegisterVC.swift
//  app-chat
//
//  Created by hieungq on 4/22/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {

    @IBOutlet weak var emailTf: InsetTextField!
    @IBOutlet weak var passwordTf: InsetTextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTf.delegate = self
        passwordTf.delegate = self

    }
    @IBAction func signUpBtnWasPressed(_ sender: Any) {
        if emailTf.text != nil && passwordTf.text != nil {
            AuthService.instance.registerUser(withEmail: self.emailTf.text!, andPassword: self.passwordTf.text!) { (registerUser, error) in
                if registerUser {
                        let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
                        self.present(mainVC!, animated: true, completion: nil)
                        print("Successfully registered user")
                        self.emailTf.endEditing(true)
                        return
                } else {
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = error?.localizedDescription
                        self.emailTf.endEditing(true)
                        self.passwordTf.endEditing(true)
                        print(error?.localizedDescription as Any)
                }
            }
        }
    }
}
extension RegisterVC: UITextFieldDelegate{
    
}
