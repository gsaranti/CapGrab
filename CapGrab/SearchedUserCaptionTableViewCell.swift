//
//  SearchedUserCaptionTableViewCell.swift
//  CapGrab
//
//  Created by George Sarantinos on 3/27/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SearchedUserCaptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var captionText: UILabel!
    
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    var postedBy = String()
    var userID = String()
    var searchedUserID = String()
    var upVotes = [String]()
    var downVotes = [String]()
    var specificImage = String()
    var specificCaption = String()
    
    @IBAction func upVote(_ sender: Any) {
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
                ref.child("photos/\(self.searchedUserID)/\(self.specificImage)/\(self.specificCaption)/upVotes").setValue(self.upVotes)
                ref.child("photos/\(self.searchedUserID)/\(self.specificImage)/\(self.specificCaption)/downVotes").setValue(self.downVotes)
            } else if(self.upVotes.contains(self.userID)) {
                capGrabScore = capGrabScore - 1
                let index = self.upVotes.index(of: self.userID)
                self.upVotes.remove(at: index!)
                self.upVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                ref.child("users/\(self.postedBy)/capScore").setValue(capGrabScore)
                ref.child("photos/\(self.searchedUserID)/\(self.specificImage)/\(self.specificCaption)/upVotes").setValue(self.upVotes)
            } else {
                capGrabScore = capGrabScore + 1
                self.upVotes.append(self.userID)
                self.upVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                ref.child("users/\(self.postedBy)/capScore").setValue(capGrabScore)
                ref.child("photos/\(self.searchedUserID)/\(self.specificImage)/\(self.specificCaption)/upVotes").setValue(self.upVotes)
            }
        })
    }
    
    @IBAction func downVote(_ sender: Any) {
        let ref: DatabaseReference
        ref = Database.database().reference()
        var capGrabScore = Int()
        
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
                ref.child("photos/\(self.searchedUserID)/\(self.specificImage)/\(self.specificCaption)/upVotes").setValue(self.upVotes)
                ref.child("photos/\(self.searchedUserID)/\(self.specificImage)/\(self.specificCaption)/downVotes").setValue(self.downVotes)
            } else if(self.downVotes.contains(self.userID)) {
                capGrabScore = capGrabScore + 1
                let index = self.downVotes.index(of: self.userID)
                self.downVotes.remove(at: index!)
                self.downVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                ref.child("users/\(self.postedBy)/capScore").setValue(capGrabScore)
                ref.child("photos/\(self.searchedUserID)/\(self.specificImage)/\(self.specificCaption)/downVotes").setValue(self.downVotes)
            } else {
                capGrabScore = capGrabScore - 1
                self.downVotes.append(self.userID)
                self.downVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                ref.child("users/\(self.postedBy)/capScore").setValue(capGrabScore)
                ref.child("photos/\(self.searchedUserID)/\(self.specificImage)/\(self.specificCaption)/downVotes").setValue(self.downVotes)
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
