//
//  MenuVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/6/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase
import MGSwipeTableCell

class MenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate {

    @IBOutlet weak var updateBtnPressed: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    var ModifyItem: ItemModel!
    
    var section = ["Non-Vegan", "Vegan", "Add-Ons"]
    var menu = [[ItemModel]]()
    var vegan = [ItemModel]()
    var Nonvegan = [ItemModel]()
    var AddOn = [ItemModel]()
    
    var Newvegan = [ItemModel]()
    var NewNonvegan = [ItemModel]()
    var NewAddOn = [ItemModel]()
    
    var counted = 0
    var sum = 0
    var restaurant_id = ""
    
    var MenuObserve: UInt!
    
    private var pullControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
        
        pullControl.tintColor = UIColor.black
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = pullControl
        } else {
            tableView.addSubview(pullControl)
        }
        
     
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        transitem = nil
        presented = nil
        
        
        
        self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
        
        
    }
    
    func checkUpdate() {
        
        if Newvegan.isEmpty != true || NewNonvegan.isEmpty != true || NewNonvegan.isEmpty != true {
            
            updateBtnPressed.isHidden = false
            
        } else {
             updateBtnPressed.isHidden = true
        }
        
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
                    
                    
                    let id = item.documentID
                    self.restaurant_id = id
                    
                    
                    if self.MenuObserve != nil {
                          
                          DataService.instance.mainRealTimeDataBaseRef.removeObserver(withHandle: self.MenuObserve)
                          
                      }
                    
                 
                    
                    self.MenuObserve = DataService.instance.mainRealTimeDataBaseRef.child("Upcomming_menu").child(item.documentID).observe(.value, with: { (cancelData) in
                          
                        
                        
                        self.loadMenu(id: id)
                          
                         
                          
                      })
                    
                    
                   
                    
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
            
            var count = 0
            
            self.vegan.removeAll()
            self.Nonvegan.removeAll()
            self.AddOn.removeAll()
            self.menu.removeAll()
            
            self.NewAddOn.removeAll()
            self.Newvegan.removeAll()
            self.NewNonvegan.removeAll()
            
            
            for item in snap!.documents {
                

                count += 1
                let dict = ItemModel(postKey: item.documentID, Item_model: item.data())
                

                if let type = item["type"] as? String {
                    
                    if type == "Vegan" {
                        
                        self.vegan.append(dict)
                        
                    } else if type == "Non-Vegan" {
                        
                        self.Nonvegan.append(dict)
                        
                    } else {
                        
                        self.AddOn.append(dict)
                        
                    }
                }
                
   
            }
            self.menu.append(self.Nonvegan)
            self.menu.append(self.vegan)
            
            self.menu.append(self.AddOn)
            
            
            if self.pullControl.isRefreshing == true {
                self.pullControl.endRefreshing()
            }
            
            
            SwiftLoader.hide()
            self.tableView.reloadData()
            
   
        }
        
    }
    
    
    @objc private func refreshListData(_ sender: Any) {
       // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
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
    
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        if menu.isEmpty != true {
            
            tableView.restore()
            return menu.count
            
        } else {
            
            tableView.setEmptyMessage("Loading menu !!!")
            return menu.count
            
        }
    

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
         return menu[section].count + 1
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        

        if indexPath.row == 0 {
            
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "addNewItemCell") as? addNewItemCell {
               
               cell.addItemBtn.addTarget(self, action: #selector(MenuVC.addItemBtnPressed), for: .touchUpInside)
               
               
               return cell
                
                
            } else {
                
                return addNewItemCell()
                
            }
            
        
            
         } else {
            
            let item = menu[indexPath.section][indexPath.row - 1]
                       
                       
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell2") as? ItemCell2 {
                
                
                if item.status != "Online" {
                    
                    cell.lock.isHidden = false
                    cell.Quanlity.isHidden = true
                    
                } else {
                    cell.lock.isHidden = true
                    
                    if item.quanlity == "0" {
                        
                        cell.Quanlity.isHidden = false
                        cell.lim.text = "Limit"
                    } else if item.quanlity == "None" {
                        cell.Quanlity.isHidden = true
                         cell.lim.text = "No limit"
                        
                    }
                }
                 
                
               cell.delegate = self
                
               cell.PlusAction = { [unowned self] in
                    
                 
                    self.handleCount(self.tableView.indexPath(for: cell)!, type: "Plus")
                
                
               }
                
                cell.MinusAction = { [unowned self] in
                  
                    self.handleCount(self.tableView.indexPath(for: cell)!, type: "Minus")
                 
               }
                
                        
               
                
                cell.configureCell(item)

                return cell
                           
            } else {
                           
                return ItemCell()
                           
            }
             
         }

    
        
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return ""
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 140.0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        let item = menu[indexPath.section][indexPath.row - 1]
        
        
        self.ModifyItem = item
        
        self.performSegue(withIdentifier: "moveToDetailMenu2", sender: nil)
        
        
        

      
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if segue.identifier == "moveToDetailMenu2"{
            if let destination = segue.destination as? ItemMenuDetailVC {
                
                destination.ModifyItem = self.ModifyItem
            
                
            }
        }
        
        
    }
    
    func handleCount(_ path: IndexPath, type: String) {
        
        
        let item = menu[(path as NSIndexPath).section][(path as NSIndexPath).row - 1]
        
        if item.Updated == false {
            
            SwiftLoader.hide()
            self.showErrorAlert("Oops !!!", msg: "This item isn't up, please tap update to make it available to modify.")
            return
            
        }
        
        
        DataService.instance.mainFireStoreRef.collection("Menu").whereField("name", isEqualTo:  item.name as Any).whereField("description", isEqualTo:  item.description as Any).whereField("category", isEqualTo:  item.category as Any).getDocuments { (snap, err) in
        
                if err != nil {
                    
                    return
                    
                }
            
                var i: ItemModel!

                for items in snap!.documents {
                    
                    if let count = items["count"] as? Int {
                        var cum = 0
                        if type == "Plus" {
                            cum = count + 1
                        } else if type == "Minus" {
                            cum = count - 1
                        } else {
                            cum = count + 0
                        }
                        
                        if cum <= 0 {
                            
                            self.swiftLoader()
                            
                            let id = items.documentID
                            DataService.instance.mainFireStoreRef.collection("Menu").document(id).updateData(["status": "Offline"])
                            
                            let dict = ["name": item.name as Any, "description": item.description as Any, "price": item.price as Any, "url": item.url as Any, "category": item.category as Any, "type": item.type as Any, "status": "Offline", "quanlity": item.quanlity as Any, "Updated": true] as [String : Any]
                            i = ItemModel(postKey: "Updated", Item_model: dict)
                            
                            if let type = item.type {
                                     
                                 if type == "Vegan"{
                                     
                                     self.vegan.remove(at: (path as NSIndexPath).row - 1)
                                     self.vegan.insert(i, at: (path as NSIndexPath).row - 1)
                            
                                 } else if type == "Non-Vegan" {
                                                       
                                     self.Nonvegan.remove(at: (path as NSIndexPath).row - 1)
                                     self.Nonvegan.insert(i, at: (path as NSIndexPath).row - 1)
                                     
                                 } else {
                                     
                                     self.AddOn.remove(at: (path as NSIndexPath).row - 1)
                                     self.AddOn.insert(i, at: (path as NSIndexPath).row - 1)
                                 }
                             
                             
                            }
                            
                            self.menu.removeAll()
                            self.menu.append(self.Nonvegan)
                            self.menu.append(self.vegan)
                            self.menu.append(self.AddOn)
                            
                            self.checkUpdate()
                            SwiftLoader.hide()
                            self.tableView.reloadData()
                            
                        } else {
                            let id = items.documentID
                            DataService.instance.mainFireStoreRef.collection("Menu").document(id).updateData(["count": cum])
                            
                        }
                    } else {
                        let id = items.documentID
                        DataService.instance.mainFireStoreRef.collection("Menu").document(id).updateData(["count": 1])
                        
                    }
                    
                    self.tableView.reloadData()
                    
            }
            
        }
        
    }
    

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 55))
        returnedView.backgroundColor = .clear

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        label.textColor = .black
        label.text = self.section[section]
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        returnedView.addSubview(label)

        return returnedView
    }
    
    @objc func addItemBtnPressed() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(MenuVC.setItem), name: (NSNotification.Name(rawValue: "setItem")), object: nil)
        
        self.ModifyItem = nil
        
           
        self.performSegue(withIdentifier: "moveToDetailMenu2", sender: nil)
    
           
    }
    
    @objc func setItem() {
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "setItem")), object: nil)
        processItem(item: transitem)
        checkUpdate()
        transitem = nil
        presented = nil

    }

    
    func processItem(item: ItemModel) {
        
        
        if let type = item.type {
            
            if type == "Vegan" {
                
                Newvegan.insert(item, at: 0)
                vegan.insert(item, at: 0)
                        
            } else if type == "Non-Vegan" {
                
                NewNonvegan.insert(item, at: 0)
                Nonvegan.insert(item, at: 0)
                
            } else {
                
                NewAddOn.insert(item, at: 0)
                AddOn.insert(item, at: 0)
                
            }
            
            self.menu.removeAll()
            menu.append(Nonvegan)
            menu.append(vegan)
            menu.append(AddOn)
         
            
           self.tableView.reloadData()
            
        }
        
        
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
               let qualityResize = resizeImage(image: UIImage(named: "Payment")!, targetSize: CGSize(width: 25.0, height: 25.0))
                 
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
            
              
            let quality = MGSwipeButton(title: "", icon: qualityResize, backgroundColor: color, padding: padding,  callback: { (cell) -> Bool in
             
             
                self.QuanlityAt(self.tableView.indexPath(for: cell)!)
                //self.deleteAtIndexPath(self.tableView.indexPath(for: cell)!)
                
                return false; //don't autohide to improve delete animation
                
                
            });

               return [remove, available, quality]
            
           } else {
               
               return nil
            
           }
              
           
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
    
        
    func availableAt(_ path: IndexPath) {
        
        swiftLoader()
        
        let item = menu[(path as NSIndexPath).section][(path as NSIndexPath).row - 1]
        
        if item.Updated == false {
            
            SwiftLoader.hide()
            self.showErrorAlert("Oops !!!", msg: "This item isn't up, please tap update to make it available to modify.")
            return
            
        }
        
        var update = ""
        
        var i: ItemModel!
        
        if item.status != "Online" || item.status == "" {
            
            update = "Online"
            let dict = ["name": item.name as Any, "description": item.description as Any, "price": item.price as Any, "url": item.url as Any, "category": item.category as Any, "type": item.type as Any, "status": "Online", "quanlity": item.quanlity as Any, "Updated": true] as [String : Any]
            i = ItemModel(postKey: "Updated", Item_model: dict)
            
            
        } else {
            
            update = "Offline"
            let dict = ["name": item.name as Any, "description": item.description as Any, "price": item.price as Any, "url": item.url as Any, "category": item.category as Any, "type": item.type as Any, "status": "Offline", "quanlity": item.quanlity as Any, "Updated": true] as [String : Any]
            i = ItemModel(postKey: "Updated", Item_model: dict)
        
        }
        
        if let type = item.type {
                 
             if type == "Vegan"{
                 
                 self.vegan.remove(at: (path as NSIndexPath).row - 1)
                 self.vegan.insert(i, at: (path as NSIndexPath).row - 1)
        
             } else if type == "Non-Vegan" {
                                   
                 self.Nonvegan.remove(at: (path as NSIndexPath).row - 1)
                 self.Nonvegan.insert(i, at: (path as NSIndexPath).row - 1)
                 
             } else {
                 
                 self.AddOn.remove(at: (path as NSIndexPath).row - 1)
                 self.AddOn.insert(i, at: (path as NSIndexPath).row - 1)
             }
         
         
        }
        
        
        
       
        
        DataService.instance.mainFireStoreRef.collection("Menu").whereField("restaurant_id", isEqualTo: self.restaurant_id).whereField("name", isEqualTo: item.name as Any).whereField("description", isEqualTo: item.description as Any).whereField("category", isEqualTo: item.category as Any).getDocuments { (snap, err) in
        
                if err != nil {
                    
                    SwiftLoader.hide()
                    self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                    return
                    
                }
                

                for item in snap!.documents {
                    
                    let id = item.documentID
                    DataService.instance.mainFireStoreRef.collection("Menu").document(id).updateData(["status": update])
                    self.menu.removeAll()
                    self.menu.append(self.Nonvegan)
                    self.menu.append(self.vegan)
                    self.menu.append(self.AddOn)
                    
                    self.checkUpdate()
                    SwiftLoader.hide()
                    self.tableView.reloadData()
                    
            }
            
        }
        
        
        
        
    }
    
    
    func QuanlityAt(_ path: IndexPath) {
        
        let item = menu[(path as NSIndexPath).section][(path as NSIndexPath).row - 1]
        
        if item.Updated == false {
            
            SwiftLoader.hide()
            self.showErrorAlert("Oops !!!", msg: "This item isn't up, please tap update to make it available to modify.")
            return
            
        }
        
        var update = ""
        
        swiftLoader()
        
        var i: ItemModel!
        
        if item.quanlity == "None" || item.quanlity == "" {
            
            let dict = ["name": item.name as Any, "description": item.description as Any, "price": item.price as Any, "url": item.url as Any, "category": item.category as Any, "type": item.type as Any, "status": item.status as Any, "quanlity": "0", "Updated": true] as [String : Any]
            
            update = "0"
            i = ItemModel(postKey: "Updated", Item_model: dict)
            
            
        } else {
            
            let dict = ["name": item.name as Any, "description": item.description as Any, "price": item.price as Any, "url": item.url as Any, "category": item.category as Any, "type": item.type as Any, "status": item.status as Any, "quanlity": "None", "Updated": true] as [String : Any]
            
            update = "None"
            i = ItemModel(postKey: "Updated", Item_model: dict)
        
        }
        
        if let type = item.type {
                 
             if type == "Vegan"{
                 
                 self.vegan.remove(at: (path as NSIndexPath).row - 1)
                 self.vegan.insert(i, at: (path as NSIndexPath).row - 1)
        
             } else if type == "Non-Vegan" {
                 
                                 
                 self.Nonvegan.remove(at: (path as NSIndexPath).row - 1)
                 self.Nonvegan.insert(i, at: (path as NSIndexPath).row - 1)
                 
             } else {
                 

        
                 self.AddOn.remove(at: (path as NSIndexPath).row - 1)
                 self.AddOn.insert(i, at: (path as NSIndexPath).row - 1)
             }
         
         
         }
        
        DataService.instance.mainFireStoreRef.collection("Menu").whereField("restaurant_id", isEqualTo: self.restaurant_id).whereField("name", isEqualTo: item.name as Any).whereField("description", isEqualTo: item.description as Any).whereField("category", isEqualTo: item.category as Any).getDocuments { (snap, err) in
        
                if err != nil {
                    
                    SwiftLoader.hide()
                    self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                    return
                    
                }
                

                for item in snap!.documents {
                    
                    let id = item.documentID
                    DataService.instance.mainFireStoreRef.collection("Menu").document(id).updateData(["quanlity": update])
                    self.menu.removeAll()
                    self.menu.append(self.Nonvegan)
                    self.menu.append(self.vegan)
                    self.menu.append(self.AddOn)
                    
                    self.checkUpdate()
                    SwiftLoader.hide()
                    self.tableView.reloadData()
                    
            }
            
        }
        
        
        
    }
       
       
       func deleteAtIndexPath(_ path: IndexPath) {
        
           let item = menu[(path as NSIndexPath).section][(path as NSIndexPath).row - 1]
          
           if let type = item.type {
                    
                if type == "Vegan"{
                    
                    
                    if Newvegan.isEmpty != true {
                        Newvegan.remove(at: (path as NSIndexPath).row - 1)
                    }
                    
                    self.vegan.remove(at: (path as NSIndexPath).row - 1)
           
                } else if type == "Non-Vegan" {
                    
                    
                   
                    if NewNonvegan.isEmpty != true {
                        NewNonvegan.remove(at: (path as NSIndexPath).row - 1)
                    }
                    
                    self.Nonvegan.remove(at: (path as NSIndexPath).row - 1)
                    
                    
                } else {
                    

                    
                    if NewAddOn.isEmpty != true {
                        NewAddOn.remove(at: (path as NSIndexPath).row - 1)
                    }
                    
                    self.AddOn.remove(at: (path as NSIndexPath).row - 1)
                    
                }
            
            
            }
        
   
     
            if item.Updated == false {
                
                
                self.menu[(path as NSIndexPath).section].remove(at: (path as NSIndexPath).row - 1)
                self.checkUpdate()
                self.tableView.reloadData()
                SwiftLoader.hide()
                return
                
            }
       
        
            DataService.instance.mainFireStoreRef.collection("Menu").whereField("restaurant_id", isEqualTo: self.restaurant_id).whereField("name", isEqualTo: item.name as Any).whereField("description", isEqualTo: item.description as Any).whereField("category", isEqualTo: item.category as Any).getDocuments { (snap, err) in
            
                    if err != nil {
                        
                        SwiftLoader.hide()
                        self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                        return
                        
                    }
                    

                    for items in snap!.documents {
                        
                        let id = items.documentID
                        DataService.instance.mainFireStoreRef.collection("Menu").document(id).delete()
                        
                        self.menu[(path as NSIndexPath).section].remove(at: (path as NSIndexPath).row - 1)
                        self.generateNotification(title: "Removed item \(item.name!)", description: "Remove \(item.name!)", type: "Remove")
                        self.checkUpdate()
                        self.tableView.reloadData()
                        
                        
                }
                
            }
        
    
           
       }
    
    
    @IBAction func UpdateBtnPressed(_ sender: Any) {
        
        
        var count = 0
        var start = 0
        
        
        self.counted = 0
        self.sum = 0
        
        
        while count < 3 {
            
            start = NewAddOn.count + Newvegan.count + NewNonvegan.count
            count += 1
            
        }
        
        sum = start
        
        if start >= 1 {
            
            uploadVegan {
                self.uploadNonVegan{
                    self.uploadAddOn{
                        
                        
            
                    }
                }
            }
            
        } else {
            
            
            self.showErrorAlert("Opss !!!", msg: "Please complete minimum 5 items to continue")
            
        }
        
    }
    
    
    func uploadVegan(completed: @escaping DownloadComplete) {
        
        
        swiftLoader()
        
        for i in Newvegan {
            if let img = i.img {
                processItem(img: img, item: i, restaurant_id: restaurant_id, type: i.type)
            }
        }
        
        Newvegan.removeAll()
        completed()
        
    }
    
    func uploadNonVegan(completed: @escaping DownloadComplete) {
        
         
        for i in NewNonvegan {
            if let img = i.img {
                processItem(img: img, item: i, restaurant_id: restaurant_id, type: i.type)
            }
        }
        
        NewNonvegan.removeAll()
        completed()
        
    }
    
    func uploadAddOn(completed: @escaping DownloadComplete) {
        
        
        for i in NewAddOn {
            if let img = i.img {
               processItem(img: img, item: i, restaurant_id: restaurant_id, type: i.type)
            }
        }
        
        
        NewAddOn.removeAll()
        
        completed()
        
        
    }
    
    func processItem(img: UIImage!, item: ItemModel, restaurant_id: String, type: String) {
        
         
          let metaData = StorageMetadata()
          let imageUID = UUID().uuidString
          metaData.contentType = "image/jpeg"
          var imgData = Data()
          imgData = img.jpegData(compressionQuality: 1.0)!
          
          
          
          DataService.instance.mainStorageRef.child(type).child(imageUID).putData(imgData, metadata: metaData) { (meta, err) in
              
              if err != nil {
                  
                  SwiftLoader.hide()
                  self.showErrorAlert("Oopss !!!", msg: "Error while saving your image, please try again")
                  print(err?.localizedDescription as Any)
                  
              } else {
                  
                  DataService.instance.mainStorageRef.child(type).child(imageUID).downloadURL(completion: { (url, err) in
                      
                      
                      guard let Url = url?.absoluteString else { return }
                      
                      let downUrl = Url as String
                      let downloadUrl = downUrl as NSString
                      let downloadedUrl = downloadUrl as String
                    
                    let dict = ["name": item.name as Any, "description": item.description as Any, "price": item.price as Any, "url": downloadedUrl as Any, "category": item.category as Any, "type": type, "restaurant_id": restaurant_id, "timeStamp": FieldValue.serverTimestamp(), "quanlity": "None", "status": "Offline", "Updated": true] as [String : Any]
                      let db = DataService.instance.mainFireStoreRef.collection("Menu")
                    
                      db.addDocument(data: dict) { err in
                      
                          if let err = err {
                              
                              SwiftLoader.hide()
                              self.showErrorAlert("Opss !", msg: err.localizedDescription)
                              
                          } else {
                            
                            
                            
                            self.counted += 1
                            self.generateNotification(title: "Updated menu", description: "Updated \(self.counted) items", type: "Add")
                            
                            if self.counted == self.sum {
                                
                                self.checkUpdate()
                                self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
                                
                                
                                
                            }
                        
                        }
                        
                        
                    }
                    
                      
                  })
                
            }
            
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
