//
//  CreateMenuVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 11/24/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//  moveToDetailTemVC

import UIKit

class CreateMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var section = ["Non-Vegan", "Vegan", "Add-Ons"]
    var menu = [[String]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        let name = ["Pre"]
        menu.append(name)
        menu.append(name)
        menu.append(name)
        tableView.reloadData()
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
    
        return section.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
         return menu[section].count
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //print(menu[indexPath.section][indexPath.row].count)
        
 
        
        if indexPath.row >= 1 {
            
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as? ItemCell {

                return cell
                
            } else {
                
                return ItemCell()
                
            }
            
            
         } else {
             
             if let cell = tableView.dequeueReusableCell(withIdentifier: "addNewItemCell") as? addNewItemCell {
                
                cell.addItemBtn.addTarget(self, action: #selector(CreateMenuVC.addItemBtnPressed), for: .touchUpInside)
                
                return cell
                 
                 
             } else {
                 
                 return addNewItemCell()
                 
             }
         }

    
        
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return ""
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90.0
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 55))
        returnedView.backgroundColor = .clear

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        label.textColor = .black
        label.text = self.section[section]
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        returnedView.addSubview(label)

        return returnedView
    }
    
    @objc func addItemBtnPressed() {
           
        self.performSegue(withIdentifier: "moveToDetailTemVC", sender: nil)
    
           
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func CreateBtnPressed(_ sender: Any) {
        
        
    }
    
}
