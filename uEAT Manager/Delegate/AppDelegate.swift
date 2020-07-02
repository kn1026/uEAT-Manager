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
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    private let baseURLString: String = "https://obscure-harbor-40524.herokuapp.com/"
    private let appleMerchantIdentifier: String = "merchant.campusConnectPay"
    private let publishableKey: String = Stripe_key

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        
        GMSServices.provideAPIKey(googleMap_Key)
        GMSPlacesClient.provideAPIKey(googleMap_Key)
        STPPaymentConfiguration.shared().publishableKey = Stripe_key
        FirebaseApp.configure()
        
        attemptRegisterForNotifications(application: application)
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hasRunBefore") == false {
            print("The app is launching for the first time. Setting UserDefaults...")
            
            do {
                try Auth.auth().signOut()
            } catch {
                
            }
            
            // Update the flag indicator
            userDefaults.set(true, forKey: "hasRunBefore")
            userDefaults.synchronize() // This forces the app to update userDefaults
            
            // Run code here for the first launch
            
        } else {
            
            print("The app has been launched before. Loading UserDefaults...")
            // Run code here for every other launch but the first
            
        }
        
        
        return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for notifications:", deviceToken)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Registered with FCM with token:", fcmToken)
    }
    
    // listen for user notifications
     @available(iOS 10.0, *)
     func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         completionHandler(.alert)
         
         
         
         
         
     }
     
     func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
         
         
     }
     
     
    
     
     @available(iOS 10.0, *)
     func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
         
         let userInfo = response.notification.request.content.userInfo

         
         if let followerId = userInfo["followerId"] as? String {
             print(followerId)
             
             // I want to push the UserProfileController for followerId somehow
             /*
             let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
             userProfileController.userId = followerId
             
             // how do we access our main UI from AppDelegate?
             if let mainTabBarController = window?.rootViewController as? MainTabBarController {
                 
                 mainTabBarController.selectedIndex = 0
                 
                 mainTabBarController.presentedViewController?.dismiss(animated: true, completion: nil)
                 
                 if let homeNavigationController = mainTabBarController.viewControllers?.first as? UINavigationController {
                     
                     homeNavigationController.pushViewController(userProfileController, animated: true)
                     
                 }
                 
             }
             
             */
         }
     }
     
     func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
         
         
     }
     
     
     
     private func attemptRegisterForNotifications(application: UIApplication) {
         print("Attempting to register APNS...")
         
         Messaging.messaging().delegate = self
         
         if #available(iOS 10.0, *) {
             UNUserNotificationCenter.current().delegate = self
             // user notifications auth
             // all of this works for iOS 10+
             let options: UNAuthorizationOptions = [.alert, .badge, .sound]
             UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, err) in
                 if let err = err {
                     print("Failed to request auth:", err)
                     return
                 }
                 
                 if granted {
                     print("Auth granted.")
                 } else {
                     print("Auth denied")
                 }
             }
         } else {
             
             let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
             application.registerUserNotificationSettings(notificationSettings)
             
             
         }
         
        
         
         application.registerForRemoteNotifications()
        
        
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

