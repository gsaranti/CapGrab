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
    var currentUserFollowers = [String]()
    var notifications = [Any]()
    
    @IBAction func captionOrFollow(_ sender: Any) {
        if notificationsSegmentControl.selectedSegmentIndex == 0 {
            notificationsTableView.reloadData()
        } else {
            notificationsTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if notificationsSegmentControl.selectedSegmentIndex == 0 {
            return notifications.count
        } else {
            return currentUserFollowRequests.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if notificationsSegmentControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
            cell.notificationMessage.text = "\(notifications[indexPath.item]) captioned your post!"
            cell.notificationButton.isHidden = true
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
            cell.notificationMessage.text = "\(currentUserFollowRequestUserNames[indexPath.item])"
            cell.notificationButton.setTitle("Follow", for: [])
            cell.followRequestUserID = currentUserFollowRequests[indexPath.item]
            cell.followers = currentUserFollowers
            cell.followRequests = currentUserFollowRequests
            return cell
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
            if (value?["notifications"] as? [Any]) != nil {
                self.notifications = (value?["notifications"] as? [Any])!
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
        }){ (error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
