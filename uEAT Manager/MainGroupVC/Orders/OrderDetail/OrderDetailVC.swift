//
//  OrderDetailVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 6/23/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class OrderDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var txtField: UITextView!
    var order_ID = ""
    var order_userUID = ""
    var order_status = ""
    var Order_key = ""
    var capture_Key = ""
    var res_id = ""
    var promo_id = ""
    
    @IBOutlet weak var SubtotalPrice: UILabel!
    @IBOutlet weak var ApplicationFee: UILabel!
    @IBOutlet weak var TaxFee: UILabel!
    @IBOutlet weak var TotalFee: UILabel!

    var detail = [OrderDetailModel]()
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var paid_price: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        if order_status == "Processed" {
            self.actionBtn.setTitle("Start cooking", for: .normal)
        } else if order_status == "Started" {
            self.actionBtn.setTitle("Ready to pick up", for: .normal)
        } else if order_status == "Cooked" {
            self.actionBtn.setTitle("Picked up", for: .normal)
        } else {
            self.actionBtn.isUserInteractionEnabled = false
            self.actionBtn.setTitle("Completed", for: .normal)
        }
        
        txtField.delegate = self
        txtField.backgroundColor = UIColor.white
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        let orderID = Int(order_ID )
        loadOrder(order_id: orderID!, order_userUID: order_userUID)
        
    }
    
    func loadOrder(order_id: Int, order_userUID: String)
    {
        
        DataService.instance.mainFireStoreRef.collection("Orders_detail").whereField("userUID", isEqualTo: order_userUID).whereField("Order_id", isEqualTo: order_id).getDocuments { (snaps, err) in
        
        if err != nil {
            
            self.showErrorAlert("Opss !", msg: err!.localizedDescription)
            return
            
        }
            if snaps?.isEmpty == true {
                
                print("Can't load order \(self.order_ID)")
                return
                
            }
        
            for item in snaps!.documents {
                
                if let special = item.data()["special_Request"] as? String {
                    
                    if special != "None" {
                        
                        self.txtField.text = special
                        
                    } else {
                        
                        self.txtField.text = "No special request for this order"
                        
                    }
                    
                } else {
                    
                    self.txtField.text = "No special request for this order"
                    
                }
                
                if let _capture_Key = item.data()["Captured_key"] as? String {
                    
                    self.capture_Key = _capture_Key
                    
                }
                
                let dict = OrderDetailModel(postKey: item.documentID, Item_model: item.data())
                self.detail.append(dict)
                
                
            }
     
             self.caculateSummary()
             self.tableView.reloadData()
            
            
            
            
        }
        
        
    }
    
    
    func capturePayment() {
           
        if capture_Key != "" {
            
            let url = MainAPIClient.shared.baseURLString
                 let urls = URL(string: url!)?.appendingPathComponent("Capture_payment")
    
                 AF.request(urls!, method: .post, parameters: [
                     
                     "chargedID": capture_Key
            
                     ])
                     
                     .validate(statusCode: 200..<500)
                     .responseJSON { responseJSON in
                         
                         switch responseJSON.result {
                             
                         case .success(let json):
                             
                             
                             if json is [String: AnyObject] {
                                 
                                 DataService.instance.mainFireStoreRef.collection("Processing_orders").document(self.Order_key).updateData(["Paid_time": FieldValue.serverTimestamp(), "Paid_Status": "Claimed"])
                                
                                 
                                 
                                self.prepare_payRestaurant(price: self.paid_price)
                                 
                                 
                             }
                             
                             
                         case .failure( _):
                             
                            DataService.instance.mainFireStoreRef.collection("Processing_orders").document(self.Order_key).updateData(["Paid_time": FieldValue.serverTimestamp(), "Paid_Status": "Not yet"])
                             self.showErrorAlert("Oops !!!", msg: "There is some error while capturing the payment, please contact us immediately")
                             
                         }
                         
                         
                 }
            
            
        } else {
            
            self.showErrorAlert("Oops !!!", msg: "Can't take the payment, please contact us for more support for this order")
            
        }
           
           
           
    
       }
    
    
    func prepare_payRestaurant(price: Double){
        DataService.instance.mainRealTimeDataBaseRef.child("Stripe_Owner_Connect_Account").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (Connect) in
              
              if Connect.exists() {
                  
                  if let acc = Connect.value as? Dictionary<String, Any> {
                      
                      if let account = acc["Stripe_Owner_Connect_Account"] as? String {
                
                          let PaidPrice = price * 100
                        
                          
                          self.make_payment(price: PaidPrice, account: account)
                          
                          
                      }
                      
                  }
              }
              
          })
          
    
      }
    
    
    func make_payment(price: Double, account: String){
        
        
        let fPrice = Int(price)
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("Transfer_payment")
        
        self.order_status = "Cooked"
        
        SwiftLoader.hide()
        AF.request(urls!, method: .post, parameters: [
            
            "price": fPrice,
            "account": account
            
            ])
            
            .validate(statusCode: 200..<500)
            .responseJSON { responseJSON in
                
                switch responseJSON.result {
                    
                case .success(let json):
                    
                    
                   
           
                    print(json)
                    
                    
                    
                case .failure( _):
                    
                    
                
                    self.showErrorAlert("Oops !!!", msg: "Due to some unknown errors, we can't pay you now. Please contact us to solve the issue")
                    
                }
                
                
        }
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
    
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return detail.count
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = detail[indexPath.row]
                   
        if let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailCell") as? OrderDetailCell {
         
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
                       
            return OrderDetailCell()
                       
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100.0
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
    
    func caculateSummary() {
        
        
        var subtotal: Float!
        var Application: Float!
        var Tax: Float!
        var total: Float!
        
        subtotal = 0.0
        Application = 0.0
        Tax = 0.0
        total = 0.0
        
        for i in detail {
            
            let quanlity = i._NewQuanlity
            let price = i.price * Float(quanlity!)
            subtotal += price
            
        }
        
        if promo_id != "Nil" {
            
            checkpromo(subtotal: subtotal, Promo_id: promo_id)
            
        } else {
            
            Application = 0.00
            Tax = subtotal * 9 / 100
            total = subtotal + Application + Tax
            
            paid_price = Double(subtotal + Tax)
            
            
            SubtotalPrice.text = "$\(String(format:"%.2f", subtotal!))"
            ApplicationFee.text = "$\(String(format:"%.2f", Application!))"
            TaxFee.text = "$\(String(format:"%.2f", Tax!))"
            TotalFee.text = "$\(String(format:"%.2f", total!))"
            
        }
       
        
        
        
      
    }
    
    func checkpromo(subtotal: Float, Promo_id: String) {
        
        DataService.instance.mainFireStoreRef.collection("Voucher").whereField("Created by", isEqualTo: "Restaurant").whereField("restaurant_id", isEqualTo: load_id).getDocuments { (snap, err) in
               
                   
               if err != nil {
                   
                   var Application: Float!
                
                   Application = 0.00
                   let Tax = subtotal * 9 / 100
                   let total = subtotal + Application + Tax
                   
                   self.paid_price = Double(subtotal + Tax)
                   
                   
                   self.SubtotalPrice.text = "$\(String(format:"%.2f", subtotal))"
                   self.ApplicationFee.text = "$\(String(format:"%.2f", Application!))"
                   self.TaxFee.text = "$\(String(format:"%.2f", Tax))"
                   self.TotalFee.text = "$\(String(format:"%.2f", total))"
                   
                   return
                   
               }
                   
                   if snap?.isEmpty == true {
                       
                       var Application: Float!
                       
                          Application = 0.00
                          let Tax = subtotal * 9 / 100
                          let total = subtotal + Application + Tax
                          
                          self.paid_price = Double(subtotal + Tax)
                          
                          
                          self.SubtotalPrice.text = "$\(String(format:"%.2f", subtotal))"
                          self.ApplicationFee.text = "$\(String(format:"%.2f", Application!))"
                          self.TaxFee.text = "$\(String(format:"%.2f", Tax))"
                          self.TotalFee.text = "$\(String(format:"%.2f", total))"
                       
                       return
                       
                       
                   } else {
                      
                       
                       var count = 0
                       var found = false
                       let limit = snap?.count
                     
                       for item in snap!.documents {
                           
                           count += 1
                           if item.documentID == Promo_id {
                               
                               
                               found = true
                               
                               let data = VoucherModel(postKey: item.documentID, Voucher_model: item.data())
                               
                              
                               
                               if data.type == "%" {
                                               
                                               if let percentage = data.value as? String {
                                               
                                                   let new = Float(percentage)
                                                   let promo = subtotal*new!/100
                                                   
                                                   
                                                   let AdjustSubtotal = subtotal - promo
                                                   let Tax = AdjustSubtotal * 9 / 100
                                                   let total = AdjustSubtotal + Tax
                                                   
                                                   self.paid_price = Double(AdjustSubtotal + Tax)
                                                   
                                                   
                                                   self.SubtotalPrice.text = "$\(String(format:"%.2f", subtotal))"
                                                   self.ApplicationFee.text = "- $\(String(format:"%.2f", promo))"
                                                   self.TaxFee.text = "$\(String(format:"%.2f", Tax))"
                                                   self.TotalFee.text = "$\(String(format:"%.2f", total))"
                                                                                                   
                                               }
                                                   else {
                                                                   
                                                   print("Can't convert \(data.value!)")
                                                   
                                               }
                                               
                                             
                                           } else if data.type == "$" {
                                           
                                               
                                               if let minus = data.value as? String {
                               
                                                 let new = Float(minus)
                                                 var promo: Float!
                                                 promo =  new
                                                 var AdjustSubtotal = subtotal - new!
                                                   
                                                 if AdjustSubtotal <= 0 {
                                                       AdjustSubtotal = 0.0
                                                 }
                                                   
                                                 let Tax = AdjustSubtotal * 9 / 100
                                                 let total = AdjustSubtotal + Tax
                                                 
                                                 self.paid_price = Double(AdjustSubtotal + Tax)
                                                 
                                                 
                                                 self.SubtotalPrice.text = "$\(String(format:"%.2f", subtotal))"
                                                 self.ApplicationFee.text = "- $\(String(format:"%.2f", promo))"
                                                 self.TaxFee.text = "$\(String(format:"%.2f", Tax))"
                                                 self.TotalFee.text = "$\(String(format:"%.2f", total))"
                                                   
                                               }
                                               else {
                                                   
                                                   print("Can't convert \(data.value!)")
                                               }
                                      
                                               
                                               
                                           } else {
                                               print("Unknown \(data.type!)")
                                           }
                               
                               
                           }
                           
                       }
                       
                       
                       if count == limit!, found == false {
                           
                           var Application: Float!
                           
                              Application = 0.00
                              let Tax = subtotal * 9 / 100
                              let total = subtotal + Application + Tax
                              
                              self.paid_price = Double(subtotal + Tax)
                              
                              
                              self.SubtotalPrice.text = "$\(String(format:"%.2f", subtotal))"
                              self.ApplicationFee.text = "$\(String(format:"%.2f", Application!))"
                              self.TaxFee.text = "$\(String(format:"%.2f", Tax))"
                              self.TotalFee.text = "$\(String(format:"%.2f", total))"
                           
                           return
                           
                         
                           
                       }
                       
                       
                       
                       
                   }
        
               
                   
                   
                   
               }
        
        
    }
    
    @IBAction func orderActionBtnPressed(_ sender: Any) {
        
        if actionBtn.titleLabel!.text == "Completed" {
            
            
        } else {
            
            loadPhone()
            
        }
 
        
    }
    
    func loadPhone() {
        
        swiftLoader()
        DataService.instance.mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: order_userUID).getDocuments { (business, err) in
        
        
            if err != nil {
                   
                SwiftLoader.hide()
                print(err!.localizedDescription)
                return
                   
            }
            
   
            for item in business!.documents {
                
                if let phone = item["Phone"] as? String {
                    
                    
                    if self.order_status == "Processed" {
                        DataService.instance.mainFireStoreRef.collection("Processing_orders").document(self.Order_key).updateData(["Order_time": FieldValue.serverTimestamp(), "Status": "Started"])
                        self.sendSmsNoti(Phone: phone, text: "Your uEAT order CC - \(self.order_ID) is being prepared")
                        self.actionBtn.setTitle("Ready for pick up", for: .normal)
                        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "refreshOrder")), object: nil)
                        self.order_status = "Started"
                        self.userStartNoti()
                        SwiftLoader.hide()
                        
                    } else if self.order_status == "Started" {
                        self.swiftLoader()
                        DataService.instance.mainFireStoreRef.collection("Processing_orders").document(self.Order_key).updateData(["Order_time": FieldValue.serverTimestamp(), "Status": "Cooked"])
                        self.sendSmsNoti(Phone: phone, text: "Your uEAT order CC - \(self.order_ID) is ready for pick up")
                        self.actionBtn.setTitle("Picked up", for: .normal)
                        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "refreshOrder")), object: nil)
                        self.userReadyNoti()
                        self.capturePayment()
                        
                    } else if self.order_status == "Cooked" {
                        
                        DataService.instance.mainFireStoreRef.collection("Processing_orders").document(self.Order_key).updateData(["Order_time": FieldValue.serverTimestamp(), "Status": "Completed"])
                        self.sendSmsNoti(Phone: phone, text: "Your uEAT order CC - \(self.order_ID) is picked up")
                        self.actionBtn.setTitle("Completed", for: .normal)
                        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "refreshOrder")), object: nil)
                        self.order_status = "Completed"
                        self.closeChat()
                        
                        
                    } else {
                        
                      
                        self.actionBtn.isUserInteractionEnabled = false
                        self.actionBtn.setTitle("Completed", for: .normal)
                        
                    }
                    
                    
              
                }
                
                
                
                
            }
            
            
            
        }
        
        
    }
    
    func closeChat() {
        
        DataService.instance.mainFireStoreRef.collection("Chat_orders").whereField("Restaurant_ID", isEqualTo: self.res_id).whereField("order_id", isEqualTo: order_ID).getDocuments { (snap, err) in
        
        if err != nil {
            
            return
            
        }
            
            for item in snap!.documents {
                let id = item.documentID
                print(id)
                DataService.instance.mainFireStoreRef.collection("Chat_orders").document(id).updateData(["Status": "Closed"])
                SwiftLoader.hide()
            
            }
              
        }
        
    }
    
    func userStartNoti() {
        
        DataService.instance.mainRealTimeDataBaseRef.child("userStartNoti").child(self.order_userUID).child(self.order_ID).removeValue()
        let values: Dictionary<String, AnyObject>  = [self.order_ID: 1 as AnyObject]
        DataService.instance.mainRealTimeDataBaseRef.child("userStartNoti").child(self.order_userUID).setValue(values)
        
    }
    
    func userReadyNoti() {
        
        DataService.instance.mainRealTimeDataBaseRef.child("userReadyNoti").child(self.order_userUID).child(self.order_ID).removeValue()
        let values: Dictionary<String, AnyObject>  = [self.order_ID: 1 as AnyObject]
        DataService.instance.mainRealTimeDataBaseRef.child("userReadyNoti").child(self.order_userUID).setValue(values)
        
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
    
    func sendSmsNoti(Phone: String, text: String) {
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("sms_noti")
        
        AF.request(urls!, method: .post, parameters: [
            
            "phone": Phone,
            "body": text
            
            
            ])
            
            .validate(statusCode: 200..<500)
            .responseJSON { responseJSON in
                
                switch responseJSON.result {
                    
                    
                case .success(let json):
                    
                    print( json)
                    
                case .failure(let err):
                    
                    print(err)
                }
                
        }
        
    }
    
}
