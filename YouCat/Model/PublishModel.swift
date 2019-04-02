//
//  PublishModel.swift
//  YouCat
//
//  Created by ting on 2018/9/11.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON

class YCPublishModel: YCBaseModel {
    
    let publishID: String;
    let uuid: String;
    let user: YCRelationUserModel?
    let content: String;
    let contentType: Int;
    let fromType: Int;
    let fromID: String;
    let fromURL: String;
    var likeCount: Int;
    var commentCount: Int;
    var shareCount: Int;
    let status: Int;
    var isLike: Int;
    let publishDate: Date?;
    var medias: [YCMediaModel];
    var tags: [YCTagModel];
    
    init(publishID: String, uuid: String, content: String, contentType: Int, fromType: Int, fromID: String, fromURL: String, likeCount: Int, commentCount: Int, shareCount: Int, status:Int, isLike: Int, publishDate: String, userJSON: JSON?, mediasJSONArray: [JSON]?, tagJSONArray: [JSON]?) {
        self.publishID = publishID;
        self.uuid = uuid;
        self.content = content;
        self.contentType = contentType;
        self.fromType = fromType;
        self.fromID = fromID;
        self.fromURL = fromURL;
        self.likeCount = likeCount;
        self.commentCount = commentCount;
        self.shareCount = shareCount;
        self.status = status;
        self.isLike = isLike;
        if publishDate == ""{
            self.publishDate = nil;
        }else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            if let date = formatter.date(from: publishDate){
                self.publishDate = date
            }else {
                self.publishDate = nil;
            }
        }
        if userJSON != nil{
            if let s = userJSON!.rawString(), s != "", s != "null" {
                self.user = YCRelationUserModel(userJSON!)
            }else {
               self.user = nil;
            }
        }else {
            self.user = nil;
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
        self.tags = [];
        if tagJSONArray != nil {
            let count = tagJSONArray!.count
            for i in 0..<count {
                let tagJSON = tagJSONArray![i];
                let tag = YCTagModel(tagJSON)
                self.tags.append(tag)
            }
        }
    }
    
    convenience init(_ json: JSON) {
        let publishID:String   = json[Parameter(.publishID)].string ?? "";
        let uuid:String        = json[Parameter(.uuid)].string ?? "";
        let content:String     = json[Parameter(.content)].string ?? "";
        let contentType:Int    = json[Parameter(.contentType)].int ?? 0;
        let fromType:Int       = json[Parameter(.fromType)].int ?? 0;
        let fromID:String      = json[Parameter(.fromID)].string ?? "";
        let fromURL:String     = json[Parameter(.fromURL)].string ?? "";
        let likeCount:Int      = json[Parameter(.likeCount)].int ?? 0;
        let commentCount:Int   = json[Parameter(.commentCount)].int ?? 0;
        let shareCount:Int     = json[Parameter(.shareCount)].int ?? 0;
        let publishDate:String = json[Parameter(.publishDate)].string ?? "";
        let status:Int         = json[Parameter(.status)].int ?? 0;
        let isLike:Int         = json[Parameter(.isLike)].int ?? 0;
        
        let userJson:JSON?     = json[Parameter(.user)]
        let medias:[JSON]?     = json[Parameter(.medias)].array ?? [];
        let tags:[JSON]?       = json[Parameter(.tags)].array ?? [];
    
        self.init(publishID: publishID, uuid: uuid, content: content, contentType: contentType, fromType: fromType, fromID: fromID, fromURL: fromURL, likeCount: likeCount, commentCount: commentCount, shareCount: shareCount, status: status, isLike: isLike, publishDate: publishDate, userJSON: userJson, mediasJSONArray: medias, tagJSONArray: tags)
    }
    
    override func getData() -> [String: Any]{
        var parameterDic: [String: Any] = [
            Parameter(.publishID)  :self.publishID,
            Parameter(.uuid)       :self.uuid,
            Parameter(.content)    :self.content,
            Parameter(.contentType):self.contentType,
            Parameter(.fromType)   :self.fromType,
            Parameter(.fromID)     :self.fromID,
            Parameter(.fromURL)    :self.fromURL,
            Parameter(.likeCount)  :self.likeCount,
            Parameter(.commentCount):self.commentCount,
            Parameter(.shareCount)  :self.shareCount,
            Parameter(.status)      :self.status,
            Parameter(.isLike)      :self.isLike
        ]
        if let publishDate = self.publishDate{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            parameterDic[Parameter(.publishDate)] = formatter.string(from: publishDate)
        }
        if let user = self.user {
            parameterDic[Parameter(.user)] = user.getData();
        }
        var mediaArray :Array<[String: Any]> = []
        let a = self.medias.count
        for i in 0..<a {
            let media = medias[i];
            let json = media.getData()
            mediaArray.append(json)
        }
        parameterDic[Parameter(.medias)] = mediaArray
        var tagArray :Array<[String: Any]> = []
        let count = self.tags.count
        for i in 0..<count {
            let tag = tags[i];
            let json = tag.getData()
            tagArray.append(json)
        }
        parameterDic[Parameter(.tags)] = tagArray
        return parameterDic
    }
}

class YCTagModel: YCBaseModel {
    
    let tagID:String;
    let tagName:String;
    
    init(tagID: String, tagName: String) {
        self.tagID = tagID;
        self.tagName = tagName;
    }
    
    convenience init(_ json: JSON){
        let tagID:String      = json[Parameter(.tagID)].string ?? "";
        let tagName:String    = json[Parameter(.tagName)].string ?? "";
        self.init(tagID: tagID, tagName: tagName)
    }
    
    override func getData() -> [String: Any]{
        return [
            Parameter(.tagID)  :self.tagID,
            Parameter(.tagName):self.tagName
        ]
    }
}
