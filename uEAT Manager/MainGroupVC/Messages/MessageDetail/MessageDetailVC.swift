//
//  MessageDetailVC.swift
//  uEAT Manager
//
//  Created by Khoi Nguyen on 6/22/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import AVFoundation
import FirebaseDatabase
import Firebase
import Cache
import Alamofire

class MessageDetailVC: JSQMessagesViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var chatUID = ""
    var chatOrderID = ""
    var chatKey = ""
    var displayName = ""
    var userUID = ""
    
    var handleObserve: UInt!
    
    var chatImage = UIImage(named: "send_btn")
    
    var messages = [JSQMessage]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.inputToolbar.contentView.textView.becomeFirstResponder()

            // Do any additional setup after loading the view.

            let buttonWidth = CGFloat(48)
            let buttonHeight = CGFloat(48)
            let customButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight))
            customButton.backgroundColor = .clear
            customButton.setImage(chatImage, for: .normal)
            customButton.imageView?.contentMode = .scaleAspectFill

            inputToolbar.contentView.rightBarButtonItemWidth = buttonWidth
            inputToolbar.contentView.rightBarButtonItem = customButton
            
            
            
            // Register nibs
            self.incomingCellIdentifier = MessageViewIncoming.cellReuseIdentifier();
            self.collectionView.register(MessageViewIncoming.nib(), forCellWithReuseIdentifier: self.incomingCellIdentifier)
            self.outgoingCellIdentifier = MessageViewOutgoing.cellReuseIdentifier();
            self.collectionView.register(MessageViewOutgoing.nib(), forCellWithReuseIdentifier: self.outgoingCellIdentifier)
            
            self.incomingMediaCellIdentifier = MessageViewIncoming.mediaCellReuseIdentifier();
            self.collectionView.register(MessageViewIncoming.nib(), forCellWithReuseIdentifier: self.incomingMediaCellIdentifier)
            self.outgoingMediaCellIdentifier = MessageViewOutgoing.mediaCellReuseIdentifier();
            self.collectionView.register(MessageViewOutgoing.nib(), forCellWithReuseIdentifier: self.outgoingMediaCellIdentifier)
            
            self.inputToolbar.contentView.backgroundColor = UIColor.white
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessageDetailVC.dismissKeyboard))
            tapGestureRecognizer.delegate = self
            
            
            
            
            self.senderId = chatUID
            
            self.collectionView?.addGestureRecognizer(tapGestureRecognizer)
            
            if displayName == "" {
                
                self.senderDisplayName = "Customer"
                
            } else {
                
                self.senderDisplayName = displayName
                
            }
            
            automaticallyScrollsToMostRecentMessage = true
            
            
            self.inputToolbar.contentView.textView.placeHolder = "Type your messages ..."
            
            self.inputToolbar.contentView.leftBarButtonItem = nil
            self.inputToolbar.contentView.textView.layer.cornerRadius = self.inputToolbar.contentView.textView.frame.width / 56
        
            self.collectionView.backgroundColor = UIColor(red: 242/255, green: 241/255, blue: 241/255, alpha: 1.0)
            
            navigationItem.title = "Order CC - \(chatOrderID)"
            
            
            
            observeMessages(FinalKey: chatKey)
            keysend = chatKey
        
            setOnline()
        
        
    }
    
    
    func setOnline() {
        
        
        
        DataService.instance.mainRealTimeDataBaseRef.child("Order_Chat_Info").child(self.chatKey).updateChildValues([self.chatUID: 1])
        
        
    }
    
    func setOffline() {
        
       DataService.instance.mainRealTimeDataBaseRef.child("Order_Chat_Info").child(self.chatKey).updateChildValues([self.chatUID: 0])
        
    }
    
    @objc func dismissKeyboard(gesture: UITapGestureRecognizer) {
            self.collectionView.layoutIfNeeded()
            
            self.view.endEditing(true)
        }
        
        override func textViewDidBeginEditing(_ textView: UITextView) {
            self.scrollToBottom(animated: true)
            
            
        }
        
        override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
            
            
            let data = self.messages[indexPath.item]
            return data
            
            
        }
        
        override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
            let message = messages[indexPath.item]
            let bubbleFactory = JSQMessagesBubbleImageFactory()
            
            if message.senderId == self.senderId {
                return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor(red: 248/255, green: 240/255, blue: 2/255, alpha: 1.0))
                
            } else {
                
                return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0))
                
            }
            
            
            
            
        }
        
        override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {

            
            // Sent by me, skip
            return nil

        }
        
        override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
                
                
             
                 if chatKey != "" {
                    
                    let key = chatKey
                     
                    if key != "" {

                        keysend = key
                        
                        let messageRef = DataService.instance.mainRealTimeDataBaseRef.child("Order_Chat").child(key).child("message")
                        
                        let newMessage = messageRef.childByAutoId()
                        let messageData = ["Text": text!, "senderId": senderId!, "senderName": senderDisplayName!, "MediaType": "Text", "timestamp": ServerValue.timestamp()] as [String : Any]
                        
                        let chatInformation: Dictionary<String, Any> = ["timeStamp": FieldValue.serverTimestamp(), "LastMessage": text!]
                        
                        self.finishSendingMessage()
                        
                        newMessage.setValue(messageData)
                        DataService.instance.mainFireStoreRef.collection("Chat_orders").document(self.chatKey).updateData(chatInformation)
                        
                        DataService.instance.mainRealTimeDataBaseRef.child("Order_Chat_Info").child(key).updateChildValues(["Last_message": text!])
                        
                        DataService.instance.mainRealTimeDataBaseRef.child("Order_Chat_Info").child(self.chatKey).observeSingleEvent(of: .value, with: { (snapInfo) in
                        
                        
                            if snapInfo.exists() {
                                
                                if let postDict = snapInfo.value as? Dictionary<String, Any> {
                                    
                                    
                                    if let status = postDict[self.userUID] as? Int {
                                        
                                        if status == 0 {
                                            
                                            DataService.instance.mainRealTimeDataBaseRef.child("userChatNoti").child(self.userUID).child(key).removeValue()
                                            let values: Dictionary<String, AnyObject>  = [key: 1 as AnyObject]
                                            DataService.instance.mainRealTimeDataBaseRef.child("userChatNoti").child(self.userUID).setValue(values)
                                            
                                        } else if status == 1 {
                                            
                                            print("Online")
                                            
                                        } else {
                                            
                                            DataService.instance.mainRealTimeDataBaseRef.child("userChatNoti").child(self.userUID).child(key).removeValue()
                                            let values: Dictionary<String, AnyObject>  = [key: 1 as AnyObject]
                                            DataService.instance.mainRealTimeDataBaseRef.child("userChatNoti").child(self.userUID).setValue(values)
                                            
                                        }
                                        
                                    } else {
                                        
                                        DataService.instance.mainRealTimeDataBaseRef.child("userChatNoti").child(self.userUID).child(key).removeValue()
                                        let values: Dictionary<String, AnyObject>  = [key: 1 as AnyObject]
                                        DataService.instance.mainRealTimeDataBaseRef.child("userChatNoti").child(self.userUID).setValue(values)
                                        
                                        
                                    }
                                    
                                }
                                
                            } else {
                                
                                
                                DataService.instance.mainRealTimeDataBaseRef.child("userChatNoti").child(self.userUID).child(key).removeValue()
                                let values: Dictionary<String, AnyObject>  = [key: 1 as AnyObject]
                                DataService.instance.mainRealTimeDataBaseRef.child("userChatNoti").child(self.userUID).setValue(values)
                                
                            }
                            
                            
                        })
                        
                        
                        
                        
                    }
                 
                 }
     
             
             
             
         }
        
        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return messages.count
        }
        
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            
            
            let message = messages[indexPath.item]
            
       
            if message.senderId == self.senderId {
                
                let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! MessageViewOutgoing
                
                
                
                cell.textView.textColor = UIColor.black
                cell.isUserInteractionEnabled = false
              
                
                return cell
                
            } else {
                
                let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! MessageViewIncoming

                cell.textView.textColor = UIColor.darkGray
                cell.isUserInteractionEnabled = false
                
                return cell
            }
        }
        
        
        func observeMessages(FinalKey: String?) {
                
                var ChatMode = ""
                
                ChatMode = "Order_Chat"
            
            
                if let key = FinalKey {
                    let messageRef = DataService.instance.mainRealTimeDataBaseRef.child(ChatMode).child(key).child("message")
                    
                    handleObserve = messageRef.queryLimited(toLast: 50).observe(.childAdded, with: { (snapshot) in
                        
                        if let dict = snapshot.value as? [String: Any] {
                            let mediaType = dict["MediaType"] as! String
                            let senderId = dict["senderId"] as! String
                            let senderName = dict["senderName"] as! String
                            let date =  dict["timestamp"]
                            let time = (date as? TimeInterval)! / 1000
                            let result = Date(timeIntervalSince1970: time)
                            
                            
                            
                            switch mediaType {
                                
                            case "Text":
                                
                                let text = dict["Text"] as! String
                                
                                self.messages.append(JSQMessage(senderId: senderId, senderDisplayName: senderName, date: result, text: text))
                                self.scrollToBottom(animated: true)
                                self.collectionView.reloadData()
                                
                            case "PHOTO":
                                
                                print("Not yet supporting PHOTO")
                                
                                
                            case "VIDEO":
                                
                                print("Not yet supporting VIDEO")
                                
                                
                            default:
                                print("No data Type")
                            }
                            
                            
                            self.scrollToBottom(animated: true)
                            self.collectionView.reloadData()
                            
                        }
                        
                        
                    })
                    
                    
                    
                    
                }

        }
        
        func dayDifference(from date : Date) -> String
        {
            let calendar = NSCalendar.current
            if calendar.isDateInYesterday(date) { return "Yesterday" }
            else if calendar.isDateInToday(date) { return "Today" }
            else if calendar.isDateInTomorrow(date) { return "Tomorrow" }
            else {
                let startOfNow = calendar.startOfDay(for: Date())
                let startOfTimeStamp = calendar.startOfDay(for: date)
                let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
                let day = components.day!
                if day < 1 { return "\(abs(day)) days ago" }
                else { return "In \(day) days" }
            }
        }


    @IBAction func back1BtnPressed(_ sender: Any) {
        
        let messageRef = DataService.instance.mainRealTimeDataBaseRef.child("Order_Chat").child(chatKey).child("message")
        messageRef.removeObserver(withHandle: handleObserve)
        
        setOffline()
        
        self.dismiss(animated: true, completion: nil)
        
    }
}



extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}

extension JSQMessagesInputToolbar {
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *), let window = self.window {
            let anchor = window.safeAreaLayoutGuide.bottomAnchor
            bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: 1.0).isActive = true
        }
    }
}

