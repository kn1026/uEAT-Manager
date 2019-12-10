//
//  VoucherCell.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/9/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import MGSwipeTableCell
class VoucherCell: MGSwipeTableCell {
    
    
    @IBOutlet var name: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    
    var info: VoucherModel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ Information: VoucherModel) {
        self.info = Information
        
     
        name.text = info.title
        
        descriptionLbl.text = info.description

 
        
    }
    

}
