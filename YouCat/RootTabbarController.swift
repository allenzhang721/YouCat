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
        
        let feed  = YCHomeViewController.getInstance()
        let feedNav = UINavigationController(rootViewController:feed)
        
        let feedTabBarItem = UITabBarItem(title: YCLanguageHelper.getString(key: "HomeLabel"), image: UIImage(named: "tabbar-home"), tag: 1)
        feedNav.tabBarItem = feedTabBarItem;
        
        let category  = YCThemeViewController.getInstance()
        let categoryNav = UINavigationController(rootViewController:category)
        let categoryTabBarItem = UITabBarItem(title: YCLanguageHelper.getString(key: "ThemeLabel"), image: UIImage(named: "tabbar-catagory"), tag: 2)
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

