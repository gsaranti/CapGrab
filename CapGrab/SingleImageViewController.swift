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
    
    override func viewDidLoad() {
        singleImage.image = passedSingleImage
        super.viewDidLoad()

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
