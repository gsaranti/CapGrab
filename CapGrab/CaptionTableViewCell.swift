//
//  CaptionTableViewCell.swift
//  CapGrab
//
//  Created by George Sarantinos on 3/14/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//

import UIKit

class CaptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var captionText: UILabel!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    
    
    
    
    @IBAction func upVoteAction(_ sender: Any) {

    }
    
    @IBAction func downVoteAction(_ sender: Any) {
        
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
