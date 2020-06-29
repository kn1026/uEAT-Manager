//
//  File.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 6/23/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import Foundation


class OrderDetailModel {
    
    
    fileprivate var _Order_id: String!
    fileprivate var _Restaurant_id: String!
    fileprivate var _UID: String!
    fileprivate var _url: String!
    fileprivate var _name: String!
    fileprivate var _Status: String!
    fileprivate var _Order_time: Any!
    fileprivate var _quanlity: Int!
    fileprivate var _price: Float!
    fileprivate var _special_Request: String!
    fileprivate var _Captured_key: String!
    
    var _NewQuanlity: Int!
    
    var quanlity: Int! {
        get {
            if _quanlity == nil {
                _quanlity = 0
            }
            return _quanlity
        }
        
    }
    
    
    var price: Float! {
        get {
            if _price == nil {
                _price = 0.0
            }
            return _price
        }
        
    }
    
    var name: String! {
        get {
            if _name == nil {
                _name = ""
            }
            return _name
        }
        
    }
    
    var url: String! {
        get {
            if _url == nil {
                _url = ""
            }
            return _url
        }
        
    }
    
    var Captured_key: String! {
        get {
            if _Captured_key == nil {
                _Captured_key = ""
            }
            return _Captured_key
        }
        
    }
    
    var special_Request: String! {
        get {
            if _special_Request == nil {
                _special_Request = ""
            }
            return _special_Request
        }
        
    }
    
    var Status: String! {
        get {
            if _Status == nil {
                _Status = ""
            }
            return _Status
        }
        
    }
    
    var Restaurant_id: String! {
        get {
            if _Restaurant_id == nil {
                _Restaurant_id = ""
            }
            return _Restaurant_id
        }
        
    }
    
    init(postKey: String, Item_model: Dictionary<String, Any>) {
          
      
          
          if let name = Item_model["name"] as? String {
              self._name = name
              
          }
          
          if let Status = Item_model["Status"] as? String {
              self._Status = Status
              
          }
          
          if let special_Request = Item_model["special_Request"] as? String {
              self._special_Request = special_Request
              
          }
          
          if let Captured_key = Item_model["Captured_key"] as? String {
              self._Captured_key = Captured_key
              
          }
          
          if let Restaurant_id = Item_model["restaurant_id"] as? String {
              self._Restaurant_id = Restaurant_id
              
          }
          
          
          if let price = Item_model["price"] as? Float {
              
             
              self._price = price
    
              
          }
          
          if let url = Item_model["url"] as? String {
              self._url = url
              
          }
          
          
          if let quanlity = Item_model["quanlity"] as? Int {
              self._quanlity = quanlity
              self._NewQuanlity = quanlity
          }
          

         
          
      }
    
    
}
