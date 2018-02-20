//
//  UploadViewController.swift
//  CapGrab
//
//  Created by George Sarantinos on 2/19/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var browseButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    
    let imageLibrary = UIImagePickerController()
    var imagePathArray = [String]()
    
    @IBAction func browsePhotoLibrary(_ sender: Any) {
        self.present(imageLibrary, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        uploadImage.image = image
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        let userID = Auth.auth().currentUser?.uid
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://capgrab-d673e.appspot.com").child(userID!)
        let imageToUpload = uploadImage.image
        let imageData = UIImageJPEGRepresentation(imageToUpload!, 0.1)
        storageRef.putData(imageData!, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                print(error?.localizedDescription as Any)
                return
            }
            let ref: DatabaseReference!
            ref = Database.database().reference()
            ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                self.imagePathArray = (value?["photos"] as! [String])
            }){ (error) in
                print(error.localizedDescription)
            }
            let uploadedImageURL = metadata?.downloadURL()?.absoluteString
            self.imagePathArray.append(uploadedImageURL!)
            ref.child("users/\(userID ?? "")/photos").setValue(self.imagePathArray)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageLibrary.delegate = self
        imageLibrary.sourceType = .photoLibrary
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
