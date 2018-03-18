//
//  UserAccountViewController.swift
//  CapGrab
//
//  Created by George Sarantinos on 2/19/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//
//  https://medium.com/yay-its-erica/creating-a-collection-view-swift-3-77da2898bb7c
//  https://stackoverflow.com/questions/28777943/hide-tab-bar-in-ios-swift-app
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UserAccountViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    var imagePaths = [String]()
    var imageArray = [UIImage]()
    var followers = [String]()
    var following = [String]()
    var captions = [String]()
    var upVotes = [String]()
    var downVotes = [String]()
    var singleImageForCaption = Int()

    
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var userName: UITextView!
    var selectedImage = UIImage()
    @IBOutlet weak var singleImageView: UIView!
    @IBOutlet weak var singleImage: UIImageView!
    @IBOutlet weak var captionTableView: UITableView!
    @IBOutlet weak var newCaptionText: UITextField!
    
    
    
    @IBAction func addNewCaption(_ sender: Any) {
        let specificImage = String(singleImageForCaption)
        let newCaption = newCaptionText.text
        let ref: DatabaseReference!
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        ref.child("photos").child(userID!).child(specificImage).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            var captionAmount = String()
            var amountOfCaptions = Int()
            if(value?["amountOfCaptions"] == nil) {
                amountOfCaptions = 2
                captionAmount = "1"
            } else {
                let amountOfCaptionsNode = value?["amountOfCaptions"] as! NSDictionary
                let previousAmount = amountOfCaptionsNode["amountOfCaptions"] as! Int
                amountOfCaptions = previousAmount + 1
                captionAmount = String(previousAmount)
            }
            let caption = newCaption
            let upVotes = [String]()
            let downVotes = [String]()
            let captionInfoArray = [caption!, upVotes, downVotes] as [Any]
            ref.child("photos").child(userID ?? "").child(specificImage).child(captionAmount).setValue(["captionInfo" : captionInfoArray])
            ref.child("photos").child(userID ?? "").child(specificImage).child("amountOfCaptions").setValue(["amountOfCaptions" : amountOfCaptions])

        }){ (error) in
            print(error.localizedDescription)
        }
    }
    
    
    @IBAction func hideSingleImageView(_ sender: Any) {
        singleImageView.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.captions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "captionCell", for: indexPath) as! CaptionTableViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! UserImageViewController
        cell.userImage.image = imageArray[indexPath.item]
        selectedImage = cell.userImage.image!
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.upVotes.removeAll()
        self.downVotes.removeAll()
        singleImageForCaption = indexPath.item
//        let ref: DatabaseReference!
//        ref = Database.database().reference()
//        let userID = Auth.auth().currentUser?.uid
//        ref.child("photos").child(userID!).child(String(indexPath.item)).observeSingleEvent(of: .value, with: { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            if (value?["upVotes"] as? [String]) != nil {
//                self.upVotes = (value?["upVotes"] as? [String])!
//            }
//            if (value?["downVotes"] as? [String]) != nil {
//                self.downVotes = (value?["downVotes"] as? [String])!
//            }
//        }){ (error) in
//            print(error.localizedDescription)
//        }
        
        singleImage.image = self.selectedImage
        self.tabBarController?.tabBar.isHidden = true
        singleImageView.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.cornerRadius = 32.0
        profilePicture.clipsToBounds = true
        singleImageView.isHidden = true
        self.captionTableView.delegate = self
        self.captionTableView.delegate = self
        
        let storage = Storage.storage()
        let ref: DatabaseReference!
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.userName.text = (value?["userName"] as! String)
            if (value?["photos"] as? [String]) != nil {
                self.imagePaths = (value?["photos"] as? [String])!
            }
            if (value?["followers"] as? [String]) != nil {
                self.followers = (value?["followers"] as? [String])!
            }
            if (value?["following"] as? [String]) != nil {
                self.following = (value?["following"] as? [String])!
            }
            self.followersButton.setTitle("\(self.followers.count) \nFollowers", for: [])
            self.followingButton.setTitle("\(self.following.count) \nFollowing", for: [])
            for path in self.imagePaths {
                let httpsReference = storage.reference(forURL: path)
                httpsReference.getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        let currentImage = UIImage(data: data!)
                        self.imageArray.append(currentImage!)
                        self.imageCollection.reloadData()
                    }
                })
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }

}
