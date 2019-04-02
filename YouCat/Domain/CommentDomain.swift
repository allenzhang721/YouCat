//
//  CommentDomain.swift
//  YouCat
//
//  Created by ting on 2018/9/20.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON

class YCCommentDomain: YCBaseDomain {
    
    func removeComment(commentID: String, completionBlock: @escaping (YCDomainResult?) -> Void) {
        YCRemoveCommentRequest(commentID: commentID).startWithComplete { (response: YCURLRequestResult) in
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
    
    func commentPublish(publishID: String, content: String, contentImages: [YCImageModel]?, completionBlock: @escaping (YCDomainModel?) -> Void) {
        YCCommentPublishRequest(publishID: publishID, content: content, contentImages: contentImages).startWithComplete { (response: YCURLRequestResult) in
            self.backCommentModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func commentTheme(themeID: String, content: String, contentImages: [YCImageModel]?, completionBlock: @escaping (YCDomainModel?) -> Void) {
        YCCommentThemeRequest(themeID: themeID, content: content, contentImages: contentImages).startWithComplete { (response: YCURLRequestResult) in
            self.backCommentModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func replyComment(commnetID: String, content: String, contentImages: [YCImageModel]? = nil, completionBlock: @escaping (YCDomainModel?) -> Void) {
        YCReplyCommentRequest(commentID: commnetID, content: content, contentImages: contentImages).startWithComplete { (response: YCURLRequestResult) in
            self.backCommentModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func publishCommentList(publishID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCPublishCommentListRequest(publishID: publishID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backCommentList(response: response, completionBlock: completionBlock)
        }
    }
    
    func themeCommentList(themeID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCThemeCommentListRequest(themeID: themeID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backCommentList(response: response, completionBlock: completionBlock)
        }
    }
    
    func replyList(commentID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCReplyListRequest(commentID: commentID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backCommentList(response: response, completionBlock: completionBlock)
        }
    }
    
    func backCommentModel(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainModel?) -> Void) {
        switch response{
        case .success(let v):
            let json:JSON = JSON(v)
            if self.checkResult(json){
                let modelJSON = json[Parameter(.model)]
                completionBlock(YCDomainModel(result: true, baseModel: YCCommentModel(modelJSON)))
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
    
    func backCommentList(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainListModel?) -> Void) {
        switch response{
        case .success(let v):
            let json:JSON = JSON(v)
            if self.checkResult(json){
                let commentList = self.commentListResult(json)
                completionBlock(YCDomainListModel(result: true, modelArray: commentList.1, totoal: commentList.0))
            }else {
                let errorMessage = self.codeMessage(json)
                completionBlock(YCDomainListModel(result: false, message: errorMessage))
            }
        case .failure:
            let errorMessage = CodeMessage(code: "000")
            completionBlock(YCDomainListModel(result: false, message: errorMessage))
        }
    }
    
    func commentListResult(_ json:JSON) -> (Int, [YCCommentModel]){
        let listArray = json[Parameter(.list)].array;
        let total = json[Parameter(.total)].int ?? 0;
        var commentArray: [YCCommentModel] = [];
        if listArray != nil{
            let count = listArray!.count
            for i in 0..<count {
                let listJson = listArray![i];
                let comment = YCCommentModel(listJson)
                commentArray.append(comment);
            }
        }
        return (total, commentArray)
    }
}
