//
//  LikeDomain.swift
//  YouCat
//
//  Created by ting on 2018/9/20.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON

class YCLikeDomain: YCBaseDomain {
    
    func likePublish(publishID: String, completionBlock: @escaping (YCDomainResult?) -> Void) {
        YCLikePublishRequest(publishID: publishID).startWithComplete { (response: YCURLRequestResult) in
            self.backLikeResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func unLikePublish(publishID: String, completionBlock: @escaping (YCDomainResult?) -> Void) {
        YCUnlikePublishRequest(publishID: publishID).startWithComplete { (response: YCURLRequestResult) in
            self.backLikeResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func publishLikeList(publishID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCPublishLikeListRequest(publishID: publishID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backLikeList(response: response, completionBlock: completionBlock)
        }
    }
    
    func likeUser(userID: String, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCLikeUserRequest(userID: userID).startWithComplete { (response: YCURLRequestResult) in
            self.backLikeResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func unLikeUser(userID: String, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCUnlikePublishRequest(publishID: userID).startWithComplete { (response: YCURLRequestResult) in
            self.backLikeResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func userLikeList(userID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCUserLikeListRequest(userID: userID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backLikeList(response: response, completionBlock: completionBlock)
        }
    }
    
    func likeTheme(themeID: String, completionBlock: @escaping (YCDomainResult?) -> Void) {
        YCLikeThemeRequest(themeID: themeID).startWithComplete { (response: YCURLRequestResult) in
            self.backLikeResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func unLikeTheme(themeID: String, completionBlock: @escaping (YCDomainResult?) -> Void) {
        YCUnlikeThemeRequest(themeID: themeID).startWithComplete { (response: YCURLRequestResult) in
            self.backLikeResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func themeLikeList(themeID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void) {
        YCThemeLikeListRequest(themeID: themeID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backLikeList(response: response, completionBlock: completionBlock)
        }
    }
    
    func likeComment(commentID: String, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCLikeCommentRequest(commentID: commentID).startWithComplete { (response: YCURLRequestResult) in
            self.backLikeResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func unLikeComment(commentID: String, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCUnlikeCommentRequest(commentID: commentID).startWithComplete { (response: YCURLRequestResult) in
            self.backLikeResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func commentLikeList(commentID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCCommentLikeListRequest(commentID: commentID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backLikeList(response: response, completionBlock: completionBlock)
        }
    }
    
    func backLikeResult(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainResult?) -> Void){
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
    
    func backLikeList(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainListModel?) -> Void) {
        switch response{
        case .success(let v):
            let json:JSON = JSON(v)
            if self.checkResult(json){
                let likeResult = self.likeListResult(json)
                completionBlock(YCDomainListModel(result: true, modelArray: likeResult.1, totoal: likeResult.0))
            }else {
                let errorMessage = self.codeMessage(json)
                completionBlock(YCDomainListModel(result: false, message: errorMessage))
            }
        case .failure:
            let errorMessage = CodeMessage(code: "000")
            completionBlock(YCDomainListModel(result: false, message: errorMessage))
        }
    }
    
    func likeListResult(_ json:JSON) -> (Int, [YCLikeModel]){
        let listArray = json[Parameter(.list)].array;
        let total = json[Parameter(.total)].int ?? 0;
        var likeArray: [YCLikeModel] = [];
        if listArray != nil{
            let count = listArray!.count
            for i in 0..<count {
                let listJson = listArray![i];
                let like = YCLikeModel(listJson)
                likeArray.append(like);
            }
        }
        return (total, likeArray)
    }
}
