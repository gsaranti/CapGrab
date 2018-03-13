//
//  SingleImageViewController.swift
//  CapGrab
//
//  Created by George Sarantinos on 3/12/18.
//  Copyright © 2018 George Sarantinos. All rights reserved.
//

import UIKit

class SingleImageViewController: UIViewController {

    @IBOutlet weak var singleImage: UIImageView!
    var passedSingleImage = UIImage()
    @IBOutlet weak var backButton: UIButton!
    var lastViewController = String()
    
    @IBAction func backToAccount(_ sender: Any) {
        performSegue(withIdentifier: "backToAccountSegue", sender: [])
    }
    
    override func viewDidLoad() {
        singleImage.image = passedSingleImage
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! UITabBarController
        destination.selectedIndex = 0
    }

}
