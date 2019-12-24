//
//  ViewController.swift
//  YouCat
//
//  Created by Emiaostein on 21/02/2018.
//  Copyright © 2018 Curios. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
//    var root: YCRootTabbarController!
    var rootNav: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
    }
    
    func setup() {
        
        let root = YCRootTabbarController()
        self.rootNav = UINavigationController(rootViewController: root)
        self.rootNav?.isNavigationBarHidden = true
        self.view.addSubview(self.rootNav!.view)
        self.addChild(self.rootNav!)

        NotificationCenter.default.addObserver(self, selector: #selector(self.rootPushUserViewNotification(_:)), name: NSNotification.Name("RootPushUserView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.rootPushPublishViewNotification(_:)), name: NSNotification.Name("RootPushPublishView"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.unLinkUserViewNotification), name: NSNotification.Name("UniversalLinkUserView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.unLinkPublishViewNotification), name: NSNotification.Name("UniversalLinkPublishView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.unLinkThemeViewNotification), name: NSNotification.Name("UniversalLinkThemeView"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func unLinkUserViewNotification(_ notify: Notification){
        if let user = notify.object as? YCRelationUserModel {
            let userProfile = YCUserViewController.getInstance() as! YCUserViewController
            userProfile.userModel = user
            userProfile.isPresent = true
            if let current = UIViewController.currentViewController() {
                if let a = current as? YCViewController{
                    a.isGoto = true
                }
                let navigationController = UINavigationController(rootViewController: userProfile)
                navigationController.isNavigationBarHidden = true
                navigationController.modalPresentationStyle = .overFullScreen
                current.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    @objc func unLinkPublishViewNotification(_ notify: Notification){
        if let publish = notify.object as? YCPublishModel {
            let publishDetail = YCPublishDetailViewController.getInstance() as! YCPublishDetailViewController
            publishDetail.contentType = .HOME
            publishDetail.contentModel = publish
            publishDetail.contentIndex = 0
            publishDetail.contents = [publish]
            publishDetail.contentID = publish.publishID
            publishDetail.isPresent = true
            if let current = UIViewController.currentViewController() {
                if let a = current as? YCViewController{
                    a.isGoto = true
                }
                let navigationController = UINavigationController(rootViewController: publishDetail)
                navigationController.isNavigationBarHidden = true
                navigationController.modalPresentationStyle = .overFullScreen
                current.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    @objc func unLinkThemeViewNotification(_ notify: Notification){
        if let theme = notify.object as? YCThemeModel {
            let themeDetail = YCThemeDetailViewController.getInstance() as! YCThemeDetailViewController
            themeDetail.themeModel = theme
            themeDetail.isPresent = true
            if let current = UIViewController.currentViewController() {
                if let a = current as? YCViewController{
                    a.isGoto = true
                }
                let navigationController = UINavigationController(rootViewController: themeDetail)
                navigationController.isNavigationBarHidden = true
                navigationController.modalPresentationStyle = .overFullScreen
                current.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    @objc func rootPushPublishViewNotification(_ notify: Notification){
        if let publishDetail = notify.object as? YCPublishDetailViewController {
            if let nav = self.rootNav {
                if let curren = UIViewController.currentViewController() as? YCViewController {
                    curren.isGoto = true
                }
                nav.pushViewController(publishDetail, animated: true)
            }
        }
    }
    
    @objc func rootPushUserViewNotification(_ notify: Notification){
        if let user = notify.object as? YCRelationUserModel {
            let userProfile = YCUserViewController.getInstance() as! YCUserViewController
            userProfile.userModel = user
            if let nav = self.rootNav {
                if let curren = UIViewController.currentViewController() as? YCViewController {
                    curren.isGoto = true
                }
                nav.pushViewController(userProfile, animated: true)
            }
        }else if let user = notify.object as? YCLoginUserModel {
            let userProfile = YCUserViewController.getInstance() as! YCUserViewController
            userProfile.userModel = user
            userProfile.loginUserType = .LoginUser
            if let nav = self.rootNav {
                if let current = UIViewController.currentViewController() {
                    if let a = current as? YCViewController {
                        a.isGoto = true
                    }
                }
                nav.pushViewController(userProfile, animated: true)
            }
        }
    }
}

