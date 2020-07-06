//
//  NotificationVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/6/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

class NotificationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var restaurant_id = ""
    var notification = [NotificationModel]()
    private var pullControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        tableView.dataSource = self
        
        
        pullControl.tintColor = UIColor.black
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = pullControl
        } else {
            tableView.addSubview(pullControl)
        }
        
        
        
    }
    
    
    func setupFCMToken(id: String) {
        
        
        guard let fcmToken = Messaging.messaging().fcmToken else { return }
        
        DataService.instance.fcmTokenUserRef.child(id).child(fcmToken).observeSingleEvent(of: .value, with: { (snapInfo) in
        
        
            if snapInfo.exists() {
                
                
               print("Found")
               
                
            } else {
                
                print("Not found")
                let profile = [fcmToken: 0 as AnyObject]
                DataService.instance.fcmTokenUserRef.child(id).updateChildValues(profile)
                
                
            }
   
                
        
            
        })
        
      
        
        
    }
    
    
    @objc private func refreshListData(_ sender: Any) {
       // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Do any additional setup after loading the view.
        notification.removeAll()
        
        if Auth.auth().currentUser?.uid != nil {
            self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
        }
    
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        
        if notification.isEmpty != true {
            
            tableView.restore()
            return 1
            
        } else {
            
            tableView.setEmptyMessage("Loading notifcations !!!")
            return 1
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
         return notification.count
           
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          
        let item = notification[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as? NotificationCell {
                      
            
            cell.configureCell(item)
            return cell
                                         
        } else {
                       
            return NotificationCell()
                       
        }
   
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return ""
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90.0
        
    }
    
    func process_email(email: String) -> String {
            
        var count = 0
        let arr = Array(email)
        var new = [String]()
               
        for i in arr {
            
            if count > 7 {
                
                new.append(String((i)))
                
            }
                count += 1
        }
               
        let stringRepresentation = new.joined(separator:"")
                         
        return stringRepresentation
        
    }
    
    func getRestaurant_ID(email: String) {
        
        let emails = process_email(email: email)
        
        DataService.instance.mainFireStoreRef.collection("Restaurant").whereField("Email", isEqualTo: emails).getDocuments { (snap, err) in
            
            if err != nil {
            
                SwiftLoader.hide()
                self.showErrorAlert("Opss !", msg: "Can't validate your menu")
                return
            
            }
     
            if snap?.isEmpty == true {
                
                SwiftLoader.hide()
                self.showErrorAlert("Opss !", msg: "Your account isn't ready yet, please wait until getting an email from us or you can contact our support")
                          
            } else {
                
                for item in snap!.documents {
                    
                    let id = item.documentID
                    self.restaurant_id = id
                    self.setupFCMToken(id: id)
                    self.loadNotifcation(id: id)
                    
                }
                
            }
        }

    }
    
    func loadNotifcation(id: String) {
        
        DataService.instance.mainFireStoreRef.collection("Restaurant_notification").whereField("restaurant_id", isEqualTo: id).order(by: "timeStamp", descending: true).limit(to: 50).getDocuments { (snap, err) in
        
            if err != nil {
                
                self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                return
                
            }
            
            self.notification.removeAll()
            
            if snap?.isEmpty == true {
                                                   
            } else {
              
                for item in snap!.documents {
                              
                              
                          let i = item.data()
                          let noti = NotificationModel(postKey: item.documentID, Notification_model: i)
                          self.notification.append(noti)
                         //self.recentCollectionView.reloadData()
                              
                              
                    }
                if self.pullControl.isRefreshing == true {
                               self.pullControl.endRefreshing()
                           }
                
                self.tableView.reloadData()
            
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
