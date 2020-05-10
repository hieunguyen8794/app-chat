//
//  InsetTextField.swift
//  app-chat
//
//  Created by hieungq on 4/18/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit

class InsetTextField: UITextField {
    
    private var padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    
    override func awakeFromNib() {
        setupView()
        super.awakeFromNib()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
         return bounds.inset(by: padding)
    }
    func setupView(){
        let placeholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.5457051079, green: 0.5457051079, blue: 0.5457051079, alpha: 1)])
        self.attributedPlaceholder = placeholder
    }

}
