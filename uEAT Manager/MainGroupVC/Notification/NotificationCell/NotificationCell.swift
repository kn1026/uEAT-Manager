//
//  NotificationCell.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/9/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    
    @IBOutlet var icon: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var timeLbl: UILabel!

    var info: NotificationModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func configureCell(_ Information: NotificationModel) {
        self.info = Information
        

        name.text = info.title
        icon.image = UIImage(named: "\(info.type!)")
        
        if info.timeStamp != nil {
            
            timeLbl.text = timeAgoSinceDate(info!.timeStamp as! Date, numericDates: true)
            
        }


        
    }
    
    func dayDifference(from date : Date) -> String
    {
        let calendar = NSCalendar.current
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        else if calendar.isDateInToday(date) { return "Today" }
        else if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        else {
            let startOfNow = calendar.startOfDay(for: Date())
            let startOfTimeStamp = calendar.startOfDay(for: date)
            let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
            let day = components.day!
            if day < 1 { return "\(abs(day)) days ago" }
            else { return "In \(day) days" }
        }
    }
    
    
    
    

}
