//
//  GroupMessageCell.swift
//  app-chat
//
//  Created by hieungq on 5/4/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit
import Firebase
class GroupMessageCell: UITableViewCell {

    let messageCell = UILabel()
    let bubbleBackgroundView = UIView()
    let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "defaultProfileImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    let userName = UILabel()
    
    var messageCellLeadingConstrain: NSLayoutConstraint!
    var messageCellTrailingConstrain: NSLayoutConstraint!
    var profileImageLeadingConstrain: NSLayoutConstraint!
    var profileImageTrailingConstrain: NSLayoutConstraint!
    
    var userNameLeadingConstrain:NSLayoutConstraint!
    var userNameTrailingConstrain:NSLayoutConstraint!

    var messageCellTopConstrainOfIsComing:NSLayoutConstraint!
    var messageCellTopConstrainOfIsNotComing:NSLayoutConstraint!
    
    var nextMessage: Bool?
    
    
    var isComing: Bool! {
        didSet {
                bubbleBackgroundView.backgroundColor = isComing ? .white : .darkGray
                messageCell.textColor = isComing ? .black : .white
                messageCellLeadingConstrain.isActive = false
                messageCellTrailingConstrain.isActive = false
                profileImageLeadingConstrain.isActive = false
                userNameLeadingConstrain.isActive = false
            
                messageCellTopConstrainOfIsComing.isActive = false
                messageCellTopConstrainOfIsNotComing.isActive = false
            
                if isComing {
                    profileImageLeadingConstrain.isActive = true
                    messageCellLeadingConstrain.isActive = true
                    messageCellTrailingConstrain.isActive = false
                    userNameLeadingConstrain.isActive = true
                    
                    userName.isHidden = false
                    profileImage.isHidden = false
                    
                    messageCellTopConstrainOfIsComing.isActive = true
                    messageCellTopConstrainOfIsNotComing.isActive = false
                } else {
                    profileImageLeadingConstrain.isActive = false
                    messageCellLeadingConstrain.isActive = false
                    messageCellTrailingConstrain.isActive = true
                    userNameLeadingConstrain.isActive = false
                    
                    userName.isHidden = true
                    profileImage.isHidden = true
                    
                    
                    messageCellTopConstrainOfIsNotComing.isActive = true
                    messageCellTopConstrainOfIsComing.isActive = false
                }
            }
    }
    
    func configureCell(withMessage  message: Message,withNextMessageComing nextMessage: Bool,withFirstGroupMessage firstMessage: Bool){
        messageCell.text = message.content
        
        self.nextMessage = nextMessage
        
        if message.senderId == Auth.auth().currentUser?.uid {
               self.isComing = false
               self.userName.text = Auth.auth().currentUser?.email
           } else {
               self.isComing = true
               DataService.instance.getUserName(withUid: message.senderId, handler: { (resultEmail) in
                   self.userName.text = resultEmail
               })
        }
        DataService.instance.getUserImage(withUid: message.senderId) { (image, error) in
            if error != nil {
                print(error!)
            } else if nextMessage == false {
                self.profileImage.image = nil
            } else {
                self.profileImage.image = image
            }
        }
        if firstMessage != false {
            messageCellTopConstrainOfIsComing.constant = 48
            messageCellTopConstrainOfIsNotComing.constant = 48
        } else {
            messageCellTopConstrainOfIsComing.constant = 16
            messageCellTopConstrainOfIsNotComing.constant = 16
        }
    }
    var actionBlock = { }
    @objc func moveToProfile() {
       actionBlock()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(userName)
        userName.text = "username@gmail.com"
        userName.font = UIFont(name: "Menlo", size: 13)
        userName.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7447827483)

        addSubview(profileImage)
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToProfile)))
        profileImage.isUserInteractionEnabled = true

        backgroundColor = .clear
        addSubview(bubbleBackgroundView)

        addSubview(messageCell)
        let messageCellConstrain = [
            messageCell.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            messageCell.widthAnchor.constraint(lessThanOrEqualToConstant: 250)
        ]
        messageCell.numberOfLines = 0
        messageCell.translatesAutoresizingMaskIntoConstraints = false
        messageCell.font = UIFont(name: "Menlo", size: 12)
        NSLayoutConstraint.activate(messageCellConstrain)
        
        let bubbleBackgroundViewConstrains = [
            bubbleBackgroundView.topAnchor.constraint(equalTo: messageCell.topAnchor, constant: -16),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageCell.leadingAnchor, constant: -16),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageCell.bottomAnchor, constant: 16),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageCell.trailingAnchor, constant: 16),
        ]
        bubbleBackgroundView.layer.cornerRadius = 16
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(bubbleBackgroundViewConstrains)
       
     
        
        let profileImageConstrains = [
            profileImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            profileImage.heightAnchor.constraint(equalToConstant: 20),
            profileImage.widthAnchor.constraint(equalToConstant: 20),
        ]
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(profileImageConstrains)
        
        
        let userNameConstrains = [
            userName.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            userName.bottomAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 5),
            userName.widthAnchor.constraint(lessThanOrEqualToConstant: 250)
        ]
        userName.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(userNameConstrains)

        userNameLeadingConstrain = userName.leadingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: 0)

        profileImageLeadingConstrain = profileImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
              
        messageCellLeadingConstrain = messageCell.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 32)
        messageCellTrailingConstrain = messageCell.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        
        
        messageCellTopConstrainOfIsComing = messageCell.topAnchor.constraint(equalTo: self.topAnchor, constant: 16)
        messageCellTopConstrainOfIsNotComing = messageCell.topAnchor.constraint(equalTo: self.topAnchor, constant: 16)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
