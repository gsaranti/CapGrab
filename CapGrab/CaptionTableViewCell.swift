//
//  CaptionTableViewCell.swift
//  CapGrab
//
//  Created by George Sarantinos on 3/14/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//
//  https://stackoverflow.com/questions/37215799/swift-bolding-uibutton
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CaptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var captionText: UILabel!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    var postedBy = String()
    var userID = String()
    var specificImage = String()
    var specificCaption = String()
    var upVotes = [String]()
 
    
    @IBAction func upVoteAction(_ sender: Any) {
        let ref: DatabaseReference
        ref = Database.database().reference()
    
        if(self.upVotes.contains(self.userID)) {
            let index = self.upVotes.index(of: self.userID)
            self.upVotes.remove(at: index!)
            upVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            ref.child("photos/\(self.userID)/\(self.specificImage)/\(self.specificCaption)/upVotes").setValue(self.upVotes)
        } else {
            self.upVotes.append(self.userID)
            upVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            ref.child("photos/\(self.userID)/\(self.specificImage)/\(self.specificCaption)/upVotes").setValue(self.upVotes)
        }
    }
    
    @IBAction func downVoteAction(_ sender: Any) {
        print("bye")
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let ref: DatabaseReference
        ref = Database.database().reference()
        ref.child("photos").child(userID).child(specificImage).child(specificCaption).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if(value?["upVotes"] as? [String]) != nil {
                self.upVotes = (value?["upVotes"] as? [String])!
                if(self.upVotes.contains(self.userID)) {
                    self.upVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                }
            }
        })
        

        // Configure the view for the selected state
    }

}
