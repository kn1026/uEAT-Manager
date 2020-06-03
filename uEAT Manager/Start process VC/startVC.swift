//
//  ViewController.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 10/21/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase

class startVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //loadCuisine()
        
    }
    

    func loadCuisine() {
        
        DataService.instance.mainFireStoreRef.collection("Ingredient_list").order(by: "name", descending: false).getDocuments { (snap, err) in
            
            
            if err != nil {
                
                //self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                return
            }
        
            for item in snap!.documents {
            
                let i = item.data()
                
                print(i["name"])
                
                
            }
        }
        
        
        
    }
    
    
    @IBAction func LoginBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToLoginVC", sender: nil)
        
    }
    
    @IBAction func SignUpBtnPresed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToSignUpVC", sender: nil)
        
    }
    
}
