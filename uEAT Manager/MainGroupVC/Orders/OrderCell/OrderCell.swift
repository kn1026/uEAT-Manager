//
//  OrderCell.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 6/23/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import Alamofire

class OrderCell: UITableViewCell {
    
    @IBOutlet var name: UILabel!
    @IBOutlet var orderNumber: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var img: UIImageView!
    
    var info: OrderModel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        
        
        
    }
    
    
    func configureCell(_ Information: OrderModel) {
        self.info = Information
        
        
        if let times = info.Order_time as? Date {
            
            time.text = timeAgoSinceDate(times, numericDates: true)
            
        } else {
            
            print("Can't convert \(info.Order_time!)")
            
        }
        
        DataService.instance.mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: info.UID!).getDocuments { (business, err) in
        
        
            if err != nil {
                   
                   print(err!.localizedDescription)
                   return
                   
            }
            
            
            
            for item in business!.documents {
                
                if let user_name = item["Name"] as? String {
                    
                    self.name.text = user_name
                    self.orderNumber.text = "Order #CC - \(self.info.Order_id!)"
                    
                }
                
                if let LogoUrl = item["avatarUrl"] as? String {
                    
                    imageStorage.async.object(forKey: LogoUrl) { result in
                        if case .value(let image) = result {
                            
                            DispatchQueue.main.async { // Make sure you're on the main thread here
                                
                                
                                self.img.image = image
                                
                                
                            }
                            
                        } else {
                            
                            
                            AF.request(LogoUrl).responseImage { response in
                                
                                switch response.result {
                                case let .success(value):
                                    self.img.image = value
                                    try? imageStorage.setObject(value, forKey: LogoUrl)
                                case let .failure(error):
                                    print(error)
                                }
                                
                                
                                
                            }
                            
                        }
                        
                    }
                    
                    
                } else {
                    
                    
                    
                }
                
                
                
            }
            
            
            
        }
        
        loadPrice(id: info.UID, order_id: info.Order_id, Promo_id: info.Promo_id)
            
    }

    
    func loadPrice(id: String, order_id: String, Promo_id: String) {
    
        var subtotal: Float!
        var Tax: Float!
        var total: Float!
        
        subtotal = 0.0
        Tax = 0.0
        total = 0.0

        
    DataService.instance.mainFireStoreRef.collection("Orders_detail").whereField("userUID", isEqualTo:id).whereField("Order_id", isEqualTo: Int(order_id)!).getDocuments { (snaps, err) in
        
        if err != nil {
            
            print(err!.localizedDescription)
            return
            
        }
            if snaps?.isEmpty == true {
                
                
                return
                
            }
            

            for item in snaps!.documents {
                
               
                if let p = item.data()["price"] as? Float {
                    
                    if let q = item.data()["quanlity"] as? Int {
                        
                        let price = p * Float(q)
                        
                        subtotal += price
                        
                        
                    }
                    
                }
                
        }
        
            
        if Promo_id != "Nil" {
            
            
            self.checkPromoAndLoadFinalPrice(Promo_id: Promo_id, subtotal: subtotal)
            
        } else {
            
            Tax = subtotal * 9 / 100
            total = subtotal + Tax
            self.price.text = "$\(String(format:"%.2f", total))"
            
        }
        
        
            
    
    }
        
    }
    
    func checkPromoAndLoadFinalPrice(Promo_id: String, subtotal: Float) {
        

        DataService.instance.mainFireStoreRef.collection("Voucher").whereField("Created by", isEqualTo: "Restaurant").whereField("restaurant_id", isEqualTo: load_id).getDocuments { (snap, err) in
        
            
        if err != nil {
            
            let Tax = subtotal * 9 / 100
            let total = subtotal + Tax
            self.price.text = "$\(String(format:"%.2f", total))"
            
            return
            
        }
            
            if snap?.isEmpty == true {
                
                let Tax = subtotal * 9 / 100
                let total = subtotal + Tax
                self.price.text = "$\(String(format:"%.2f", total))"
                
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
                                            self.price.text = "$\(String(format:"%.2f", total))"
                                                                                            
                                        }
                                            else {
                                                            
                                            print("Can't convert \(data.value!)")
                                            
                                        }
                                        
                                      
                                    } else if data.type == "$" {
                                    
                                        
                                        if let minus = data.value as? String {
                        
                                            let new = Float(minus)
                                            var AdjustSubtotal = subtotal - new!
                                            
                                            if AdjustSubtotal <= 0 {
                                                AdjustSubtotal = 0.0
                                            }
                                            
                                          let Tax = AdjustSubtotal * 9 / 100
                                          let total = AdjustSubtotal + Tax
                                          self.price.text = "$\(String(format:"%.2f", total))"
                                            
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
                    
                    let Tax = subtotal * 9 / 100
                    let total = subtotal + Tax
                    self.price.text = "$\(String(format:"%.2f", total))"
                    
                  
                    
                }
                
                
                
                
            }
 
        
            
            
            
        }
        
        
    }
    
    
}

  

