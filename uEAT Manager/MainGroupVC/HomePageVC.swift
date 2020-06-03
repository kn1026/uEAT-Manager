//
//  HomePageVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/6/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import Alamofire

class HomePageVC: UITabBarController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        check_condition()
        
    }
    

    // check condition for login
    
    func check_condition() {
        
        
        if let uid = Auth.auth().currentUser?.uid, uid != "" {
        
                 // Fetch object from the cache
                 check_payment()
                 
             } else {
                 
                 
                try! Auth.auth().signOut()
                 
            
                DispatchQueue.main.async { // Make sure you're on the main thread here
                   self.performSegue(withIdentifier: "moveToSignInVC", sender: nil)
                }
                 
                 
        }
             
        
        
    }
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func check_payment() {
        
        DataService.instance.mainRealTimeDataBaseRef.child("Stripe_Owner_Connect_Account").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (Connect) in
        
        
        if Connect.exists() {
            
        
        } else {
            
            self.processStripe()
        }
            
            
        })
        
        
    }
    
    func processStripe() {
        
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            dynamicAnimatorActive: true,
            buttonsLayout: .horizontal
        )
        
        let alert = SCLAlertView(appearance: appearance)
        _ = alert.addButton("Got it") {
            
            
            NotificationCenter.default.addObserver(self, selector: #selector(CreateMenuVC.autoProcessCodeFromDelegate), name: (NSNotification.Name(rawValue: "CodeProcess")), object: nil)
            
            //Progess
            let url = "https://connect.stripe.com/express/oauth/authorize?response_type=code&client_id=\(client_id)&scope=read_write"
            
            
            guard let urls = URL(string: url) else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                
                UIApplication.shared.open(urls)
                
            } else {
                
                UIApplication.shared.openURL(urls)
                
            }
            
            
        }
        
        let icon = UIImage(named:"logo")
        
        _ = alert.showCustom("Notice!", subTitle: "You will have to finish your payment information to start selling", color: UIColor.black, icon: icon!)
          
          
        
    }
    
    @objc func autoProcessCodeFromDelegate() {
        
        if authCode != "" {
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "CodeProcess")), object: nil)
            self.processCode(authorization_code: authCode)
        }
        
    }
    
    
    func processCode(authorization_code: String) {
        
        if  authorization_code != "" {
            
            swiftLoader()
            
            let url = MainAPIClient.shared.baseURLString
            let urls = URL(string: url!)?.appendingPathComponent("redirect")
            
            AF.request(urls!, method: .post, parameters: [
                
                "authorization_code": authorization_code
                
                ])
                
                .validate(statusCode: 200..<500)
                .responseJSON { responseJSON in
                    
                    switch responseJSON.result {
                        
                    case .success(let json):
                        
                        
                        if let dict = json as? [String: AnyObject] {
                            
                            if let account = dict["stripe_user_id"] as? String {
                                
                                
                                self.createLoginLinks(account: account)
                                
                                
                                
                            }
                            
                            
                        }
                        
                    case .failure( _):
                        
                        
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops !!!", msg: "There are some unknown error during setting up your payout account. Please try again and contact us for more help")
                        
                    }
                    
                    
            }
            
            
        } else {
            
            
            
            self.showErrorAlert("Oops !!!", msg: "Please provide your code")
            
        }
        
        
    }
    
    func createLoginLinks(account: String){
         
         let url = MainAPIClient.shared.baseURLString
         let urls = URL(string: url!)?.appendingPathComponent("login_links")
         
         AF.request(urls!, method: .post, parameters: [
             
             "account": account
             
             ])
             
             .validate(statusCode: 200..<500)
             .responseJSON { responseJSON in
                 
                 switch responseJSON.result {
                     
                 case .success(let json):
                     
                     
                     if let dict = json as? [String: AnyObject] {
                         
                         if let url = dict["url"] as? String {
                             
                            DataService.instance.mainRealTimeDataBaseRef.child("Stripe_Owner_Connect_Account").child(Auth.auth().currentUser!.uid).setValue(["Stripe_Owner_Connect_Account": account,"Login_link": url, "Timestamp": ServerValue.timestamp()])
                            
                            
                              
                            SwiftLoader.hide()
                              
    
                             
                             
                         }
                         
                         
                     }
                     
                 case .failure( _):
                     
                     
                     SwiftLoader.hide()
                     self.showErrorAlert("Oops !!!", msg: "There are some unknown error during setting up your payout account. Please try again and contact us for more help")
                     
                 }
                 
                 
         }
         
     }
    

    
    func swiftLoader() {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: "", animated: true)
        
                                                                                                                                      
        
    }
    



}

extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func restore() {
        self.backgroundView = nil
        
    }
}
