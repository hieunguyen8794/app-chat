//
//  AuthService.swift
//  app-chat
//
//  Created by hieungq on 4/18/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import Foundation
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class AuthService {
    static let instance = AuthService()
    
    func registerUser(withEmail email: String, andPassword password: String, userCreationComplete: @escaping (_ status: Bool ,_ error: Error? )-> ()){
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            guard let authDataResult = authDataResult else {
                userCreationComplete(false,error)
                return
            }
            let userData = ["provider": authDataResult.user.providerID, "email": authDataResult.user.email]
            DataService.instance.createDBUser(uid: authDataResult.user.uid, userData: userData as Dictionary<String, Any>)
            userCreationComplete(true,error)
        }
    }
    func loginUserByMail(withEmail email: String, andPassword password: String, loginComplete: @escaping (_ status: Bool ,_ error: Error? )-> ()){
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error != nil {
                loginComplete(false,error)
                return
            }
            loginComplete(true,error)
        }
    }
    func loginUserByFacebook (uiviewController : UIViewController, loginComplete: @escaping (_ status : Bool,_ error: Error?)->()){
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile","email"], from: uiviewController) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { (result, error) in
                if let error = error {
                    loginComplete(false,error)
                    return
                }
                let userData = ["provider": result?.user.providerID, "email": result?.user.email]
                DataService.instance.createDBUser(uid: (result?.user.uid)!, userData: userData as Dictionary<String, Any>)
              
                
                loginComplete(true,nil)
                print("Successfully login by Facebook")
            }
        }
    }
    func logOutUser(logOutCompletion: @escaping (_ status: Bool ,_ error: Error? )-> ()) {
        let firebaseAuth = Auth.auth()
        let loginManager = LoginManager()
        do {
            try
                firebaseAuth.signOut()
                loginManager.logOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            logOutCompletion(false,signOutError)
            return
        }
        logOutCompletion(true,nil)
    }
}
