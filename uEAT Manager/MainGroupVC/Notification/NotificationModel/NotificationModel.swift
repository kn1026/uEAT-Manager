//
//  NotificationModel.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/9/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import Foundation
import UIKit

class NotificationModel {
    
    
    
    fileprivate var _title: String!
    fileprivate var _timeStamp: Any!
    fileprivate var _type: String!
    
    
    
    
    
    var title: String! {
        get {
            if _title == nil {
                _title = ""
            }
            return _title
        }
        
    }
    
    var type: String! {
        get {
            if _type == nil {
                _type = ""
            }
            return _type
        }
        
    }
    
    
    var timeStamp: Any! {
        get {
            if _timeStamp == nil {
                _timeStamp = 0
            }
            return _timeStamp
        }
    }
    
    
    
    init(postKey: String, Notification_model: Dictionary<String, Any>) {
        
    
        if let title = Notification_model["title"] as? String {
            self._title = title
            
        }
        
        if let type = Notification_model["type"] as? String {
            self._type = type
            
        }
        
        if let timeStamp = Notification_model["timeStamp"] {
            
            self._timeStamp = timeStamp
            
        }
        
        
    }
    
    
    
    
    
    
}
