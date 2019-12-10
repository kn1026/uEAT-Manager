//
//  EditVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/9/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase

class EditVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var PhoneNumberTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var websiteTxtField: UITextField!
    
    var restaurant_id = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        PhoneNumberTxtField.attributedPlaceholder = NSAttributedString(string: "Phone number",
                                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
                      
        PhoneNumberTxtField.delegate = self
               
        emailTxtField.attributedPlaceholder = NSAttributedString(string: "Email address",
                                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
                      
        emailTxtField.delegate = self

        websiteTxtField.attributedPlaceholder = NSAttributedString(string: "Website",
                                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
                      
        websiteTxtField.delegate = self
        
        
        
        
        
        
        
        
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
        
        
        PhoneNumberTxtField.becomeFirstResponder()
        self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
        
    }
    
    
    func getRestaurant_ID(email: String) {
        
        let emails = process_email(email: email)
        
        DataService.instance.mainFireStoreRef.collection("Restaurant").whereField("Email", isEqualTo: emails).getDocuments { (snap, err) in
            
            if err != nil {
            
                SwiftLoader.hide()
                self.showErrorAlert("Opss !", msg: "Can't validate your account")
                print(err?.localizedDescription as Any)
                return
            
            }
            
            
            if snap?.isEmpty == true {
                
                SwiftLoader.hide()
                             
                self.showErrorAlert("Opss !", msg: "Your account isn't ready yet, please wait until getting an email from us or you can contact our support")
                          
            } else {
                
                
                for item in snap!.documents {
                    
                    let id = item.documentID
                    self.restaurant_id = id
                    
                }
                
                
                
            }
            
            
            
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    

    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func SaveBtnPressed(_ sender: Any) {
        
        
        swiftLoader()
        updatePhone {
            self.updateEmail {
                self.updateWebsite {
                    SwiftLoader.hide()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func updatePhone(completed: @escaping DownloadComplete) {
        
        if let phone = PhoneNumberTxtField.text, phone != "" {
            
            
            DataService.instance.mainFireStoreRef.collection("Restaurant").document(restaurant_id).updateData(["Phone": phone])
            completed()
            
        } else {
            
            
            completed()
            
        }
        
    }
    
    func updateEmail(completed: @escaping DownloadComplete) {
        
        if let email = emailTxtField.text, email != "" {
            
            DataService.instance.mainFireStoreRef.collection("Restaurant").document(restaurant_id).updateData(["Email": email])
            completed()
            
        } else {
            
            
            completed()
            
        }
        
    }
    
    func updateWebsite(completed: @escaping DownloadComplete) {
        
        if let website = websiteTxtField.text, website != "" {
            
            
            DataService.instance.mainFireStoreRef.collection("Restaurant").document(restaurant_id).updateData(["webAdress": website])
            completed()
            
        } else {
            
            
            completed()
            
        }
        
    }
    
    
}
