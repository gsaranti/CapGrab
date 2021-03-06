//
//  ViewController.swift
//  CapGrab
//
//  Created by George Sarantinos on 2/5/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//
//  https://firebase.google.com/docs/database/ios/read-and-write
//  https://firebase.google.com/docs/storage/ios/create-reference
//  https://www.youtube.com/watch?v=OEUeGuBnNAs&t=0s
//  https://www.youtube.com/watch?v=_sBUwR128m4
//  https://www.youtube.com/watch?v=NxLAc1nnNVs&t=290s
//  https://stackoverflow.com/questions/41537721/how-to-hide-keyboard-when-return-key-is-hit-swift/41537966?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
//  https://firebase.google.com/docs/auth/ios/password-auth
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var LoginOrSignUp: UISegmentedControl!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passwordCheck: UITextField!
    
    @IBOutlet weak var EnterButton: UIButton!
    @IBOutlet weak var selectPicture: UIButton!
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    let imageLibrary = UIImagePickerController()
    
    @IBAction func userNameVisibility(_ sender: Any) {
        if LoginOrSignUp.selectedSegmentIndex == 0 {
            userName.isHidden = true
            passwordCheck.isHidden = true
            profilePicture.isHidden = true
            selectPicture.isHidden = true
            EnterButton.setTitle("Login", for: .normal)
        } else {
            userName.isHidden = false
            passwordCheck.isHidden = false
            profilePicture.isHidden = false
            selectPicture.isHidden = false
            EnterButton.setTitle("Sign Up", for: .normal)
        }
    }
    
    @IBAction func selectProfilePicture(_ sender: Any) {
        self.present(imageLibrary, animated: true, completion: nil)
    }

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        profilePicture.image = image
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginOrSignUpAction(_ sender: Any) {
        if LoginOrSignUp.selectedSegmentIndex == 0 {
            if email.text == "" || password.text == "" {
                let message = "You need to enter an email and password"
                let alert = UIAlertController(title: "Uh Oh", message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            Auth.auth().signIn(withEmail: email.text!, password: password.text!, completion: { (user, error) in
                if error != nil{
                    if let signinError = error?.localizedDescription {
                        print(signinError)
                        return
                    }
                }
                self.performSegue(withIdentifier:"loginSegue", sender: self)
            })
        } else {
            if password.text != passwordCheck.text {
                let message = "Your passwords do not match!"
                let alert = UIAlertController(title: "Uh Oh", message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            if email.text == "" || userName.text == "" || password.text == "" || passwordCheck.text == "" {
                let message = "Make sure you have filled all of the fields!"
                let alert = UIAlertController(title: "Uh Oh", message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            Auth.auth().createUser(withEmail: email.text!, password: password.text!, completion: { (user, error) in
                if error != nil {
                    if let signinError = error?.localizedDescription {
                        print(signinError)
                        return
                    }
                }
                let storage = Storage.storage()
                let storageRef = storage.reference(forURL: "gs://capgrab-d673e.appspot.com").child("profilePicutres").child((user?.uid)!)
                let currentProfilePicture = self.profilePicture.image
                let pictureData = UIImageJPEGRepresentation(currentProfilePicture!, 0.1)
                storageRef.putData(pictureData!, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        return
                    }
                    let profilePictureURL = metadata?.downloadURL()?.absoluteString
                    let ref: DatabaseReference!
                    ref = Database.database().reference()
                    let followers = [String]()
                    let following = [String]()
                    let followRequests = [String]()
                    let photoPaths = [Any]()
                    let notifications = [Any]()
                    ref.child("users").child((user?.uid)!).setValue(["userName": self.userName.text!, "email": self.email.text!, "capScore": 0, "fullName": "", "profilePicture": profilePictureURL!, "photos": photoPaths, "followers": followers, "following": following, "followRequests": followRequests, "notifications": notifications])
                })
                Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!, completion: { (user, error) in
                    if error != nil{
                        if let signinError = error?.localizedDescription {
                            print(signinError)
                            return
                        }
                    }
                    self.performSegue(withIdentifier:"loginSegue", sender: self)
                })
            })
        }
    }
    
    func textFieldShouldReturn(_ textFields: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email.delegate = self
        userName.delegate = self
        password.delegate = self
        passwordCheck.delegate = self
        
        userName.isHidden = true
        profilePicture.isHidden = true
        passwordCheck.isHidden = true
        profilePicture.image = UIImage(named: "images")
        profilePicture.layer.cornerRadius = 38.0
        profilePicture.clipsToBounds = true
        selectPicture.isHidden = true
        email.placeholder = "Email"
        password.placeholder = "Password"
        passwordCheck.placeholder = "Re-enter Password"
        userName.placeholder = "Username"
        EnterButton.layer.cornerRadius = 5
        
        imageLibrary.delegate = self
        imageLibrary.sourceType = .photoLibrary
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

