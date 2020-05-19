//
//  FeedCell.swift
//  app-chat
//
//  Created by hieungq on 4/21/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {
    
    
    let profileImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 25
        image.layer.masksToBounds = true
        return image
    }()
    let userName: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 18)
        label.text = "123"
        label.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let timeStampLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo", size: 12)
        label.text = "13:06:2020 08:00"
        label.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let mainContent:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo", size: 12)
        label.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1869209111, green: 0.2056120634, blue: 0.2248058021, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let likeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let commentBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let likeNumber: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo", size: 12)
        label.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style,reuseIdentifier: reuseIdentifier)
        backgroundColor = #colorLiteral(red: 0.1817291081, green: 0.186937958, blue: 0.20142892, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var actionBlock = { }
    @objc func moveToProfile() {
        actionBlock()
    }
    var likeFeed = { }
    @objc func likeThatFeed() {
        likeFeed()
    }
    var actionMoveToPost = { }
    @objc func moveToPost(){
        actionMoveToPost()
    }
    
    func configure (imageView: UIImage,userMail: String,message: String,timeStamp: NSNumber,numberOfLike: Int){
        let timeStamp: NSNumber = timeStamp
        addSubview(profileImage)
        profileImage.image = imageView
        userName.text = userMail
        userName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToProfile)))
        userName.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToProfile)))
        profileImage.isUserInteractionEnabled = true
        likeBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(likeThatFeed)))
        likeBtn.isUserInteractionEnabled = true
        commentBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToPost)))
        commentBtn.isUserInteractionEnabled = true
        mainContent.text = message
        setupTimeStamp(timeStamp: timeStamp)
        if numberOfLike > 0 {
            likeNumber.text = "\(numberOfLike) likes"
        } else {
            likeNumber.text = ""
        }
        let profileImageContrains = [
            profileImage.topAnchor.constraint(equalTo: topAnchor,constant: 16),
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 16),
            profileImage.widthAnchor.constraint(equalToConstant: 48),
            profileImage.heightAnchor.constraint(equalToConstant: 48)
        ]
        NSLayoutConstraint.activate(profileImageContrains)
        
        addSubview(userName)
        let userNameConstrains = [
            userName.topAnchor.constraint(equalTo: topAnchor,constant: 16),
            userName.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor,constant: 16),
            userName.trailingAnchor.constraint(equalTo: trailingAnchor,constant: 16)
        ]
        NSLayoutConstraint.activate(userNameConstrains)
        
        addSubview(timeStampLbl)
        let timeStampConstrains = [
            timeStampLbl.topAnchor.constraint(equalTo: userName.bottomAnchor,constant: 8),
            timeStampLbl.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor,constant: 16),
            timeStampLbl.trailingAnchor.constraint(equalTo: trailingAnchor,constant: 16)
        ]
        NSLayoutConstraint.activate(timeStampConstrains)
        
        addSubview(mainContent)
        let mainContainConstrains = [
            mainContent.topAnchor.constraint(equalTo: profileImage.bottomAnchor,constant: 16),
            mainContent.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 16),
            mainContent.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -16)
        ]
        NSLayoutConstraint.activate(mainContainConstrains)
     
        addSubview(likeBtn)
        let likeBtnConstrains = [
            likeBtn.topAnchor.constraint(equalTo: mainContent.bottomAnchor, constant: 8),
            likeBtn.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 32)
        ]
        NSLayoutConstraint.activate(likeBtnConstrains)
        
        addSubview(commentBtn)
        let commentBtnConstrains = [
            commentBtn.topAnchor.constraint(equalTo: mainContent.bottomAnchor, constant: 8),
            commentBtn.leadingAnchor.constraint(equalTo: likeBtn.trailingAnchor,constant: 16)
        ]
        NSLayoutConstraint.activate(commentBtnConstrains)
        
        addSubview(likeNumber)
        let likeNumberConstrains = [
            likeNumber.topAnchor.constraint(equalTo: likeBtn.bottomAnchor, constant: 8),
            likeNumber.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
        ]
        NSLayoutConstraint.activate(likeNumberConstrains)
        
        addSubview(separatorView)
        let separatorViewConstrains = [
            separatorView.topAnchor.constraint(equalTo: likeNumber.bottomAnchor, constant: 8),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 0),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: 0),
            separatorView.heightAnchor.constraint(equalToConstant: 10)
        ]
        NSLayoutConstraint.activate(separatorViewConstrains)
    }
    func setupTimeStamp (timeStamp: NSNumber) {
        let timeStampData = NSDate(timeIntervalSince1970: timeStamp.doubleValue)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm dd/MM"
        
        timeStampLbl.text = dateFormatter.string(from: timeStampData as Date)
    }
    
    
}
