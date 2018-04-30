//
//  NotificationViewController.swift
//  CapGrab
//
//  Created by George Sarantinos on 2/19/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var notificationsSegmentControl: UISegmentedControl!
    
    var currentUserFollowRequests = [String]()
    var currentUserFollowRequestUserNames = [String]()
    var currentUserNotificationUserNames = [String]()
    var currentUserFollowers = [String]()
    var requestUserFollowing = [String]()
    var notifications = [String]()
    var segueUserID = String()
    
    @IBAction func captionOrFollow(_ sender: Any) {
        if notificationsSegmentControl.selectedSegmentIndex == 0 {
            notificationsTableView.reloadData()
        } else {
            notificationsTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if notificationsSegmentControl.selectedSegmentIndex == 0 {
            return currentUserNotificationUserNames.count
        } else {
            return currentUserFollowRequests.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if notificationsSegmentControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
            cell.notificationMessage.text = "\(currentUserNotificationUserNames[indexPath.item]) captioned your post!"
            cell.notificationButton.isHidden = true
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
            cell.notificationMessage.text = "\(currentUserFollowRequestUserNames[indexPath.item])"
            cell.notificationButton.setTitle("Accept", for: .normal)
            cell.notificationButton.isHidden = false
            if(self.currentUserFollowers.count >= 20) {
                cell.notificationButton.isEnabled = false
            }
            cell.followRequestUserID = currentUserFollowRequests[indexPath.item]
            cell.followers = currentUserFollowers
            cell.followRequests = currentUserFollowRequests
            let ref: DatabaseReference!
            ref = Database.database().reference()
            ref.child("users").child(cell.followRequestUserID).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if (value?["following"] as? [String]) != nil {
                    self.requestUserFollowing = (value?["following"] as? [String])!
                }
            }){ (error) in
                print(error.localizedDescription)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if notificationsSegmentControl.selectedSegmentIndex == 1 {
            segueUserID = currentUserFollowRequests[indexPath.item]
            self.performSegue(withIdentifier: "followNotificationSegue", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref: DatabaseReference!
        ref = Database.database().reference()
        let currentUserID = Auth.auth().currentUser?.uid
        ref.child("users").child(currentUserID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if (value?["followRequests"] as? [String]) != nil {
                self.currentUserFollowRequests = (value?["followRequests"] as? [String])!
            }
            if (value?["notifications"] as? [String]) != nil {
                self.notifications = (value?["notifications"] as? [String])!
            }
            if (value?["followers"] as? [String]) != nil {
                self.currentUserFollowers = (value?["followers"] as? [String])!
            }
            for userIDs in self.currentUserFollowRequests {
                ref.child("users").child(userIDs).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    let userName = value?["userName"] as? String
                    self.currentUserFollowRequestUserNames.append(userName!)
                    self.notificationsTableView.reloadData()
                }){ (error) in
                    print(error.localizedDescription)
                }
            }
            for userIDs in self.notifications {
                
                ref.child("users").child(userIDs).child("userName").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    self.currentUserNotificationUserNames.append((snapshot.value as? String)!)
                    self.notificationsTableView.reloadData()

                }){ (error) in
                    print(error.localizedDescription)
                }
            }
        }){ (error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! SeachedUserAccountViewController
        destination.searchedUserID = segueUserID
        destination.lastViewController = "NotificationViewController"
    }
}
