//
//  ThemeRequest.swift
//  YouCat
//
//  Created by ting on 2018/9/15.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation

class YCThemeIDRequest: YCBaseRequest{
    
    let themeID: String
    
    init(themeID: String){
        self.themeID = themeID;
    }
    
    override func urlPath() -> String {
       return ""
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.themeID): self.themeID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return ""
    }
}

class YCAddThemeRequest: YCBaseRequest {
    
    let userID: String
    let name: String;
    let description: String;
    let coverImage: YCImageModel?
    let coverVideo: YCVideoModel?
    let themeType: Int;
    
    init(userID: String, name: String, description: String, themeType: Int, coverImage: YCImageModel?, coverVideo: YCVideoModel?){
        self.userID = userID;
        self.name = name;
        self.description = description;
        self.themeType = themeType;
        self.coverImage = coverImage;
        self.coverVideo = coverVideo;
    }
    
    init(name: String, description: String, themeType: Int, coverImage: YCImageModel?, coverVideo: YCVideoModel?){
        self.userID = "";
        self.name = name;
        self.description = description;
        self.themeType = themeType;
        self.coverImage = coverImage;
        self.coverVideo = coverVideo;
    }
    
    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.addTheme.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [
            Parameter(.userID): self.userID,
            Parameter(.themeType) : self.themeType
        ];
        if let nameEncode = self.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            dic[Parameter(.name)] = nameEncode
        }
        if let decEncode = self.description.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            dic[Parameter(.description)] = decEncode
        }
        if let coverImage = self.coverImage {
            dic[Parameter(.coverImage)] = coverImage.getData();
        }
        if let coverVideo = self.coverVideo {
            dic[Parameter(.coverVideo)] = coverVideo.getData();
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "AddTheme"
    }
}

class YCUpdateThemeRequest: YCAddThemeRequest {
    
    let themeID: String
    
    init(themeID: String, name: String, description: String, themeType: Int, coverImage: YCImageModel?, coverVideo: YCVideoModel?){
        self.themeID = themeID;
        super.init(name: name, description: description, themeType: themeType, coverImage: coverImage, coverVideo: coverVideo)
    }

    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.updateTheme.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic = super.parameter();
        dic[Parameter(.themeID)] = self.themeID;
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UpdateTheme"
    }
}

class YCRemoveThemeRequest: YCThemeIDRequest {
    
    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.removeTheme.description
        return urlPath
    }
    
    override func errorMessage() -> String {
        return "RemoveTheme"
    }
}

class YCThemeDetailRequest: YCThemeIDRequest {
    
    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.themeDetail.description
        return urlPath
    }
    
    override func errorMessage() -> String {
        return "ThemeDetail"
    }
}

class YCThemeDetailByUUIDRequest: YCBaseRequest {
    let uuid: String;
    
    init(uuid: String) {
        self.uuid = uuid;
        super.init()
    }
    
    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.themeDetailByUUID.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic: [String: Any] = [
            Parameter(.uuid): self.uuid
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "ThemeDetailByUUID"
    }
}

class YCThemeListRequest: YCListRequest {
    
    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.themeList.description
        return urlPath
    }
    
    override func errorMessage() -> String {
        return "ThemeList"
    }
    
}

class YCTopThemeListRequest: YCListRequest {
    
    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.topThemeList.description
        return urlPath
    }
    
    override func errorMessage() -> String {
        return "TopThemeList"
    }
    
}

class YCFollowThemeListRequest: YCListRequest {
    
    let userID: String;
    
    init(userID: String, start: Int, count: Int){
        self.userID = userID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.followThemeList.description
        return urlPath
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
        return "FollowThemeList"
    }
}

class YCBlockThemeListRequest: YCListRequest {
    
    let userID: String;
    
    init(userID: String, start: Int, count: Int){
        self.userID = userID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.followThemeList.description
        return urlPath
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
        return "BlockThemeList"
    }
}

class YCPublishThemeListRequest: YCListRequest {
    
    let publishID: String
    
    init(publishID: String, start: Int, count: Int){
        self.publishID = publishID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.publishThemeList.description
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
        return "PublishThemeList"
    }
}

class YCSearchThemeListRequest: YCListRequest{
    
    let keyWord: String;
    
    init(keyWord: String, start: Int, count: Int){
        self.keyWord = keyWord;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.searchThemeList.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [
            Parameter(.start) : self.start,
            Parameter(.count) : self.count
        ];
        if let keyWordEncode = self.keyWord.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed){
            dic[Parameter(.keyWord)] =  keyWordEncode
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "SearchThemeList"
    }
    
}

class YCAddPublishToThemeRequest: YCBaseRequest {
    
    let publishID: String;
    let themeID: String;
    
    init(publishID: String, themeID: String){
        self.publishID = publishID;
        self.themeID = themeID;
    }
    
    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.addPublishToTheme.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.publishID): self.publishID,
            Parameter(.themeID) : self.themeID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "AddPublishToTheme"
    }
}

class YCRemoveThemePublishRequest: YCBaseRequest {
    
    let publishID: String;
    let themeID: String;
    
    init(publishID: String, themeID: String){
        self.publishID = publishID;
        self.themeID = themeID;
    }
    
    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.removeThemePublish.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.publishID): self.publishID,
            Parameter(.themeID) : self.themeID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "RemovePublishToTheme"
    }
}

class YCFollowThemeRequest: YCThemeIDRequest {
    
    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.followTheme.description
        return urlPath
    }
    
    override func errorMessage() -> String {
        return "FollowTheme"
    }

}

class YCUnFollowThemeRequest: YCThemeIDRequest {

    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.unFollowTheme.description
        return urlPath
    }

    override func errorMessage() -> String {
        return "UnFollowTheme"
    }
}

class YCBlockThemeRequest: YCThemeIDRequest {
    
    override func urlPath() -> String {
        let urlPath = ThemeRequestURL.blockTheme.description
        return urlPath
    }
    
    override func errorMessage() -> String {
        return "BlockTheme"
    }
}



