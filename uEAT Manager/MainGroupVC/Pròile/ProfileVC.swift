//
//  ProfileVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/6/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVKit
import AVFoundation
import CoreLocation
import SafariServices

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {

    var feature = ["Open hours", "Payment", "Security", "Vouchers", "Contact Info", "Help & Support", "Log out"]
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        tableView.reloadData()
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feature.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = feature[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as? ProfileCell {
            
            if indexPath.row != 0 {
                
                let lineFrame = CGRect(x:0, y:-10, width: self.view.frame.width, height: 11)
                let line = UIView(frame: lineFrame)
                line.backgroundColor = UIColor.lightGray
                cell.addSubview(line)
                
            }
            
            cell.configureCell(item)
            
            return cell
            
        } else {
            
            return ProfileCell()
            
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let item = feature[indexPath.row]
        
        if item == "Notifications" {
            
           // self.performSegue(withIdentifier: "MoveToNotificationVC", sender: nil)
            
        } else if item == "Payment" {
            
            
            self.retrieve_earningAccount()
            
            
        } else if item == "Security" {
            
            self.performSegue(withIdentifier: "moveToSecurityVC", sender: nil)
            
        }
        else if item == "Vouchers" {
            
            self.performSegue(withIdentifier: "moveToVoucherVC", sender: nil)
            
        }
        else if item == "Contact Info" {
            
            self.performSegue(withIdentifier: "moveToContactVC", sender: nil)
            
        }
        else if item == "Help & Support" {
            
            self.performSegue(withIdentifier: "moveToHelpVC", sender: nil)
            
        }
        else if item == "Open hours" {
            
            self.performSegue(withIdentifier: "moveTohoursVC", sender: nil)
            
        }
        else {
            
            
            try? Auth.auth().signOut()
            self.performSegue(withIdentifier: "moveToSignIn3VC", sender: nil)
            
            
        }
    }
    
    
    func retrieve_earningAccount() {
      
        DataService.instance.mainRealTimeDataBaseRef.child("Stripe_Owner_Connect_Account").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (Connect) in
          
          if Connect.exists() {
              
              if let acc = Connect.value as? Dictionary<String, Any> {
                  
                  if let Login_link = acc["Login_link"] as? String {
                      
                      
                      guard let urls = URL(string: Login_link) else {
                          return //be safe
                      }
                      
                      let vc = SFSafariViewController(url: urls)
                      
                      
                      self.present(vc, animated: true, completion: nil)
                      
                      
                  }
                  
              }
          }
              
          
      })
      
    }



}
