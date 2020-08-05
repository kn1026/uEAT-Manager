//
//  VoucherModel.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/9/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import Foundation


class VoucherModel {
   
    fileprivate var _Created_by: String!
    fileprivate var _title: String!
    fileprivate var _description: String!
    fileprivate var _category: String!
    fileprivate var _category_url: String!
    fileprivate var _type: String!
    fileprivate var _value: Any!
    fileprivate var _fromDate: Any!
    fileprivate var _untilDate: Any!
    fileprivate var _timeStamp: Any!
    fileprivate var _restaurant_id: String!
    fileprivate var _status: String!
    
    
    
    var Created_by: String! {
        get {
            if _Created_by == nil {
                _Created_by = ""
            }
            return _Created_by
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
    
    var fromDate: Any! {
        get {
            if _fromDate == nil {
                _fromDate = 0
            }
            return _fromDate
        }
        
    }
    
    var untilDate: Any! {
        get {
            if _untilDate == nil {
                _untilDate = 0
            }
            return _untilDate
        }
        
    }
    
    var category_url: String! {
           get {
               if _category_url == nil {
                   _category_url = ""
               }
               return _category_url
           }
           
       }
    
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
        
        
        
        
        
        if let untilDate = Voucher_model["untilDate"] {
            self._untilDate = untilDate
            
        }
        
        if let fromDate = Voucher_model["fromDate"] {
            self._fromDate = fromDate
            
        }
        
        if let category_url = Voucher_model["category_url"] as? String {
            self._category_url = category_url
            
        }
        
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
        
        if let timeStamp = Voucher_model["timeStamp"] {
            self._timeStamp = timeStamp
            
        }
        
        if let Created_by = Voucher_model["Created by"] as? String {
            self._Created_by = Created_by
            
        }
        
        
        
    }
    
    
}
