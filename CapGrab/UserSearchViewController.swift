//
//  UserSearchViewController.swift
//  CapGrab
//
//  Created by George Sarantinos on 2/19/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//

import UIKit
import FirebaseDatabase

class UserSearchViewController: UIViewController {
    
    var returnedUsers = [Array<Any>]()
    @IBOutlet weak var usersTable: UITableView!
    @IBOutlet weak var userSearch: UISearchBar!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("users").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            for users in value! {
                let userNames = users.value as? NSDictionary
                let returnedUserName = userNames!["userName"]!
                let userID = users.key
                self.returnedUsers.append([userID, returnedUserName as! String])
            }
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
