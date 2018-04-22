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

class CaptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var captionText: UILabel!
    @IBOutlet weak var captionScore: UILabel!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    var postedBy = String()
    var userID = String()
    var specificImage = String()
    var specificCaption = String()
    var upVotes = [String]()
    var downVotes = [String]()
 
    
    @IBAction func upVoteAction(_ sender: Any) {
        let ref: DatabaseReference
        ref = Database.database().reference()
        var capGrabScore = Int()
        
        ref.child("users").child(self.postedBy).child("capScore").observeSingleEvent(of: .value, with: { (snapshot) in
            
            capGrabScore = (snapshot.value as? Int)!
            
            if(self.downVotes.contains(self.userID)) {
                capGrabScore = capGrabScore + 2
                let index = self.downVotes.index(of: self.userID)
                self.downVotes.remove(at: index!)
                self.downVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                self.upVotes.append(self.userID)
                self.upVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                ref.child("users/\(self.postedBy)/capScore").setValue(capGrabScore)
                ref.child("photos/\(self.userID)/\(self.specificImage)/\(self.specificCaption)/upVotes").setValue(self.upVotes)
                ref.child("photos/\(self.userID)/\(self.specificImage)/\(self.specificCaption)/downVotes").setValue(self.downVotes)
                self.captionScore.text = String(Int(self.captionScore.text!)! + 2)
            } else if(self.upVotes.contains(self.userID)) {
                capGrabScore = capGrabScore - 1
                let index = self.upVotes.index(of: self.userID)
                self.upVotes.remove(at: index!)
                self.upVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                ref.child("users/\(self.postedBy)/capScore").setValue(capGrabScore)
                ref.child("photos/\(self.userID)/\(self.specificImage)/\(self.specificCaption)/upVotes").setValue(self.upVotes)
                self.captionScore.text = String(Int(self.captionScore.text!)! - 1)
            } else {
                capGrabScore = capGrabScore + 1
                self.upVotes.append(self.userID)
                self.upVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                ref.child("users/\(self.postedBy)/capScore").setValue(capGrabScore)
                ref.child("photos/\(self.userID)/\(self.specificImage)/\(self.specificCaption)/upVotes").setValue(self.upVotes)
                self.captionScore.text = String(Int(self.captionScore.text!)! + 1)
            }
            print(self.upVotes)
        })
    }
    
    @IBAction func downVoteAction(_ sender: Any) {
        let ref: DatabaseReference
        ref = Database.database().reference()
        var capGrabScore = Int()
        print(self.downVotes)
        
        ref.child("users").child(self.postedBy).child("capScore").observeSingleEvent(of: .value, with: { (snapshot) in
            
            capGrabScore = (snapshot.value as? Int)!
            
            if(self.upVotes.contains(self.userID)) {
                capGrabScore = capGrabScore - 2
                let index = self.upVotes.index(of: self.userID)
                self.upVotes.remove(at: index!)
                self.upVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                self.downVotes.append(self.userID)
                self.downVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                ref.child("users/\(self.postedBy)/capScore").setValue(capGrabScore)
                ref.child("photos/\(self.userID)/\(self.specificImage)/\(self.specificCaption)/upVotes").setValue(self.upVotes)
                ref.child("photos/\(self.userID)/\(self.specificImage)/\(self.specificCaption)/downVotes").setValue(self.downVotes)
                self.captionScore.text = String(Int(self.captionScore.text!)! - 2)
            } else if(self.downVotes.contains(self.userID)) {
                capGrabScore = capGrabScore + 1
                let index = self.downVotes.index(of: self.userID)
                self.downVotes.remove(at: index!)
                self.downVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                ref.child("users/\(self.postedBy)/capScore").setValue(capGrabScore)
                ref.child("photos/\(self.userID)/\(self.specificImage)/\(self.specificCaption)/downVotes").setValue(self.downVotes)
                self.captionScore.text = String(Int(self.captionScore.text!)! + 1)
            } else {
                capGrabScore = capGrabScore - 1
                self.downVotes.append(self.userID)
                self.downVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                ref.child("users/\(self.postedBy)/capScore").setValue(capGrabScore)
                ref.child("photos/\(self.userID)/\(self.specificImage)/\(self.specificCaption)/downVotes").setValue(self.downVotes)
                self.captionScore.text = String(Int(self.captionScore.text!)! - 1)
            }
        })
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
