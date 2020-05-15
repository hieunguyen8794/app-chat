//
//  SecondViewController.swift
//  app-chat
//
//  Created by hieungq on 4/3/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import UIKit

class GroupsVC: UIViewController {
    
    var arrayGroup = [Group]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DataService.instance.REF_GROUPS.observe(.value) { (result) in
            DataService.instance.getAllGroup { (returnGroupArray) in
                self.arrayGroup = returnGroupArray.reversed()
                self.tableView.reloadData()
            }
        }
    }
    
    
}
extension GroupsVC : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayGroup.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as? GroupCell else { return UITableViewCell() }
        let group = arrayGroup[indexPath.row]
        
        
        DataService.instance.getLastMessageOfGroup(withGroupKey: group.key) { (resultLastMessage) in
            cell.ConfigureCell(title: group.title, description: group.description, lastContent: resultLastMessage.content, timeStamp:               resultLastMessage.timeStamp)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let groupMessageVC = storyboard?.instantiateViewController(identifier: "GroupMessageVC") as? GroupMessageVC else { return}
        groupMessageVC.initData(forGroup: arrayGroup[indexPath.row])
        present(groupMessageVC, animated: true, completion: nil)
    }
}
