//
//  AlertController.swift
//  YouCat
//
//  Created by ting on 2018/11/29.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit

protocol YCAlertProtocol {
    func showTempAlert(_ alertTile: String?, alertMessage: String?, view: UIViewController, completionBlock: (() -> Void)?)
    func showSelectedAlert(_ alertTile:String?, alertMessage:String?, okAlertLabel:String, cancelAlertLabel:String, view: UIViewController, compelecationBlock: @escaping (Bool) -> Void)
    func showTextInputAlert(_ alertTile:String?, alertMessage:String?, okAlertLabel:String, cancelAlertLabel:String, view: UIViewController, compelecationBlock: @escaping (Bool, String) -> Void)
    func showSingleAlert(_ alertTile:String?, alertMessage:String?, view: UIViewController, compelecationBlock: (() -> Void)?)
    func showSheetAlert(_ alertTile:String?, alertMessage:String?, okAlertArray:Array<[String: Any]>, cancelAlertLabel:String, view: UIViewController, compelecationBlock: @escaping (_ index:Int) -> Void)
}

extension YCAlertProtocol {
    
    func showTempAlert(_ alertTile: String?, alertMessage: String?, view: UIViewController, completionBlock: (() -> Void)?){
        let alert = UIAlertController(title: alertTile, message: alertMessage, preferredStyle: .alert)
        view.present(alert, animated: true, completion:nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            alert.dismiss(animated: true, completion: {
                if let complete = completionBlock {
                    complete()
                }
            })
        }
    }
    
    func showSelectedAlert(_ alertTile:String?, alertMessage:String?, okAlertLabel:String, cancelAlertLabel:String, view: UIViewController, compelecationBlock: @escaping (Bool) -> Void){
        let alert = UIAlertController(title: alertTile, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okAlertLabel, style: .destructive, handler: { (_) -> Void in
            compelecationBlock(true)
        }))
        alert.addAction(UIAlertAction(title: cancelAlertLabel, style: UIAlertActionStyle.cancel, handler: { (_) -> Void in
            compelecationBlock(false)
        }))
        view.present(alert, animated: true, completion: nil)
    }
    
    func showTextInputAlert(_ alertTile:String?, alertMessage:String?, okAlertLabel:String, cancelAlertLabel:String, view: UIViewController, compelecationBlock: @escaping (Bool, String) -> Void){
        let alert = UIAlertController(title: alertTile, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okAlertLabel, style: .default, handler: { (_) -> Void in
            let firstTextField = alert.textFields![0] as UITextField
            compelecationBlock(true, firstTextField.text!)
        }))
        alert.addAction(UIAlertAction(title: cancelAlertLabel, style: UIAlertActionStyle.cancel, handler: { (_) -> Void in
            compelecationBlock(false, "")
        }))
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
        }
        view.present(alert, animated: true, completion: nil)
    }
    
    func showSingleAlert(_ alertTile:String?, alertMessage:String?, view: UIViewController, compelecationBlock: (() -> Void)?){
        let alert = UIAlertController(title: alertTile, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: YCLanguageHelper.getString(key: "OKLabel"), style: .default, handler: { (_) -> Void in
            if compelecationBlock != nil {
                compelecationBlock!()
            }
        }))
        view.present(alert, animated: true, completion: nil)
    }
    
    func showSheetAlert(_ alertTile:String?, alertMessage:String?, okAlertArray:Array<[String: Any]>, cancelAlertLabel:String, view: UIViewController, compelecationBlock: @escaping (_ index:Int) -> Void){
        let alert = UIAlertController(title: alertTile, message: alertMessage, preferredStyle: .actionSheet)
        for i in 0..<okAlertArray.count {
            var alertIndex = i
            let alertDic = okAlertArray[i]
            var alertStyle:UIAlertActionStyle = .default
            let title = alertDic["title"] as? String
            if let style = alertDic["style"] as? UIAlertActionStyle {
                alertStyle = style
            }
            if let index = alertDic["tag"] as? Int {
                alertIndex = index
            }
            let alertAction = UIAlertAction(title: title, style: alertStyle, handler: { (_) -> Void in
                compelecationBlock(alertIndex)
            })
            if let textColor = alertDic["textColor"] {
                alertAction.setValue(textColor, forKey: "titleTextColor")
            }
            alert.addAction(alertAction)
        }
        let cancel = UIAlertAction(title: cancelAlertLabel, style: UIAlertActionStyle.cancel, handler: { (_) -> Void in
            compelecationBlock(-1)
        })
        alert.addAction(cancel)
        if alert.popoverPresentationController != nil {
            alert.popoverPresentationController!.sourceView = view.view
            alert.popoverPresentationController!.sourceRect = CGRect(x: 100, y: 50, width: 100, height: 400)
        }
        view.present(alert, animated: true, completion: nil)
    }
}
