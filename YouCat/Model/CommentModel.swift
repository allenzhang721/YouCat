//
//  CommentModel.swift
//  YouCat
//
//  Created by ting on 2018/9/13.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON

class YCCommentModel: YCBaseModel {
    
    let commentID: String;
    let user: YCRelationUserModel?
    let beRepliedUser: YCRelationUserModel?
    let beCommentedID: String;
    let beCommentedType: Int;
    let beRepliedID: String;
    let commentType: Int;
    let content: String;
    let contentType: Int;
    var likeCount: Int;
    var isLike: Int;
    let commentDate: Date?;
    var replyCount: Int;
    var listCount: Int;
    var medias: [YCMediaModel];
    var replyList: [YCCommentModel]
    
    init(commentID: String, userJSON: JSON?, beRepliedUserJSON: JSON?, beCommentedID: String, beCommentedType: Int, beRepliedID: String, commentTyp: Int, content: String, contentType: Int, likeCount: Int, isLike: Int, commentDate: String, replyCount: Int, listCount: Int, mediasJSONArray: [JSON]?, replyJSONArray: [JSON]?) {
        self.commentID = commentID;
        self.beCommentedID = beCommentedID;
        self.beCommentedType = beCommentedType;
        self.beRepliedID = beRepliedID;
        self.commentType = commentTyp;
        self.content = content;
        self.contentType = contentType;
        self.likeCount = likeCount;
        self.isLike = isLike;
        self.replyCount = replyCount;
        self.listCount = listCount;
        
        if commentDate == ""{
            self.commentDate = nil;
        }else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            if let date = formatter.date(from: commentDate){
                self.commentDate = date
            }else {
                self.commentDate = nil;
            }
        }
        if userJSON != nil{
            if let s = userJSON!.rawString(), s != "", s != "null" {
                self.user = YCRelationUserModel(userJSON!)
            }else {
                self.user = nil
            }
        }else {
            self.user = nil;
        }
        if beRepliedUserJSON != nil{
            if let s = beRepliedUserJSON!.rawString(), s != "", s != "null" {
                self.beRepliedUser = YCRelationUserModel(beRepliedUserJSON!)
            }else {
                self.beRepliedUser = nil
            }
        }else {
            self.beRepliedUser = nil;
        }
        self.medias = [];
        if mediasJSONArray != nil{
            let count = mediasJSONArray!.count
            for i in 0..<count {
                let mediasJson = mediasJSONArray![i];
                if self.contentType == 1{
                    let imageModel = YCImageModel(mediasJson)
                    self.medias.append(imageModel)
                }else if self.contentType == 2{
                    let videoModel = YCVideoModel(mediasJson)
                    self.medias.append(videoModel)
                }
            }
        }
        self.replyList = [];
        if replyJSONArray != nil{
            let count = replyJSONArray!.count
            for i in 0..<count {
                let replyJson = replyJSONArray![i];
                let reply = YCCommentModel(replyJson);
                self.replyList.append(reply)
            }
        }
    }

    convenience init(_ json: JSON) {
        
        let commentID:String     = json[Parameter(.commentID)].string ?? "";
        let beCommentedID:String = json[Parameter(.beCommentedID)].string ?? "";
        let beCommentedType:Int  = json[Parameter(.beCommentedType)].int ?? 0;
        let beRepliedID:String   = json[Parameter(.beRepliedID)].string ?? "";
        let commentType:Int      = json[Parameter(.commentType)].int ?? 0;
        let content:String       = json[Parameter(.content)].string ?? "";
        let contentType:Int      = json[Parameter(.contentType)].int ?? 0;
        let likeCount:Int        = json[Parameter(.likeCount)].int ?? 0;
        let isLike:Int           = json[Parameter(.isLike)].int ?? 0;
        let commentDate:String   = json[Parameter(.commentDate)].string ?? "";
        let replyCount:Int       = json[Parameter(.replyCount)].int ?? 0;
        let listCount:Int        = json[Parameter(.listCount)].int ?? 0;
       
        let user:JSON?           = json[Parameter(.user)]
        let beRepliedUser:JSON?  = json[Parameter(.beRepliedUser)]
        let medias:[JSON]?       = json[Parameter(.medias)].array ?? [];
        let replyList:[JSON]?    = json[Parameter(.replyList)].array ?? [];
        
        self.init(commentID: commentID, userJSON: user, beRepliedUserJSON: beRepliedUser, beCommentedID: beCommentedID, beCommentedType: beCommentedType, beRepliedID: beRepliedID, commentTyp: commentType, content: content, contentType: contentType, likeCount: likeCount, isLike: isLike, commentDate: commentDate, replyCount: replyCount, listCount: listCount, mediasJSONArray: medias, replyJSONArray: replyList)
    }
    
    convenience init(_ commentID: String, commentType: Int, replyCount: Int, listCount: Int) {
        self.init(commentID: commentID, userJSON: nil, beRepliedUserJSON: nil, beCommentedID: "", beCommentedType: -1, beRepliedID: "", commentTyp: commentType, content: "", contentType: -1, likeCount: 0, isLike: -1, commentDate: "", replyCount: replyCount, listCount: listCount, mediasJSONArray: nil, replyJSONArray: nil)
    }
    
    override func getData() -> [String : Any] {
        var parameterDic: [String: Any] = [
            Parameter(.commentID)      :self.commentID,
            Parameter(.beCommentedID)  :self.beCommentedID,
            Parameter(.beCommentedType):self.beCommentedType,
            Parameter(.beRepliedID)    :self.beRepliedID,
            Parameter(.content)        :self.content,
            Parameter(.contentType)    :self.contentType,
            Parameter(.likeCount)      :self.likeCount,
            Parameter(.isLike)         :self.isLike,
            Parameter(.replyCount)     :self.replyCount,
            Parameter(.listCount)      :self.listCount
        ]
        if let commentDate = self.commentDate{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            parameterDic[Parameter(.commentDate)] = formatter.string(from: commentDate)
        }
        if let user = self.user {
            parameterDic[Parameter(.user)] = user.getData();
        }
        if let beRepliedUser = self.beRepliedUser {
            parameterDic[Parameter(.beRepliedUser)] = beRepliedUser.getData();
        }
        var mediaArray :Array<[String: Any]> = []
        let a = self.medias.count
        for i in 0..<a {
            let media = self.medias[i];
            let json = media.getData()
            mediaArray.append(json)
        }
        parameterDic[Parameter(.medias)] = mediaArray
        var replyArray :Array<[String: Any]> = []
        let count = self.replyList.count
        for i in 0..<count {
            let reply = self.replyList[i];
            let json = reply.getData()
            replyArray.append(json)
        }
        parameterDic[Parameter(.replyList)] = replyArray
        return parameterDic
    }
}
