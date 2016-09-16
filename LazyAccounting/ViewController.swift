//
//  ViewController.swift
//  LazyAccounting
//
//  Created by 梁浩 on 16/7/21.
//  Copyright © 2016年 LeungHowell. All rights reserved.
//

import UIKit
import Haneke
import SwiftyJSON

class ViewController: UIViewController, UIWebViewDelegate, WebViewProgressDelegate, QRScanResultDelegate, UMSocialUIDelegate {
    
    @IBOutlet var rightTopButton: UIButton!
    @IBOutlet var webView: UIWebView!
    
    private var progressView: WebViewProgressView!
    private var progressProxy: WebViewProgress!

    private var leftBarButton: UIBarButtonItem?
    private var leftButton: UIButton?
    
    private var rightDidPopover = false
    private var rightButton: UIButton?
    private var rightBarButton: UIBarButtonItem?
    private var rightPopover: PopoverController?
    
    private var webLocation = ""
    private var initLocation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.rightBarButtonItem = UIBarButtonItem()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        navigationController?.navigationBar.barStyle = .Black
        
        initView()
        initWebView()
        
        checkVersion()
    }
    
    func initView() {
        let back = UIBarButtonItem()
        back.title = "主页"
        navigationItem.backBarButtonItem = back
        
        title = Config.Title
        navigationController?.navigationBar.tintColor = Config.TitleColor
        navigationController?.navigationBar.barTintColor = Config.BarColor
        
        let titleLabel = UILabel(frame: CGRectMake(0, 0 , 100, 44))
        titleLabel.text = Config.Title
        titleLabel.textColor = Config.TitleColor
        titleLabel.font = UIFont(name: titleLabel.font!.fontName, size: 20)
        titleLabel.textAlignment = .Center
        navigationItem.titleView = titleLabel
    }
    
    func checkVersion() {
        AlamofireUtil.doRequest("http://888.jiubaiwang.cn/iosversion.php?", parameters: ["a": "a"]) { (result, response) in
            if result && response != "" {
                let responseDic = UtilBox.convertStringToDictionary(response)
                
                if responseDic == nil {
                self.noticeError("发送失败", autoClear: true, autoClearTime: 2)
                    return
                }
                
                let json = JSON(responseDic!)
                
                let version = json["version"].stringValue.stringByReplacingOccurrencesOfString("lanrenjizhangV", withString: "")
                
                let currentVersion = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
                
                if Int(currentVersion) < Int(version) {
                    let alertController = UIAlertController(title: json["info"].stringValue, message: nil, preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "更新", style: .Default, handler: { (UIAlertAction) in
                        UIApplication.sharedApplication().openURL(NSURL(string: "http://cn.bing.com")!)
                    })
                    let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func setupLeftBarButton() {
        if leftButton == nil {
            leftButton = UIButton(type: .Custom)
            leftButton?.tintColor = Config.TitleColor
            leftButton?.backgroundColor = UIColor.clearColor()
            leftButton?.frame = CGRect(x: 0, y: 0, width: 65, height: 44)
            leftButton?.addTarget(self, action: #selector(ViewController.left), forControlEvents: .TouchUpInside)
            
            leftButton?.setImage(UIImage(named: "back"), forState: .Normal)
            leftButton?.imageView?.contentMode = .ScaleAspectFit
            leftButton!.imageEdgeInsets = UIEdgeInsets(top: 10, left: 2, bottom: 10, right: 2)
            
            leftButton?.setTitle("返回", forState: .Normal)
            leftButton?.titleLabel?.font = UIFont(name: leftButton!.titleLabel!.font!.fontName, size: 17)
            
            leftBarButton = UIBarButtonItem(customView: leftButton!)
            leftBarButton?.style = .Plain
        }
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        spacer.width = -15
        
        navigationItem.leftBarButtonItems = [spacer, leftBarButton!]
    }
    
    func initWebView() {
        progressProxy = WebViewProgress()
        webView.delegate = progressProxy
        progressProxy.webViewProxyDelegate = self
        progressProxy.progressDelegate = self
        
        let progressBarHeight: CGFloat = 2.0
        let navigationBarBounds = self.navigationController!.navigationBar.bounds
        let barFrame = CGRect(x: 0, y: navigationBarBounds.size.height - progressBarHeight, width: navigationBarBounds.width, height: progressBarHeight)
        progressView = WebViewProgressView(frame: barFrame)
        progressView.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
        progressView.progressBarView.backgroundColor = UIColor.greenColor()
        
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.addSubview(progressView)
    }
    
    func webViewProgress(webViewProgress: WebViewProgress, updateProgress progress: Float) {
        progressView.setProgress(progress, animated: true)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        
        Config.Cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies
        
        if Config.ShouldLoadUrl != "" {
            let url = NSURL(string: Config.ShouldLoadUrl)!
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
            
            Config.ShouldLoadUrl = ""
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let requestString = request.URL!.absoluteString!.stringByRemovingPercentEncoding

        if requestString != nil {
            
            let commands = requestString!.componentsSeparatedByString(":::")
            
            print(requestString!)
            
            if commands.count > 1 && commands[0].hasSuffix("app") {
                for index in 1...commands.count-1 {
                    execute(commands[index])
                }
            }
        }
        
        return true
    }
    
    func execute(command: String!) {
        let components = command.componentsSeparatedByString("::")
        
        if components.count > 1 {
            let cmd = components[0]
            
            switch cmd {
            case "title":
                let titleLabel = UILabel(frame: CGRectMake(0, 0 , 100, 44))
                titleLabel.text = components[1]
                titleLabel.textColor = Config.TitleColor
                titleLabel.font = UIFont(name: titleLabel.font!.fontName, size: 20)
                titleLabel.textAlignment = .Center
                titleLabel.backgroundColor = UIColor.clearColor()
                navigationItem.titleView = titleLabel
                title = components[1]
                Config.Title = title!
                
            case "titleColor":
                Config.TitleColor = UIColor(
                    red: (NSNumberFormatter().numberFromString(components[1])) as! CGFloat / 255,
                    green: (NSNumberFormatter().numberFromString(components[2])) as! CGFloat / 255,
                    blue: (NSNumberFormatter().numberFromString(components[3])) as! CGFloat / 255,
                    alpha: (NSNumberFormatter().numberFromString(components[4])) as! CGFloat)
                
                let dict: NSDictionary = [
                    NSForegroundColorAttributeName: UIColor(
                    red: (NSNumberFormatter().numberFromString(components[1])) as! CGFloat / 255,
                    green: (NSNumberFormatter().numberFromString(components[2])) as! CGFloat / 255,
                    blue: (NSNumberFormatter().numberFromString(components[3])) as! CGFloat / 255,
                    alpha: (NSNumberFormatter().numberFromString(components[4])) as! CGFloat)
                ]
                
                self.navigationController?.navigationBar.titleTextAttributes = dict as? [String : AnyObject]
                self.navigationController?.navigationBar.tintColor = Config.TitleColor
                
                UIApplication.sharedApplication().statusBarStyle = .LightContent
                
            case "barColor":
                let alpha = (NSNumberFormatter().numberFromString(components[4])) as! CGFloat
                Config.BarColor = UIColor(
                    red: (NSNumberFormatter().numberFromString(components[1])) as! CGFloat / 255,
                    green: (NSNumberFormatter().numberFromString(components[2])) as! CGFloat / 255,
                    blue: (NSNumberFormatter().numberFromString(components[3])) as! CGFloat / 255,
                    alpha: alpha)
                
                navigationController?.navigationBar.barTintColor = Config.BarColor
                navigationController?.navigationBar.alpha = alpha
                navigationController?.navigationBar.translucent = alpha != 1 ? true : false
                
            case "rightBtnUrl":
                if components[1] == "null" {
                    rightButton = nil
                    rightBarButton = nil
                    navigationItem.rightBarButtonItem = nil
                    rightPopover = nil
                } else {
                    if rightButton == nil {
                        rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
                        rightButton!.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
                        rightButton?.addTarget(self, action: #selector(ViewController.right), forControlEvents: .TouchUpInside)
                    }
                    rightButton?.setImage(UIImage(named: "btn"), forState: .Normal)
                    rightButton?.imageView?.contentMode = .ScaleAspectFit
                
                    rightBarButton = UIBarButtonItem(customView: rightButton!)
                    rightBarButton?.style = .Plain
                    rightBarButton!.target = self
                    rightBarButton!.action = #selector(ViewController.right)
                    
                    let spacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
                    spacer.width = -20
                
                    self.navigationItem.rightBarButtonItems = [rightBarButton!, spacer]
                }
                
            case "rightBtnStyle":
                let count = (NSNumberFormatter().numberFromString(components[1])) as! Int
                
                var items: [PopoverItem] = []
                
                for i in 1...count {
                    
                    let title = components[i * 3 - 1]
                    var image = UIImage(named: components[i * 3])
                    let action = components[i * 3 + 1]
                    
                    if image == nil {
                        image = UIImage()
                    }
                    
                    let item = PopoverItem(title: title, titleColor: UIColor.whiteColor(), image: image, handler: { (PopoverItem) in
                        self.webView.stringByEvaluatingJavaScriptFromString(action+"()")
                    })
                    items.append(item)
                }
                
                self.rightPopover = PopoverController(items: items, fromView: self.rightTopButton, direction: .Down, style: .WithImage)
                self.rightPopover?.coverColor = Config.BarColor
                self.rightPopover?.textColor = Config.TitleColor
                
            case "showLeftBtn":
                if components[1] == "true" {
                    setupLeftBarButton()
                } else {
                    navigationItem.leftBarButtonItems = [UIBarButtonItem()]
                }
                
            case "refresh":
                refresh()
                
            case "qrScan":
                qrScan()
                
            case "share":
                share(title!, text: components[1], url: components[2])
                
            case "feedback":
                feedback()
                
            default:
                break
            }
        }
    }
    
    func left() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    func right() {
        if popoverDidAppear {
            dismissPopover()
        } else {
            popover(rightPopover!)
        }
    }
    
    func qrScan() {
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner
        style.photoframeLineW = 2
        style.photoframeAngleW = 18
        style.photoframeAngleH = 18
        style.isNeedShowRetangle = false
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove
        style.colorAngle = UIColor(red: 0.0/255, green: 200.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_Scan_weixin_Line")

        let vc = QRScanViewController()
        vc.scanStyle = style
        vc.title = "二维码"
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didScan(result: String?) {
        if result != nil {
            if result!.containsString("http") {
                let url = NSURL(string: result!)!
                let request = NSURLRequest(URL: url)
                webView.loadRequest(request)
            } else {
                UtilBox.alert(self, message: result!)
            }
        }
    }
    
    func refresh() {
        let url = NSURL(string: "http://888.jiubaiwang.cn")!
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }
    
    func share(title: String, text: String, url: String) {
        UMSocialData.defaultData().extConfig.title = title
        UMSocialData.defaultData().extConfig.qqData.url = url
        UMSocialSnsService.presentSnsIconSheetView(self, appKey: "5793363ee0f55a3159000168", shareText: text, shareImage: UIImage(), shareToSnsNames: [UMShareToQQ, UMShareToQzone,
            UMShareToWechatTimeline, UMShareToWechatSession], delegate: self)
    }
    
    func feedback() {
        performSegueWithIdentifier("feedback", sender: self)
    }
}
