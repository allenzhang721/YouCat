//
//  RootTabbarController.swift
//  YouCat
//
//  Created by ting on 2018/9/25.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit

class YCRootTabbarController: UITabBarController {

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.creatTabBar()
        self.delegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //创建tabBar
    func creatTabBar()  {
        
        let feed  = YCFavoriteViewController.getInstance()
        let feedNav = UINavigationController(rootViewController:feed)
        
        let feedTabBarItem = UITabBarItem(title: YCLanguageHelper.getString(key: "HomeLabel"), image: UIImage(named: "tabbar-home"), tag: 1)
        feedTabBarItem.selectedImage = UIImage(named: "tabbar-home-selected")
        
        feedNav.tabBarItem = feedTabBarItem;
        
        let category  = YCThemeViewController.getInstance()
        let categoryNav = UINavigationController(rootViewController:category)
        let categoryTabBarItem = UITabBarItem(title: YCLanguageHelper.getString(key: "ThemeLabel"), image: UIImage(named: "tabbar-catagory"), tag: 2)
        categoryTabBarItem.selectedImage = UIImage(named: "tabbar-catagory-selected")
        categoryNav.tabBarItem = categoryTabBarItem;
    
        self.viewControllers = [feedNav,categoryNav]
        self.tabBar.tintColor = YCStyleColor.red
        self.navigationController?.isNavigationBarHidden = true
    }
}

extension YCRootTabbarController: UITabBarControllerDelegate{
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let cl = tabBarController.selectedViewController, cl.isEqual(viewController){
            let index = tabBarController.selectedIndex
            if index == 0 {
                NotificationCenter.default.post(name: NSNotification.Name("reFreshHome"), object: nil)
            }else if index == 1 {
                NotificationCenter.default.post(name: NSNotification.Name("reFreshCategory"), object: nil)
            }
            return false;
        }
        return true
    }
}

extension UINavigationController{
    
    override open var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    override open var childForStatusBarHidden: UIViewController?{
        return self.topViewController
    }
}


class YCNavigationController: UINavigationController{
    
    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    override var childForStatusBarHidden: UIViewController?{
        return self.topViewController
    }
}

class YCViewController: UIViewController {

    var isGoto: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.delegate = self
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isGoto = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !self.isGoto {
            self.resetViewController()
        }
        if let delegate = self.navigationController?.interactivePopGestureRecognizer?.delegate as? YCViewController, delegate == self {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
        if let delegate = self.navigationController?.delegate as? YCViewController, delegate == self {
            self.navigationController?.delegate = nil
        }
    }
    
    func initViewController(){
        
    }
    
    func resetViewController() {
    }
}

extension YCViewController:UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
}
