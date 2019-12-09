//
//  Constant.swift
//  Campus Connect
//
//  Created by Khoi Nguyen on 3/19/18.
//  Copyright © 2018 Campus Connect LLC. All rights reserved.
//

import Foundation
import Cache
import UIKit
import CoreLocation



let googleMap_Key = "AIzaSyAAYuBDXTubo_qcayPX6og_MrWq9-iM_KE"
let googlePlace_key = "AIzaSyAAYuBDXTubo_qcayPX6og_MrWq9-iM_KE"
let Stripe_key = "pk_live_1AA3PY5adk3jGDL1Eo5Db3PZ"
var applicationKey = "fd466555-559c-447e-95a0-4cc5ffbf303c"
let stripe_test_key = "pk_test_9edrI9MoXrXoYp591KT93gxW"
let dpwd = "ooewiuroiweyuruwehrgwehfgdsjhf"
let client_id = "ca_DWkdLOAvNorIOTz9TNDMsOjGOVq94jbJ"

var testEmailed = ""
var stripeID = ""

let Shadow_Gray: CGFloat = 120.0 / 255.0
typealias DownloadComplete = () -> ()


var authCode = ""
var ratio_width = 414
var ratio_height = 896

var presented: UIImage!

let BColor = UIColor(red: 226, green: 221, blue: 0, alpha: 1)

var transitem: ItemModel!

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

func timeAgoSinceDate(_ date:Date, numericDates:Bool) -> String {
    let calendar = Calendar.current
    let now = Date()
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
    if (components.year! >= 2) {
        return "\(String(describing: components.year)) years ago"
    } else if (components.year! >= 1){
        if (numericDates){
            return "1 year ago"
        } else {
            return "Last year"
        }
    } else if (components.month! >= 2) {
        return "\(components.month!) months ago"
    } else if (components.month! >= 1){
        if (numericDates){
            return "1 month ago"
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks ago"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "1 week ago"
        } else {
            return "Last week"
        }
    } else if (components.day! >= 2) {
        return "\(components.day!) days ago"
    } else if (components.day! >= 1){
        if (numericDates){
            return "1 day ago"
        } else {
            return "Yesterday"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hrs ago"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1 hr ago"
        } else {
            return "An hour ago"
        }
    } else if (components.minute! >= 2) {
        return "\(components.minute!) mins ago"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1 min ago"
        } else {
            return "A min ago"
        }
    } else if (components.second! >= 3) {
        return "\(components.second!)s"
    } else {
        return "Just now"
    }
    
}


func delay(_ seconds: Double, completion:@escaping ()->()) {
    let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: popTime) {
        completion()
    }
}

func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}


extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}
extension StringProtocol {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
extension Date {
    func addedBy(minutes:Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}


func applyShadowOnView(_ view:UIView) {

    view.layer.cornerRadius = 8
    view.layer.shadowColor = UIColor.lightGray.cgColor
    view.layer.shadowOpacity = 1
    view.layer.shadowOffset = CGSize.zero
    view.layer.shadowRadius = 3

}

let disksConfig = DiskConfig(name: "Mix")

let dataStorage = try! Storage(
  diskConfig: disksConfig,
  memoryConfig: MemoryConfig(),
  transformer: TransformerFactory.forData()
)


let imageStorage = dataStorage.transformImage()
