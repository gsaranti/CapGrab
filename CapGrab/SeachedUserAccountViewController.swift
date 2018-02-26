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
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImagesCollection: UICollectionView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.cornerRadius = 32.0
        profilePicture.clipsToBounds = true
        
        print(searchedUserID)
        
        let storage = Storage.storage()
        let ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("users").child(searchedUserID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.userName.text = (value?["userName"] as! String)
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! UITabBarController
        destination.selectedIndex = 1
    }

}
