//
//  ReturnedUserTableViewCell.swift
//  CapGrab
//
//  Created by George Sarantinos on 2/23/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//

import UIKit

class ReturnedUserTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    var userID = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
