//
//  FirstViewController.swift
//  app-chat
//
//  Created by hieungq on 4/3/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit
import Firebase
class FeedVC: UIViewController ,UIAdaptivePresentationControllerDelegate, UIGestureRecognizerDelegate{
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var barView: UITabBarItem!
    @IBOutlet weak var tableView: UITableView!
    var lastContentOffset: CGFloat = 0
    
    var messageArray = [Message]()
    var headerView:UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1234754696, green: 0.128762424, blue: 0.1390718222, alpha: 1)
        return view
    }()
    var titleLbl:UILabel = {
        let label = UILabel()
        label.text = "_feed"
        label.textColor = #colorLiteral(red: 0.2039215686, green: 0.7803921569, blue: 0.3490196078, alpha: 0.495956206)
        label.font = UIFont(name: "Menlo-Bold", size: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var createPostBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "compose"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(presentCreatePostVC), for: .touchUpInside)
        return btn
        
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FeedCell.self, forCellReuseIdentifier: "feedCell")
        
        setupHeader()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DataService.instance.REF_FEED.observe(.value) { (DataSnapshot) in
            DataService.instance.getAllFeedMessage { (returnMessageArray) in
                self.messageArray = returnMessageArray.reversed()
                self.tableView.reloadData()
            }
        }
        tableView.separatorStyle = .none
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func setupHeader(){
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 56)
        tableView.addSubview(self.headerView)
        
        
        headerView.addSubview(titleLbl)
        titleLbl.centerXAnchor.constraint(equalTo: self.headerView.centerXAnchor).isActive = true
        titleLbl.bottomAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: -16).isActive = true
        
        headerView.addSubview(createPostBtn)
        createPostBtn.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -16).isActive = true
        createPostBtn.bottomAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: -16).isActive = true
        createPostBtn.heightAnchor.constraint(equalToConstant: 32).isActive = true
        createPostBtn.widthAnchor.constraint(equalToConstant: 32).isActive = true
    }
    @objc func presentCreatePostVC(){
        guard let createPostVC = self.storyboard?.instantiateViewController(withIdentifier: "CreatePostVC") else { return }
        self.present(createPostVC, animated: true, completion: nil)
    }

}
extension FeedVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell") as? FeedCell else {return UITableViewCell()}
        let message = messageArray[indexPath.row]
        cell.selectionStyle = .none
        var numberLike = Int()
        DataService.instance.REF_FEED.child(message.keyFeed).observe(.value) { (DataSnapshot) in
            DataService.instance.getLikeFeed(withKey: message.keyFeed) { (resultData) in
                numberLike = resultData.count
                if resultData.contains(Auth.auth().currentUser!.uid) {
                    cell.likeBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                } else {
                    cell.likeBtn.setImage(UIImage(systemName: "heart"), for: .normal)
                }
            }
        }
        DataService.instance.getUserImage(withUid: message.senderId) { (image, error) in
            if error != nil {
                print(error!)
            }
            DataService.instance.getUserName(withUid: message.senderId) { (resultUserName) in
                DispatchQueue.main.async {
                    cell.configure(imageView: image!, userMail: resultUserName, message: message.content,timeStamp: message.timeStamp,numberOfLike: numberLike)
                }
            }
        }
        cell.actionBlock = {
            let profileView = ProfileView()
            profileView.initData(withUID: message.senderId)
            self.view.addSubview(profileView)
            
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged))
            profileView.addGestureRecognizer(gesture)
            profileView.isUserInteractionEnabled = true
            gesture.delegate = self
            
            let profileViewConstrains = [
                profileView.topAnchor.constraint(equalTo: self.mainView!.topAnchor,constant: 0),
                profileView.leadingAnchor.constraint(equalTo: self.mainView!.leadingAnchor,constant: 0),
                profileView.bottomAnchor.constraint(equalTo: self.mainView!.bottomAnchor,constant: 0),
                profileView.trailingAnchor.constraint(equalTo: self.mainView!.trailingAnchor,constant: 0)
            ]
            profileView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(profileViewConstrains)
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                profileView.center.x -= self.view.bounds.width
            }) { (complete) in
                
            }
        }
        cell.actionMoveToPost = {
            let feedDetail = self.messageArray[indexPath.row]
            guard let detailFeedVC = self.storyboard?.instantiateViewController(identifier: "DetailFeedVC") as? DetailFeedVC else { return }
            detailFeedVC.getDetailFeed(message: feedDetail)
          
            self.present(detailFeedVC, animated: true, completion: nil)
                      
        }
        cell.likeFeed = {
            DataService.instance.uploadLike(forFeed: message.keyFeed) { (result) in
                if result {
                    cell.likeBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                } else {
                    cell.likeBtn.setImage(UIImage(systemName: "heart"), for: .normal)
                }
            }
        }
        return cell
    }
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began , .changed:
            let translation = gestureRecognizer.translation(in: self.view)
            let centerXOfView = gestureRecognizer.view!.center.x
            //print(gestureRecognizer.view!.center.x)
            
            if(centerXOfView >= view.frame.width / 2) {
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y)

            }
            gestureRecognizer.setTranslation(CGPoint(x: 0,y: 0), in: self.view)
        case .ended:
            print("ended")
            if(gestureRecognizer.view!.center.x < view.frame.width) {
                gestureRecognizer.view!.center = CGPoint(x: view.frame.width / 2, y: gestureRecognizer.view!.center.y)
            } else {
                gestureRecognizer.view!.center = CGPoint(x: view.frame.width * 1.5, y: gestureRecognizer.view!.center.y)
                gestureRecognizer.view!.removeFromSuperview()
            }
        case .cancelled, .failed:
            print("cancelled - failed")
        default:
            break
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feedDetail = messageArray[indexPath.row]
        guard let detailFeedVC = storyboard?.instantiateViewController(identifier: "DetailFeedVC") as? DetailFeedVC else { return }
        detailFeedVC.getDetailFeed(message: feedDetail)
        present(detailFeedVC, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messageArray[indexPath.row]
        let widthOfMainContent = view.frame.width - 16 - 16
        let size = CGSize(width: widthOfMainContent, height: 1000)
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Menlo", size: 12)]
        let estimatedFrame = NSString(string: message.content).boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        
        //print(estimatedFrame.height)
        return estimatedFrame.height + 140
    }
 
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    // set properti table -> group -> have a  
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return -20
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let safeAreaTop = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0
        let offset = scrollView.contentOffset.y
        //        if(offset > 50){
        //            topViewTitle.frame = CGRect(x: 0, y: offset - 50, width: self.view.bounds.size.width, height: 100)
        //        }else{
        //            topViewTitle.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 100)
        //        }
        
//        if self.lastContentOffset < scrollView.contentOffset.y {
//            // did move up
//        } else if self.lastContentOffset > scrollView.contentOffset.y {
//            // did move down
//        } else {
//            // didn't move
//        }
        // fade out fade in
        let alpha: CGFloat = 2 - (safeAreaTop + offset) / safeAreaTop
        self.titleLbl.alpha =  alpha
        self.createPostBtn.alpha = alpha
    }

    
}


