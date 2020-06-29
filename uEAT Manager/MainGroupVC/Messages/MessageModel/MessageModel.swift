//
//  MessageModel.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 6/22/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import Foundation

class MessageModel {
    
    fileprivate var _LastMessage: String!
    fileprivate var _userUID: String!
    fileprivate var _order_id: String!
    fileprivate var _chat_key: String!
    fileprivate var _Restaurant_ID: String!
    fileprivate var _timeStamp: Any!
    
       
       
       var LastMessage: String! {
           get {
               if _LastMessage == nil {
                   _LastMessage = ""
               }
               return _LastMessage
           }
           
       }
       
       var userUID: String! {
           get {
               if _userUID == nil {
                   _userUID = ""
               }
               return _userUID
           }
           
       }
       
       var order_id: String! {
           get {
               if _order_id == nil {
                   _order_id = ""
               }
               return _order_id
           }
           
       }
       
       var chat_key: String! {
           get {
               if _chat_key == nil {
                   _chat_key = ""
               }
               return _chat_key
           }
           
       }
       
       var Restaurant_ID: String! {
           get {
               if _Restaurant_ID == nil {
                   _Restaurant_ID = ""
               }
               return _Restaurant_ID
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

       
       

       
       init(postKey: String, Chat_model: Dictionary<String, Any>) {
           
       //
           
           
           if let chat_key = Chat_model["chat_key"] as? String {
               self._chat_key = chat_key
               
           }
           
           if let LastMessage = Chat_model["LastMessage"] as? String {
               self._LastMessage = LastMessage
               
           }
           
           if let userUID = Chat_model["userUID"] as? String {
               self._userUID = userUID
               
           }
           
           if let order_id = Chat_model["order_id"] as? String {
               
               
               self._order_id = order_id
               
           }
           
           if let Restaurant_ID = Chat_model["Restaurant_ID"] as? String {
               self._Restaurant_ID = Restaurant_ID
               
           }
           
           
           if let timeStamp = Chat_model["timeStamp"] {
               self._timeStamp = timeStamp
               
           }

          
           
       }
    
    
    
    
}
