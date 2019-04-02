//
//  PublishRequest.swift
//  YouCat
//
//  Created by ting on 2018/9/11.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation

class YCRemovePublishRequest: YCBaseRequest {
    
    let publishID: String
    
    init(publishID: String){
        self.publishID = publishID;
    }
    
    override func urlPath() -> String {
        let urlPath = PublishRequestURL.removePublish.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.publishID): self.publishID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "RemovePublish"
    }
}

class YCUpdatePublishRequest: YCBaseRequest {
    
    let publishModel: YCPublishModel
    
    init(publishModel: YCPublishModel) {
        self.publishModel = publishModel;
    }
    
    override func urlPath() -> String {
        let urlPath = PublishRequestURL.updatePublish.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic = publishModel.getData()
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UpdatePublish"
    }
}

class YCPublishListRequest: YCListRequest{
    
    override func urlPath() -> String {
        let urlPath = PublishRequestURL.publishList.description
        return urlPath
    }
    
    override func errorMessage() -> String {
        return "PublishList"
    }
}

class YCTopPublishListRequest: YCListRequest{
    
    override func urlPath() -> String {
        let urlPath = PublishRequestURL.topPublishList.description;
        return urlPath
    }
    
    override func errorMessage() -> String {
        return "TopPublishList"
    }
}

class YCPublishMoreListRequest: YCListRequest {
    
    let publishID: String
    
    init(publishID: String, start: Int, count: Int) {
        self.publishID = publishID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = PublishRequestURL.publishMoreList.description;
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.publishID): self.publishID,
            Parameter(.start) : self.start,
            Parameter(.count) : self.count
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "PublishMoreList"
    }
}

class YCUserPublishListRequest: YCListRequest{
    
    let userID: String
    
    init(userID: String, start: Int, count: Int) {
        self.userID = userID
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = PublishRequestURL.userPublishList.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.userID): self.userID,
            Parameter(.start) : self.start,
            Parameter(.count) : self.count
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "TopPublishList"
    }
}

class YCUserLikePublishListRequest: YCListRequest {
    
    let userID: String
    
    init(userID: String, start: Int, count: Int){
        self.userID = userID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = PublishRequestURL.userLikePublishList.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.userID): self.userID,
            Parameter(.start) : self.start,
            Parameter(.count) : self.count
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UserLikePublishList"
    }
}

class YCUserFollowPublishListRequest: YCListRequest {
    
    let userID: String;
    
    init(userID: String, start: Int, count: Int){
        self.userID = userID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = PublishRequestURL.userFollowPublishList.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.userID): self.userID,
            Parameter(.start) : self.start,
            Parameter(.count) : self.count
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UserFollowPublishList"
    }
}

class YCThemePublishListRequest: YCListRequest {
    
    let themeID: String;
    let type: Int
    
    init(themeID: String, type: Int, start: Int, count: Int){
        self.themeID = themeID;
        self.type = type
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = PublishRequestURL.themePublishList.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.themeID): self.themeID,
            Parameter(.type)   : self.type,
            Parameter(.start)  : self.start,
            Parameter(.count)  : self.count
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "ThemePublishList"
    }
}

class YCTagPublishListRequest: YCListRequest {
    
    let tagID: String
    
    init(tagID: String, start: Int, count: Int) {
        self.tagID = tagID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = PublishRequestURL.tagPublishList.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.tagID)  : self.tagID,
            Parameter(.start)  : self.start,
            Parameter(.count)  : self.count
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "TagPublishList"
    }
}

class YCSearchPublishListRequest: YCListRequest {

    let keyWord: String;
    let publishType: Int;
    
    init(keyWord: String, publishType: Int, start: Int, count: Int) {
        self.keyWord = keyWord;
        self.publishType = publishType;
        super.init(start: start, count: count)
    }
    
    init(keyWord: String, start: Int, count: Int){
        self.keyWord = keyWord;
        self.publishType = 0;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = PublishRequestURL.searchPublishList.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        
        var dic:Dictionary<String, Any> = [
            Parameter(.publishType): self.publishType,
            Parameter(.start)  : self.start,
            Parameter(.count)  : self.count
        ];
        if let keyWordEncode = self.keyWord.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed){
            dic[Parameter(.keyWord)] =  keyWordEncode
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "SearchPublishList"
    }
}

class YCSearchUserPublishListRequest: YCListRequest {
    
    let keyWord: String;
    let userID: String;
    
    init(keyWord: String, userID: String, start: Int, count: Int) {
        self.keyWord = keyWord;
        self.userID = userID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = PublishRequestURL.searchUserPublishList.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [
            Parameter(.userID) : self.userID,
            Parameter(.start)  : self.start,
            Parameter(.count)  : self.count
        ];
        if let keyWordEncode = self.keyWord.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed){
            dic[Parameter(.keyWord)] =  keyWordEncode
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "SearchUserPublishList"
    }
}

class YCSearchThemePublishListRequest: YCListRequest {
    
    let keyWord: String;
    let themeID: String;
    
    init(keyWord: String, themeID: String, start: Int, count: Int) {
        self.keyWord = keyWord;
        self.themeID = themeID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = PublishRequestURL.searchThemePublishList.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [
            Parameter(.themeID): self.themeID,
            Parameter(.start)  : self.start,
            Parameter(.count)  : self.count
        ];
        if let keyWordEncode = self.keyWord.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed){
            dic[Parameter(.keyWord)] =  keyWordEncode
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "SearchThemePublishList"
    }
}
