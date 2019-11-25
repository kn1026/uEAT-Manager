//
//  Cuisine_model.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 11/23/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import Foundation


class Cuisine_model {
    
    
    fileprivate var _name: String!
    fileprivate var _url: String!
    
    
    
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
    

    
    init(postKey: String, Cuisine_model: Dictionary<String, Any>) {
        
        
        
        if let name = Cuisine_model["Cuisine"] as? String {
            self._name = name
            
        }
        
        if let url = Cuisine_model["Url"] as? String {
            self._url = url
            
        }
        
        
        
        
        
    }
    
    
}
