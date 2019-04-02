//
//  ViewController.swift
//  YouCat
//
//  Created by Emiaostein on 21/02/2018.
//  Copyright © 2018 Curios. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var root: YCRootTabbarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
    }
    
    func setup() {
        
        self.root = YCRootTabbarController()
        let navigationController = UINavigationController(rootViewController: self.root)
        navigationController.isNavigationBarHidden = true
        self.view.addSubview(navigationController.view)
        self.addChildViewController(navigationController)

        NotificationCenter.default.addObserver(self, selector: #selector(self.rootPushUserViewNotification(_:)), name: NSNotification.Name("RootPushUserView"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func rootPushUserViewNotification(_ notify: Notification){
        if let user = notify.object as? YCRelationUserModel {
            let userProfile = YCUserViewController.getInstance()
            userProfile.userModel = user
            if let nav = self.root.navigationController {
                nav.pushViewController(userProfile, animated: true)
            }
        }else if let user = notify.object as? YCLoginUserModel {
            let userProfile = YCUserViewController.getInstance()
            userProfile.userModel = user
            userProfile.loginUserType = .LoginUser
            if let nav = self.root.navigationController {
                nav.pushViewController(userProfile, animated: true)
            }
        }
    }
}

