//
//  BaseDomain.swift
//  YouCat
//
//  Created by ting on 2018/9/11.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol YCBaseDomain{
    func checkResult(_ json: JSON) -> Bool;
    func codeMessage(_ json: JSON) -> String;
}

extension YCBaseDomain{
    func checkResult(_ json: JSON) -> Bool{
        let reslut = json[Parameter(.status)].int
        if reslut == YCResultStatus.success {
            return true;
        }else{
            return false;
        }
    }
    
    func codeMessage(_ json: JSON) -> String{
        let code = json[Parameter(.code)].string
        return CodeMessage(code: code)
    }
}

struct YCDomainResult {
    
    let result:Bool
    var message:String?
    
    init(result:Bool, message:String?){
        self.result  = result
        self.message = message
    }
}

struct YCDomainModel {
    
    let result:Bool
    var baseModel:YCBaseModel?
    var message:String?
    
    init(result:Bool, baseModel:YCBaseModel?, message:String?){
        self.result      = result
        self.baseModel   = baseModel
        self.message     = message
    }
    
    init(result:Bool, message:String?){
        self.result  = result
        self.message = message
    }
    
    init(result:Bool, baseModel:YCBaseModel?){
        self.result    = result
        self.baseModel = baseModel
    }
}

struct YCDomainListModel {
    
    let result:Bool
    var modelArray:Array<YCBaseModel>?
    var message:String?
    let totoal: Int
    
    init(result:Bool, modelArray:Array<YCBaseModel>, message:String?, totoal: Int){
        self.result      = result
        self.modelArray  = modelArray
        self.message     = message
        self.totoal      = totoal
    }
    
    init(result:Bool, message:String?){
        self.result  = result
        self.message = message
        self.totoal  = 0
    }
    
    init(result:Bool, modelArray:Array<YCBaseModel>, totoal: Int){
        self.result     = result
        self.modelArray = modelArray
        self.totoal     = totoal
    }
}

class YCShareDomain: YCBaseDomain {
    
    func sharePublish(publishID: String, platform: Int, shareType: Int, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCSharePublishRequest(publishID: publishID, platform: platform, shareType: shareType).startWithComplete { (response: YCURLRequestResult) in
            self.backShareResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func shareUser(userID: String, platform: Int, shareType: Int, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCShareUserRequest(userID: userID, platform: platform, shareType: shareType).startWithComplete { (response: YCURLRequestResult) in
            self.backShareResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func shareTheme(themeID: String, platform: Int, shareType: Int, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCShareThemeRequest(themeID: themeID, platform: platform, shareType: shareType).startWithComplete { (response: YCURLRequestResult) in
            self.backShareResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func shareImage(imageID: String, platform: Int, shareType: Int, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCShareImageRequest(imageID: imageID, platform: platform, shareType: shareType).startWithComplete { (response) in
            self.backShareResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func shareVideo(videoID: String, platform: Int, shareType: Int, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCShareVideoRequest(videoID: videoID, platform: platform, shareType: shareType).startWithComplete { (response) in
            self.backShareResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func backShareResult(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainResult?) -> Void) {
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
}

class YCReportDomain: YCBaseDomain {
    
    func reportPublish(publishID: String, reportType: Int, content: String, contentImages: [YCImageModel]?, completionBlock: @escaping (YCDomainResult?) -> Void) {
        YCReportPublishRequest(publishID: publishID, reportType: reportType, content: content, contentImages: contentImages).startWithComplete { (response: YCURLRequestResult) in
            self.backReportResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func reportUser(userID: String, reportType: Int, content: String, contentImages: [YCImageModel]?, completionBlock: @escaping (YCDomainResult?) -> Void) {
        YCReportUserRequest(userID: userID, reportType: reportType, content: content, contentImages: contentImages).startWithComplete { (response: YCURLRequestResult) in
            self.backReportResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func reportTheme(themeID: String, reportType: Int, content: String, contentImages: [YCImageModel]?, completionBlock: @escaping (YCDomainResult?) -> Void) {
        YCReportThemeRequest(themeID: themeID, reportType: reportType, content: content, contentImages: contentImages).startWithComplete { (response: YCURLRequestResult) in
            self.backReportResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func reportComment(commentID: String, reportType: Int, content: String, contentImages: [YCImageModel]?, completionBlock: @escaping (YCDomainResult?) -> Void) {
        YCReportCommentRequest(commentID: commentID, reportType: reportType, content: content, contentImages: contentImages).startWithComplete { (response: YCURLRequestResult) in
            self.backReportResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func backReportResult(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainResult?) -> Void) {
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
}

class YCFocusDomain: YCBaseDomain {
    
    func focusPublish(publishID: String, focusLevel: Int, startDate: Date?, endDate: Date?, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCFocusPublishRequest(publishID: publishID, focusLevel: focusLevel, startDate: startDate, endDate: endDate).startWithComplete { (response: YCURLRequestResult) in
            self.backFocusResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func focusUser(userID: String, focusLevel: Int, startDate: Date?, endDate: Date?, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCFocusUserRequest(userID: userID, focusLevel: focusLevel, startDate: startDate, endDate: endDate).startWithComplete { (response: YCURLRequestResult) in
            self.backFocusResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func focusTheme(themeID: String, focusLevel: Int, startDate: Date?, endDate: Date?, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCFocusThemeRequest(themeID: themeID, focusLevel: focusLevel, startDate: startDate, endDate: endDate).startWithComplete { (response: YCURLRequestResult) in
            self.backFocusResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func backFocusResult(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainResult?) -> Void) {
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
}


