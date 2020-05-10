//
//  GroupFeedVC.swift
//  app-chat
//
//  Created by hieungq on 4/30/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit
import Firebase

class GroupFeedVC: UIViewController {
    
    var group:Group?
    var messageArray = [Message]()
    
    @IBOutlet weak var bottomConstrain: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var viewSendBtn: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupTitleLbl: UILabel!
    //@IBOutlet weak var test: UIView! hold tableview + viewsendBtn is not working
    //stackview is not working
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @objc func keyboardWillShowNotification(_ notification: NSNotification){
        if let userInfor = notification.userInfo {
            let keyboardFrame = (userInfor[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            print(isKeyboardShowing)
            bottomConstrain.constant = isKeyboardShowing ? keyboardFrame.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (complete) in
                if isKeyboardShowing {
                    self.tableView.scrollToRow(at: IndexPath(row: self.messageArray.count - 1, section: 0), at: .none, animated: true)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.groupTitleLbl.text = group?.title
        
        DataService.instance.REF_GROUPS.observe(.value) { (DataSnapshot) in
            DataService.instance.getAllMessageGroup(forGroup: self.group!) { (messageArray) in
                self.messageArray = messageArray
                self.tableView.reloadData()
                
                if self.messageArray.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: self.messageArray.count - 1, section: 0), at: .none, animated: true)
                }
            }
        }
    }
    func initData(forGroup group: Group){
        self.group = group
    }
    @IBAction func sendBtnWasPressed(_ sender: Any) {
        if messageTextField.text != "" {
            self.sendBtn.isEnabled = true
            DataService.instance.uploadPost(withMessage: messageTextField.text!, forUser: (Auth.auth().currentUser?.uid)!, withGroup: group?.key) { (complete) in
                if complete {
                    self.messageTextField.text = ""
                }
            }
        }
    }
    
    @IBAction func backBtnWasPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension GroupFeedVC: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupFeedCell") as? GroupFeedCell else { return UITableViewCell() }
        let imageProfile = UIImage(named: "defaultProfileImage")!
        let message = messageArray[indexPath.row]
        DataService.instance.getUserName(withUid: message.senderId) { (resultUserName) in
            cell.configureCell(imageProfile: imageProfile, content: message.content, email: resultUserName)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messageTextField.endEditing(true)
    }
    
}
