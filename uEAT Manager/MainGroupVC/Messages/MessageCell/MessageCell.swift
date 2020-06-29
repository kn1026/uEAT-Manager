//
//  MessageCell.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 6/22/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import Cache
import Alamofire

class MessageCell: UITableViewCell {

    @IBOutlet var img: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var message: UILabel!
    @IBOutlet var time: UILabel!
    
    var info: MessageModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ Information: MessageModel) {
        
        self.info = Information

        self.title.text = "Order CC - \(info.order_id!)"
        
        if info.LastMessage == "" {
            
            
            self.message.text = "You can start chatting with restaurant to get more support for order CC - \(info.order_id!)"
            
            
        } else {
            
            
            self.message.text = info.LastMessage!
             
            
        }
        if let times = info.timeStamp as? Date {
            
            time.text = timeAgoSinceDate(times, numericDates: true)
            
        } else {
            
            print("Can't convert \(info.timeStamp!)")
            
        }
        
        
        DataService.instance.mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: info.userUID!).getDocuments { (business, err) in
        
        
            if err != nil {
                   
                   print(err!.localizedDescription)
                   return
                   
            }
            
            for item in business!.documents {
                
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
                    
                    
                }
                
                
                
            }
            
            
            
        }
        
        
    }
    
    
    
    

}
