//
//  commentCell.swift
//  app-chat
//
//  Created by hieungq on 5/19/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var mainContent: UILabel!
    @IBOutlet weak var timeContent: UILabel!
    
    func configureCell(imageProfile: UIImage,content: String, email: String, timeStamp: NSNumber){
        self.profileImage.image = imageProfile
        self.profileImage.layer.cornerRadius = 32
        self.profileImage.layer.masksToBounds = true
        
        self.mainContent.text = content
        self.userEmail.text = email
        
        // setup - lastTimeMessage label
        let timeStampData = NSDate(timeIntervalSince1970: timeStamp.doubleValue)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm dd/MM"

        timeContent.text = dateFormatter.string(from: timeStampData as Date)

    }
    
}
