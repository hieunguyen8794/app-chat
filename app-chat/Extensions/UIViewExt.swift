//
//  UIViewExt.swift
//  app-chat
//
//  Created by hieungq on 4/20/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit

extension UIView {
    struct Holder {
        static var contraint: NSLayoutConstraint = NSLayoutConstraint()
    }

    var actualVariable: NSLayoutConstraint {
        get {
            return Holder.contraint
        }
        set {
            Holder.contraint = newValue
        }
    }
    func bindToKeyboard(withConstrainItem constrainItem: NSLayoutConstraint){
        actualVariable = constrainItem
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    func unbindToKeyboard(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    @objc func keyboardWillShowNotification(_ notification: NSNotification){
       let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
       let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
       let startingFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endingFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let dataY = endingFrame.origin.y - startingFrame.origin.y

        let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
        print(isKeyboardShowing)
        
        //UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
        //    self.frame.origin.y += dataY
        //}) { (complete) in
            //self.actualVariable.constant = isKeyboardShowing ? endingFrame.height : 0
        //}
        UIView.self.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += dataY
            //self.actualVariable.constant = endingFrame.height
            
       }){ (complete) in
           self.actualVariable.constant = isKeyboardShowing ? endingFrame.height : 0
       }
        
        
    }

}
