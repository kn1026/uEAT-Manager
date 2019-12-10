//
//  VoucherModel.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/9/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import Foundation


class VoucherModel {
   
    fileprivate var _title: String!
    fileprivate var _description: String!
    fileprivate var _category: String!
    fileprivate var _type: String!
    fileprivate var _value: Any!
    fileprivate var _restaurant_id: String!
    fileprivate var _status: String!
    
    
    
    var status: String! {
        get {
            if _status == nil {
                _status = ""
            }
            return _status
        }
        
    }
    
    var title: String! {
        get {
            if _title == nil {
                _title = ""
            }
            return _title
        }
        
    }
    var description: String! {
        get {
            if _description == nil {
                _description = ""
            }
            return _description
        }
        
    }
    var category: String! {
        get {
            if _category == nil {
                _category = ""
            }
            return _category
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
    var value: Any! {
        get {
            if _value == nil {
                _value = 0
            }
            return _value
        }
        
    }
    var restaurant_id: String! {
        get {
            if _restaurant_id == nil {
                _restaurant_id = ""
            }
            return _restaurant_id
        }
        
    }
    
    
    init(postKey: String, Voucher_model: Dictionary<String, Any>) {
        
    
        if let title = Voucher_model["title"] as? String {
            self._title = title
            
        }
        
        if let description = Voucher_model["description"] as? String {
            self._description = description
            
        }
        
        if let category = Voucher_model["category"] as? String {
            self._category = category
            
        }
        
        if let type = Voucher_model["type"] as? String {
            self._type = type
            
        }
        
        if let restaurant_id = Voucher_model["restaurant_id"] as? String {
            self._restaurant_id = restaurant_id
            
        }
        
        if let value = Voucher_model["value"] {
            self._value = value
            
        }
        
        if let status = Voucher_model["status"] as? String {
            self._status = status
            
        }

    }
    
    
}
