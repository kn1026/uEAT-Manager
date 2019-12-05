//
//  AppDelegate.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 10/21/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import GoogleMaps

import Stripe

import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let baseURLString: String = "https://obscure-cliffs-52108.herokuapp.com/"
    private let appleMerchantIdentifier: String = "merchant.campusConnectPay"
    private let publishableKey: String = Stripe_key

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        GMSServices.provideAPIKey(googleMap_Key)
        GMSPlacesClient.provideAPIKey(googleMap_Key)
        STPPaymentConfiguration.shared().publishableKey = Stripe_key
        FirebaseApp.configure()
        
        return true
    }
    

  

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    class func getAppDelegate() -> AppDelegate {
           return UIApplication.shared.delegate as! AppDelegate
    }
    
    override init() {
        super.init()
        
        // Stripe payment configuration
        STPPaymentConfiguration.shared().companyName = "Campus Connect LLC"
        
        if !publishableKey.isEmpty {
            STPPaymentConfiguration.shared().publishableKey = publishableKey
        }
        
        if !appleMerchantIdentifier.isEmpty {
            STPPaymentConfiguration.shared().appleMerchantIdentifier = appleMerchantIdentifier
        }

        // Main API client configuration
        MainAPIClient.shared.baseURLString = baseURLString
        
        
    }


}

