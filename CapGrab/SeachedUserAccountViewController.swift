//
//  SeachedUserAccountViewController.swift
//  CapGrab
//
//  Created by George Sarantinos on 2/24/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//
//  https://stackoverflow.com/questions/33873630/swift-how-do-i-segue-with-a-button-from-viewcontroller-to-a-specific-tabbarcon
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SeachedUserAccountViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var searchedUserID = String()
    var imagePaths = [String]()
    var imageArray = [UIImage]()
    var followersArray = [String]()
    var followingArray = [String]()
    var followRequests = [String]()
    var currentUserFollowingArray = [String]()
    var lastViewController = String()
    
    var isFollower = false
    var hasRequested = false
    
    let currentUserID = Auth.auth().currentUser?.uid

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImagesCollection: UICollectionView!
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBAction func userRelationAction(_ sender: Any) {
        if(isFollower == true) {
            let index = followersArray.index(of: currentUserID!)
            followersArray.remove(at: index!)
            let searchedUserIndex = currentUserFollowingArray.index(of: searchedUserID)
            currentUserFollowingArray.remove(at: searchedUserIndex!)
            isFollower = false
            let ref: DatabaseReference!
            ref = Database.database().reference()
            ref.child("users/\(self.searchedUserID)/followers").setValue(self.followersArray)
            ref.child("users/\(currentUserID!)/following").setValue(self.currentUserFollowingArray)
            reloadPage()
        } else if(hasRequested == true) {
            let index = followRequests.index(of: currentUserID!)
            followRequests.remove(at: index!)
            let ref: DatabaseReference!
            ref = Database.database().reference()
            ref.child("users/\(self.searchedUserID)/followRequests").setValue(self.followRequests)
            reloadPage()
        } else {
            let ref: DatabaseReference!
            ref = Database.database().reference()
            followRequests.append(currentUserID!)
            ref.child("users/\(self.searchedUserID)/followRequests").setValue(self.followRequests)
            reloadPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell2", for: indexPath) as! SearchedUserImagesCollectionViewCell
        cell.userImage.image = imageArray[indexPath.item]
        return cell
    }
    
    @IBAction func backToSearch(_ sender: Any) {
        performSegue(withIdentifier: "backToSearchSegue", sender: self)
    }
    
    func reloadPage() {
        let storage = Storage.storage()
        let ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("users").child(searchedUserID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.userName.text = (value?["userName"] as! String)
            
            if (value?["followers"] as? [String]) != nil {
                self.followersArray = (value?["followers"] as? [String])!
            }
            if (value?["following"] as? [String]) != nil {
                self.followingArray = (value?["following"] as? [String])!
            }
            if (value?["followRequests"] as? [String]) != nil {
                self.followRequests = (value?["followRequests"] as? [String])!
            }
            
            if(self.followersArray.contains(self.currentUserID!)) {
                self.isFollower = true
                self.followButton.setTitle("Unfollow", for: [])
            } else if(self.followRequests.contains(self.currentUserID!)) {
                self.isFollower = false
                self.hasRequested = true
                self.followButton.setTitle("Pending", for: [])
            } else {
                self.isFollower = false
                self.followButton.setTitle("Follow", for: [])
            }
            
            if(self.isFollower == true) {
                if (value?["photos"] as? [String]) != nil {
                    self.imagePaths = (value?["photos"] as? [String])!
                }
                for path in self.imagePaths {
                    let httpsReference = storage.reference(forURL: path)
                    httpsReference.getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            let currentImage = UIImage(data: data!)
                            self.imageArray.append(currentImage!)
                            self.userImagesCollection.reloadData()
                        }
                    })
                }
            }
            
            let profilePicturePath = (value?["profilePicture"] as! String)
            let profilePictureImage = storage.reference(forURL: profilePicturePath)
            profilePictureImage.getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.profilePicture.image = UIImage(data: data!)
                }
            })
        }){ (error) in
            print(error.localizedDescription)
        }
        ref.child("users").child(currentUserID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if (value?["following"] as? [String]) != nil {
                self.currentUserFollowingArray = (value?["following"] as? [String])!
            }
        }){ (error) in
            print(error.localizedDescription)
        }
            
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.cornerRadius = 32.0
        profilePicture.clipsToBounds = true
        
        reloadPage()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(lastViewController == "NotificationViewController") {
            let destination = segue.destination as! UITabBarController
            destination.selectedIndex = 3
        } else {
            let destination = segue.destination as! UITabBarController
            destination.selectedIndex = 1
        }
    }
}
