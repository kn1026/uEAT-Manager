//
//  ItemModel.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/4/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import Foundation
import UIKit

class ItemModel {
    
    
    
    fileprivate var _name: String!
    fileprivate var _type: String!
    fileprivate var _description: String!
    fileprivate var _category: String!
    fileprivate var _Restaurant_ID: String!
    fileprivate var _price: Float!
    fileprivate var _img: UIImage!
    fileprivate var _timeStamp: Any!
    
    
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
    
    var type: String! {
        get {
            if _type == nil {
                _type = ""
            }
            return _type
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
    
    var Restaurant_ID: String! {
        get {
            if _Restaurant_ID == nil {
                _Restaurant_ID = ""
            }
            return _Restaurant_ID
        }
        
    }
    
    var img: UIImage! {
        get {
            if _img == nil {
                _img = nil
            }
            return _img
        }
        
    }
    
    
    

    
    init(postKey: String, Item_model: Dictionary<String, Any>) {
        
    
        if let name = Item_model["name"] as? String {
            self._name = name
            
        }
        
        if let type = Item_model["type"] as? String {
            self._type = type
            
        }
        
        if let description = Item_model["description"] as? String {
            self._description = description
            
        }
        
        if let category = Item_model["category"] as? String {
            self._category = category
            
        }
        
        if let Restaurant_ID = Item_model["Restaurant_ID"] as? String {
            self._Restaurant_ID = Restaurant_ID
            
        }
        
        if let img = Item_model["img"] as? UIImage {
            self._img = img
            
        }
        
        if let price = Item_model["price"] as? Float {
            
           
            self._price = price
  
            
        }
     
       
        
    }
    
    
    
    
    
    
}
