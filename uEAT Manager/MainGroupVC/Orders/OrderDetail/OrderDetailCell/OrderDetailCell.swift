
//
//  OrderDetailCell.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 6/23/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import Alamofire

class OrderDetailCell: UITableViewCell {

    @IBOutlet var img: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var finalPrice: UILabel!
    @IBOutlet var eachPrice: UILabel!
       
       var info: OrderDetailModel!

       override func awakeFromNib() {
           super.awakeFromNib()
           // Initialization code
       }

       override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)

           // Configure the view for the selected state
           
       }
       
       func configureCell(_ Information: OrderDetailModel) {
           self.info = Information
           
           let price = self.info.price * Float(self.info.quanlity!)
           
           self.name.text = self.info.name
           self.eachPrice.text = "$\(self.info.price!) items x \(self.info.quanlity!)"
           self.finalPrice.text = "$\(price)"

          
           if info.url != "" {
               
               
               imageStorage.async.object(forKey: info.url) { result in
                   if case .value(let image) = result {
                       
                       DispatchQueue.main.async { // Make sure you're on the main thread here
                           
                           
                           self.img.image = image
                           
                           //try? imageStorage.setObject(image, forKey: url)
                           
                       }
                       
                   } else {
                       
                       
                       AF.request(self.info.url).responseImage { response in
                           
                           switch response.result {
                           case let .success(value):
                               self.img.image = value
                               try? imageStorage.setObject(value, forKey: self.info.url)
                           case let .failure(error):
                               print(error)
                           }
                           
                           
                           
                       }
                       
                   }
                   
               }
               
               
               
           }
           
           
           
       }

}
