//
//  FeedbackViewController.swift
//  LazyAccounting
//
//  Created by 梁浩 on 16/9/3.
//  Copyright © 2016年 LeungHowell. All rights reserved.
//

import UIKit
import SwiftyJSON

class FeedbackViewController: UIViewController {
    @IBOutlet var textView: BRPlaceholderTextView!
    @IBOutlet var sendButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
        initNavBar()
    }
    
    func initView() {
        textView.placeholder = "请输入要反馈的内容"
        textView.setPlaceholderFont(UIFont(name: (textView.font?.fontName)!, size: 17))
        
        sendButton.tintColor = Config.TitleColor
    }
    
    func initNavBar() {
        let titleLabel = UILabel(frame: CGRectMake(0, 0 , 100, 44))
        titleLabel.text = "意见反馈"
        titleLabel.textColor = Config.TitleColor
        titleLabel.font = UIFont(name: titleLabel.font!.fontName, size: 20)
        titleLabel.textAlignment = .Center
        titleLabel.backgroundColor = UIColor.clearColor()
        navigationItem.titleView = titleLabel
    }
    
    @IBAction func send(sender: UIBarButtonItem) {
        textView.resignFirstResponder()
        
        if textView.text == nil || textView.text == "" {
            UtilBox.alert(self, message: "请输入要反馈的内容")
            return
        }
        
        self.pleaseWait()
        
        var params: [String: String] = ["a": "app_feedback", "content": textView.text!, "equipment": UIDevice.currentDevice().name + "##" + UIDevice.currentDevice().systemVersion]
        
        if Config.Cookies != nil && Config.Cookies!.count > 0 {
            for cookie: NSHTTPCookie in Config.Cookies! {
                params[cookie.name] = cookie.value
            }
        }
        
        AlamofireUtil.doRequest("http://ucenter.jiubaiwang.cn/app_api.php?", parameters: params) { (result, response) in
            self.clearAllNotice()
            
            if result {
                self.noticeSuccess("发送成功", autoClear: true, autoClearTime: 1)
            
                let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
                dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
                    NSThread.sleepForTimeInterval(1)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                }
            } else {
                self.noticeError("发送失败", autoClear: true, autoClearTime: 2)
            }
        }
    }
}
