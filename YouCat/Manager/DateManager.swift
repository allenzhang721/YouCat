//
//  DateManager.swift
//  YouCat
//
//  Created by ting on 2018/10/19.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON
import Locksmith

class YCDateManager {
    
    class func loadPublishListDate(account: String) -> [YCPublishModel] {
        guard let dic = Locksmith.loadDataForUserAccount(userAccount: account, inService: LocalManager.service) else {
            return []
        }
        let json = JSON(dic)
        if let modelJSONArray = json["DateArray"].array {
            var publishList: [YCPublishModel] = []
            for modelJSON in modelJSONArray {
                let publish = YCPublishModel.init(modelJSON)
                publishList.append(publish)
            }
            return publishList
        }else {
            return []
        }
    }
    
    class func loadThemeListDate(account: String) -> [YCThemeModel] {
        guard let dic = Locksmith.loadDataForUserAccount(userAccount: account, inService: LocalManager.service) else {
            return []
        }
        let json = JSON(dic)
        if let modelJSONArray = json["DateArray"].array {
            var themeList: [YCThemeModel] = []
            for modelJSON in modelJSONArray {
                let model = YCThemeModel.init(modelJSON)
                themeList.append(model)
            }
            return themeList
        }else {
            return []
        }
    }
    
    class func loadModelListDate(account: String) -> [Any] {
        guard let dic = Locksmith.loadDataForUserAccount(userAccount: account, inService: LocalManager.service) else {
            return []
        }
        let json = JSON(dic)
        if let modelJSONArray = json["DateArray"].array {
            var modelList: [Any] = []
            for modelJSON in modelJSONArray {
                modelList.append(modelJSON)
            }
            return modelList
        }else {
            do {
                try Locksmith.deleteDataForUserAccount(userAccount: account, inService: LocalManager.service)
            } catch {
                debugPrint("Delete Error = \(error)")
            }
            return []
        }
    }
    
    class func saveModelListDate(modelList: [YCBaseModel], account: String) -> Bool {
        do {
            var modelDateArray: [[String : Any]] = []
            for model in modelList {
                let modelDate = model.getData()
                modelDateArray.append(modelDate)
            }
            let modelList = loadModelListDate(account: account)
            if modelList.count == 0 {
                try Locksmith.saveData(data: ["DateArray": modelDateArray], forUserAccount: account, inService: LocalManager.service)
            }else {
                try Locksmith.updateData(data: ["DateArray": modelDateArray], forUserAccount: account, inService: LocalManager.service)
            }
            
            return true
        } catch let error {
            debugPrint("Error = \(error)")
            return false
        }
    }
}
