//
//  CreateGroupVC.swift
//  app-chat
//
//  Created by hieungq on 4/27/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit
import Firebase

class CreateGroupVC: UIViewController {

    @IBOutlet weak var listUserInGroupLbl: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var titleTextFiled: InsetTextField!
    @IBOutlet weak var descriptionTextFiled: InsetTextField!
    @IBOutlet weak var addPeopleTextFiled: InsetTextField!
    @IBOutlet weak var tableView: UITableView!
    
    var arrayEmail = [String]()
    var chosenEmailArray = [String]()
    var yourSelfEmail = Auth.auth().currentUser?.email
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        addPeopleTextFiled.delegate = self
        addPeopleTextFiled.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        //addPeopleTextFiled.addTarget(self, action: #selector(textFieldDidEnd), for: .editingDidEnd)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doneBtn.isHidden = true
        DataService.instance.getMail(emailQuery: nil) { (resultEmailArray) in
            self.arrayEmail = resultEmailArray
            self.tableView.reloadData()
        }
    }
    @objc func textFieldDidChanged() {
        if addPeopleTextFiled.text == "" {
            self.arrayEmail = chosenEmailArray
            self.tableView.reloadData()
        } else {
            DataService.instance.getMail(emailQuery: addPeopleTextFiled.text!) { (resultEmailArray) in
                self.arrayEmail = resultEmailArray
                self.tableView.reloadData()
            }
        }
    }
    //@objc func textFieldDidEnd() {
        //self.arrayEmail = chosenEmailArray
        //self.tableView.reloadData()
    //}
    
    @IBAction func backBtnWasPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func doneBtnWasPressed(_ sender: Any) {
        if titleTextFiled.text != "" && descriptionTextFiled.text != "" {
            chosenEmailArray.contains(yourSelfEmail!) ? nil : chosenEmailArray.append(yourSelfEmail!)
            DataService.instance.getUids(forUsernames: chosenEmailArray) { (arrayUids) in
                DataService.instance.createGroup(withTitle: self.titleTextFiled.text!, withDescription: self.descriptionTextFiled.text!, withUids: arrayUids) { (result) in
                    if result {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } else {
            
        }
    }
    

}
extension CreateGroupVC: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayEmail.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserCell else {return UITableViewCell() }
        var profileImage = UIImage(named: "defaultProfileImage")
        //setup image cell
        
        
     
        cell.configureCell(profileImage: profileImage!, emailLbl: arrayEmail[indexPath.row], isSelected: chosenEmailArray.contains(arrayEmail[indexPath.row]) ? true : false)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? UserCell else { return }
        if !chosenEmailArray.contains(cell.emailLbl.text!) {
            chosenEmailArray.append(cell.emailLbl.text!)
        } else {
            chosenEmailArray.remove(at: chosenEmailArray.firstIndex(of: cell.emailLbl.text!)!)
        }
        if chosenEmailArray.count >= 1 {
            self.doneBtn.isHidden = false
            self.listUserInGroupLbl.text = "list people in your group"
        } else {
            self.doneBtn.isHidden = true
            self.listUserInGroupLbl.text = "add people to your group"
        }
        //print( "\(chosenEmailArray.count) ---- \(chosenEmailArray)")
    }
}
extension CreateGroupVC: UITextFieldDelegate {
    
}
