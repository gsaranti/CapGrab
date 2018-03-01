//
//  NotificationTableViewCell.swift
//  CapGrab
//
//  Created by George Sarantinos on 2/26/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var notificationMessage: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    var followRequestUserID = String()
    var followRequests = [String]()
    var followers = [String]()
    var requestUserFollowing = [String]()
    
    @IBAction func notificationAction(_ sender: Any) {
        notificationButton.isEnabled = false
        let ref: DatabaseReference!
        ref = Database.database().reference()
        let currentUserID = Auth.auth().currentUser?.uid
        followers.append(followRequestUserID)
        let followRequestIndex = followRequests.index(of: followRequestUserID)
        followRequests.remove(at: followRequestIndex!)
        requestUserFollowing.append(currentUserID!)
        ref.child("users/\(currentUserID ?? "")/followers").setValue(followers)
        ref.child("users/\(currentUserID ?? "")/followRequests").setValue(followRequests)
        ref.child("users/\(followRequestUserID)/following").setValue(requestUserFollowing)
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
