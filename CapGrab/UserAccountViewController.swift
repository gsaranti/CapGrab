//
//  UserAccountViewController.swift
//  CapGrab
//
//  Created by George Sarantinos on 2/19/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//
//  https://medium.com/yay-its-erica/creating-a-collection-view-swift-3-77da2898bb7c
//  https://stackoverflow.com/questions/28777943/hide-tab-bar-in-ios-swift-app
//  https://stackoverflow.com/questions/46091920/how-to-make-a-loop-wait-until-task-is-finished
//  https://stackoverflow.com/questions/38028013/how-to-set-uicollectionviewcell-width-and-height-programmatically
//  https://stackoverflow.com/questions/24110762/swift-determine-ios-screen-size
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UserAccountViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    var imagePaths = [String]()
    var imageArray = [UIImage]()
    var followers = [String]()
    var following = [String]()
    var captions = [String]()
    var postedBy = [String]()
    var upVotes = [[String]]()
    var downVotes = [[String]]()
    var singleImageForCaption = Int()
    var ready = true

    
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var imageCollection: UICollectionView!

    @IBOutlet weak var userName: UILabel!
    var selectedImage = UIImage()
    @IBOutlet weak var singleImageView: UIView!
    @IBOutlet weak var singleImage: UIImageView!
    @IBOutlet weak var captionTableView: UITableView!
    @IBOutlet weak var newCaptionText: UITextField!
    @IBOutlet weak var capScore: UILabel!
    @IBOutlet weak var settingsView: UIView!
    
    @IBAction func logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@:", signOutError)
        }
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
    @IBAction func hideSettings(_ sender: Any) {
        settingsView.isHidden = true
        settingsView.layer.zPosition = 0
    }
    
    
    @IBAction func settings(_ sender: Any) {
        settingsView.isHidden = false
        settingsView.layer.zPosition = 1
    }
    
    
    @IBAction func addNewCaption(_ sender: Any) {
        let specificImage = String(singleImageForCaption)
        let newCaption = newCaptionText.text
        let ref: DatabaseReference!
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        self.postedBy.append(userID!)
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

            ref.child("photos").child(userID ?? "").child(specificImage).child(captionAmount).setValue(["caption": caption])
            
            ref.child("photos/\(userID ?? "")/\(specificImage)/\(captionAmount)/postedBy").setValue(userID)
            
            ref.child("photos").child(userID ?? "").child(specificImage).child("amountOfCaptions").setValue(["amountOfCaptions" : amountOfCaptions])
            
            self.captions.append(caption!)
            self.upVotes.append([])
            self.downVotes.append([])
            self.captionTableView.reloadData()

        }){ (error) in
            print(error.localizedDescription)
        }
        self.newCaptionText.text?.removeAll()
    }
    
    
    @IBAction func hideSingleImageView(_ sender: Any) {
        singleImageView.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        self.captions.removeAll()
        self.captionTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.captions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userID = Auth.auth().currentUser?.uid
        let cell = tableView.dequeueReusableCell(withIdentifier: "captionCell", for: indexPath) as! CaptionTableViewCell
        cell.captionText.text = self.captions[indexPath.item]
        cell.postedBy = self.postedBy[indexPath.item]
        if(self.upVotes.count != 0) {
            cell.upVotes = self.upVotes[indexPath.item]
            if(self.upVotes[indexPath.item].contains(userID!)) {
                cell.upVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            } else {
                cell.upVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            }
        }
        if(self.downVotes.count != 0) {
            cell.downVotes = self.downVotes[indexPath.item]
            if(self.downVotes[indexPath.item].contains(userID!)) {
                cell.downVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            } else {
                cell.downVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            }
        }
        cell.userID = userID!
        cell.specificImage = String(singleImageForCaption)
        cell.specificCaption = String(indexPath.item + 1)
        cell.captionText.numberOfLines = Int(Double(self.captions[indexPath.item].count / 2) * 2.5)
        if(self.captions[indexPath.item].count > 60) {
            self.captionTableView.rowHeight = (CGFloat(Double(self.captions[indexPath.item].count / 2) * 2.0))
        } else {
            self.captionTableView.rowHeight = 60.0
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! UserImageViewController
        cell.userImage.image = imageArray[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.upVotes.removeAll()
        self.downVotes.removeAll()
        self.captions.removeAll()
        self.postedBy.removeAll()
        singleImageForCaption = indexPath.item
        let specificImage = String(singleImageForCaption)
        
        let ref: DatabaseReference!
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        ref.child("photos").child(userID!).child(specificImage).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if(value != nil) {
                for i in 1...value!.count - 1 {
                    let captionNumber = String(i)
                    let singleCaption = value![captionNumber]! as! NSDictionary
                    self.captions.append(singleCaption["caption"]! as! String)
                    self.postedBy.append(singleCaption["postedBy"]! as! String)
                    if(singleCaption["upVotes"] as? [String] != nil) {
                        self.upVotes.append(singleCaption["upVotes"] as! [String])
                    } else {
                        self.upVotes.append([])
                    }
                    if(singleCaption["downVotes"] as? [String] != nil) {
                        self.downVotes.append(singleCaption["downVotes"] as! [String])
                    } else {
                        self.downVotes.append([])
                    }
                }
            }
            self.captionTableView.reloadData()
        })
        singleImage.image = imageArray[indexPath.item]
        self.tabBarController?.tabBar.isHidden = true
        singleImageView.isHidden = false
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.width / 3
        return CGSize(width: width, height: width)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.cornerRadius = 32.0
        profilePicture.clipsToBounds = true
        singleImageView.isHidden = true
        self.captionTableView.delegate = self
        settingsView.isHidden = true
        settingsView.layer.cornerRadius = 20

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
            self.capScore.text = String(value?["capScore"] as! Int)

            if (value?["followers"] as? [String]) != nil {
                self.followers = (value?["followers"] as? [String])!
            }
            if (value?["following"] as? [String]) != nil {
                self.following = (value?["following"] as? [String])!
            }
            self.followersButton.setTitle("\(self.followers.count) \nFollowers", for: [])
            self.followingButton.setTitle("\(self.following.count) \nFollowing", for: [])
            
            let semaphore = DispatchSemaphore(value: 1)
            DispatchQueue.global().async {
                for path in self.imagePaths {
                    semaphore.wait()
                    let httpsReference = storage.reference(forURL: path)
                    httpsReference.getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            self.imageArray.append(UIImage(data: data!)!)
                            self.imageCollection.reloadData()
                            semaphore.signal()
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
        userName.sizeToFit()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }

}
