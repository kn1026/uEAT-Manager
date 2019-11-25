//
//  defaultCardView.swift
//  Campus Connect
//
//  Created by Khoi Nguyen on 3/26/18.
//  Copyright © 2018 Campus Connect LLC. All rights reserved.
//

import UIKit

class defaultCardView: UIView {
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
      
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1.0
        
        layer.cornerRadius = self.frame.height / 7
        clipsToBounds = true
 
        
        
    }
    
    

}
