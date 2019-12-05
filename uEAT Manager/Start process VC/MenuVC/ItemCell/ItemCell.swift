//
//  ItemCell.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 11/24/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import MGSwipeTableCell

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
        
        img.image = info.img
        
        
    }
    

}
