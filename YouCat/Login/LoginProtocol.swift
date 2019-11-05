//
//  LoginProtocol.swift
//  YouCat
//
//  Created by ting on 2018/11/23.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
import Kingfisher


protocol YCLoginProtocol {
    func showLoginView(view: UIViewController, noNeedShowBlock: (()->Void)?, completeBlock: (()->Void)?);
    func setLoginUserIcon(userIcon: UIImageView);
}

extension YCLoginProtocol {
    
    func showLoginView(view: UIViewController, noNeedShowBlock: (()->Void)?, completeBlock: (()->Void)?) {
        if YCUserManager.isLogin {
            if let block = noNeedShowBlock {
                block()
            }
        }else {
            let loginView = YCLoginViewController.getInstance()
            loginView.completeBlock = completeBlock
            let navigationController = UINavigationController(rootViewController: loginView)
            navigationController.isNavigationBarHidden = true
            navigationController.modalPresentationStyle = .overFullScreen
            navigationController.modalTransitionStyle = .crossDissolve
            view.present(navigationController, animated: true) {
                
            }
        }
    }
    
    func setLoginUserIcon(userIcon: UIImageView){
        if YCUserManager.isLogin {
            if let user = YCUserManager.loginUser, let icon = user.icon {
                let imgPath = icon.imagePath
                if imgPath != "", let imgURL = URL(string: imgPath){
                    userIcon.kf.setImage(with: ImageResource(downloadURL: imgURL), placeholder: UIImage(named: "default_icon"), options: nil, progressBlock: nil, completionHandler: nil)
                }else {
                    userIcon.image = UIImage(named: "default_icon")
                }
            }else {
                userIcon.image = UIImage(named: "default_icon")
            }
        }else {
            userIcon.image = UIImage(named: "default_icon")
        }
    }
    
}
