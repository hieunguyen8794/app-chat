//
//  fetchFbData.swift
//  app-chat
//
//  Created by hieungq on 4/20/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class fbData {
    static let instance = fbData()

    func fetchUserData(imageView: UIImageView) {
        let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, email, name, picture.width(360).height(360)"])
        graphRequest.start(completionHandler: { (connection, result, error) in
            if error != nil {
                print("Error",error!.localizedDescription)
            }
            else{
                print(result!)
                let field = result! as? [String:Any]
                //self.userNameLabel.text = field!["name"] as? String
                if let imageURL = ((field!["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                    print(imageURL)
                    let url = URL(string: imageURL)
                    let data = NSData(contentsOf: url!)
                    let image = UIImage(data: data! as Data)
                    imageView.image = image
                    imageView.layer.cornerRadius = imageView.frame.height / 2
                    imageView.layer.masksToBounds = true
                }
            }
        })
    }
}
