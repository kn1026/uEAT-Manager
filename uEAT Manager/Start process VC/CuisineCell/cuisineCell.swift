//
//  cuisineCell.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 11/23/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class cuisineCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var name: UILabel!
    
    
    var info: Cuisine_model!
    
    
    func configureCell(_ Information: Cuisine_model) {
        self.info = Information
        
        
        
        self.name.text = info.name
        
        if let url = info.url {
            
            
            Alamofire.request(url).responseImage { response in
                
                if let image = response.result.value {
                    
                    
                    self.imageView.image = image
                    
                    /*
                    let wrapper = ImageWrapper(image: image)
                    self.requestDriverImg.image = image
                    try? InformationStorage?.setObject(wrapper, forKey: DriverData.Face_ID)
                    */
                    
                }
                
                
            }
            
        }
        
        
        
        
    }
    
}
