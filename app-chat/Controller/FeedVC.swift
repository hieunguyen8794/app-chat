//
//  FirstViewController.swift
//  app-chat
//
//  Created by hieungq on 4/3/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit
import Firebase
class FeedVC: UIViewController ,UIAdaptivePresentationControllerDelegate{
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var barView: UITabBarItem!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var messageArray = [Message]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FeedCell.self, forCellReuseIdentifier: "feedCell")
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
        cell.actionBlock = {
            let profileView = ProfileView()
            profileView.initData(withUID: message.senderId)
            
            self.view.addSubview(profileView)
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
        return cell
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
        return estimatedFrame.height + 100
    }
    
}


