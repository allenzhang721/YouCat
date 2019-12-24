//
//  ThemeDomain.swift
//  YouCat
//
//  Created by ting on 2018/9/18.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON

class YCThemeDomain: YCBaseDomain {
    
    func addTheme(name: String, description: String, themeType: Int, coverImage: YCImageModel?, coverVideo: YCVideoModel?, completionBlock: @escaping (YCDomainModel?) -> Void) {
    
        YCAddThemeRequest(name: name, description: description, themeType: themeType, coverImage: coverImage, coverVideo: coverVideo).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func updateTheme(themeModel: YCThemeModel, completionBlock: @escaping (YCDomainModel?) -> Void){
        
        let themeID = themeModel.themeID
        let name = themeModel.name
        let description = themeModel.description
        let themeType = themeModel.themeType
        let coverImage = themeModel.coverImage
        let coverVideo = themeModel.coverVideo
        
        YCUpdateThemeRequest(themeID: themeID, name: name, description: description, themeType: themeType, coverImage: coverImage, coverVideo: coverVideo).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func removeTheme(themeID: String, completionBlock: @escaping (YCDomainResult?) -> Void) {
        YCRemoveThemeRequest(themeID: themeID).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func themeDetail(themeID: String, completionBlock: @escaping (YCDomainModel?) -> Void) {
        YCThemeDetailRequest(themeID: themeID).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeDetailModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func themeDetailByUUID(uuid: String, completionBlock: @escaping (YCDomainModel?) -> Void) {
        YCThemeDetailByUUIDRequest(uuid: uuid).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeDetailModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func themeList(start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCThemeListRequest(start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeList(response: response, completionBlock: completionBlock)
        }
    }
    
    func topThemeList(start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCTopThemeListRequest(start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeList(response: response, completionBlock: completionBlock)
        }
    }
    
    func userFollowThemeList(userID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCFollowThemeListRequest(userID: userID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeList(response: response, completionBlock: completionBlock)
        }
    }
    
    func userBlockThemeList(userID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void) {
        YCBlockThemeListRequest(userID: userID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeList(response: response, completionBlock: completionBlock)
        }
    }
    
    func publishThemeList(publishID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void) {
        YCPublishThemeListRequest(publishID: publishID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeList(response: response, completionBlock: completionBlock)
        }
    }
    
    func searchThemeList(keyWord: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void) {
        YCSearchThemeListRequest(keyWord: keyWord, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeList(response: response, completionBlock: completionBlock)
        }
    }
    
    func addPublishToTheme(publishID: String, themeID: String, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCAddPublishToThemeRequest(publishID: publishID, themeID: themeID).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func removeThemePublish(publishID: String, themeID: String, completionBlock: @escaping (YCDomainResult?) -> Void) {
        YCRemoveThemePublishRequest(publishID: publishID, themeID: themeID).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func followTheme(themeID: String, completionBlock: @escaping (YCDomainResult?) -> Void) {
        YCFollowThemeRequest(themeID: themeID).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func unFollowTheme(themeID: String, completionBlock: @escaping (YCDomainResult?) -> Void) {
        YCUnFollowThemeRequest(themeID: themeID).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func blockTheme(themeID: String, completionBlock: @escaping (YCDomainResult?) -> Void) {
        YCBlockThemeRequest(themeID: themeID).startWithComplete { (response: YCURLRequestResult) in
            self.backThemeResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func backThemeResult(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainResult?) -> Void) {
        switch response{
        case .success(let v):
            let json:JSON = JSON(v)
            if self.checkResult(json){
                completionBlock(YCDomainResult(result: true, message: ""))
            }else {
                let errorMessage = self.codeMessage(json)
                completionBlock(YCDomainResult(result: false, message: errorMessage))
            }
            break;
        case .failure:
            let errorMessage = CodeMessage(code: "000")
            completionBlock(YCDomainResult(result: false, message: errorMessage))
            break
        }
    }
    
    func backThemeModel(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainModel?) -> Void) {
        switch response{
        case .success(let v):
            let json:JSON = JSON(v)
            if self.checkResult(json){
                let modelJSON = json[Parameter(.model)]
                completionBlock(YCDomainModel(result: true, baseModel: YCThemeModel(modelJSON)))
            }else {
                let errorMessage = self.codeMessage(json)
                completionBlock(YCDomainModel(result: false, message: errorMessage))
            }
            break;
        case .failure:
            let errorMessage = CodeMessage(code: "000")
            completionBlock(YCDomainModel(result: false, message: errorMessage))
            break
        }
    }
    
    func backThemeDetailModel(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainModel?) -> Void) {
        switch response{
        case .success(let v):
            let json:JSON = JSON(v)
            if self.checkResult(json){
                let modelJSON = json[Parameter(.model)]
                completionBlock(YCDomainModel(result: true, baseModel: YCThemeDetailModel(modelJSON)))
            }else {
                let errorMessage = self.codeMessage(json)
                completionBlock(YCDomainModel(result: false, message: errorMessage))
            }
            break;
        case .failure:
            let errorMessage = CodeMessage(code: "000")
            completionBlock(YCDomainModel(result: false, message: errorMessage))
            break
        }
    }
    
    func backThemeList(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainListModel?) -> Void) {
        switch response{
        case .success(let v):
            let json:JSON = JSON(v)
            if self.checkResult(json){
                let themeList = self.themeListResult(json)
                completionBlock(YCDomainListModel(result: true, modelArray: themeList.1, totoal: themeList.0))
            }else {
                let errorMessage = self.codeMessage(json)
                completionBlock(YCDomainListModel(result: false, message: errorMessage))
            }
        case .failure:
            let errorMessage = CodeMessage(code: "000")
            completionBlock(YCDomainListModel(result: false, message: errorMessage))
        }
    }
    
    func themeListResult(_ json:JSON) -> (Int, [YCThemeModel]){
        let listArray = json[Parameter(.list)].array;
        let total = json[Parameter(.total)].int ?? 0;
        var themeArray: [YCThemeModel] = [];
        if listArray != nil{
            let count = listArray!.count
            for i in 0..<count {
                let listJson = listArray![i];
                let theme = YCThemeModel(listJson)
                themeArray.append(theme);
            }
        }
        return (total, themeArray)
    }
}
