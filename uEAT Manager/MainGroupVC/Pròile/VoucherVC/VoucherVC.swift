//
//  VoucherVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/9/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase
import MGSwipeTableCell

class VoucherVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate {
    
    var restaurant_id = ""
    var voucher = [VoucherModel]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        voucher.removeAll()
        self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
    
        if voucher.isEmpty != true {
            
            tableView.restore()
            return 1
        } else {
            
            tableView.setEmptyMessage("Don't have any voucher, let's create one !!!")
            return 1
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
         return voucher.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let item = voucher[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "VoucherCell") as? VoucherCell {
            
          
            
            if item.status != "Online" {
                cell.contentView.backgroundColor = UIColor.placeholderText
                
            } else {
                cell.contentView.backgroundColor = UIColor.clear
                
            }
            
            cell.delegate = self
            cell.configureCell(item)
            return cell
                       
                       
        } else {
                       
            return VoucherCell()
                       
        }

    
        
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return ""
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90.0
        
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
              return true;
          }
          
          // Fetch object from the cache
          
          func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
              
              
              let color = UIColor(red: 249/255, green: 252/255, blue: 254/255, alpha: 1.0)
              
              swipeSettings.transition = MGSwipeTransition.border;
              expansionSettings.buttonIndex = 0
              let padding = 25
              if direction == MGSwipeDirection.rightToLeft {
                  expansionSettings.fillOnTrigger = false;
                  expansionSettings.threshold = 1.1
                  

                  let RemoveResize = resizeImage(image: UIImage(named: "remove")!, targetSize: CGSize(width: 25.0, height: 25.0))
                  let availableResize = resizeImage(image: UIImage(named: "Security")!, targetSize: CGSize(width: 25.0, height: 25.0))
                    
                  let remove = MGSwipeButton(title: "", icon: RemoveResize, backgroundColor: color, padding: padding,  callback: { (cell) -> Bool in
                   
                       
                       let sheet = UIAlertController(title: "Are you sure to remove this item", message: "", preferredStyle: .actionSheet)
                       
                       
                       
                       let delete = UIAlertAction(title: "Delete", style: .default) { (alert) in
                           
                           self.deleteAtIndexPath(self.tableView.indexPath(for: cell)!)
                           
                       }
                       
                       let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
                           
                       }
                       

                       sheet.addAction(delete)
                       sheet.addAction(cancel)
                       self.present(sheet, animated: true, completion: nil)

                       
                      
                      return false; //don't autohide to improve delete animation
                      
                      
                  });
               

               
                 
               let available = MGSwipeButton(title: "", icon: availableResize, backgroundColor: color, padding: padding,  callback: { (cell) -> Bool in
                
                   
                   self.availableAt(self.tableView.indexPath(for: cell)!)
                   
                   
                   
                   return false; //don't autohide to improve delete animation
                   
                   
               });
               
                

                  return [remove, available]
               
              } else {
                  
                  return nil
               
              }
                 
              
       }
    func deleteAtIndexPath(_ path: IndexPath) {
     
        swiftLoader()
        
        let item = voucher[(path as NSIndexPath).row]
       
        DataService.instance.mainFireStoreRef.collection("Voucher").whereField("restaurant_id", isEqualTo: self.restaurant_id).whereField("title", isEqualTo: item.title as Any).whereField("description", isEqualTo: item.description as Any).whereField("category", isEqualTo: item.category as Any).getDocuments { (snap, err) in
        
                if err != nil {
                    
                    SwiftLoader.hide()
                    self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                    return
                    
                }
                

                for item in snap!.documents {
                    
                    let id = item.documentID
                    DataService.instance.mainFireStoreRef.collection("Voucher").document(id).delete()
                    
                    self.voucher.remove(at: (path as NSIndexPath).row)
                    self.tableView.deleteRows(at: [path], with: .left)

                    SwiftLoader.hide()
                    
                    
            }
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func availableAt(_ path: IndexPath) {
        
        swiftLoader()
        
        let item = voucher[(path as NSIndexPath).row]
        
        var update = ""
        
        var i: VoucherModel!
        
        if item.status != "Online" || item.status == "" {
            
            update = "Online"
            let dict = ["title": item.title!, "description": item.description!, "category": item.category!, "type": item.type!, "value": item.value!, "restaurant_id": item.restaurant_id!, "timeStamp": FieldValue.serverTimestamp(),  "status": "Online"] as [String : Any]
            i = VoucherModel(postKey: "Updated", Voucher_model: dict)
            
           
            
            
        } else {
            
            update = "Offline"
            let dict = ["title": item.title!, "description": item.description!, "category": item.category!, "type": item.type!, "value": item.value!, "restaurant_id": item.restaurant_id!, "timeStamp": FieldValue.serverTimestamp(),  "status": "Offline"] as [String : Any]
            i = VoucherModel(postKey: "Updated", Voucher_model: dict)
            
           
        }
        
        self.voucher.remove(at: (path as NSIndexPath).row)
        self.voucher.insert(i, at: (path as NSIndexPath).row)

        
        DataService.instance.mainFireStoreRef.collection("Voucher").whereField("restaurant_id", isEqualTo: self.restaurant_id).whereField("title", isEqualTo: item.title as Any).whereField("description", isEqualTo: item.description as Any).whereField("category", isEqualTo: item.category as Any).getDocuments { (snap, err) in
        
                if err != nil {
                    
                    SwiftLoader.hide()
                    self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                    return
                    
                }
                

                for item in snap!.documents {
                    
                    let id = item.documentID
                    DataService.instance.mainFireStoreRef.collection("Voucher").document(id).updateData(["status": update])

                    SwiftLoader.hide()
                    
                    
            }
            
            self.tableView.reloadData()
            
        }
        
        
        
        
    }
    
    @IBAction func CreateBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToCreateVoucherVC", sender: nil)
        
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
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
                    self.loadVoucher(id: id)
                    
                    
                }
                
                
                
            }
            
            

            
        }

        
        

    }
    
    func loadVoucher(id: String) {
        

        
        DataService.instance.mainFireStoreRef.collection("Voucher").whereField("restaurant_id", isEqualTo: id).order(by: "timeStamp", descending: true).getDocuments { (snap, err) in
        
        if err != nil {
            
            self.showErrorAlert("Opss !", msg: err!.localizedDescription)
            return
            
        }
        
        
        for item in snap!.documents {
            
            let dict = VoucherModel(postKey: item.documentID, Voucher_model: item.data())
            
            self.voucher.append(dict)
            
            }
            
            self.tableView.reloadData()
            
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
