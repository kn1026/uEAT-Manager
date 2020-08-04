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
    
    var itemarr = [ItemModel]()
    
    var pickerViewController = pickView.type

    @IBOutlet weak var validLimitTxtField: UITextField!
    @IBOutlet weak var validUntilTxtField: UITextField!
    @IBOutlet weak var titleTxtField: UITextField!
    @IBOutlet weak var DescriptionTxrField: UITextField!
    @IBOutlet weak var TypeTxtField: UITextField!
    @IBOutlet weak var ValueTxtField: UITextField!
    @IBOutlet weak var categoryTxtField: UITextField!
    
    var type = ["$", "%"]
    var restaurant_id = ""
    var fromDate: Date!
    var untilDate: Date!

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
        
        
        validUntilTxtField.attributedPlaceholder = NSAttributedString(string: "Valid from",
                                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
                      
        validUntilTxtField.delegate = self
        
        validLimitTxtField.attributedPlaceholder = NSAttributedString(string: "Valid until",
                                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
                      
        validLimitTxtField.delegate = self
        
               
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
                    
                    self.loadMenu(id: id)
                    
                }
                
                
                
            }
            
            

            
        }

        
        

    }
    
    func loadMenu(id: String) {
               
         
         DataService.instance.mainFireStoreRef.collection("Menu").whereField("restaurant_id", isEqualTo: id).getDocuments { (snap, err) in
             
             if err != nil {
                 
                 self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                 return
                 
             }
             
            self.itemarr.removeAll()
            
            let dicts = ["name": "All menu" as Any, "description": "All menu" as Any, "price": 0 as Any, "url": "" as Any, "category": "" as Any, "type": "", "restaurant_id": id, "timeStamp": "", "quanlity": "None", "status": "Offline", "Updated": true] as [String : Any]
            let dict = ItemModel(postKey: "All", Item_model: dicts)
            self.itemarr.append(dict)
    
             for item in snap!.documents {
                 

                 
                 let dictss = ItemModel(postKey: item.documentID, Item_model: item.data())
                 

                 if let type = item["type"] as? String {
                     
                     if type != "Add-onn" {
                         
                         self.itemarr.append(dictss)
                         
                     }
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
        
        if let title = titleTxtField.text, let description = DescriptionTxrField.text, let category = categoryTxtField.text, category != "", let type = TypeTxtField.text, type != "", let value = ValueTxtField.text, value != "", restaurant_id != "", let startTime = validUntilTxtField.text, startTime != "", let untilTime = validLimitTxtField.text, untilTime != "" {
            
            if type == "%" {
                if Int(value)! > 100 {
                    
                    
                    self.showErrorAlert("Oops !!!", msg: "Because the type is %, so the value can't be higher than 100%, please fix and re-submit")
                    
                    return
                    
                }
                    
                
            }
            
            var dict = [String : Any]()
            
            if category == "All menu" {
                
                dict = ["title": title, "description": description, "category": category, "type": type, "value": value, "restaurant_id": restaurant_id, "timeStamp": FieldValue.serverTimestamp(), "status": "Online", "category_url": "All", "fromDate": fromDate!, "untilDate": untilDate!] as [String : Any]
                
            } else {
                
                dict = ["title": title, "description": description, "category": category, "type": type, "value": value, "restaurant_id": restaurant_id, "timeStamp": FieldValue.serverTimestamp(), "status": "Online", "category_url": get_categoryID(category: category), "fromDate": fromDate!, "untilDate": untilDate! ] as [String : Any]
                
            }
            
          
            swiftLoader()

            
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
    
    
    func get_categoryID(category: String) -> String {
        
        for i in itemarr {
            
            if i.name == category {
                
                return i.url
                
            }
            
        }
        
        return "All"
        
    
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
    
    @IBAction func TimeChoooseBtn(_ sender: Any) {
        
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePickerView.minimumDate = Date().addingTimeInterval(60 * 60 * 2)
        validUntilTxtField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(CreateVoucherVC.dateFromValueChanged(_:)), for: UIControl.Event.valueChanged)
        
    }
   
  
    @IBAction func createLimit(_ sender: Any) {
        
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePickerView.minimumDate = Date().addingTimeInterval(60 * 60 * 24)
        validLimitTxtField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(CreateVoucherVC.dateUntilValueChanged(_:)), for: UIControl.Event.valueChanged)
        
    }
    
    
    @objc func dateFromValueChanged(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.short
        //dateFormatter.dateFormat = "MM-dd-yyyy"
        validUntilTxtField.text = dateFormatter.string(from: sender.date)

        
        fromDate = sender.date
    }
    
    @objc func dateUntilValueChanged(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.short
        //dateFormatter.dateFormat = "MM-dd-yyyy"
        validLimitTxtField.text = dateFormatter.string(from: sender.date)
        
        untilDate = sender.date
       

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
                return itemarr.count
            
        }
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
        
        switch (pickerViewController) {
            
            case .type:
                return type[row]
            case .category:
                return itemarr[row].name
            
        }
     
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        switch (pickerViewController) {
            
            case .type:
                TypeTxtField.text = type[row]
            case .category:
                categoryTxtField.text = itemarr[row].name
            
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
                label.text = itemarr[row].name
            
        }

        label.textAlignment = .center
        return label

        
    }
}
