//
//  ContactVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 12/9/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

class ContactVC: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var webLbl: UILabel!
    
    var marker = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
        
        styleMap()
        
    }
    
    func styleMap() {
    
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "customizedMap", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    
    
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getRestaurant_ID(email: (Auth.auth().currentUser?.email)!)
    }
    
    
    func getRestaurant_ID(email: String) {
        
        let emails = process_email(email: email)
        
        DataService.instance.mainFireStoreRef.collection("Restaurant").whereField("Email", isEqualTo: emails).getDocuments { (snap, err) in
            
            if err != nil {
            
                SwiftLoader.hide()
                self.showErrorAlert("Opss !", msg: "Can't validate your account")
                print(err?.localizedDescription as Any)
                return
            
            }
            
            
            if snap?.isEmpty == true {
                
                SwiftLoader.hide()
                             
                self.showErrorAlert("Opss !", msg: "Your account isn't ready yet, please wait until getting an email from us or you can contact our support")
                          
            } else {
                
                
                for item in snap!.documents {
                    
                    //let id = item.documentID
                    if let businessAddress = item["businessAddress"] as? String {
                        
                        self.addressLbl.text = businessAddress
                        
                    }
                    
                    if let Phone = item["Phone"] as? String {
                        
                        self.phoneLbl.text = Phone
                        
                    }
                    
                    if let email = item["Email"] as? String {
                        
                        self.emailLbl.text = email
                        
                    }
                    
                    if let webAdress = item["webAdress"] as? String {
                        
                        self.webLbl.text = webAdress
                        
                    }
                    
                    if let Lat = item["Lat"] as? CLLocationDegrees, let Lon = item["Lon"] as? CLLocationDegrees  {
                        
                        let location = CLLocationCoordinate2D(latitude: Lat, longitude: Lon)
                        self.centerMapOnUserLocation(location: location)
                        
                    }
                    
                }
                
                
                
            }
            
            
            
        }
        
        

    }
    
    func centerMapOnUserLocation(location: CLLocationCoordinate2D) {
           

           // get MapView
           let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 17)
           

           self.marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        
           marker.position = location
        
           marker.map = mapView
           mapView.camera = camera
           mapView.animate(to: camera)
           marker.appearAnimation = GMSMarkerAnimation.pop
           
           
           marker.isTappable = false
           
            
           
    }
    
    func process_email(email: String) -> String {
        
        
        var count = 0
        let arr = Array(email)
        var new = [String]()
               
        for i in arr {
            
            if count > 7 {
                
                new.append(String((i)))
                
            }
                   
                count += 1
        }
               
        let stringRepresentation = new.joined(separator:"")
               
               
        return stringRepresentation
        
    }
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func swiftLoader() {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: "", animated: true)
        
         
        
    }
    
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func EditBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToContactDetailVC", sender: nil)
        
    }
}
