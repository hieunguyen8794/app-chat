//
//  GroupFeedCell.swift
//  app-chat
//
//  Created by hieungq on 4/30/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit

class GroupFeedCell: UITableViewCell {

    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var emailUserLbl: UILabel!
    @IBOutlet weak var imageProfile: UIImageView!
    
    func configureCell(imageProfile: UIImage,content: String, email: String){
        self.imageProfile.image = imageProfile
        self.contentLbl.text = content
        self.emailUserLbl.text = email
        
    }

}
