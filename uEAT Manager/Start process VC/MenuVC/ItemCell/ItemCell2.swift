//
//  ItemCell2.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/9/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import Alamofire


class ItemCell2: MGSwipeTableCell {
    
    @IBOutlet weak var Quanlity: UIStackView!

    @IBOutlet var img: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var price: UILabel!
    
    
    var info: ItemModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureCell(_ Information: ItemModel) {
        self.info = Information
        
        
        
        self.name.text = info.name
        self.price.text = "$ \(info.price!)"
        
        
        
        if info.img != nil {
            
            img.image = info.img
            
            
        } else {
            
            if info.url != "" {
                
                
                imageStorage.async.object(forKey: info.url) { result in
                    if case .value(let image) = result {
                        
                        DispatchQueue.main.async { // Make sure you're on the main thread here
                            
                            
                            self.img.image = image
                            
                            //try? imageStorage.setObject(image, forKey: url)
                            
                        }
                        
                    } else {
                        
                        
                        Alamofire.request(self.info.url).responseImage { response in
                            
                            if let image = response.result.value {
                                
                                
                                self.img.image = image
                                try? imageStorage.setObject(image, forKey: self.info.url)
                                
                                
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
                
                
            }
            
        }

        
        
    }

}
