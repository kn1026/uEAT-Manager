//
//  SignInVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 11/23/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase

class SignInVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    var email = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        emailTxtField.attributedPlaceholder = NSAttributedString(string: "Email address",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
               
        emailTxtField.delegate = self
        
        passwordTxtField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
               
        passwordTxtField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        emailTxtField.becomeFirstResponder()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
        
    }
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func NextBtnPressed(_ sender: Any) {
        
        if let email = emailTxtField.text, email != "", let password = passwordTxtField.text, password != "" {
            
            swiftLoader()
            
            self.email = email
            
            DataService.instance.mainFireStoreRef.collection("Restaurant").whereField("Email", isEqualTo: email).whereField("Status", isEqualTo: "Ready").getDocuments { (snap, err) in
                
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
                    
                    
                    Auth.auth().signIn(withEmail: "Manager-\(email)", password: password) { (data, err) in
                        
                        if err != nil {
                            
                            SwiftLoader.hide()
                            self.showErrorAlert("Opss!!!", msg: err!.localizedDescription)
                            return
                            
                        }
                        
                        SwiftLoader.hide()
                        self.performSegue(withIdentifier: "moveToPhoneVC", sender: nil)
                        
                    }
                    
                    
                }
                
                
                
            }
            
            print("Manager-\(email)", password)
            
            
        } else  {
            
            self.showErrorAlert("Opss !!!", msg: "Please enter your email and password")
            
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if segue.identifier == "moveToPhoneVC"{
            if let destination = segue.destination as? TwoFactorAuthenticationVC {
                
                destination.email = email
                
                
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
