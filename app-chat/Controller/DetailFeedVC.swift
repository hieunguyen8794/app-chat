//
//  DetailFeedVC.swift
//  app-chat
//
//  Created by hieungq on 4/22/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FBSDKLoginKit
//import FirebaseAuth

class DetailFeedVC: UIViewController {
    public var detailFeed: Message?
    public var likeData: [String]?
    public var commentData = [Message]()

    @IBOutlet weak var numberOfLike: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var imageProfileUser: UIImageView!
    @IBOutlet weak var emailUserLBL: UILabel!
    @IBOutlet weak var detailContent: UILabel!
    @IBOutlet weak var btnDeteleFeed: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var commentView:UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.2857607901, green: 0.3037998676, blue: 0.3347896338, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var commentTextFieldBottomConstrain: NSLayoutConstraint?
    var commentTf:UITextField = {
        let cmttf = InsetTextField()
        cmttf.placeholder = "Type your comment"
        cmttf.translatesAutoresizingMaskIntoConstraints = false
        return cmttf
    }()
    let sendBtn: UIButton = {
        let sendBtn = UIButton()
        sendBtn.setImage(UIImage(named: "send"), for: .normal)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        return sendBtn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailContent.text = detailFeed?.content
        imageProfileUser.layer.cornerRadius = 25
        imageProfileUser.layer.masksToBounds = true
        
        emailUserLBL.isUserInteractionEnabled = true
        emailUserLBL.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToProfile)))
        imageProfileUser.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToProfile)))
        imageProfileUser.isUserInteractionEnabled = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.instance.getUserName(withUid: detailFeed!.senderId, handler: { (resultUsername) in
            self.emailUserLBL.text = resultUsername
            if Auth.auth().currentUser?.email == resultUsername {
                self.btnDeteleFeed.isHidden = false
                //self.detailContent.isEditable = true
            }
        })
        DataService.instance.getUserImage(withUid: detailFeed!.senderId) { (image, error) in
            if error != nil {
                print(error!)
            } else {
                self.imageProfileUser.image = image
            }
        }
        DataService.instance.REF_FEED.child(detailFeed!.keyFeed).observe(.value) { (DataSnapshot) in
            DataService.instance.getLikeFeed(withKey: self.detailFeed!.keyFeed) { (resultData) in
                let numberLike = resultData.count
                if numberLike != 0 {
                    self.numberOfLike.text = "\(numberLike) likes"
                } else {
                    self.numberOfLike.text = ""
                }
                if resultData.contains(Auth.auth().currentUser!.uid) {
                    self.likeBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        tableView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.onDrag
        setupCommentTf()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataService.instance.REF_FEED.observe(.value) { (DataSnapshot) in
            DataService.instance.getCommetFeed(withKey: self.detailFeed!.keyFeed) { (resultComment) in
                self.commentData = resultComment
                self.tableView.reloadData()
            }
        }
        setupHeightHeader()
    }
    func setupHeightHeader(){
        let message = detailFeed?.content
        let widthOfMainContent = view.frame.width - 8 - 8
        let size = CGSize(width: widthOfMainContent, height: 1000)
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Menlo", size: 16)]
        let estimatedFrame = NSString(string: message!).boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: estimatedFrame.height + 128)
    }
    func setupCommentTf(){
        view.addSubview(commentView)
        let commentViewConstrains = [
            commentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            commentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            commentView.heightAnchor.constraint(equalToConstant: 50)
        ]
        NSLayoutConstraint.activate(commentViewConstrains)
        commentTextFieldBottomConstrain = commentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        commentTextFieldBottomConstrain!.isActive = true
        
        commentView.addSubview(commentTf)
        let commentTFConstrains = [
            commentTf.leadingAnchor.constraint(equalTo: commentView.leadingAnchor, constant: 0),
            commentTf.topAnchor.constraint(equalTo: commentView.topAnchor, constant: 0),
            commentTf.bottomAnchor.constraint(equalTo: commentView.bottomAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(commentTFConstrains)
        
        commentView.addSubview(sendBtn)
        let sendBtnConstrain = [
                   sendBtn.topAnchor.constraint(equalTo: commentView.topAnchor),
                   sendBtn.leadingAnchor.constraint(equalTo: commentTf.trailingAnchor),
                   sendBtn.bottomAnchor.constraint(equalTo: commentView.bottomAnchor),
                   sendBtn.trailingAnchor.constraint(equalTo: commentView.trailingAnchor),
                   sendBtn.widthAnchor.constraint(equalToConstant: 80)
               ]
       NSLayoutConstraint.activate(sendBtnConstrain)
       sendBtn.addTarget(self, action: #selector(sendBtnWasPressed), for: .touchUpInside)
    }
    func getDetailFeed(message: Message){
        self.detailFeed = message
    }
    @objc func sendBtnWasPressed(){
        if commentTf.text != "" {
           self.sendBtn.isEnabled = true
            DataService.instance.uploadComment(withMessage: commentTf.text!, forUser: Auth.auth().currentUser!.uid, forFeed: detailFeed!.keyFeed) { (result) in
                if result {
                    self.commentTf.text = ""
                    self.commentTf.endEditing(true)
                    print("done")
                }
            }
       }
    }
    
    @IBAction func likeBtnWasPressed(_ sender: Any) {
        DataService.instance.uploadLike(forFeed: detailFeed!.keyFeed) { (result) in
            if result {
                self.likeBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            } else {
                self.likeBtn.setImage(UIImage(systemName: "heart"), for: .normal)
            }
        }
    }
    @IBAction func commentBtnWasPressed(_ sender: Any) {
        commentTf.becomeFirstResponder()
    }
    @objc func keyboardWillChangeFrame(_ notification: NSNotification){
        if let userInfo = notification.userInfo{
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            commentTextFieldBottomConstrain?.constant = isKeyboardShowing ? -keyboardFrame.height : 0
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (complete) in
                if isKeyboardShowing && self.commentData.count > 0 {
//                    let autolayout = NSLayoutConstraint.init(item: self.tableView, attribute: .bottom, relatedBy: .equal, toItem: self.commentView, attribute: .top, multiplier: 1, constant: 0)
//                    autolayout.isActive = true
                    
                    self.tableView.scrollToRow(at: IndexPath(row: self.commentData.count - 1, section: 0), at: .none, animated: true)
                }
            }
        }
    }
    @IBAction func backBtnWasPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func moveToProfile() {
        print("moveToProfileFromDetailVC")
    }
    @IBAction func deleteBtnWasPressed(_ sender: Any) {
        let alertDelete = UIAlertController(title: "Alert", message: "Do you want to delete this _feed?", preferredStyle: .actionSheet)
        let okeAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            print("deleting...")
            DataService.instance.removeFeedMessage(forKey: self.detailFeed!.keyFeed) { (result,error) in
                if result {
                    print("Successfully delete feed")
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print(error!.localizedDescription)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) in
            print("canceling...")
        }
        alertDelete.addAction(okeAction)
        alertDelete.addAction(cancelAction)
        self.present(alertDelete, animated: true) {
            print("presented")
        }
    }
    
}
extension DetailFeedVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commentDataCell = commentData[indexPath.row]
        var emailUser:String?
        DataService.instance.getUserName(withUid: commentDataCell.senderId) { (userName) in
            emailUser = userName
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as? CommentCell  else  { return UITableViewCell()}
        DataService.instance.getUserImage(withUid: commentDataCell.senderId) { (image, error) in
            if error != nil {
                print("error")
            } else {
                cell.configureCell(imageProfile: image!, content: commentDataCell.content, email: emailUser!, timeStamp: commentDataCell.timeStamp)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = commentData[indexPath.row]
        let widthOfMainContent = view.frame.width - 32 - 8 - 8
        let size = CGSize(width: widthOfMainContent, height: 1000)
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Menlo", size: 12)]
        let estimatedFrame = NSString(string: message.content).boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        return estimatedFrame.height + 80
    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        let message = detailFeed?.content
//        let widthOfMainContent = view.frame.width - 8 - 8
//        let size = CGSize(width: widthOfMainContent, height: 1000)
//        let attributes = [NSAttributedString.Key.font : UIFont(name: "Menlo", size: 16)]
//        let estimatedFrame = NSString(string: message!).boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
//        print(estimatedFrame.height)
//        return estimatedFrame.height + 200
//    }
}
