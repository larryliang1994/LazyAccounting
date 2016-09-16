//
//  UtilBox.swift
//  TaskMoment
//
//  Created by 梁浩 on 15/12/14.
//  Copyright © 2015年 LeungHowell. All rights reserved.
//

import Foundation
import UIKit
import Photos

class UtilBox {
    // 字符串转Dic
    static func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    // 弹出提示对话框
    static func alert(vc: UIViewController, message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "好的", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        
        vc.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // 弹出提示对话框
    static func funcAlert(vc: UIViewController, message: String, okAction: UIAlertAction?, cancelAction: UIAlertAction?) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        if cancelAction != nil {
            alertController.addAction(cancelAction!)
        }
        if okAction != nil {
            alertController.addAction(okAction!)
        }
        
        vc.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // 通过ID获取vc
    static func getController(identifier: String) -> UIViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle())
        return storyboard.instantiateViewControllerWithIdentifier(identifier)
    }
}

extension Int {
    func toString() -> String {
        let myString = String(self)
        return myString
    }
}

extension UIView {
    class func loadFromNibNamed(nibName:String,bundle : NSBundle? = nil) -> UIView? {
        return UINib(nibName: nibName, bundle: bundle).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}
