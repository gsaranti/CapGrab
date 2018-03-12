//
//  UserAccountViewController.swift
//  CapGrab
//
//  Created by George Sarantinos on 2/19/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//
//  https://medium.com/yay-its-erica/creating-a-collection-view-swift-3-77da2898bb7c
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UserAccountViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var imagePaths = [String]()
    var imageArray = [UIImage]()
    var followers = [String]()
    var following = [String]()

    
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var userName: UITextView!
    var selectedImage = UIImage()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! UserImageViewController
        cell.userImage.image = imageArray[indexPath.item]
        selectedImage =  cell.userImage.image!
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "singlePhotoSegue", sender: [])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.cornerRadius = 32.0
        profilePicture.clipsToBounds = true
        
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
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! SingleImageViewController
        destination.passedSingleImage = selectedImage
        destination.lastViewController = "UserAccountViewController"
    }

}
