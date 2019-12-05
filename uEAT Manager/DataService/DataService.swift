//
//  DataService.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 11/23/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage


class DataService {
    

    fileprivate static let _instance = DataService()
   
    
    static var instance: DataService {
        return _instance
    }
    
    var mainRealTimeDataBaseRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var mainFireStoreRef: Firestore {
        return Firestore.firestore()
    }
    
    var checkPhoneUserRef: DatabaseReference {
        return mainRealTimeDataBaseRef.child("Phone")
    }
    
    var checkEmailUserRef: DatabaseReference {
        return mainRealTimeDataBaseRef.child("Email")
    }
    
    var checReskPhoneUserRef: DatabaseReference {
        return mainRealTimeDataBaseRef.child("Res_Phone")
    }
    
    var checkResEmailUserRef: DatabaseReference {
        return mainRealTimeDataBaseRef.child("Res_Email")
    }
    
    var checkDefaultUserRef: DatabaseReference {
        return mainRealTimeDataBaseRef.child("Default_card")
    }

    let connectedRef = Database.database().reference(withPath: ".info/connected")
    
    
    var mainStorageRef: StorageReference {
        return Storage.storage().reference(forURL: "gs://ueat-4397e.appspot.com")
    }
    
    var CuisineStorageRef: StorageReference {
        return mainStorageRef.child("Cuisine")
    }
    
    var AvatarStorageRef: StorageReference {
        return mainStorageRef.child("Avatar")
    }
    
    var LogoStorageRef: StorageReference {
        return mainStorageRef.child("Logo")
    }
    
    
}
