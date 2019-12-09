//
//  DetailVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 11/25/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import AVFoundation

class DetailVC: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var uploadProfileImg: borderAvatarView!
    @IBOutlet weak var categoryTxtField: UITextField!
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var descriptionTxtField: UITextField!
    @IBOutlet weak var priceTxtField: UITextField!
    @IBOutlet weak var uploadBtn: UIButton!
    
    @IBOutlet weak var NonVeganBtn: UIButton!
    @IBOutlet weak var VeganBtn: UIButton!
    @IBOutlet weak var addOnBtn: UIButton!
    @IBOutlet weak var addItem: UIButton!
    
    var type = ""
    var cuisineList = [Cuisine_model]()
    
    @IBOutlet weak var totalLbl: UILabel!
    
    var img: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        categoryTxtField.attributedPlaceholder = NSAttributedString(string: "Category",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
               
        categoryTxtField.delegate = self
        
        nameTxtField.attributedPlaceholder = NSAttributedString(string: "Name",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
               
        nameTxtField.delegate = self
        
        descriptionTxtField.attributedPlaceholder = NSAttributedString(string: "Description",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
               
        descriptionTxtField.delegate = self
        
        priceTxtField.attributedPlaceholder = NSAttributedString(string: "Price",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
               
        priceTxtField.delegate = self

        // Do any additional setup after loading the view.
        
        priceTxtField.keyboardType = .decimalPad
        
        priceTxtField.addTarget(self, action: #selector(DetailVC.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        loadCuisine()
        
        if transitem != nil {
            
            categoryTxtField.text = transitem.category
            nameTxtField.text = transitem.name
            descriptionTxtField.text = transitem.description
            priceTxtField.text = "\(transitem.price!)"
            totalLbl.text = "$\(transitem.price!)"
            img = transitem.img
            uploadProfileImg.image = transitem.img
            
            if transitem.img == nil {
                
                if presented != nil {
                    uploadProfileImg.image = presented
                }
                
            }
        
            if transitem.type == "Vegan"{
                
                NonVeganBtn.backgroundColor = UIColor.clear
                VeganBtn.backgroundColor = UIColor.yellow
                addOnBtn.backgroundColor = UIColor.clear
                
                type = "Vegan"
                 
            } else if transitem.type == "Non-Vegan" {
                
                NonVeganBtn.backgroundColor = UIColor.yellow
                VeganBtn.backgroundColor = UIColor.clear
                addOnBtn.backgroundColor = UIColor.clear
                
                type = "Non-Vegan"
                
            } else {
                
                NonVeganBtn.backgroundColor = UIColor.clear
                VeganBtn.backgroundColor = UIColor.clear
                addOnBtn.backgroundColor = UIColor.yellow
                
                type = "Add-on"
                
            }
          
            categoryTxtField.isUserInteractionEnabled = false
            nameTxtField.isUserInteractionEnabled = false
            descriptionTxtField.isUserInteractionEnabled = false
            priceTxtField.isUserInteractionEnabled = false
            
            NonVeganBtn.isUserInteractionEnabled = false
            VeganBtn.isUserInteractionEnabled = false
            addOnBtn.isUserInteractionEnabled = false
            uploadBtn.isUserInteractionEnabled = false
            
            addItem.isHidden = true
            
        }
        
    }
    
    
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            totalLbl.text = "$\(text)"
        }
        
    }
    
    
    @IBAction func categoryBtnPressed(_ sender: Any) {
        
        
        createDayPicker()
        
    }
    
    func createDayPicker() {
        
        
        let dayPicker = UIPickerView()
        dayPicker.delegate = self

        //Customizations
        
        
        categoryTxtField.inputView = dayPicker
        
        
    }
    
    
    @IBAction func uploadBtnPressed(_ sender: Any) {
        
        
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
    
    @IBAction func addItemBtnPressed(_ sender: Any) {
        
        if let name = nameTxtField.text, name != "", let description = descriptionTxtField.text, description != "", let price = priceTxtField.text, price != "", img != nil, let category = categoryTxtField.text, category != "", type != "" {
            
            let pri = Float(price)
            
            
            let dict = ["name": name, "description": description, "price": pri as Any, "img": img as Any, "category": category, "type": type, "status": "Online", "quanlity": "None"] as [String : Any]
            let item = ItemModel(postKey: "1234", Item_model: dict)
            transitem = item
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "setItem")), object: nil)
            
            self.dismiss(animated: true, completion: nil)
            
            
        } else {
            
            self.showErrorAlert("Ops !!!", msg: "Please fill all required fields to continue !!!")
            
            
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

        
        img = image
        uploadProfileImg.image = image

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
    
    @IBAction func NonVeganBtnPressed(_ sender: Any) {
        
        
        //NonVeganBtn
        NonVeganBtn.backgroundColor = UIColor.yellow
        VeganBtn.backgroundColor = UIColor.clear
        addOnBtn.backgroundColor = UIColor.clear
        
        type = "Non-Vegan"
        
    }
    
    @IBAction func VeganBtn(_ sender: Any) {
        
        
        NonVeganBtn.backgroundColor = UIColor.clear
        VeganBtn.backgroundColor = UIColor.yellow
        addOnBtn.backgroundColor = UIColor.clear
        
        type = "Vegan"
        
    }
    
    @IBAction func AddOnsBtnPressed(_ sender: Any) {
        
        NonVeganBtn.backgroundColor = UIColor.clear
        VeganBtn.backgroundColor = UIColor.clear
        addOnBtn.backgroundColor = UIColor.yellow
        
        type = "Add-on"
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        
        self.view.endEditing(true)
        
    }
    
    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        moveTextField(textField, moveDistance: -220, up: true)
        
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
        moveTextField(textField, moveDistance: -220, up: false)
        
           
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
       // let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
       
        
        
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
                
                
                
            }
        }
        
        
        
    }
 

    
}

extension DetailVC: UIImagePickerControllerDelegate {
    
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


extension DetailVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        
        return 1
            
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return cuisineList.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
        
        return cuisineList[row].name
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        categoryTxtField.text = cuisineList[row].name
        //GenderSelected = GenderTxt.text
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel!
        
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.text = cuisineList[row].name
        
        label.textAlignment = .center
        return label

        
    }
}


extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}
