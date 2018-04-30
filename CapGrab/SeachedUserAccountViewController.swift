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

class SeachedUserAccountViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var searchedUserID = String()
    var imagePaths = [String]()
    var imageArray = [UIImage]()
    var followersArray = [String]()
    var followingArray = [String]()
    var followRequests = [String]()
    var currentUserFollowingArray = [String]()
    var lastViewController = String()
    var singleImageForCaption = Int()
    var captions = [String]()
    var upVotes = [[String]]()
    var downVotes = [[String]]()
    var postedBy = [String]()
    var notificationArray = [String]()
    
    var isFollower = false
    var hasRequested = false
    
    let currentUserID = Auth.auth().currentUser?.uid

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImagesCollection: UICollectionView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var singleImage: UIImageView!
    @IBOutlet weak var captionTableView: UITableView!
    @IBOutlet weak var captionText: UITextField!
    @IBOutlet weak var singleImageView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var capScore: UILabel!
    
    @IBAction func hideSingleImageView(_ sender: Any) {
        captionText.endEditing(true)
        let returnYContraint = UIScreen.main.bounds.height - 50
        captionText.frame.origin.y = returnYContraint
        submitButton.frame.origin.y = returnYContraint
        singleImageView.isHidden = true
        self.captions.removeAll()
        self.captionTableView.reloadData()
    }
    
    @IBAction func addNewCaption(_ sender: Any) {
        let specificImage = String(singleImageForCaption)
        let newCaption = captionText.text
        let ref: DatabaseReference!
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        self.postedBy.append(userID!)
        ref.child("photos").child(searchedUserID).child(specificImage).observeSingleEvent(of: .value, with: { (snapshot) in
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
            ref.child("photos").child(self.searchedUserID).child(specificImage).child(captionAmount).setValue(["caption": caption])
            
                ref.child("photos/\(self.searchedUserID)/\(specificImage)/\(captionAmount)/postedBy").setValue(userID)
            ref.child("photos").child(self.searchedUserID).child(specificImage).child("amountOfCaptions").setValue(["amountOfCaptions" : amountOfCaptions])
            
            self.captions.append(caption!)
            self.upVotes.append([])
            self.downVotes.append([])
            self.captionTableView.reloadData()
            
        }){ (error) in
            print(error.localizedDescription)
        }
        ref.child("users").child(searchedUserID).child("notifications").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if (snapshot.value as? [String]) != nil {
                self.notificationArray = (snapshot.value as? [String])!
            }
            
            self.notificationArray.insert(self.currentUserID!, at: 0)
            ref.child("users/\(self.searchedUserID)/notifications").setValue(self.notificationArray)
        }) { (error) in
            print(error.localizedDescription)
        }
        self.captionText.text?.removeAll()
    }
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.captions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCaptionCell", for: indexPath) as! SearchedUserCaptionTableViewCell
        cell.captionText.text = self.captions[indexPath.item]
        cell.postedBy = self.postedBy[indexPath.item]
        cell.userID = self.currentUserID!
        if(self.upVotes.count != 0) {
            cell.upVotes = self.upVotes[indexPath.item]
            if(self.upVotes[indexPath.item].contains(currentUserID!)) {
                cell.upVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            } else {
                cell.upVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            }
        }
        if(self.downVotes.count != 0) {
            cell.downVotes = self.downVotes[indexPath.item]
            if(self.downVotes[indexPath.item].contains(currentUserID!)) {
                cell.downVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            } else {
                cell.downVoteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            }
        }
        cell.searchedUserID = self.searchedUserID
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell2", for: indexPath) as! SearchedUserImagesCollectionViewCell
        cell.userImage.image = imageArray[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.captions.removeAll()
        self.upVotes.removeAll()
        self.downVotes.removeAll()
        self.postedBy.removeAll()
        singleImageForCaption = indexPath.item
        let specificImage = String(singleImageForCaption)
        
        let ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("photos").child(searchedUserID).child(specificImage).observeSingleEvent(of: .value, with: { (snapshot) in
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
        singleImageView.isHidden = false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.width / 3
        return CGSize(width: width, height: width)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let textBoxHeight = singleImage.frame.origin.y + singleImage.bounds.height - 40
        captionText.frame.origin.y = textBoxHeight
        submitButton.frame.origin.y = textBoxHeight
    }
    
    func textFieldShouldReturn(_ textFields: UITextField) -> Bool {
        self.view.endEditing(true)
        let returnYContraint = UIScreen.main.bounds.height - 50
        captionText.frame.origin.y = returnYContraint
        submitButton.frame.origin.y = returnYContraint
        return true
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
            self.capScore.text = String(value?["capScore"] as! Int)
            
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
                self.followButton.setTitle("Unfollow", for: .normal)
            } else if(self.followRequests.contains(self.currentUserID!)) {
                self.isFollower = false
                self.hasRequested = true
                self.followButton.setTitle("Pending", for: .normal)
            } else {
                self.isFollower = false
                self.followButton.setTitle("Follow", for: .normal)
            }
            
            if(self.isFollower == true) {
                if (value?["photos"] as? [String]) != nil {
                    self.imagePaths = (value?["photos"] as? [String])!
                }
                let semaphore = DispatchSemaphore(value: 1)
                DispatchQueue.global().async { 
                    for path in self.imagePaths {
                        semaphore.wait()
                        let httpsReference = storage.reference(forURL: path)
                        httpsReference.getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                let currentImage = UIImage(data: data!)
                                self.imageArray.append(currentImage!)
                                self.userImagesCollection.reloadData()
                                semaphore.signal()
                            }
                        })
                    }
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
        
        captionText.delegate = self
        profilePicture.layer.cornerRadius = 32.0
        profilePicture.clipsToBounds = true
        self.captionTableView.delegate = self
        self.singleImageView.isHidden = true
        submitButton.layer.cornerRadius = 5
        
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
