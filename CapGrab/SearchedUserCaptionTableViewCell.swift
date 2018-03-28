//
//  SearchedUserCaptionTableViewCell.swift
//  CapGrab
//
//  Created by George Sarantinos on 3/27/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//

import UIKit

class SearchedUserCaptionTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var captionText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
