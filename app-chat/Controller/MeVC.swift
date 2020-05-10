//
//  MeVC.swift
//  app-chat
//
//  Created by hieungq on 4/19/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit
import Firebase

class MeVC: UIViewController {

    @IBOutlet weak var cancelImageBtn: UIButton!
    @IBOutlet weak var saveImageBtn: UIButton!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailLbl.text = Auth.auth().currentUser?.email
        
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target:  self,action: #selector(selectProfileImageView) ))
        profileImage.isUserInteractionEnabled = true
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.layer.masksToBounds = true
        cancelImageBtn.isHidden = true
        saveImageBtn.isHidden = true
        setupImageProfile()
    }
    @objc func selectProfileImageView(){
        let pickerImage = UIImagePickerController()
        pickerImage.delegate = self
        pickerImage.allowsEditing = true
        present(pickerImage, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromePicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromePicker = editedImage
        }else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromePicker = originalImage
        }
        if let selectedImage = selectedImageFromePicker {
            profileImage.image = selectedImage
            saveImageBtn.isHidden = false
            cancelImageBtn.isHidden = false
        } else {
            saveImageBtn.isHidden = true
            cancelImageBtn.isHidden = true
        }
        dismiss(animated: true, completion: nil)
    }
    func setupImageProfile(){
        DataService.instance.getUserImage(withUid: Auth.auth().currentUser!.uid) { (image, error) in
            if error != nil {
                print(error!)
            }
            self.profileImage.image = image
        }
    }
    @IBAction func saveImageBtnWasPressed(_ sender: Any) {
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
        let image = self.profileImage.image!
        if let uploadData = image.pngData() {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                print(metadata!)
                storageRef.downloadURL { (url, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    DataService.instance.uploadProfileWithImage(forUser: Auth.auth().currentUser!.uid, withUrl: url!.absoluteString) { (result) in
                        if result {
                            print("done")
                            self.saveImageBtn.isHidden = true
                            self.cancelImageBtn.isHidden = true
                        } else {
                            print("error")
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func cancelBtnImageWasPressed(_ sender: Any) {
        saveImageBtn.isHidden = true
        cancelImageBtn.isHidden = true
        DataService.instance.getUserImage(withUid: Auth.auth().currentUser!.uid, handler: { (image, error) in
            if error != nil {
                print(error)
            } else {
                self.profileImage.image = image
            }
        })
    }
    @IBAction func signOutWasPressed(_ sender: Any) {
        let alertSignOut = UIAlertController(title: "Alert", message: "Do you want to sign out?", preferredStyle: .actionSheet)
        let okeAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            AuthService.instance.logOutUser { (logOutResult, error) in
                if logOutResult {
                    guard let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") else { return }
                    self.present(authVC, animated: true, completion: nil)
                } else {
                    print(error?.localizedDescription as Any)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) in
        }
        alertSignOut.addAction(okeAction)
        alertSignOut.addAction(cancelAction)
        self.present(alertSignOut, animated: true) {
            print("presented")
        }
    }
    

}
extension MeVC: UIImagePickerControllerDelegate ,UINavigationControllerDelegate {
    
}
