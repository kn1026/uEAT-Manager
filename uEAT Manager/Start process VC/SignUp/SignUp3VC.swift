//
//  SignUp2VC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 11/22/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import CoreLocation
import MobileCoreServices
import AVKit
import AVFoundation
import ZSWTappableLabel
import ZSWTaggedString
import SafariServices
import Firebase
import FirebaseAuth
import SCLAlertView
import GeoFire

class SignUp3VC: UIViewController, UITextFieldDelegate, ZSWTappableLabelTapDelegate {

    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var termOfUseLbl: ZSWTappableLabel!
    
    var businessName = ""
    var businessAddress = ""
    var RestaurantLocation = CLLocationCoordinate2D()
    var logo: UIImage?
    var itemList = [String]()
    
    static let URLAttributeName = NSAttributedString.Key(rawValue: "URL")
    
    enum LinkType: String {
        case Privacy = "Privacy"
        case TermsOfUse = "TOU"
        case CodeOfProduct = "COP"
        
        var URL: Foundation.URL {
            switch self {
            case .Privacy:
                return Foundation.URL(string: "http://campusconnectonline.com/wp-content/uploads/2017/07/Web-Privacy-Policy.pdf")!
            case .TermsOfUse:
                return Foundation.URL(string: "http://campusconnectonline.com/wp-content/uploads/2017/07/Website-Terms-of-Use.pdf")!
            case .CodeOfProduct:
                return Foundation.URL(string: "http://campusconnectonline.com/wp-content/uploads/2017/07/User-Code-of-Conduct.pdf")!
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTxt.attributedPlaceholder = NSAttributedString(string: "Email address",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
               
        emailTxt.delegate = self
        
        phoneTxt.attributedPlaceholder = NSAttributedString(string: "Phone number",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
               
        phoneTxt.delegate = self

        // Do any additional setup after loading the view.
        
        phoneTxt.keyboardType = .numberPad
        
        
        termOfUseLbl.tapDelegate = self
        
        let options = ZSWTaggedStringOptions()
        options["link"] = .dynamic({ tagName, tagAttributes, stringAttributes in
            guard let typeString = tagAttributes["type"] as? String,
                let type = LinkType(rawValue: typeString) else {
                    return [NSAttributedString.Key: AnyObject]()
            }
            
            return [
                .tappableRegion: true,
                .tappableHighlightedBackgroundColor: UIColor.lightGray,
                .tappableHighlightedForegroundColor: UIColor.black,
                .foregroundColor: UIColor.black,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                SignUp3VC.URLAttributeName: type.URL
            ]
        })
        
        let string = NSLocalizedString("By clicking Finish, you agree to our <link type='TOU'>Terms of use</link>, <link type='Privacy'>Privacy Policy</link> and <link type='COP'>User Code of Conduct</link>.", comment: "")
        
        termOfUseLbl.attributedText = try? ZSWTaggedString(string: string).attributedString(with: options)
        
    }
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any] = [:]) {
        guard let URL = attributes[SignUp3VC.URLAttributeName] as? URL else {
            return
        }
        
        if #available(iOS 9, *) {
            show(SFSafariViewController(url: URL), sender: self)
        } else {
            UIApplication.shared.openURL(URL)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTxt.becomeFirstResponder()
        
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == phoneTxt {
            
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            textField.text = formattedNumber(number: newString)
            
            return false
        } else {
            
            return true
        }
          
    }
    
    private func formattedNumber(number: String) -> String {
        let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "(XXX) XXX-XXXX"
        
        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        
        
        return result
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func convertPhoneNumber(Phone: String) -> String {
        
        let arr = Array(Phone)
        var new = [String]()
        
        for i in arr {
            
            if i != "(", i != ")", i != " ", i != "-" {
                
                
                new.append(String((i)))
                
            
            }
            
        }
        
        let stringRepresentation = new.joined(separator:"")
        
        
        return stringRepresentation
    }
    
    @IBAction func finishBtnPressed(_ sender: Any) {
        
        if let phone = phoneTxt.text, let email = emailTxt.text, phone != "", email != "" {
            
            let converted = convertPhoneNumber(Phone: phone)
            
            if converted.count != 10 {
                
                self.showErrorAlert("Ops !", msg: "Your phone number is invalid")
                
            } else {
                
                if email.contains("@") == true, email.contains(".") == true {
                    
                    
                    
                    if let img = logo {
                        
                        self.uploadLogoImg(image: img, email: email, Phone: converted)
                        
                    }
                    
                } else {
                    
                    self.showErrorAlert("Opss !!!", msg: "Your email is invalid")
                    
                }
                
            }
            
            
        } else {
            
            
            self.showErrorAlert("Opss !!!", msg: "Please enter email and password.")
            
        }
        
    }
    
    func uploadLogoImg(image: UIImage, email: String, Phone: String) {
        
        
        
        self.swiftLoader()
        
        var  dotCount = [Int]()
        var count = 0
        var testEmails = ""
        
        
        var testEmailArr = Array(email)
        for _ in 0..<(testEmailArr.count) {
            if testEmailArr[count] == "." {
                
                dotCount.append(count)
                
            }
            count += 1
        }
        
        
        
        for indexCount in dotCount {
            
            testEmailArr[indexCount] = ","
            let testEmail = String(testEmailArr)
            testEmails = testEmail
            testEmailed = testEmail
            
        }
        
        
        DataService.instance.checkResEmailUserRef.child(testEmails).observeSingleEvent(of: .value, with: { (snapData) in
                                   
                                   
            if snapData.exists() {
                
                SwiftLoader.hide()
                                    
                self.showErrorAlert("Oopss !!!", msg: "This email has been used")
                
            } else {
                
                DataService.instance.checReskPhoneUserRef.child("+1\(Phone)").observeSingleEvent(of: .value, with: { (snapData) in
                    
                    
                    if snapData.exists() {
                        
                        SwiftLoader.hide()
                        
                        self.showErrorAlert("Oopss !!!", msg: "This phone has been used")
                        
                    } else {
                        
                        
                        let metaData = StorageMetadata()
                        let imageUID = UUID().uuidString
                        metaData.contentType = "image/jpeg"
                        var imgData = Data()
                        imgData = image.jpegData(compressionQuality: 1.0)!
                        
                        
                        
                        DataService.instance.LogoStorageRef.child(imageUID).putData(imgData, metadata: metaData) { (meta, err) in
                            
                            if err != nil {
                                
                                SwiftLoader.hide()
                                self.showErrorAlert("Oopss !!!", msg: "Error while saving your image, please try again")
                                print(err?.localizedDescription as Any)
                                
                            } else {
                                
                                DataService.instance.LogoStorageRef.child(imageUID).downloadURL(completion: { (url, err) in
                                    
                                    
                                    guard let Url = url?.absoluteString else { return }
                                    
                                    
                                    var ref: DocumentReference? = nil
                                    
                                    let downUrl = Url as String
                                    let downloadUrl = downUrl as NSString
                                    let downloadedUrl = downloadUrl as String
                                    
                                    let data = ["Phone": Phone, "Lat": self.RestaurantLocation
                                        .latitude, "Lon": self.RestaurantLocation.longitude, "businessAddress": self.businessAddress, "businessName": self.businessName, "Email": email, "Status" : "Pending", "LogoUrl": downloadedUrl, "Timestamp": FieldValue.serverTimestamp(), "Cuisine": self.itemList] as [String : Any]
                                             
                                    let db = DataService.instance.mainFireStoreRef.collection("Restaurant")
                                    
                                    ref = db.addDocument(data: data) { err in
                                        
                                        if let err = err {
                                            
                                            SwiftLoader.hide()
                                            self.showErrorAlert("Opss !", msg: err.localizedDescription)
                                            
                                        } else {
                                            
                                            self.view.endEditing(true)
                                            
                                            let id = ref!.documentID
                                            
                                            let data = ["Restaurant_id": id] as [String : Any]
                                            
                                            
                                            DataService.instance.mainFireStoreRef.collection("Restaurant").document(id).updateData(data)
                                            
                                            DataService.instance.mainFireStoreRef.collection("Restaurant_check_list").document(id).setData(["Menu": false, "Two-factor-authentication": false, "Timestamp": FieldValue.serverTimestamp()])
                                            
                                            self.create_location(loc: self.RestaurantLocation, key: id)
                                            
                                            
                                            DataService.instance.checkResEmailUserRef.child(testEmails).setValue(["Timestamp": ServerValue.timestamp()])
                                            DataService.instance.checReskPhoneUserRef.child("+1\(Phone)").setValue(["Timestamp": ServerValue.timestamp()])
                                            
                                            
                                            DataService.instance.mainRealTimeDataBaseRef.child("newApplicationNoti").child("Admin").child(self.businessName).removeValue()
                                            let values: Dictionary<String, AnyObject>  = [self.businessName: 1 as AnyObject]
                                            DataService.instance.mainRealTimeDataBaseRef.child("newApplicationNoti").child("Admin").setValue(values)
                                            
                                       
                                            
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
                                                
                                                
                                                self.performSegue(withIdentifier: "moveBack", sender: nil)
                                                
                                                
                                            }
                                            
                                            let icon = UIImage(named:"logo")
                                            
                                            _ = alert.showCustom("Congratulations!", subTitle: "You have successfully submitted the application to join us, we will process your application soon and reach back out to you by phone and email", color: UIColor.black, icon: icon!)
                                            
                                            
                                            
                                        }
                                      
                                    
                                    
                                    
                                    }
                                    
                                    
                                    
                                })
                                
                                
                                
                                
                                
                            }
                            
                            
                        }

                        
                        
                    }
                    
                    
                })
                
                
                
            }
            
        })
        
        
        
        
        
    }
    
    
    func create_location(loc: CLLocationCoordinate2D, key: String) {
         
         let rootRef = Database.database().reference()
         let geoRef = GeoFire(firebaseRef: rootRef.child("Restaurant_coordinator"))
         
    
         
        geoRef.setLocation(CLLocation(latitude: loc.latitude, longitude: loc.longitude), forKey: key) { (error) in
             if (error != nil) {
                debugPrint("An error occured: \(error!.localizedDescription)")
             } else {
                 print("Saved location successfully!")
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
    

    
   

}
