//
//  GroupCell.swift
//  app-chat
//
//  Created by hieungq on 4/30/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var memberLbl: UILabel!
    
    func ConfigureCell(title: String, description: String, member: Int) {
        self.titleLbl.text = title
        self.descriptionLbl.text = description
        self.memberLbl.text = "\(member) member"
    }

}
