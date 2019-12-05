//
//  SignUp1VC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 11/21/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import CoreLocation
import MobileCoreServices
import AVKit
import AVFoundation
import Firebase
import SCLAlertView

class SignUp1VC: UIViewController, GMSMapViewDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var uploadLogo: UIButton!
    @IBOutlet weak var BusinessTxtField: UITextField!
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoView: borderAvatarView!
    @IBOutlet weak var mapView: GMSMapView!
    
    var businessName = ""
    var businessAddress = ""
    var logo: UIImage?
    
    var RestaurantLocation = CLLocationCoordinate2D()
    
    let autocompleteController = GMSAutocompleteViewController()
    
    var marker = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mapView.delegate = self
        autocompleteController.delegate = self
        mapView.isUserInteractionEnabled = false
        styleMap()
        // Do any additional setup after loading the view.
        
        
        BusinessTxtField.attributedPlaceholder = NSAttributedString(string: "Find your business",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
               
        BusinessTxtField.delegate = self
        
    }
    
    @IBAction func UploadLogoBtnPressed(_ sender: Any) {
        
        let sheet = UIAlertController(title: "Upload your logo !!!", message: "", preferredStyle: .actionSheet)
        
        
        
        let album = UIAlertAction(title: "Upload from album", style: .default) { (alert) in
            
            self.album()
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        

        sheet.addAction(album)
        sheet.addAction(cancel)
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    func album() {
        
        self.getMediaFrom(kUTTypeImage as String)
             
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }

    @IBAction func businessBtnPressed(_ sender: Any) {
        
        self.present(autocompleteController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func NextBtnPressed(_ sender: Any) {
        
        
        if logoView.image != nil, BusinessTxtField.text != "" {
            
            
            swiftLoader()
           
            
            DataService.instance.mainFireStoreRef.collection("Restaurant").whereField("businessName", isEqualTo: BusinessTxtField.text!).whereField("Lat", isEqualTo: RestaurantLocation.latitude).whereField("Lon", isEqualTo: RestaurantLocation.longitude).getDocuments { (snap, err) in
            
                if err != nil {
                
                    SwiftLoader.hide()
                    self.showErrorAlert("Opss !", msg: "Can't validate your application this time")
                    print(err?.localizedDescription as Any)
                    return
                
                }
                
                
                if snap?.isEmpty == true {
                    
                    SwiftLoader.hide()
                                 
                    self.performSegue(withIdentifier: "MoveToCuisineVC", sender: nil)
                              
                } else {
                    
                    
                    SwiftLoader.hide()
                    
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                        kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                        showCloseButton: false,
                        dynamicAnimatorActive: true,
                        buttonsLayout: .horizontal
                    )
                    
                    let alert = SCLAlertView(appearance: appearance)
                    _ = alert.addButton("Got it") {
                        
                        
                        
                        
                        
                    }
                    
                    let icon = UIImage(named:"logo")
                    
                    _ = alert.showCustom("Application found !!!", subTitle: "You have successfully submitted the application to join us, Please wait and we will contact you soon", color: UIColor.black, icon: icon!)
                      
                
                }
                
                
                
                
            }
            
            
        } else {
            
            
            self.showErrorAlert("Oops !!!", msg: "Please upload your logo and find your business")
            
        }
        
        
        
    }
    
    func centerMapOnUserLocation(location: CLLocationCoordinate2D, text: String, add: String) {
           

           // get MapView
           let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 17)
           

           self.marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        
           marker.position = location
           marker.title = text
        
           marker.map = mapView
           mapView.camera = camera
           mapView.animate(to: camera)
           marker.appearAnimation = GMSMarkerAnimation.pop
           
           
           marker.isTappable = false
           marker.snippet = add
           
            
           
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
    
    func getMediaFrom(_ type: String) {
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.allowsEditing = true
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    func getMediaCamera(_ type: String) {
        
        
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.allowsEditing = true
        mediaPicker.mediaTypes = [type as String] //UIImagePickerController.availableMediaTypes(for: .camera)!
        mediaPicker.sourceType = .camera
        self.present(mediaPicker, animated: true, completion: nil)
        
    }
    
    func getImage(image: UIImage) {

        
        logo = image
        logoView.image = image

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
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if segue.identifier == "MoveToCuisineVC"{
            if let destination = segue.destination as? SignUp2VC {
                
                destination.businessName = businessName
                destination.businessAddress = businessAddress
                destination.RestaurantLocation = RestaurantLocation
                destination.logo = logo
                
            }
        }
        
        
    }
    
    
    func checkDuplicateRestaurant() {
        
        
        
        
    }
 
    
}

extension SignUp1VC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
       
        
    
        let placed = place.name
        let address = place.formattedAddress
       
        let lat = place.coordinate.latitude
        let lon = place.coordinate.longitude
        
        businessName = placed!
        businessAddress = address!
        
        
        BusinessTxtField.text = placed!
        mapViewHeightConstraint.constant = 150.0
        
        RestaurantLocation.latitude = lat
        RestaurantLocation.longitude = lon
        
        centerMapOnUserLocation(location: RestaurantLocation, text: placed!, add: address!)

        dismiss(animated: true, completion: nil)
        
    }
    
   
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}

extension SignUp1VC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let editedImage = info[.editedImage] as? UIImage {
            getImage(image: editedImage)
        } else if let originalImage =
            info[.originalImage] as? UIImage {
            getImage(image: originalImage)
        }
        
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    

    
}
