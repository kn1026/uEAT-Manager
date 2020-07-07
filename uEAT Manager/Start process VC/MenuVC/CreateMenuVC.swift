//
//  CreateMenuVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 11/24/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//  moveToDetailTemVC

import UIKit
import MGSwipeTableCell
import Firebase
import SCLAlertView
import Alamofire

class CreateMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var section = ["Non-Vegan", "Vegan", "Add-Ons"]
    var menu = [[ItemModel]]()
    var vegan = [ItemModel]()
    var Nonvegan = [ItemModel]()
    var AddOn = [ItemModel]()
    var restaurant_id = ""
    
    var counted = 0
    var sum = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        

        menu.append(Nonvegan)
        menu.append(vegan)
        menu.append(AddOn)
        
        
        tableView.reloadData()
          
        guard Auth.auth().currentUser?.email != nil else {
            
            return
            
        }
        
       self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    
        
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
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
    
        return menu.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
         return menu[section].count + 1
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        

        if indexPath.row == 0 {
            
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "addNewItemCell") as? addNewItemCell {
               
               cell.addItemBtn.addTarget(self, action: #selector(CreateMenuVC.addItemBtnPressed), for: .touchUpInside)
               
               
               return cell
                
                
            } else {
                
                return addNewItemCell()
                
            }
            
        
            
         } else {
            
            let item = menu[indexPath.section][indexPath.row - 1]
                       
                       
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as? ItemCell {
                           
                
                cell.delegate = self
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
        
        return 90.0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        let item = menu[indexPath.section][indexPath.row - 1]
        NotificationCenter.default.addObserver(self, selector: #selector(CreateMenuVC.setItem), name: (NSNotification.Name(rawValue: "setItem")), object: nil)
        
        
        transitem = item
        originItem = item
        
     
        self.performSegue(withIdentifier: "moveToDetailTemVC", sender: nil)
      
        
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(CreateMenuVC.setItem), name: (NSNotification.Name(rawValue: "setItem")), object: nil)
           
        self.performSegue(withIdentifier: "moveToDetailTemVC", sender: nil)
    
           
    }
    
    @objc func setItem() {
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "setItem")), object: nil)
        
        if isSave == false {
            processItem(item: transitem)
        } else {
           
            replaceAndProcessItem(item: transitem)
            
        }
    
        transitem = nil
        originItem = nil

    }
    
    func replaceAndProcessItem(item: ItemModel) {
        
        if let type = originItem.type {
            
            var index = 0
           
            
            if type == "Vegan"{
                
                for i in vegan {
                    
    
                    if i.category == originItem.category, i.name == originItem.name, i.type == originItem.type {
                        
                        
                        
                        if originItem.type != item.type {
                            
                            if item.type ==  "Non-Vegan" {
                                
                                self.Nonvegan.insert(item, at: 0)
                                
                                
                            } else {
                                
                                self.AddOn.insert(item, at: 0)
                                
                            }
                            
                            
                            self.vegan.remove(at: index)
                            
                            
                        } else {
                            
                            self.vegan[index] = item
                            
                        }
                        
    
                        
                    

                    } else {
                        
                        print("Can't find")
                        
                    }
                    
                    index += 1
                    
                }
                
                
                
            } else if type == "Non-Vegan" {
                
                
                
                
                for i in Nonvegan {
                    
                    if i.category == originItem.category, i.name == originItem.name {
                        
                        if originItem.type != item.type {
                            
                            if item.type ==  "Vegan" {
                                
                                self.vegan.insert(item, at: 0)
                                
                                
                            } else {
                                
                                self.AddOn.insert(item, at: 0)
                                
                            }
                            
                            
                            self.Nonvegan.remove(at: index)
                            
                            
                        } else {
                            
                            self.Nonvegan[index] = item
                            
                        }
                        
                       
                        
                        
                      
                    } else {
                        
                        print("Can't find")
                        
                    }
                    
                    index += 1
                    
                }
                
            } else {
                
                for i in AddOn {
                                    
                    
                    if i.category == originItem.category, i.name == originItem.name {
                        
                        
                       if originItem.type != item.type {
                           
                           if item.type ==  "Vegan" {
                               
                               self.vegan.insert(item, at: 0)
                               
                               
                           } else {
                               
                               self.Nonvegan.insert(item, at: 0)
                               
                           }
                           
                           
                           self.AddOn.remove(at: index)
                           
                           
                       } else {
                            
                            self.AddOn[index] = item
                            
                        }
                      
               
                        
                       
                    } else {
                        
                        print("Can't find")
                        
                    }
                    
                    index += 1
                    
                }
                
            }
            
            

             self.menu.removeAll()
             menu.append(Nonvegan)
             menu.append(vegan)
             menu.append(AddOn)
             self.tableView.reloadData()
          
              
            
        } else {
            print("Can't load type")
        }
    
    }
    
    
    func processItem(item: ItemModel) {
        
        
        if let type = item.type {
            
            if type == "Vegan"{
                
                vegan.insert(item, at: 0)
                
                
                
            } else if type == "Non-Vegan" {
                
                Nonvegan.insert(item, at: 0)
                
            } else {
                
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
           let padding = 70
           if direction == MGSwipeDirection.rightToLeft {
               expansionSettings.fillOnTrigger = false;
               expansionSettings.threshold = 1.1
               

               let RemoveResize = resizeImage(image: UIImage(named: "remove")!, targetSize: CGSize(width: 25.0, height: 25.0))
               
                 
               let remove = MGSwipeButton(title: "", icon: RemoveResize, backgroundColor: color, padding: padding,  callback: { (cell) -> Bool in
                
                
                   
                   self.deleteAtIndexPath(self.tableView.indexPath(for: cell)!)
                   
                   return false; //don't autohide to improve delete animation
                   
                   
               });
               
               
               return [remove]
            
           } else {
               
               return nil
            
           }
              
           
       }
       
       
       func deleteAtIndexPath(_ path: IndexPath) {
        
           let item = menu[(path as NSIndexPath).section][(path as NSIndexPath).row - 1]
        
            print((path as NSIndexPath).row)
           
           if let type = item.type {
                    
                if type == "Vegan"{
                    
                    self.vegan.remove(at: (path as NSIndexPath).row - 1)
                    
                    
                } else if type == "Non-Vegan" {
                    
                    
                    self.Nonvegan.remove(at: (path as NSIndexPath).row - 1)
                    
                    
                } else {
                    

                    self.AddOn.remove(at: (path as NSIndexPath).row - 1)
                    
                }
            
            
            }
        
              
           self.menu[(path as NSIndexPath).section].remove(at: (path as NSIndexPath).row - 1)
        
           self.tableView.reloadData()
           
       }
    
    
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func processStripe() {
        
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            dynamicAnimatorActive: true,
            buttonsLayout: .horizontal
        )
        
        let alert = SCLAlertView(appearance: appearance)
        _ = alert.addButton("Got it") {
            
            
            NotificationCenter.default.addObserver(self, selector: #selector(CreateMenuVC.autoProcessCodeFromDelegate), name: (NSNotification.Name(rawValue: "CodeProcess")), object: nil)
            
            //Progess
            let url = "https://connect.stripe.com/express/oauth/authorize?response_type=code&client_id=\(client_id)&scope=read_write"
            
            
            guard let urls = URL(string: url) else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                
                UIApplication.shared.open(urls)
                
            } else {
                
                UIApplication.shared.openURL(urls)
                
            }
            
            
        }
        
        let icon = UIImage(named:"logo")
        
        _ = alert.showCustom("Congratulations!", subTitle: "You will have to finish your payment information to start selling", color: UIColor.black, icon: icon!)
          
          
        
    }
    
    @objc func autoProcessCodeFromDelegate() {
        
        if authCode != "" {
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "CodeProcess")), object: nil)
            self.processCode(authorization_code: authCode)
        }
        
    }
    
    
    func processCode(authorization_code: String) {
        
        if  authorization_code != "" {
            
            swiftLoader()
            
            let url = MainAPIClient.shared.baseURLString
            let urls = URL(string: url!)?.appendingPathComponent("redirect")
            
            AF.request(urls!, method: .post, parameters: [
                
                "authorization_code": authorization_code
                
                ])
                
                .validate(statusCode: 200..<500)
                .responseJSON { responseJSON in
                    
                    switch responseJSON.result {
                        
                    case .success(let json):
                        
                        
                        if let dict = json as? [String: AnyObject] {
                            
                            if let account = dict["stripe_user_id"] as? String {
                                
                                
                                self.createLoginLinks(account: account)
                                
                                
                                
                            }
                            
                            
                        }
                        
                    case .failure( _):
                        
                        
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops !!!", msg: "There are some unknown error during setting up your payout account. Please try again and contact us for more help")
                        
                    }
                    
                    
            }
            
            
        } else {
            
            
            
            self.showErrorAlert("Oops !!!", msg: "Please provide your code")
            
        }
        
        
    }
    
    func createLoginLinks(account: String){
         
         let url = MainAPIClient.shared.baseURLString
         let urls = URL(string: url!)?.appendingPathComponent("login_links")
         
         AF.request(urls!, method: .post, parameters: [
             
             "account": account
             
             ])
             
             .validate(statusCode: 200..<500)
             .responseJSON { responseJSON in
                 
                 switch responseJSON.result {
                     
                 case .success(let json):
                     
                     
                     if let dict = json as? [String: AnyObject] {
                         
                         if let url = dict["url"] as? String {
                             
                            DataService.instance.mainRealTimeDataBaseRef.child("Stripe_Owner_Connect_Account").child(Auth.auth().currentUser!.uid).setValue(["Stripe_Owner_Connect_Account": account,"Login_link": url, "Timestamp": ServerValue.timestamp()])
                            
                            
                              
                            SwiftLoader.hide()
                              
    
                             
                             
                         }
                         
                         
                     }
                     
                 case .failure( _):
                     
                     
                     SwiftLoader.hide()
                     self.showErrorAlert("Oops !!!", msg: "There are some unknown error during setting up your payout account. Please try again and contact us for more help")
                     
                 }
                 
                 
         }
         
     }
    
    @IBAction func CreateBtnPressed(_ sender: Any) {
        
        
        var count = 0
        var start = 0
        
        
        
        while count < 3 {
            
            start = menu[count].count + start
            count += 1
            
        }
        
        sum = start
        
        if start >= 5 {
            
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
        
        for i in vegan {
            if let img = i.img {
                processItem(img: img, item: i, restaurant_id: restaurant_id, type: i.type)
            }
        }
        
        completed()
        
    }
    
    func uploadNonVegan(completed: @escaping DownloadComplete) {
        
         
        for i in Nonvegan {
            if let img = i.img {
                processItem(img: img, item: i, restaurant_id: restaurant_id, type: i.type)
            }
        }
        
        completed()
        
    }
    
    func uploadAddOn(completed: @escaping DownloadComplete) {
        
        
        for i in AddOn {
            if let img = i.img {
               processItem(img: img, item: i, restaurant_id: restaurant_id, type: i.type)
            }
        }
        
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
                    
                      let dict = ["name": item.name as Any, "description": item.description as Any, "price": item.price as Any, "url": downloadedUrl as Any, "category": item.category as Any, "type": type, "restaurant_id": restaurant_id, "timeStamp": ServerValue.timestamp(), "Quanlity": "None"] as [String : Any]
                      let db = DataService.instance.mainFireStoreRef.collection("Menu")
                    
                      db.addDocument(data: dict) { err in
                      
                          if let err = err {
                              
                              SwiftLoader.hide()
                              self.showErrorAlert("Opss !", msg: err.localizedDescription)
                              
                          } else {
                            
             
                            self.counted += 1
                            
                            if self.counted == self.sum {
                                
                                
                                DataService.instance.mainFireStoreRef.collection("Restaurant_check_list").document(restaurant_id).updateData(["Menu": true])
                                SwiftLoader.hide()
                                self.processStripe()
                                
                            }
                        
                        }
                        
                        
                    }
                    
                      
                  })
                
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
