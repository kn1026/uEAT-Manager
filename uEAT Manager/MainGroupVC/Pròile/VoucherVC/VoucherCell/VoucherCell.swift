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
    @IBOutlet var created: UILabel!
    
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
        
     
        name.text = "\(self.info.title!) - \(self.info.description!)"
        created.text = ""
        
        if let FromTimes = info.fromDate as? Date, let UntilTime = info.untilDate as? Date {
            
            descriptionLbl.text = "Active from \(convertDate(date: FromTimes)) to \(convertDate(date: UntilTime))"
            
            
        } else {
            
            descriptionLbl.text = "Error day/time"
            
            
        }
        
        if let create = info.timeStamp as? Date {
            
            created.text = "Created \(timeAgoSinceDate(create, numericDates: true))"
            
        }
        

 
        
    }
    
    
    func convertDate(date: Date!) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        //dateFormatter.dateFormat = "MM-dd-yyyy"
        let result = dateFormatter.string(from: date)

        
        return result
    }

}
