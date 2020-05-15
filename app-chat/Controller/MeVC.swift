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
    
    @IBOutlet weak var tableView: UITableView!
    
    var messageArray = [Message]()
    var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1234754696, green: 0.128762424, blue: 0.1390718222, alpha: 1)
        return view
    }()
    var profileImage: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.masksToBounds = true
        return profileImageView
    }()
    var choseImage: UIButton = {
        let chose = UIButton()
        chose.setImage(UIImage(systemName: "camera"), for: .normal)
        chose.translatesAutoresizingMaskIntoConstraints = false
        chose.layer.cornerRadius = chose.frame.height / 2
        chose.layer.masksToBounds = true
        chose.tintColor = .black
        chose.backgroundColor = .lightText
        return chose
    }()
    var saveImageBtn: UIButton = {
        let saveBtn = UIButton()
        saveBtn.setTitle(" Save", for: .normal)
        saveBtn.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        saveBtn.setTitleColor(.systemGreen, for: .normal)
        saveBtn.tintColor = .systemGreen
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        return saveBtn
    }()
    var cancelImageBtn: UIButton = {
        let cancelBtn = UIButton()
        cancelBtn.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        return cancelBtn
    }()
    var emailLbl: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.4125089049, green: 0.8123833537, blue: 0.9942517877, alpha: 1)
        label.font = UIFont(name: "Menlo-Bold", size: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var bioLbl: UILabel = {
        let label = UILabel()
        label.text = "First stop on our #EuropaRoadTrip with my 🥜 Lloyd Griffith and Enterprise… "
        label.textColor = #colorLiteral(red: 0.4125089049, green: 0.8123833537, blue: 0.9942517877, alpha: 1)
        label.font = UIFont(name: "Menlo", size: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailLbl.text = Auth.auth().currentUser?.email
        

        profileImage.addGestureRecognizer(UITapGestureRecognizer(target:  self,action: #selector(selectProfileImageView) ))
        profileImage.isUserInteractionEnabled = true
        
        choseImage.addGestureRecognizer(UITapGestureRecognizer(target:  self,action: #selector(selectProfileImageView) ))
        choseImage.isUserInteractionEnabled = true
        
        saveImageBtn.addTarget(self, action: #selector(saveImageBtnWasPressed), for: .touchUpInside)
        cancelImageBtn.addTarget(self, action: #selector(cancelBtnImageWasPressed), for: .touchUpInside)
        
        cancelImageBtn.isHidden = true
        saveImageBtn.isHidden = true
        setupImageProfile()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FeedCell.self, forCellReuseIdentifier: "feedCell")
        
        setupHeaderView()
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
    func setupHeaderView(){
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 250)
        tableView.addSubview(headerView)
        
        headerView.addSubview(profileImage)
        profileImage.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16).isActive = true
        profileImage.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        headerView.addSubview(choseImage)
        choseImage.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 0).isActive = true
        choseImage.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 0).isActive = true
        
      
        headerView.addSubview(cancelImageBtn)
        cancelImageBtn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        cancelImageBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        cancelImageBtn.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0).isActive = true
        cancelImageBtn.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 0).isActive = true
        
        headerView.addSubview(saveImageBtn)
        saveImageBtn.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 0).isActive = true
        saveImageBtn.topAnchor.constraint(equalTo: cancelImageBtn.bottomAnchor, constant: 16).isActive = true

        headerView.addSubview(emailLbl)
        emailLbl.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 16).isActive = true
        emailLbl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        emailLbl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16).isActive = true
        
        headerView.addSubview(bioLbl)
        bioLbl.topAnchor.constraint(equalTo: emailLbl.bottomAnchor, constant: 16).isActive = true
        bioLbl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        bioLbl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16).isActive = true
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
    @objc func saveImageBtnWasPressed() {
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
    
    @objc func cancelBtnImageWasPressed() {
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 250
    }
    
}
