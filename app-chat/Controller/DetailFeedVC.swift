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
    @IBOutlet weak var imageProfileUser: UIImageView!
    @IBOutlet weak var emailUserLBL: UILabel!
    @IBOutlet weak var detailContent: UITextView!
    @IBOutlet weak var btnDeteleFeed: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailContent.text = detailFeed?.content
        imageProfileUser.layer.cornerRadius = 25
        imageProfileUser.layer.masksToBounds = true
        DataService.instance.getUserName(withUid: detailFeed!.senderId, handler: { (resultUsername) in
            self.emailUserLBL.text = resultUsername
            if Auth.auth().currentUser?.email == resultUsername {
                self.btnDeteleFeed.isHidden = false
                //self.detailContent.isEditable = true
            }
        })
        DataService.instance.getUserImage(withUid: Auth.auth().currentUser!.uid) { (image, error) in
            if error != nil {
                print(error)
            } else {
                self.imageProfileUser.image = image
            }
        }
    }
    func getDetailFeed(message: Message){
        self.detailFeed = message
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
