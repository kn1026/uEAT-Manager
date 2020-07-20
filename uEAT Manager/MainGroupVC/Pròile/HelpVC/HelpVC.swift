//
//  HelpVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 7/17/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//  Start a new issue // solving current issue

import UIKit
import Firebase

class HelpVC: UIViewController {
    
    
    @IBOutlet weak var issueBtn: UIButton!
    var restaurant_id = ""
    var issue_id = ""
    var restaurant_name = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
        
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
                    
                    if let restaurant_names = item.data()["businessName"] as? String {
                        
                        
                        let id = item.documentID
                        self.restaurant_id = id
                        self.restaurant_name = restaurant_names
                        self.checkIssue(id: id)
                        
                        
                    }
        
                    
                }
                
                
                
            }
            
            

            
        }

        
        

    }
    
    func checkIssue(id: String) {
        

        
        DataService.instance.mainFireStoreRef.collection("Issues").whereField("Id", isEqualTo: id).whereField("Status", isEqualTo: true).getDocuments { (snap, err) in
        
        if err != nil {
            
            self.showErrorAlert("Opss !", msg: err!.localizedDescription)
            return
            
        }
            
            if snap?.isEmpty == true {
                
                self.issueBtn.setTitle("Start a new issue", for: .normal)
                
            } else {
                
                
                for item in snap!.documents {
                    
                    
                    if let Issue_id = item.data()["Issue_id"] as? String {
                        
                        self.issue_id = Issue_id
                        self.issueBtn.setTitle("Solving current issue", for: .normal)
                        
                        
                    }
                    
                    
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
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func ChatSupportBtnPressed(_ sender: Any) {
        
        if issueBtn.titleLabel?.text == "Start a new issue" {
            
            self.showInputDialog(title: "Please tell us your issue!",
                            subtitle: "After you finish this, we will connect your issue to our supporters !",
                            actionTitle: "Submit",
                            cancelTitle: "Cancel",
                            inputPlaceholder: "Issue",
                            inputKeyboardType: .default)
            { (input:String?) in
                if let text = input, text != "" {
                    
                    self.swiftLoader()
                    
                    var ref: DocumentReference? = nil
                    let dict = ["Id": self.restaurant_id as Any, "Issue": text as Any, "Type": "Restaurant" as Any, "Status": true, "timestamp": FieldValue.serverTimestamp()] as [String : Any]
                    ref = DataService.instance.mainFireStoreRef.collection("Issues").addDocument(data: dict) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                            
                            DataService.instance.mainRealTimeDataBaseRef.child("newIssueNoti").child("Admin").removeValue()
                            let values: Dictionary<String, AnyObject>  = [text: 1 as AnyObject]
                            DataService.instance.mainRealTimeDataBaseRef.child("newIssueNoti").child("Admin").setValue(values)
                            
                            DataService.instance.mainFireStoreRef.collection("Issues").document(ref!.documentID).updateData(["Issue_id": ref!.documentID])
                            self.issue_id = ref!.documentID
                            let messageRef = DataService.instance.mainRealTimeDataBaseRef.child("Issue_Chat").child(ref!.documentID).child("message")
                            
                            let newMessage = messageRef.childByAutoId()
                            let messageData = ["Text": text, "senderId": self.restaurant_id, "senderName": self.restaurant_name, "MediaType": "Text", "timestamp": ServerValue.timestamp()] as [String : Any]
                            
                            let chatInformation: Dictionary<String, Any> = ["timeStamp": FieldValue.serverTimestamp(), "LastMessage": text]
                            
                            newMessage.setValue(messageData)
                            DataService.instance.mainFireStoreRef.collection("Chat_issues").document(ref!.documentID).updateData(chatInformation)
                            
                            DataService.instance.mainRealTimeDataBaseRef.child("Issue_Chat_Info").child(ref!.documentID).updateChildValues(["Last_message": text])
                            
                            
                            SwiftLoader.hide()
                            
                            
                            self.performSegue(withIdentifier: "moveToChatIssueVC", sender: self)
                        }
                    }
                    
       
                    
                } else {
                    
                    
                    self.showErrorAlert("No issue found !", msg: "Please provide your issue to continue.")
                    
                }
            }
            
        } else if issueBtn.titleLabel?.text == "Solving current issue" {
            
            
            self.performSegue(withIdentifier: "moveToChatIssueVC", sender: self)
            
            
        } else {
            
            print("3")
            
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "moveToChatIssueVC") {
            

            let navigationView = segue.destination as! UINavigationController
            let ChatController = navigationView.topViewController as? HelpMessageVC
            

            ChatController?.chatUID = restaurant_id
            ChatController?.chatOrderID = issue_id
            ChatController?.chatKey = issue_id
            ChatController?.userUID = "Admin"

                  
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
