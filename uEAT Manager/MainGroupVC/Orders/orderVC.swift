//
//  orderVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/6/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase

class orderVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var AcceptedBtn: UIButton!
    @IBOutlet weak var CompletedBtn: UIButton!
    @IBOutlet weak var cookingBtn: UIButton!
    @IBOutlet weak var PickingUpBtn: UIButton!
    
    var orderObserve: UInt!
    
    var type = ""
    var orderArr = [OrderModel]()
 
    var order_ID = ""
    var order_userUID = ""
    var order_status = ""
    var Order_key = ""
    var res_id = ""
    var promo_id = ""
    private var pullControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        

        
        AcceptedBtn.backgroundColor = UIColor.yellow
        CompletedBtn.backgroundColor = UIColor.clear
        type = "Processed"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
    
        
        self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
        
        
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
        
    }
    
    
    func loadOrder(id: String, status: String) {
        
        DataService.instance.mainFireStoreRef.collection("Processing_orders").order(by: "Order_time", descending: true).whereField("Restaurant_id", isEqualTo: id).whereField("Status", isEqualTo: status).limit(to: 25).getDocuments { (snaps, err) in
         
         if err != nil {
             
            
           
             self.showErrorAlert("Opss !", msg: err!.localizedDescription)
             return
             
         }
             
             
            
            if snaps?.isEmpty == true {
                
                
                self.orderArr.removeAll()
                self.tableView.reloadData()
                return
                
            }
         
             self.orderArr.removeAll()
            
             for item in snaps!.documents {
                
                let order = OrderModel(postKey: item.documentID, Order_model: item.data())
                 self.orderArr.append(order)
         
             }
             
            if self.pullControl.isRefreshing == true {
                self.pullControl.endRefreshing()
            }
            
             self.tableView.reloadData()
             
             
             
             
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
            
                
                self.showErrorAlert("Opss !", msg: "Can't validate your menu")
                return
            
            }
            
            
            if snap?.isEmpty == true {
                
                
                self.showErrorAlert("Opss !", msg: "Your account isn't ready yet, please wait until getting an email from us or you can contact our support")
                          
            } else {
                
                
                for item in snap!.documents {
                    
                    let res_id = item.documentID
                    load_id = res_id
                    
                    if self.orderObserve != nil {
                        
                        DataService.instance.mainRealTimeDataBaseRef.removeObserver(withHandle: self.orderObserve)
                        
                    }
                  
                    self.orderObserve = DataService.instance.mainRealTimeDataBaseRef.child("Upcomming_order").child(res_id).observe(.value, with: { (cancelData) in
                        
                        if self.type == "Processed" {
                            self.loadOrder(id:res_id, status: "Processed")
                        } else if self.type == "Started" {
                            self.loadOrder(id:res_id, status: "Started")
                        } else if self.type == "Cooked" {
                            self.loadOrder(id:res_id, status: "Cooked")
                        } else {
                            self.loadOrder(id:res_id, status: "Completed")
                        }
                        
                    })


                    
                }
                
                
                
            }
            
            
            
        }
        
        

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        if orderArr.isEmpty != true {
            
            tableView.restore()
            return 1
            
        } else {
            
            tableView.setEmptyMessage("Loading orders !!!")
            return 1
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = orderArr[indexPath.row]
                   
                   
        if let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell") as? OrderCell {
           
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
                       
            return OrderCell()
                       
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80.0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = orderArr[indexPath.row]
        
        order_ID = item.Order_id
        order_userUID = item.UID
        order_status = item.Status
        Order_key = item.Order_key
        res_id = item.Restaurant_id
        promo_id = item.Promo_id

        
        NotificationCenter.default.addObserver(self, selector: #selector(orderVC.refreshOrder), name: (NSNotification.Name(rawValue: "refreshOrder")), object: nil)
        self.performSegue(withIdentifier: "moveToOrderDetailVC", sender: nil)
        
    }
    
    @objc func refreshOrder() {
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "refreshOrder")), object: nil)
        self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToOrderDetailVC"{
            if let destination = segue.destination as? OrderDetailVC
            {
                
                destination.order_ID = self.order_ID
                destination.order_userUID = self.order_userUID
                destination.order_status = self.order_status
                destination.Order_key = Order_key
                destination.res_id = res_id
                destination.promo_id = promo_id
                
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

    

    @IBAction func AcceptedBtnPressed(_ sender: Any) {
        
    
        if self.type != "Accepted" {
            self.type = "Processed"
            
            
            AcceptedBtn.backgroundColor = UIColor.yellow
            cookingBtn.backgroundColor = UIColor.clear
            PickingUpBtn.backgroundColor = UIColor.clear
            CompletedBtn.backgroundColor = UIColor.clear
            
            self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
        }
        
        
    }
    
    @IBAction func PickingUpBtnPressed(_ sender: Any) {
        
        if self.type != "Picked up" {
            self.type = "Cooked"
            
            
            AcceptedBtn.backgroundColor = UIColor.clear
            cookingBtn.backgroundColor = UIColor.clear
            PickingUpBtn.backgroundColor = UIColor.yellow
            CompletedBtn.backgroundColor = UIColor.clear
            
            self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
            
        }
    }
    
    @IBAction func CompletedBtnPressed(_ sender: Any) {
        
        if self.type != "Completed" {
            self.type = "Completed"
            
            
            AcceptedBtn.backgroundColor = UIColor.clear
            cookingBtn.backgroundColor = UIColor.clear
            PickingUpBtn.backgroundColor = UIColor.clear
            CompletedBtn.backgroundColor = UIColor.yellow
            
            
            self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
            
        }
        
        
        
        
        
        
    }
    
    @IBAction func CookingBtnPressed(_ sender: Any) {
        
        if self.type != "Started" {
            self.type = "Started"
            
            
            AcceptedBtn.backgroundColor = UIColor.clear
            cookingBtn.backgroundColor = UIColor.yellow
            PickingUpBtn.backgroundColor = UIColor.clear
            CompletedBtn.backgroundColor = UIColor.clear
            
            self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
            
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
