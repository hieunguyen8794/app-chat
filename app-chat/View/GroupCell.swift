//
//  GroupCell.swift
//  app-chat
//
//  Created by hieungq on 4/30/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    @IBOutlet weak var lastTimeMessage: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var profileBoxChat: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var memberLbl: UILabel!
    
    func ConfigureCell(title: String, description: String, lastContent: String, timeStamp: NSNumber) {
        self.titleLbl.text = title
        //self.descriptionLbl.text = description
        self.memberLbl.text = lastContent


        // setup - lastTimeMessage label
        let timeStampData = NSDate(timeIntervalSince1970: timeStamp.doubleValue)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm dd/MM"

        lastTimeMessage.text = dateFormatter.string(from: timeStampData as Date)
    }

}
