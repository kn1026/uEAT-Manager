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
        
        
        DataService.instance.mainFireStoreRef.collection("Orders_detail").whereField("userUID", isEqualTo: info.UID!).whereField("Order_id", isEqualTo: Int(info.Order_id)!).getDocuments { (snaps, err) in
        
        if err != nil {
            
            print(err!.localizedDescription)
            return
            
        }
            if snaps?.isEmpty == true {
                
                
                return
                
            }
            
            let limit = snaps?.count
            var prices: Float!
            var Tax: Float!
            prices = 0.0
            Tax = 0.0
        
            for item in snaps!.documents {
                
               
                if let p = item.data()["price"] as? Float {
                    
                    prices = p
                    
                }
                
            }
            
            let new = prices * Float(limit!)
            Tax = prices * 9 / 100
            let total = new + Tax
            self.price.text = "$\(String(format:"%.2f", total))"
            
            
            
            
            
            
        }

        
        
    }

}
