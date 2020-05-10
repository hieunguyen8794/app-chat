//
//  Message.swift
//  app-chat
//
//  Created by hieungq on 4/21/20.
//  Copyright © 2020 hieungq. All rights reserved.
//

import Foundation

class Message {
    private var _content: String
    private var _senderId: String
    private var _keyFeed: String
    private var _timeStamp: NSNumber
    
    var content: String {
        return _content
    }
    var senderId: String {
        return _senderId
    }
    var keyFeed: String {
        return _keyFeed
    }
    var timeStamp: NSNumber {
        return _timeStamp
    }
    init(keyFeed: String,content: String, senderId: String, timeStamp: NSNumber) {
        self._content = content
        self._senderId = senderId
        self._keyFeed = keyFeed
        self._timeStamp = timeStamp
    }
}
