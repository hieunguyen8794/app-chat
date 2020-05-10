//
//  ShadowView.swift
//  app-chat
//
//  Created by hieungq on 4/18/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    override func awakeFromNib() {
        self.layer.shadowOpacity = 0.75
        self.layer.shadowRadius = 5
        self.layer.shadowColor = UIColor.black.cgColor
        
        super.awakeFromNib()
    }
    
}
