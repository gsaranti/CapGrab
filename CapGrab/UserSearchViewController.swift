//
//  UserSearchViewController.swift
//  CapGrab
//
//  Created by George Sarantinos on 2/19/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//

import UIKit
import FirebaseDatabase

class UserSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
        
    var returnedUsers = [Array<Any>]()
    @IBOutlet weak var usersTable: UITableView!
    @IBOutlet weak var userSearch: UISearchBar!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return returnedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! ReturnedUserTableViewCell
        cell.userName.text = returnedUsers[indexPath.item][1] as? String
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        returnedUsers.removeAll(keepingCapacity: true)
        let userNameSearch = userSearch.text
        let ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("users").observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            for users in value! {
                let userNames = users.value as? NSDictionary
                let returnedUserName = userNames!["userName"]! as! String
                if userNameSearch == returnedUserName {
                    let userID = users.key
                    self.returnedUsers.append([userID, returnedUserName])
                }
            }
            self.usersTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userSearch.delegate = self
        self.usersTable.delegate = self
        self.usersTable.rowHeight = 40
        
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
