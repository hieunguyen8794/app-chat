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
    
    @IBOutlet weak var bioLbl: UILabel!
    @IBOutlet weak var choseImage: UIButton!
    @IBOutlet weak var cancelImageBtn: UIButton!
    @IBOutlet weak var saveImageBtn: UIButton!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var messageArray = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailLbl.text = Auth.auth().currentUser?.email
        
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target:  self,action: #selector(selectProfileImageView) ))
        profileImage.isUserInteractionEnabled = true
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.layer.masksToBounds = true
        
        choseImage.addGestureRecognizer(UITapGestureRecognizer(target:  self,action: #selector(selectProfileImageView) ))
        choseImage.isUserInteractionEnabled = true
        choseImage.layer.cornerRadius = choseImage.frame.height / 2
        choseImage.layer.masksToBounds = true
        
        cancelImageBtn.isHidden = true
        saveImageBtn.isHidden = true
        setupImageProfile()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FeedCell.self, forCellReuseIdentifier: "feedCell")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataService.instance.REF_FEED.observe(.value) { (result) in
            DataService.instance.getAllFeedWithUid(uid: Auth.auth().currentUser!.uid) { (resultMessage) in
                self.messageArray = resultMessage
                self.tableView.reloadData()
            }
        }
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
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
        let image = self.profileImage.image!
//        if let uploadData = image.pngData() {
        if let uploadData = image.jpegData(compressionQuality: 0.1) {
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
                print(error!)
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
extension MeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell") as? FeedCell else { return UITableViewCell()}
        let message = messageArray[indexPath.row]
        var imageProfile:UIImage = #imageLiteral(resourceName: "defaultProfileImage")
        DataService.instance.getUserImage(withUid: message.senderId) { (image, error) in
            if error != nil {
                print(error!)
            } else {
                imageProfile = image!
                cell.configure(imageView: imageProfile, userMail: Auth.auth().currentUser!.email!, message: message.content, timeStamp: message.timeStamp)
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messageArray[indexPath.row]
        let widthOfMainContent = view.frame.width - 16 - 16
        let size = CGSize(width: widthOfMainContent, height: 1000)
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Menlo", size: 12)]
        let estimatedFrame = NSString(string: message.content).boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        
        //print(estimatedFrame.height)
        return estimatedFrame.height + 100
    }
    
}
