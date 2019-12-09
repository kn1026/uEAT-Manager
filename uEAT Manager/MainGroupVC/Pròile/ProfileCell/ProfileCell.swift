//
//  ProfileCell.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/8/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {

    @IBOutlet var icon: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var count: UILabel!
    
    var info: String!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        
    }
    
    func configureCell(_ Information: String) {
        
        self.info = Information

        icon.image = UIImage(named: "\(Information)")
        name.text = self.info
        
        if self.info != "Notifications" {
            
            
            count.text = ""
            
        }

        
        
    }

}
