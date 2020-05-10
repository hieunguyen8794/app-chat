//
//  UserCell.swift
//  app-chat
//
//  Created by hieungq on 4/28/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {


    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    func configureCell(profileImage image : UIImage,emailLbl: String, isSelected: Bool){
        self.profileImage.image = image
        self.emailLbl.text = emailLbl
        DispatchQueue.main.async {
            if isSelected  {
                self.checkImage.isHidden = false
            } else {
                self.checkImage.isHidden = true
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            checkImage.isHidden == true ? (checkImage.isHidden = false) : (checkImage.isHidden = true)
        }
    }
}
