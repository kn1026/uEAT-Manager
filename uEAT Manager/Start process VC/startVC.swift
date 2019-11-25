//
//  ViewController.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 10/21/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit


class startVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func LoginBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToLoginVC", sender: nil)
        
    }
    
    @IBAction func SignUpBtnPresed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToSignUpVC", sender: nil)
        
    }
    
}
