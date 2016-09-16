//
//  AppDelegate.swift
//  LazyAccounting
//
//  Created by 梁浩 on 16/7/21.
//  Copyright © 2016年 LeungHowell. All rights reserved.
//

import UIKit
import HcdGuideView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // 初始化UserAgent
        initUserAgent()
        
        // 初始化数据统计服务
        initUMAnalytics()
        
        // 初始化分享
        initUMShare()
        
        // 初始化推送
        initUMMessage(launchOptions)
        
        // 初始化引导页
        initGuidePage()
        
        return true
    }
    
    func initUserAgent() {
        let webView = UIWebView()
        
        let userAgent = webView.stringByEvaluatingJavaScriptFromString("navigator.userAgent")
        
        let ua = NSString(format: "%@\\%@", userAgent!, "JiubaiwangLanren")
        
        NSUserDefaults.standardUserDefaults().registerDefaults(["UserAgent": ua, "User-Agent": ua])
    }
    
    func initUMAnalytics() {
        MobClick.setLogEnabled(true)
        let config = UMAnalyticsConfig.init()
        config.appKey = "5793363ee0f55a3159000168"
        config.bCrashReportEnabled = true
        config.ePolicy = BATCH
        config.channelId = "Developer"
        MobClick.startWithConfigure(config)
    }
    
    func initUMShare() {
        UMSocialData.setAppKey("5793363ee0f55a3159000168")
        
        UMSocialWechatHandler.setWXAppId("wx698954241d0efc96", appSecret: "022a1078d40881525588b4bf39867072", url: "http://888.jiubaiwang.cn")
        UMSocialQQHandler.setQQWithAppId("appid", appKey: "appKey", url: "url")
    }
    
    func initGuidePage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier("MainVC")
        window?.makeKeyAndVisible()
    
        let images: [AnyObject] = [UIImage(named: "guide1")!, UIImage(named: "guide2")!, UIImage(named: "guide3")!]
    
        HcdGuideViewManager.sharedInstance().showGuideViewWithImages(
            images,
            andButtonTitle: "立即体验",
            andButtonTitleColor: UIColor.whiteColor(),
            andButtonBGColor: UIColor.orangeColor(),
            andButtonBorderColor: UIColor.orangeColor())
    }
    
    func initUMMessage(launchOptions: [NSObject: AnyObject]?) {
        UMessage.setLogEnabled(true)
        UMessage.startWithAppkey("5793363ee0f55a3159000168", launchOptions: launchOptions)
        
        let openAction = UIMutableUserNotificationAction()
        openAction.identifier = "openAction"
        openAction.title = "进入"
        openAction.activationMode = .Foreground
        openAction.destructive = true
        
        let closeAction = UIMutableUserNotificationAction()
        closeAction.identifier = "closeAction"
        closeAction.title = "关闭"
        closeAction.activationMode = .Background
        closeAction.destructive = true
        
        let category = UIMutableUserNotificationCategory()
        category.setActions([openAction, closeAction], forContext: .Default)
        
        let categorys = NSSet(object: category)
        
        UMessage.registerForRemoteNotifications(categorys as? Set<UIUserNotificationCategory>)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        if identifier == "openAction" {
            if let url = userInfo["url"] {
                Config.ShouldLoadUrl = url as! String
            }
        } else if identifier == "closeAction" {
            
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        UMessage.didReceiveRemoteNotification(userInfo)
        print(userInfo)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

