//
//  CreatePostVC.swift
//  app-chat
//
//  Created by hieungq on 4/20/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit
import Firebase
class CreatePostVC: UIViewController {
    var window: UIWindow?
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var contentTV: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTV.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userEmail.text = Auth.auth().currentUser?.email
        sendBtn.isEnabled = true
//        sendBtn.isHidden = true
        userImage.layer.cornerRadius = 25
        userImage.layer.masksToBounds = true
        DataService.instance.getUserImage(withUid: Auth.auth().currentUser!.uid) { (image, error) in
            if error != nil {
                print(error!)
            } else {
                self.userImage.image = image
            }
        }
        
    }
    @IBAction func sendBtnWasPressed(_ sender: Any) {
        if contentTV.text != "" && contentTV.text != "Write something ...." {
            sendBtn.isEnabled = false
            DataService.instance.uploadPost(withMessage: contentTV.text, forUser: Auth.auth().currentUser!.uid, withGroup: nil) { (result) in
                if result {
                    //print("Successfully+ \(Auth.auth().currentUser!.uid)")
                    self.sendBtn.isEnabled = true
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.sendBtn.isEnabled = true
                    print("error")
                }
            }
        } 
    }
}
extension CreatePostVC: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        contentTV.text = ""
//        sendBtn.isHidden = false
    }
}
