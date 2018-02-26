//
//  UserSearchViewController.swift
//  CapGrab
//
//  Created by George Sarantinos on 2/19/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.


import UIKit
import FirebaseDatabase

class UserSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
        
    var returnedUsers = [Array<Any>]()
    @IBOutlet weak var usersTable: UITableView!
    @IBOutlet weak var userSearch: UISearchBar!
    var userIDtoSend = String()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return returnedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! ReturnedUserTableViewCell
        cell.userName.text = returnedUsers[indexPath.item][1] as? String
        cell.userID = (returnedUsers[indexPath.item][0] as? String)!
        userIDtoSend = cell.userID
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "searchSegue", sender: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! SeachedUserAccountViewController
        destination.searchedUserID = userIDtoSend
    }
}
