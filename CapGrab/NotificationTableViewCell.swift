//
//  NotificationTableViewCell.swift
//  CapGrab
//
//  Created by George Sarantinos on 2/26/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var notificationMessage: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    
    @IBAction func notificationAction(_ sender: Any) {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
