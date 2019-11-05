//
//  AppDelegate.swift
//  YouCat
//
//  Created by Emiaostein on 21/02/2018.
//  Copyright © 2018 Curios. All rights reserved.
//

import UIKit
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WeiboSDKDelegate, WXApiDelegate{

    var blockRotation: Bool = false
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIButton.initializeMethod()
        self.setup()
        
        WeiboSDK.registerApp(YCSocialConfigs.weibo.appKey)
        WeiboSDK.enableDebugMode(true)
        
        WXApi.registerApp(YCSocialConfigs.weChat.appID, universalLink: YCSocialConfigs.universalLink)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return WXApi.handleOpenUniversalLink(userActivity, delegate: self)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.scheme == "wx78fe2e04c0038988" {
            // 微信 的回调
            return  WXApi.handleOpen(url, delegate: self)
        }
        if url.scheme == "wb1479783390" {
            // 新浪微博 的回调
            return WeiboSDK.handleOpen(url, delegate: self)
        }
        
//        if let urlKey: String = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String {
//            if urlKey == "com.sina.weibo" {
//                // 新浪微博 的回调
//                return WeiboSDK.handleOpen(url, delegate: self)
//            }
//            if urlKey == "com.tencent.xin" {
//                // 微信 的回调
//
//            }
//        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if url.scheme == "wb1479783390" {
            // 新浪微博 的回调
            return WeiboSDK.handleOpen(url, delegate: self)
        }
        if url.scheme == "wx78fe2e04c0038988" {
            // 微信 的回调
            return WXApi.handleOpen(url, delegate: self)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if blockRotation {
            return .allButUpsideDown
        }
        return .portrait
    }
    
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        
    }
    
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        guard let res = response as? WBAuthorizeResponse else { return  }
        guard let uid = res.userID else { return  }
        guard let accessToken = res.accessToken else { return }
        
        let urlStr = "https://api.weibo.com/2/users/show.json?uid=\(uid)&access_token=\(accessToken)&source=\(YCSocialConfigs.weibo.appKey)"
        let url = URL(string: urlStr)
        do {
            let responseData = try Data.init(contentsOf: url!, options: Data.ReadingOptions.alwaysMapped)
            let dict = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, Any>
            guard let dic = dict else {
                //获取授权信息异常
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name("WeiboLoginComplete"), object: dic)
        } catch {
            //获取授权信息异常
        }
    }
    
    func onReq(_ req: BaseReq) {
        
    }
    
    func onResp(_ resp: BaseResp) {
        // 这里是使用异步的方式来获取的
        let sendRes: SendAuthResp? = resp as? SendAuthResp
        let queue = DispatchQueue(label: "wechatLoginQueue")
        queue.async {
            print("async: \(Thread.current)")
            if let sd = sendRes {
                if sd.errCode == 0 {
                    guard (sd.code) != nil else {
                        return
                    }
                    // 第一步: 获取到code, 根据code去请求accessToken
                    self.requestAccessToken((sd.code)!)
                } else {
                    DispatchQueue.main.async {
                        // 授权失败
                    }
                }
            } else {
                DispatchQueue.main.async {
                    // 异常
                }
            }
        }
    }
    
    private func requestAccessToken(_ code: String) {
        // 第二步: 请求accessToken
        let urlStr = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(YCSocialConfigs.weChat.appID)&secret=\(YCSocialConfigs.weChat.appSecret)&code=\(code)&grant_type=authorization_code"
        let url = URL(string: urlStr)
        do {
            let responseData = try Data.init(contentsOf: url!, options: Data.ReadingOptions.alwaysMapped)
            let dic = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, Any>
            guard dic != nil else {
                DispatchQueue.main.async {
                    // 获取授权信息异常
                }
                return
            }
            guard let accessToken = dic!["access_token"] else {
                DispatchQueue.main.async {
                    
                }
                return
            }
            guard let openID = dic!["openid"] else {
                DispatchQueue.main.async {
                    // 获取授权信息异常
                }
                return
            }
            let userURLStr = "https://api.weixin.qq.com/sns/userinfo?access_token=\(accessToken)&openid=\(openID)"
            guard let userURL = URL(string: userURLStr) else {
                DispatchQueue.main.async {
                    // 获取授权信息异常
                }
                return
            }
            let userResponse = try Data.init(contentsOf: userURL, options: Data.ReadingOptions.alwaysMapped)
            let userDic = try JSONSerialization.jsonObject(with: userResponse, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, Any>
            guard userDic != nil else {
                DispatchQueue.main.async {
                    // 获取授权信息异常
                }
                return
            }
            if let userDic = userDic {
                // 这个字典(dic)内包含了我们所请求回的相关用户信息
                DispatchQueue.main.async {
                    // 获取授权信息异常
                    NotificationCenter.default.post(name: NSNotification.Name("WeChatLoginComplete"), object: userDic)
                }
            }
        } catch {
            DispatchQueue.main.async {
                // 获取授权信息异常
            }
        }
    }

    func setup() {
        ImageCache.default.maxMemoryCost = UInt(512 * 1024 * 1024) // Allen: 256 MB
        // Override point for customization after application launch.
        #if DEBUG
            FilePath.baseURL = RequestHost.debug.description;
        #else
            FilePath.baseURL = RequestHost.production.description;
        #endif
        YCLanguageHelper.shareInstance.initUserLanguage()
        YCDeviceManager.setUUID();
        
        //YCUserManager.logout()
        let _ = YCUserManager.load()

        let screenW = UIApplication.shared.statusBarOrientation.isLandscape ? UIScreen.main.bounds.size.height : UIScreen.main.bounds.size.width
        let screenH = UIApplication.shared.statusBarOrientation.isLandscape ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.height
        YCScreen.bounds = CGRect(x: 0, y: 0, width: screenW, height: screenH)
        
        if let w = UIApplication.shared.delegate?.window {
            if #available(iOS 11.0, *) {
                if let safeArea = w?.safeAreaInsets {
                    var top = UIApplication.shared.statusBarOrientation.isLandscape ? safeArea.left : safeArea.top
                    if top == 0 {
                        top = 22
                    }
                    let bottom: CGFloat = top==44 ? 34 : 0
                    YCScreen.safeArea = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
                    YCScreen.fullScreenArea = UIEdgeInsets(top: 0, left: 0, bottom: bottom+49, right: 0)
                }
            } else {
                // Fallback on earlier versions
                YCScreen.safeArea = UIEdgeInsets(top: 22, left: 0, bottom: 0, right: 0)
                YCScreen.fullScreenArea = UIEdgeInsets(top: 0, left: 0, bottom: 49, right: 0)
            }
        }
    }
}

