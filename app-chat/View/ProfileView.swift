//
//  ProfileVC.swift
//  app-chat
//
//  Created by hieungq on 5/11/20.
//  Copyright © 2020 hieungq. All rights reserved.
//


import UIKit
import Firebase

class ProfileView: UIView {

    let labelTitle = UILabel()
    let topView = UIView()
    let profileImage = UIImageView()
    let profileName = UILabel()
    let profileBio = UILabel()
    let separatorView = UIView()
    let tableView = UITableView()

    var messageArray = [Message]()
    
    var btnCancel: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(dismissProfileView), for: .touchUpInside)
        return btn
    }()
    @objc func dismissProfileView () {
        self.removeFromSuperview()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 0.1816827953, green: 0.1895715594, blue: 0.1993684471, alpha: 1)
        setupBtnCancel()
        setupTopView()
        setupProfileImage()
        setupProfileName()
        setupProfileBio()
        setupSeparator()
        setupTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FeedCell.self, forCellReuseIdentifier: "feedCell")
//        DataService.instance.REF_FEED.observe(.value) { (DataSnapshot) in
//            DataService.instance.getAllFeedWithUid(uid: "uid") { (messageArray) in
//                self.messageArray = messageArray.reversed()
//                self.tableView.reloadData()
//            }
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initData(withUID uid: String) {
        DataService.instance.getUserName(withUid: uid) { (userName) in
            self.labelTitle.text = userName
            self.profileName.text = userName
        }
        DataService.instance.getUserImage(withUid: uid) { (image,error) in
            self.profileImage.image = image
        }
        DataService.instance.getAllFeedWithUid(uid: uid) { (message) in
            self.messageArray = message.reversed()
            self.tableView.reloadData()
        }
    }
    func setupBtnCancel(){
        self.addSubview(btnCancel)
        let btnCancelConstrains = [
            btnCancel.topAnchor.constraint(equalTo: self.topAnchor, constant: 32),
            btnCancel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            btnCancel.heightAnchor.constraint(equalToConstant: 50),
            btnCancel.widthAnchor.constraint(equalToConstant: 50)
        ]
        NSLayoutConstraint.activate(btnCancelConstrains)
    }
    func setupTopView(){
        self.addSubview(topView)
        topView.backgroundColor = #colorLiteral(red: 0.1335376501, green: 0.1437028348, blue: 0.1589070857, alpha: 1)
        topView.translatesAutoresizingMaskIntoConstraints = false
        let topViewConstrains = [topView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
                                 topView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
                                 topView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
                                 topView.heightAnchor.constraint(equalToConstant: 100)]
        NSLayoutConstraint.activate(topViewConstrains)
        
        topView.addSubview(labelTitle)
        labelTitle.text = "123"
        labelTitle.textColor = #colorLiteral(red: 0.3336617947, green: 0.7598311305, blue: 0.969689548, alpha: 1)
        labelTitle.font = UIFont(name: "Menlo-Bold", size: 15)
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        let labelTitleConstrains = [labelTitle.centerXAnchor.constraint(equalTo: topView.centerXAnchor, constant: 0),
                                    labelTitle.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -16)
        ]
        NSLayoutConstraint.activate(labelTitleConstrains)
        
        let backBtn = UIButton()
        topView.addSubview(backBtn)
        backBtn.setImage(UIImage(named: "backIcon"), for: .normal)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        let backBtnContrains = [
            backBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            backBtn.centerYAnchor.constraint(equalTo: labelTitle.centerYAnchor, constant: 0),
            backBtn.heightAnchor.constraint(equalToConstant: 32),
            backBtn.widthAnchor.constraint(equalToConstant: 32)
        ]
        NSLayoutConstraint.activate(backBtnContrains)
        backBtn.addTarget(self, action: #selector(dismissProfileView), for: .touchUpInside)
    }
    func setupProfileImage(){
        self.addSubview(profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.layer.cornerRadius = 32
        profileImage.layer.masksToBounds = true
        profileImage.image = #imageLiteral(resourceName: "defaultProfileImage")
        
        let profileImageConstrains = [
            profileImage.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 16),
            profileImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImage.heightAnchor.constraint(equalToConstant: 96),
            profileImage.widthAnchor.constraint(equalToConstant: 96)
        ]
        NSLayoutConstraint.activate(profileImageConstrains)
    }
    func setupProfileName(){
        self.addSubview(profileName)
        profileName.translatesAutoresizingMaskIntoConstraints = false
        profileName.font = UIFont(name: "Menlo-Bold", size: 25)
        profileName.textColor = #colorLiteral(red: 0.3336617947, green: 0.7598311305, blue: 0.969689548, alpha: 1)
        profileName.text = "profile name"
        profileName.numberOfLines = 1
        profileName.minimumScaleFactor = 0.5
        profileName.adjustsFontSizeToFitWidth = true
        let profileNameConstrains = [
            profileName.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 16),
            profileName.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileName.widthAnchor.constraint(lessThanOrEqualToConstant: 250)
        ]
        NSLayoutConstraint.activate(profileNameConstrains)
    }
    func setupProfileBio(){
        self.addSubview(profileBio)
        profileBio.translatesAutoresizingMaskIntoConstraints = false
        profileBio.font = UIFont(name: "Menlo", size: 12)
        profileBio.textColor = #colorLiteral(red: 0.3336617947, green: 0.7598311305, blue: 0.969689548, alpha: 1)
        profileBio.text = "Aut viam inveniam aut faciam. Aut viam inveniam aut faciam. Aut viam inveniam aut faciam."
        profileBio.numberOfLines = 0
        profileBio.textAlignment = .center
        
        let profileBioConstrains = [
            profileBio.topAnchor.constraint(equalTo: profileName.bottomAnchor, constant: 16),
            profileBio.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileBio.widthAnchor.constraint(lessThanOrEqualToConstant: 250)
        ]
        NSLayoutConstraint.activate(profileBioConstrains)
    }
    func setupSeparator(){
        self.addSubview(separatorView)
        separatorView.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        let separatorVIewConstrains = [
            separatorView.topAnchor.constraint(equalTo: profileBio.bottomAnchor, constant: 16),
            separatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ]
        NSLayoutConstraint.activate(separatorVIewConstrains)
    }
    func setupTableView(){
        self.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let tableViewConstrains = [
            tableView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(tableViewConstrains)
    }
}
extension ProfileView: UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell") as? FeedCell else { return UITableViewCell()}
        
        if indexPath.row == 0 {
            
        }
        
        let message = messageArray[indexPath.row]
        cell.selectionStyle = .none
        DataService.instance.getUserImage(withUid: message.senderId) { (image, error) in
            if error != nil {
                print(error!)
            }
            DataService.instance.getUserName(withUid: message.senderId) { (resultUserName) in
                DispatchQueue.main.async {
                    cell.configure(imageView: image!, userMail: resultUserName, message: message.content,timeStamp: message.timeStamp)
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messageArray[indexPath.row]
        let widthOfMainContent = self.frame.width - 16 - 16
        let size = CGSize(width: widthOfMainContent, height: 1000)
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Menlo", size: 12)]
        let estimatedFrame = NSString(string: message.content).boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        
        //print(estimatedFrame.height)
        return estimatedFrame.height + 100
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
}
