//
//  PublishDomain.swift
//  YouCat
//
//  Created by ting on 2018/9/11.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON


class YCPublishDomain: YCBaseDomain {
    
    func removePublish(publishID: String, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCRemovePublishRequest(publishID: publishID).startWithComplete { (response: YCURLRequestResult) in
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
    
    func updatePublish(publishModel: YCPublishModel, completionBlock: @escaping (YCDomainModel?) -> Void){
        YCUpdatePublishRequest(publishModel: publishModel).startWithComplete { (response: YCURLRequestResult) in
            self.backPublishModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func publishList(start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void) {
        YCPublishListRequest.init(start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backPublishList(response: response, completionBlock: completionBlock)
        }
    }
    
    func topPublishList(start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void) {
        YCTopPublishListRequest(start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backPublishList(response: response, completionBlock: completionBlock)
        }
    }
    
    func publishMoreList(publishID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCPublishMoreListRequest(publishID: publishID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backPublishList(response: response, completionBlock: completionBlock)
        }
    }
    
    func userPublishList(userID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCUserPublishListRequest(userID: userID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backPublishList(response: response, completionBlock: completionBlock)
        }
    }

    func userLikePublishList(userID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCUserLikePublishListRequest(userID: userID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backPublishList(response: response, completionBlock: completionBlock)
        }
    }
    
    func userFollowPublishList(userID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCUserFollowPublishListRequest(userID: userID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backPublishList(response: response, completionBlock: completionBlock)
        }
    }
    
    func themePublishList(themeID: String, type: Int, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCThemePublishListRequest(themeID: themeID, type: type, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backPublishList(response: response, completionBlock: completionBlock)
        }
    }
    
    func searchPublishList(keyWord: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void) {
        YCSearchPublishListRequest(keyWord: keyWord, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backPublishList(response: response, completionBlock: completionBlock)
        }
    }
    
    func searchUserPublishList(keyWord: String, userID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void) {
        YCSearchUserPublishListRequest(keyWord: keyWord, userID: userID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backPublishList(response: response, completionBlock: completionBlock)
        }
    }
    
    func searchThemePublishList(keyWord: String, themeID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCSearchThemePublishListRequest(keyWord: keyWord, themeID: themeID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backPublishList(response: response, completionBlock: completionBlock)
        }
    }
    
    func backPublishModel(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainModel?) -> Void) {
        switch response{
        case .success(let v):
            let json:JSON = JSON(v)
            if self.checkResult(json){
                let modelJSON = json[Parameter(.model)]
                completionBlock(YCDomainModel(result: true, baseModel: YCPublishModel(modelJSON)))
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
    
    func backPublishList(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainListModel?) -> Void) {
        switch response{
        case .success(let v):
            let json:JSON = JSON(v)
            if self.checkResult(json){
                let publishList = self.publishListResult(json)
                completionBlock(YCDomainListModel(result: true, modelArray: publishList.1, totoal: publishList.0))
            }else {
                let errorMessage = self.codeMessage(json)
                completionBlock(YCDomainListModel(result: false, message: errorMessage))
            }
        case .failure:
            let errorMessage = CodeMessage(code: "000")
            completionBlock(YCDomainListModel(result: false, message: errorMessage))
        }
    }
    
    func publishListResult(_ json:JSON) -> (Int, [YCPublishModel]){
        let listArray = json[Parameter(.list)].array;
        let total = json[Parameter(.total)].int ?? 0;
        var publishArray: [YCPublishModel] = [];
        if listArray != nil{
            let count = listArray!.count
            for i in 0..<count {
                let listJson = listArray![i];
                let publish = YCPublishModel(listJson)
                publishArray.append(publish);
            }
        }
        return (total, publishArray)
    }
}
