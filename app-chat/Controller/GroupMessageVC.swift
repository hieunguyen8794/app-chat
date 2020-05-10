//
//  GroupMessage.swift
//  app-chat
//
//  Created by hieungq on 5/4/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit
import Firebase
class GroupMessageVC: UIViewController {

    var group:Group?
    var messageArray = [Message]()
    let topView = UIView()
    let tableView = UITableView()
    var viewSendBtnBottomConstrain:NSLayoutConstraint?
    let messageTextField : UITextField = {
        let messTf = InsetTextField()
        messTf.placeholder = "Type your message"
        return messTf
    }()
    
    let viewSendBtn : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.2846882589, green: 0.303610295, blue: 0.3337724414, alpha: 1)
        return view
    }()
    let sendBtn: UIButton = {
        let sendBtn = UIButton()
        sendBtn.setImage(UIImage(named: "send"), for: .normal)
        return sendBtn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopView()
        setupTextField()
        setupTableView()
        tableView.register(GroupMessageCell.self, forCellReuseIdentifier: "GroupMessageCell")
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataService.instance.REF_GROUPS.observe(.value) { (resultData) in
            DataService.instance.getAllMessageGroup(forGroup: self.group!) { (messageArray) in
                self.messageArray = messageArray
                self.tableView.reloadData()
                if self.messageArray.count > 0  {
                    self.tableView.scrollToRow(at: IndexPath(row: self.messageArray.count - 1, section: 0), at: .none, animated: true)
                }
            }
        }
//        messageTextField.becomeFirstResponder()
    }
    func initData(forGroup group: Group){
        self.group = group
    }
    
    func setupTopView(){
        view.addSubview(topView)
        topView.backgroundColor = #colorLiteral(red: 0.1335376501, green: 0.1437028348, blue: 0.1589070857, alpha: 1)
        topView.translatesAutoresizingMaskIntoConstraints = false
        let topViewConstrains = [topView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                                 topView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                                 topView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                                 topView.heightAnchor.constraint(equalToConstant: 130)]
        NSLayoutConstraint.activate(topViewConstrains)
        
        let labelTitle = UILabel()
        topView.addSubview(labelTitle)
        labelTitle.text = group?.title
        labelTitle.textColor = #colorLiteral(red: 0.2246118883, green: 0.869918648, blue: 0.3916975, alpha: 0.495956206)
        labelTitle.font = UIFont(name: "Menlo-Bold", size: 25)
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        let labelTitleConstrains = [labelTitle.centerXAnchor.constraint(equalTo: topView.centerXAnchor, constant: 0),
                                    labelTitle.topAnchor.constraint(equalTo: topView.topAnchor, constant: 70)
        ]
        NSLayoutConstraint.activate(labelTitleConstrains)
        
        let backBtn = UIButton()
        topView.addSubview(backBtn)
        backBtn.setImage(UIImage(named: "backIcon"), for: .normal)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        let backBtnContrains = [
            backBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            backBtn.centerYAnchor.constraint(equalTo: labelTitle.centerYAnchor, constant: 0),
            backBtn.heightAnchor.constraint(equalToConstant: 50),
            backBtn.widthAnchor.constraint(equalToConstant: 50)
        ]
        NSLayoutConstraint.activate(backBtnContrains)
        backBtn.addTarget(self, action: #selector(backBtnWasPressed(sender:)), for: .touchUpInside)
    }
    @objc func backBtnWasPressed(sender: UIButton!){
        dismiss(animated: true, completion: nil)
    }
    func setupTableView(){
        view.addSubview(tableView)
        tableView.backgroundColor = #colorLiteral(red: 0.1869209111, green: 0.2056120634, blue: 0.2248058021, alpha: 1)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let tableViewConstrains = [
            tableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: viewSendBtn.topAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(tableViewConstrains)
        tableView.separatorStyle = .none
    }
    func setupTextField() {
        view.addSubview(viewSendBtn)
        let viewSendBtnConstrains = [
            viewSendBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewSendBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewSendBtn.heightAnchor.constraint(equalToConstant: 50)
        ]
        viewSendBtn.translatesAutoresizingMaskIntoConstraints = false
        viewSendBtnBottomConstrain = viewSendBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        viewSendBtnBottomConstrain?.isActive = true
        NSLayoutConstraint.activate(viewSendBtnConstrains)
        
        
        viewSendBtn.addSubview(messageTextField)
        viewSendBtn.addSubview(sendBtn)
        let messageTextFieldConstrains = [
            messageTextField.topAnchor.constraint(equalTo: viewSendBtn.topAnchor),
            messageTextField.leadingAnchor.constraint(equalTo: viewSendBtn.leadingAnchor),
            messageTextField.trailingAnchor.constraint(equalTo: messageTextField.trailingAnchor),
            messageTextField.bottomAnchor.constraint(equalTo: viewSendBtn.bottomAnchor)
        ]
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(messageTextFieldConstrains)
        
        let sendBtnConstrain = [
            sendBtn.topAnchor.constraint(equalTo: viewSendBtn.topAnchor),
            sendBtn.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor),
            sendBtn.bottomAnchor.constraint(equalTo: viewSendBtn.bottomAnchor),
            sendBtn.trailingAnchor.constraint(equalTo: viewSendBtn.trailingAnchor),
            sendBtn.widthAnchor.constraint(equalToConstant: 80)
        ]
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(sendBtnConstrain)
        sendBtn.addTarget(self, action: #selector(sendBtnWasPressed), for: .touchUpInside)
    }
    @objc func keyboardWillChangeFrame(_ notification: NSNotification){
        if let userInfo = notification.userInfo{
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
//            print(isKeyboardShowing)
            viewSendBtnBottomConstrain?.constant = isKeyboardShowing ? -keyboardFrame.height : 0
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (complete) in
                if isKeyboardShowing && self.messageArray.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: self.messageArray.count - 1, section: 0), at: .none, animated: true)
                }
            }
        }
    }
    @objc func sendBtnWasPressed(){
        if messageTextField.text != "" {
           self.sendBtn.isEnabled = true
           DataService.instance.uploadPost(withMessage: messageTextField.text!, forUser: (Auth.auth().currentUser?.uid)!, withGroup: group?.key) { (complete) in
               if complete {
                   self.messageTextField.text = ""
               }
           }
       }
    }
}
extension GroupMessageVC : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMessageCell") as? GroupMessageCell else { return UITableViewCell() }
        cell.messageCell.text = messageArray[indexPath.row].content
        cell.selectionStyle = .none
        if self.messageArray[indexPath.row].senderId == Auth.auth().currentUser?.uid {
               cell.isComing = false
               cell.userName.text = Auth.auth().currentUser?.email
           } else {
               cell.isComing = true
               DataService.instance.getUserName(withUid: self.messageArray[indexPath.row].senderId, handler: { (resultEmail) in
                   cell.userName.text = resultEmail
               })
        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messageTextField.endEditing(true)
    }
    
}
