//
//  DeviceManager.swift
//  YouCat
//
//  Created by ting on 2018/9/21.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import Locksmith
import SwiftyJSON

class YCDeviceManager {
    
    static fileprivate(set) var UUID: String?
    
    class func setUUID() {
        let uuid = loadUUID();
        if uuid ==  "" {
            if let newID = UIDevice.current.identifierForVendor?.uuidString {
                if saveUUID(UUID: newID) {
                    YCDeviceManager.UUID = newID
                }
            }
        }else {
            YCDeviceManager.UUID = uuid
        }
    }
    
    class func loadUUID() -> String {
        guard let dic = Locksmith.loadDataForUserAccount(userAccount: LocalManager.uuid, inService: LocalManager.service) else {
            return ""
        }
        let json = JSON(dic)
        let uuid = json["UUID"].string ?? "";
        return uuid
    }
    
    class func saveUUID(UUID: String) -> Bool {
        do {
            try Locksmith.saveData(data: ["UUID": UUID], forUserAccount: LocalManager.uuid, inService: LocalManager.service)
            return true
        } catch let error {
            debugPrint("Error = \(error)")
            return false
        }
    }
    
}
