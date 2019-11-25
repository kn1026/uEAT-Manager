//
//  SignUp2VC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 11/23/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import CoreLocation
import MobileCoreServices
import AVKit
import AVFoundation

class SignUp2VC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var itemList = [String]()
    var cuisineList = [Cuisine_model]()
    
    var businessName = ""
    var businessAddress = ""
    var RestaurantLocation = CLLocationCoordinate2D()
    var logo: UIImage?
    
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        collectionView.allowsMultipleSelection = true

        // Do any additional setup after loading the view.
        
        loadCuisine()
        
    }
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
           return 1
       }
       
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           
           return cuisineList.count
           
       }
       
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
           let item = cuisineList[indexPath.row]
           
           if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CuisineCell", for: indexPath) as? cuisineCell {
               
               cell.configureCell(item)
               
               return cell
               
           } else {
               
               return UICollectionViewCell()
               
           }
           
       }
       
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           
           let cell = collectionView.cellForItem(at: indexPath as IndexPath)
           if cell?.isSelected == true {
               
               cell!.backgroundColor = .clear
               cell!.layer.cornerRadius = 10
               cell!.layer.borderWidth = 2
               cell!.layer.borderColor = UIColor.black.cgColor
               
           }
           
           let item = cuisineList[indexPath.row]
           itemList.append(item.name)
           
       }
       
       func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
           
           let cell = collectionView.cellForItem(at: indexPath as IndexPath)
           cell!.layer.borderColor = UIColor.clear.cgColor
           
           let item = cuisineList[indexPath.row]
           
           
           var count = 0
           for x in itemList {
    
               if let name = item.name {
                   
                   if x == name {
                       
                       itemList.remove(at: count)
                       
                   }
                   
               }
               
               count += 1
               
           }
           
       }
       

       func loadCuisine() {
           
           DataService.instance.mainFireStoreRef.collection("Cuisine").order(by: "Cuisine", descending: false).getDocuments { (snap, err) in
               
               
               if err != nil {
                   
                   self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                   return
               }
           
               for item in snap!.documents {
                   
               
                   let i = item.data()
                   
                   let cuisine = Cuisine_model(postKey: item.documentID, Cuisine_model: i)
                   
                   self.cuisineList.append(cuisine)
                   
                   
                   
                   self.collectionView.reloadData()
                   
                   
               }
           }
           
           
           
       }
       
       
       // func show error alert
       
       func showErrorAlert(_ title: String, msg: String) {
           
           let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
           let action = UIAlertAction(title: "OK", style: .default, handler: nil)
           alert.addAction(action)
           
           
           present(alert, animated: true, completion: nil)
           
       }
    
    @IBAction func NextBtnPressed(_ sender: Any) {
        
        
        if itemList.isEmpty == true {
            
            self.showErrorAlert("Opss !", msg: "Please choose at least one cuisine belongs to your restaurant")
            
        } else {
            
            self.performSegue(withIdentifier: "MoveToContactVC", sender: nil)
            
        }
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if segue.identifier == "MoveToContactVC"{
            if let destination = segue.destination as? SignUp3VC {
                
                destination.businessName = businessName
                destination.businessAddress = businessAddress
                destination.RestaurantLocation = RestaurantLocation
                destination.itemList = itemList
                destination.logo = logo
            
                
            }
        }
        
        
    }
}
