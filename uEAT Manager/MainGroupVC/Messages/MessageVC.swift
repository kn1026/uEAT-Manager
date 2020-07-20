//
//  MessageVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/6/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase

class MessageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var messageArr = [MessageModel]()
    var chatUID = ""
    var chatOrderID = ""
    var chatKey = ""
    var displayName = ""
    var userUID = ""
   
    
    
    private var pullControl = UIRefreshControl()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        
        pullControl.tintColor = UIColor.black
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = pullControl
        } else {
            tableView.addSubview(pullControl)
        }
        
    }
    

    
    @objc private func refreshListData(_ sender: Any) {
       // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        if messageArr.isEmpty != true {
            
            tableView.restore()
            return 1
            
        } else {
            
            tableView.setEmptyMessage("Loading messages !!!")
            return 1
            
        }
    
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = messageArr[indexPath.row]
                   
                   
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageCell {
           
            //cell.img.frame = cell.frame.offsetBy(dx: 10, dy: 10);
            if indexPath.row != 0 {
                let color = self.view.backgroundColor
                let lineFrame = CGRect(x:0, y:-20, width: self.view.frame.width, height: 40)
                let line = UIView(frame: lineFrame)
                line.backgroundColor = color
                cell.addSubview(line)
                
            }
            
            cell.configureCell(item)

            return cell
                       
        } else {
                       
            return MessageCell()
                       
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 120.0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = messageArr[indexPath.row]
        
        
        self.displayName = "Restaurant"
        self.chatUID = item.Restaurant_ID
        self.chatOrderID = item.order_id
        self.chatKey = item.chat_key!
        self.userUID = item.userUID!
        
        
        self.performSegue(withIdentifier: "moveToChatDetailVC", sender: nil)
        
        
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "moveToChatDetailVC") {
            

            let navigationView = segue.destination as! UINavigationController
            let ChatController = navigationView.topViewController as? MessageDetailVC
            

            ChatController?.chatUID = chatUID
            ChatController?.chatOrderID = chatOrderID
            ChatController?.chatKey = chatKey
            ChatController?.userUID = userUID

                  
        }
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
                    self.loadChatOrder(id: id)
                    
                }
                
                
                
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
    
    func loadChatOrder(id: String) {
        

            
        DataService.instance.mainFireStoreRef.collection("Chat_orders").order(by: "timeStamp", descending: true).whereField("Restaurant_ID", isEqualTo: id).whereField("Status", isEqualTo: "Open").getDocuments { (snap, err) in
            
            if err != nil {
                
                
                //print(err?.localizedDescription)
                self.showErrorAlert("Opss !", msg: "Can't load your recent messages")
                return
                
                }
                
                self.messageArr.removeAll()
                
                for item in snap!.documents {
                    
   
                    let i = item.data()
                    let ChatItem = MessageModel(postKey: item.documentID, Chat_model: i)
                    self.messageArr.append(ChatItem)
 
                }
            
            if self.pullControl.isRefreshing == true {
                self.pullControl.endRefreshing()
            }
          
                self.tableView.reloadData()
                
            }
            
        
        
        
        
        
    }
    
    


}
