//
//  DataService.swift
//  app-chat
//
//  Created by hieungq on 4/18/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import Foundation
import Firebase
import UIKit

let DB_BASE = Database.database().reference()

class DataService {
    static let instance = DataService()
    let imageCache = NSCache<AnyObject, AnyObject>()
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_GROUPS = DB_BASE.child("groups")
    private var _REF_FEED = DB_BASE.child("feed")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    var REF_GROUPS: DatabaseReference {
        return _REF_GROUPS
    }
    var REF_FEED: DatabaseReference {
        return _REF_FEED
    }
    func createDBUser(uid: String, userData: Dictionary<String, Any>){
        REF_USERS.child(uid).updateChildValues(userData)
    }
    func uploadPost(withMessage message: String, forUser uid: String, withGroup groupKey: String?, sendComplete: @escaping (_ status: Bool) -> ()){
        if groupKey != nil {
            REF_GROUPS.child(groupKey!).child("messages").childByAutoId().updateChildValues(["sendID": uid,"content": message,"timestamp": Int(NSDate().timeIntervalSince1970)])
            sendComplete(true)
        } else {
            REF_FEED.childByAutoId().updateChildValues(["content" : message,"sendID" : uid,"timestamp": Int(NSDate().timeIntervalSince1970)])
            sendComplete(true)
        }
    }
    func uploadProfileWithImage(forUser uid: String, withUrl url: String, Complete: @escaping (_ status: Bool)->()){
        REF_USERS.child(uid).updateChildValues(["photoURL": url])
        Complete(true)
    }
    func getUserName (withUid uid: String, handler: @escaping (_ result: String)->()){
        REF_USERS.child(uid).observe(.value) { (result) in
            handler(result.childSnapshot(forPath: "email").value as! String)
        }
    }
    func getUserImage (withUid uid: String, handler: @escaping (_ image: UIImage?,_ error: Error?)->()){
        REF_USERS.child(uid).observe(.value) { (result) in
            let url  = result.childSnapshot(forPath: "photoURL").value as? String
            if url != nil {
                if let cachedImage = self.imageCache.object(forKey: url as AnyObject) as? UIImage {
                    //                    print("image be cached")
                    handler(cachedImage,nil)
                    return
                }
                let storageRef = Storage.storage().reference(forURL: url!)
                storageRef.getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        handler(UIImage(named: "defaultProfileImage"),error)
                        return
                    }
                    self.imageCache.setObject(UIImage(data: data!)!, forKey: url as AnyObject)
                    //                    print("image be set")
                    handler(UIImage(data: data!),error)
                })
            }else{
                handler(UIImage(named: "defaultProfileImage"),nil)
            }
        }
    }
    func getAllFeedMessage (handler: @escaping (_ message: [Message])->()){
        var messageArray = [Message]()
        REF_FEED.observeSingleEvent(of: .value) { (feedMessageSnapshot) in
            guard let feedMessageSnapshot = feedMessageSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for message in feedMessageSnapshot {
                let keyFeed = message.key
                let content = message.childSnapshot(forPath: "content").value as! String
                let senderId = message.childSnapshot(forPath: "sendID").value as! String
                let timeStamp = message.childSnapshot(forPath: "timestamp").value  as! NSNumber
                let message = Message(keyFeed: keyFeed,content: content, senderId: senderId, timeStamp: timeStamp)
                messageArray.append(message)
            }
            handler(messageArray)
        }
    }
    func getAllMessageGroup (forGroup: Group, handler: @escaping (_ message: [Message])->()){
        var messageArray = [Message]()
        REF_GROUPS.child(forGroup.key).child("messages").observeSingleEvent(of: .value) { (returnGroupMessage) in
            guard let returnGroupMessage = returnGroupMessage.children.allObjects as? [DataSnapshot] else { return }
            for message in returnGroupMessage {
                let keyMessage = message.key
                let content = message.childSnapshot(forPath: "content").value as! String
                let senderId = message.childSnapshot(forPath: "sendID").value as! String
                let timeStamp = message.childSnapshot(forPath: "timestamp").value as! NSNumber
                let message = Message(keyFeed: keyMessage,content: content, senderId: senderId, timeStamp: timeStamp)
                messageArray.append(message)
            }
            handler(messageArray)
        }
    }
    func removeFeedMessage(forKey key: String, handler: @escaping (_ result: Bool, _ error: Error?)->()){
        REF_FEED.child(key).removeValue(){ error,result in
            if error != nil {
                print("error \(String(describing: error))")
                handler(false,error!)
            }
        }
        handler(true,nil)
    }
    func getMail(emailQuery query: String?, handler: @escaping (_ emailArray: [String])->()){
        var emailArray = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (userDataSnapshot) in
            guard let userDataSnapshot = userDataSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for email in userDataSnapshot {
                let emailContain = email.childSnapshot(forPath: "email").value as! String
                if query != nil {
                    if emailContain.contains(query!) {
                        emailArray.append(emailContain)
                    }
                } else {
                    emailArray.append(emailContain)
                }
            }
            handler(emailArray)
        }
    }
    func getUids(forUsernames username: [String],handler: @escaping (_ arrayUids: [String])->() ){
        var arrayUids = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                if username.contains(user.childSnapshot(forPath: "email").value as! String ) {
                    arrayUids.append(user.key)
                }
            }
            handler(arrayUids)
        }
    }
    func createGroup(withTitle title: String,withDescription description: String, withUids uids:[String],handler: @escaping (_ result: Bool)->()){
        REF_GROUPS.childByAutoId().updateChildValues(["title": title,"description": description,"members": uids])
        handler(true)
    }
    func getAllGroup(handler: @escaping (_ groupArray: [Group] )->()){
        var groupArray = [Group]()
        REF_GROUPS.observeSingleEvent(of: .value) { (resultDataGroup) in
            guard let resultDataGroup = resultDataGroup.children.allObjects as? [DataSnapshot] else { return }
            for group in resultDataGroup {
                let memberArray = group.childSnapshot(forPath: "members").value as! [String]
                if memberArray.contains(Auth.auth().currentUser!.uid) {
                    let title = group.childSnapshot(forPath: "title").value as! String
                    let description = group.childSnapshot(forPath: "description").value as! String
                    groupArray.append(Group(title: title,description: description,key: group.key,members: memberArray,memberCount:memberArray.count))
                }
            }
            handler(groupArray)
        }
    }
    func getAllFeedWithUid(uid: String,handler: @escaping (_ result: [Message])->()){
        var messageArray = [Message]()
        REF_FEED.observeSingleEvent(of: .value) { (messageArrayDataSnapshot) in
            guard let messageArrayDataSnapshot = messageArrayDataSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for message in messageArrayDataSnapshot{
                if message.childSnapshot(forPath: "sendID").value as! String == uid {
                    let keyFeed = message.key
                    let content = message.childSnapshot(forPath: "content").value as! String
                    let senderId = message.childSnapshot(forPath: "sendID").value as! String
                    let timeStamp = message.childSnapshot(forPath: "timestamp").value  as! NSNumber
                    let message = Message(keyFeed: keyFeed,content: content, senderId: senderId, timeStamp: timeStamp)
                    messageArray.append(message)
                }
            }
            handler(messageArray)
        }
    }
    func getLastMessageOfGroup(withGroupKey groupKey: String, handler: @escaping (_ result: Message)->()){
        REF_GROUPS.child(groupKey).child("messages").observe(.value) { (resultMessage) in
            guard let resultMessage = resultMessage.children.allObjects as? [DataSnapshot] else { return }
            let message = resultMessage.last!
            let keyFeed = message.key
            let content = message.childSnapshot(forPath: "content").value as! String
            let senderId = message.childSnapshot(forPath: "sendID").value as! String
            let timeStamp = message.childSnapshot(forPath: "timestamp").value  as! NSNumber
            let messageResult = Message(keyFeed: keyFeed,content: content, senderId: senderId, timeStamp: timeStamp)
            handler(messageResult)
        }
    }
}
