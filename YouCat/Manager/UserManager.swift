//
//  UserManager.swift
//  YouCat
//
//  Created by ting on 2018/9/21.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON
import Locksmith

class YCUserManager {
    
    static fileprivate(set) var loginUser: YCLoginUserModel?
    
    static var isLogin: Bool {
        return YCUserManager.loginUser != nil
    }
    
    class func save(_ loginUser: YCLoginUserModel) -> Bool {
        do {
            var isHave = false
            if let _ = Locksmith.loadDataForUserAccount(userAccount: LocalManager.loginAccount, inService: LocalManager.service) {
                isHave = true
            }else {
                isHave = false
            }
            if !isHave {
                try Locksmith.saveData(data: loginUser.getData(), forUserAccount: LocalManager.loginAccount, inService: LocalManager.service)
                YCUserManager.loginUser = loginUser
                return true
            }else {
                try Locksmith.updateData(data: loginUser.getData(), forUserAccount: LocalManager.loginAccount, inService: LocalManager.service)
                YCUserManager.loginUser = loginUser
                return true
            }
        } catch let error {
            
            debugPrint("Error = \(error)")
            return false
        }
    }
    
    class func load() -> Bool {
        guard let dic = Locksmith.loadDataForUserAccount(userAccount: LocalManager.loginAccount, inService: LocalManager.service) else {
            return false
        }
        let json = JSON(dic)
        let loginUser = YCLoginUserModel(json)
        YCUserManager.loginUser = loginUser
        return true
    }
    
    class func logout() -> Bool {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: LocalManager.loginAccount, inService: LocalManager.service)
            loginUser = nil
            return true
        } catch {
            return false
        }
    }
}
