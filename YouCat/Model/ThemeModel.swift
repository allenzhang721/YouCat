//
//  ThemeModel.swift
//  YouCat
//
//  Created by ting on 2018/9/13.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON

class YCThemeModel: YCBaseModel {
    
    let themeID: String;
    let uuid: String;
    let name: String;
    let description: String;
    let themeType: Int;
    let createDate: Date?
    let creator: YCRelationUserModel?
    let coverImage: YCImageModel?
    let coverVideo: YCVideoModel?
    var relation: Int;
    
    init(themeID: String, uuid: String, name:String, description: String, themeType: Int, relation: Int, createDate: String, creatorJSON: JSON?, coverImageJSON: JSON?, coverVideoJSON: JSON?) {
        self.themeID = themeID;
        self.uuid = uuid;
        self.name = name;
        self.description = description;
        self.themeType = themeType;
        self.relation = relation;
        if createDate == ""{
            self.createDate = nil;
        }else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            if let date = formatter.date(from: createDate){
                self.createDate = date
            }else {
                self.createDate = nil;
            }
        }
        if creatorJSON != nil{
            if let s = creatorJSON!.rawString(), s != "", s != "null" {
                self.creator = YCRelationUserModel(creatorJSON!)
            }else {
                self.creator = nil;
            }
        }else {
            self.creator = nil;
        }
        if coverImageJSON != nil{
            if let s = coverImageJSON!.rawString(), s != "", s != "null" {
                self.coverImage = YCImageModel(coverImageJSON!)
            }else {
                self.coverImage = nil;
            }
        }else {
            self.coverImage = nil;
        }
        if coverVideoJSON != nil{
            if let s = coverVideoJSON!.rawString(), s != "", s != "null" {
                self.coverVideo = YCVideoModel(coverVideoJSON!)
            }else {
                self.coverVideo = nil;
            }
        }else {
            self.coverVideo = nil;
        }
    }
    
    convenience init(_ json: JSON) {
        let themeID:String     = json[Parameter(.themeID)].string ?? "";
        let uuid:String        = json[Parameter(.uuid)].string ?? "";
        let name:String        = json[Parameter(.name)].string ?? "";
        let description:String = json[Parameter(.description)].string ?? "";
        let themeType:Int      = json[Parameter(.themeType)].int ?? 0;
        let relation:Int       = json[Parameter(.relation)].int ?? 0;
        
        let createDate:String  = json[Parameter(.createDate)].string ?? "";
        
        let creator:JSON       = json[Parameter(.creator)]
        let coverImage:JSON    = json[Parameter(.coverImage)]
        let coverVideo:JSON    = json[Parameter(.coverVideo)]
        
        self.init(themeID: themeID, uuid: uuid, name: name, description: description, themeType: themeType, relation: relation, createDate: createDate, creatorJSON: creator, coverImageJSON: coverImage, coverVideoJSON: coverVideo)
    }
    
    override func getData() -> [String : Any] {
        var parameterDic: [String: Any] = [
            Parameter(.themeID)     :self.themeID,
            Parameter(.uuid)        :self.uuid,
            Parameter(.name)        :self.name,
            Parameter(.description) :self.description,
            Parameter(.themeType)   :self.themeType,
            Parameter(.relation)    :self.relation
        ]
        if let createDate = self.createDate{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            parameterDic[Parameter(.createDate)] = formatter.string(from: createDate)
        }
        if let creator = self.creator {
            parameterDic[Parameter(.creator)] = creator.getData();
        }
        if let coverImage = self.coverImage {
            parameterDic[Parameter(.coverImage)] = coverImage.getData();
        }
        if let coverVideo = self.coverVideo {
            parameterDic[Parameter(.coverVideo)] = coverVideo.getData();
        }
        return parameterDic
    }
}

class YCThemeDetailModel: YCThemeModel{
    
    let followersCount: Int;
    let publishCount: Int;
    let likeCount: Int;
    let commentCount: Int;
    var isLike: Int;
    
    init(themeID: String, uuid: String, name:String, description: String, themeType: Int, relation: Int, followersCount: Int, publishCount: Int, likeCount: Int, commentCount: Int, isLike: Int, createDate: String, creatorJSON: JSON?, coverImageJSON: JSON?, coverVideoJSON: JSON?) {
        
        self.followersCount = followersCount
        self.publishCount = publishCount
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.isLike = isLike
        
        super.init(themeID: themeID, uuid: uuid, name: name, description: description, themeType: themeType, relation: relation, createDate: createDate, creatorJSON: creatorJSON, coverImageJSON: coverImageJSON, coverVideoJSON: coverVideoJSON)
    }
    
    convenience init(_ json: JSON) {
        let themeID:String     = json[Parameter(.themeID)].string ?? "";
        let uuid:String        = json[Parameter(.uuid)].string ?? "";
        let name:String        = json[Parameter(.name)].string ?? "";
        let description:String = json[Parameter(.description)].string ?? "";
        let themeType:Int      = json[Parameter(.themeType)].int ?? 0;
        let relation:Int       = json[Parameter(.relation)].int ?? 0;
        let followersCount:Int = json[Parameter(.followersCount)].int ?? 0;
        let publishCount:Int   = json[Parameter(.publishCount)].int ?? 0;
        let likeCount:Int      = json[Parameter(.likeCount)].int ?? 0;
        let commentCount:Int   = json[Parameter(.commentCount)].int ?? 0;
        let isLike:Int         = json[Parameter(.isLike)].int ?? 0;
        let createDate:String  = json[Parameter(.createDate)].string ?? "";
        
        let creator:JSON       = json[Parameter(.creator)]
        let coverImage:JSON    = json[Parameter(.coverImage)]
        let coverVideo:JSON    = json[Parameter(.coverVideo)]
        
        self.init(themeID: themeID, uuid: uuid, name: name, description: description, themeType: themeType, relation: relation, followersCount: followersCount, publishCount: publishCount, likeCount: likeCount, commentCount: commentCount, isLike: isLike, createDate: createDate, creatorJSON: creator, coverImageJSON: coverImage, coverVideoJSON: coverVideo)
    }
    
    override func getData() -> [String : Any] {
        var parameterDic: [String: Any] = super.getData()
        parameterDic[Parameter(.followersCount)]  = self.followersCount
        parameterDic[Parameter(.publishCount)]  = self.publishCount
        parameterDic[Parameter(.commentCount)]  = self.commentCount
        parameterDic[Parameter(.likeCount)]  = self.likeCount
        parameterDic[Parameter(.isLike)]  = self.isLike
        return parameterDic
    }
}
