//
//  CreateVoucherVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/9/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase

class CreateVoucherVC: UIViewController, UITextFieldDelegate {
    
    enum pickView {
        
        case type
        case category
     
    }
    
    var pickerViewController = pickView.type

    @IBOutlet weak var titleTxtField: UITextField!
    @IBOutlet weak var DescriptionTxrField: UITextField!
    @IBOutlet weak var TypeTxtField: UITextField!
    @IBOutlet weak var ValueTxtField: UITextField!
    @IBOutlet weak var categoryTxtField: UITextField!
    
    var type = ["$", "%"]
    var category = ["All", "First order", "Every 10 orders"]
    var restaurant_id = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        titleTxtField.attributedPlaceholder = NSAttributedString(string: "Title",
                                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
                      
        titleTxtField.delegate = self
               
        DescriptionTxrField.attributedPlaceholder = NSAttributedString(string: "Description",
                                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
                      
        DescriptionTxrField.delegate = self

        categoryTxtField.attributedPlaceholder = NSAttributedString(string: "Category",
                                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
                      
        categoryTxtField.delegate = self
        
        TypeTxtField.attributedPlaceholder = NSAttributedString(string: "Type",
                                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
                      
        TypeTxtField.delegate = self
        
        ValueTxtField.attributedPlaceholder = NSAttributedString(string: "Value",
                                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
                      
        ValueTxtField.delegate = self
               // Do any additional setup after loading the view.
        
        
        
        
               
        ValueTxtField.keyboardType = .numberPad
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
        titleTxtField.becomeFirstResponder()
        
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
                    
                    
                    
                }
                
                
                
            }
            
            

            
        }

        
        

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
    
    @IBAction func createBtnPressed(_ sender: Any) {
        
        if let title = titleTxtField.text, let description = DescriptionTxrField.text, let category = categoryTxtField.text, category != "", let type = TypeTxtField.text, type != "", let value = ValueTxtField.text, value != "", restaurant_id != "" {
            
            swiftLoader()
            
            let dict = ["title": title, "description": description, "category": category, "type": type, "value": value, "restaurant_id": restaurant_id, "timeStamp": FieldValue.serverTimestamp(), "status": "Online"] as [String : Any]
            
            let db = DataService.instance.mainFireStoreRef.collection("Voucher")
            
              db.addDocument(data: dict) { err in
              
                  if let err = err {
                      
                      SwiftLoader.hide()
                      self.showErrorAlert("Opss !", msg: err.localizedDescription)
                      
                  } else {
                    
                    self.generateNotification(title: "Added \(title) voucher", description: description, type: "voucher")
                    
                    SwiftLoader.hide()
                    self.dismiss(animated: true, completion: nil)
                
                }
                
                
            }
            
            
            
        } else {
            
            self.showErrorAlert("Oops !!!", msg: "Please fill all required field to continue")
            
            
            
        }
        
    }
    @IBAction func CategoryBtnPressed(_ sender: Any) {
        
        pickerViewController = pickView.category
        createDayPicker()
    }
    
    
    @IBAction func typeBtnPressed(_ sender: Any) {
        
        pickerViewController = pickView.type
        createDayPicker()
        
    }
    
    func createDayPicker() {
        
        
        let dayPicker = UIPickerView()
        dayPicker.delegate = self

        //Customizations
        
         switch (pickerViewController) {
            
            case .type:
                TypeTxtField.inputView = dayPicker
            case .category:
                categoryTxtField.inputView = dayPicker
            
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
    
    func generateNotification(title: String, description: String, type: String) {
        
        let Notification = ["title": title as Any, "description": description as Any, "restaurant_id": restaurant_id, "timeStamp": FieldValue.serverTimestamp(), "type": type] as [String : Any]
        let db = DataService.instance.mainFireStoreRef.collection("Restaurant_notification")
        
          db.addDocument(data: Notification) { err in
          
              if let err = err {
                  
                  
                  self.showErrorAlert("Opss !", msg: err.localizedDescription)
                  
              } else {
                
                print("Updated")
            }
            
            
        }
        
        
    }
    
     
}

extension CreateVoucherVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        
        return 1
            
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        switch (pickerViewController) {
            
            case .type:
                return type.count
            case .category:
                return category.count
            
        }
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
        
        switch (pickerViewController) {
            
            case .type:
                return type[row]
            case .category:
                return category[row]
            
        }
     
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        switch (pickerViewController) {
            
            case .type:
                TypeTxtField.text = type[row]
            case .category:
                categoryTxtField.text = category[row]
            
        }

        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel!
        
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        switch (pickerViewController) {
            
            case .type:
                label.text = type[row]
            case .category:
                label.text = category[row]
            
        }

        label.textAlignment = .center
        return label

        
    }
}
