//
//  ItemCell.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 11/24/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import Alamofire

class ItemCell: MGSwipeTableCell {
    
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
    

}
