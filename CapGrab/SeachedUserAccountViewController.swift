//
//  SeachedUserAccountViewController.swift
//  CapGrab
//
//  Created by George Sarantinos on 2/24/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SeachedUserAccountViewController: UIViewController {
    
    var userID = String()
    var imagePaths = [String]()
    var imageArray = [UIImage]()
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.cornerRadius = 32.0
        profilePicture.clipsToBounds = true
        
        let storage = Storage.storage()
        let ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
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
                        //self.imageCollection.reloadData()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
