//
//  BaseRequest.swift
//  YouCat
//
//  Created by ting on 2018/9/17.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation

class YCSharePublishRequest: YCBaseRequest {
    
    let publishID: String;
    let platform: Int;
    let shareType: Int;
    
    init(publishID: String, platform: Int, shareType: Int){
        self.publishID = publishID;
        self.platform = platform;
        self.shareType = shareType
    }
    
    override func urlPath() -> String {
        let urlPath = RequestURL.sharePublish.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.publishID) : self.publishID,
            Parameter(.platform) : self.platform,
            Parameter(.shareType) : self.shareType
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "SharePublish"
    }
}

class YCShareUserRequest: YCBaseRequest {
    
    let userID: String;
    let platform: Int;
    let shareType: Int;
    
    init(userID: String, platform: Int, shareType: Int){
        self.userID = userID;
        self.platform = platform;
        self.shareType = shareType;
    }
    
    override func urlPath() -> String {
        let urlPath = RequestURL.shareUser.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.userID) : self.userID,
            Parameter(.platform) : self.platform,
            Parameter(.shareType) : self.shareType
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "ShareUser"
    }
}

class YCShareThemeRequest: YCBaseRequest {
    
    let themeID: String;
    let platform: Int;
    let shareType: Int;
    
    init(themeID: String, platform: Int, shareType: Int){
        self.themeID = themeID;
        self.platform = platform;
        self.shareType = shareType;
    }
    
    override func urlPath() -> String {
        let urlPath = RequestURL.shareTheme.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.themeID) : self.themeID,
            Parameter(.platform) : self.platform,
            Parameter(.shareType) : self.shareType
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "ShareTheme"
    }
}

class YCShareImageRequest: YCBaseRequest {
    
    let imageID: String;
    let platform: Int;
    let shareType: Int
    
    init(imageID: String, platform: Int, shareType: Int){
        self.imageID = imageID;
        self.platform = platform;
        self.shareType = shareType;
    }
    
    override func urlPath() -> String {
        let urlPath = RequestURL.shareImage.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.imageID) : self.imageID,
            Parameter(.platform) : self.platform,
            Parameter(.shareType) : self.shareType
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "ShareImage"
    }
}

class YCShareVideoRequest: YCBaseRequest {
    
    let videoID: String;
    let platform: Int;
    let shareType: Int;
    
    init(videoID: String, platform: Int, shareType: Int){
        self.videoID = videoID;
        self.platform = platform;
        self.shareType = shareType
    }
    
    override func urlPath() -> String {
        let urlPath = RequestURL.shareVideo.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.videoID) : self.videoID,
            Parameter(.platform) : self.platform,
            Parameter(.shareType) : self.shareType
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "ShareVideo"
    }
}

class YCReportPublishRequest: YCBaseRequest {
    
    let publishID: String;
    let reportType: Int;
    let content: String;
    let contentImages: [YCImageModel]?
    
    init(publishID: String, reportType: Int, content: String, contentImages: [YCImageModel]?){
        self.publishID = publishID;
        self.reportType = reportType;
        self.content = content;
        self.contentImages = contentImages;
    }
    
    override func urlPath() -> String {
        let urlPath = RequestURL.reportPublish.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [
            Parameter(.publishID) : self.publishID,
            Parameter(.reportType) : self.reportType
        ];
        if let contentEncode = self.content.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            dic[Parameter(.content)] = contentEncode
        }
        if let images = self.contentImages {
            var imageArray :Array<[String: Any]> = []
            let a = images.count
            for i in 0..<a {
                let image = images[i];
                let json = image.getData()
                imageArray.append(json)
            }
            dic[Parameter(.contentImages)] = imageArray
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "ReportPublish"
    }
}

class YCReportUserRequest: YCBaseRequest {
    
    let userID: String;
    let reportType: Int;
    let content: String;
    let contentImages: [YCImageModel]?
    
    init(userID: String, reportType: Int, content: String, contentImages: [YCImageModel]?){
        self.userID = userID;
        self.reportType = reportType;
        self.content = content;
        self.contentImages = contentImages;
    }
    
    override func urlPath() -> String {
        let urlPath = RequestURL.reportUser.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [
            Parameter(.userID) : self.userID,
            Parameter(.reportType) : self.reportType
        ];
        if let contentEncode = self.content.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            dic[Parameter(.content)] = contentEncode
        }
        if let images = self.contentImages {
            var imageArray :Array<[String: Any]> = []
            let a = images.count
            for i in 0..<a {
                let image = images[i];
                let json = image.getData()
                imageArray.append(json)
            }
            dic[Parameter(.contentImages)] = imageArray
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "ReportUser"
    }
}

class YCReportThemeRequest: YCBaseRequest {
    
    let themeID: String;
    let reportType: Int;
    let content: String;
    let contentImages: [YCImageModel]?
    
    init(themeID: String, reportType: Int, content: String, contentImages: [YCImageModel]?){
        self.themeID = themeID;
        self.reportType = reportType;
        self.content = content;
        self.contentImages = contentImages;
    }
    
    override func urlPath() -> String {
        let urlPath = RequestURL.reportTheme.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [
            Parameter(.themeID) : self.themeID,
            Parameter(.reportType) : self.reportType
        ];
        if let contentEncode = self.content.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            dic[Parameter(.content)] = contentEncode
        }
        if let images = self.contentImages {
            var imageArray :Array<[String: Any]> = []
            let a = images.count
            for i in 0..<a {
                let image = images[i];
                let json = image.getData()
                imageArray.append(json)
            }
            dic[Parameter(.contentImages)] = imageArray
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "ReportTheme"
    }
}

class YCReportCommentRequest: YCBaseRequest {
    
    let commentID: String;
    let reportType: Int;
    let content: String;
    let contentImages: [YCImageModel]?
    
    init(commentID: String, reportType: Int, content: String, contentImages: [YCImageModel]?){
        self.commentID = commentID;
        self.reportType = reportType;
        self.content = content;
        self.contentImages = contentImages;
    }
    
    override func urlPath() -> String {
        let urlPath = RequestURL.reportComment.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [
            Parameter(.commentID) : self.commentID,
            Parameter(.reportType) : self.reportType
        ];
        if let contentEncode = self.content.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            dic[Parameter(.content)] = contentEncode
        }
        if let images = self.contentImages {
            var imageArray :Array<[String: Any]> = []
            let a = images.count
            for i in 0..<a {
                let image = images[i];
                let json = image.getData()
                imageArray.append(json)
            }
            dic[Parameter(.contentImages)] = imageArray
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "ReportComment"
    }
}

class YCFocusPublishRequest: YCBaseRequest {
    
    let publishID: String;
    let focusLevel: Int;
    let startDate: Date?;
    let endDate: Date?;
    
    init(publishID: String, focusLevel: Int, startDate: Date?, endDate: Date?){
        self.publishID = publishID;
        self.focusLevel = focusLevel;
        self.startDate = startDate;
        self.endDate = endDate;
    }
    
    override func urlPath() -> String {
        let urlPath = RequestURL.focusPublish.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [
            Parameter(.publishID) : self.publishID,
            Parameter(.focusLevel) : self.focusLevel
        ];
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        if let startDate = self.startDate {
            dic[Parameter(.startDate)] = formatter.string(from: startDate)
        }
        if let endDate = self.endDate {
            dic[Parameter(.endDate)] = formatter.string(from: endDate)
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "FocusPublish"
    }
}

class YCFocusUserRequest: YCBaseRequest {
    
    let userID: String;
    let focusLevel: Int;
    let startDate: Date?;
    let endDate: Date?;
    
    init(userID: String, focusLevel: Int, startDate: Date?, endDate: Date?){
        self.userID = userID;
        self.focusLevel = focusLevel;
        self.startDate = startDate;
        self.endDate = endDate;
    }
    
    override func urlPath() -> String {
        let urlPath = RequestURL.focusUser.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [
            Parameter(.userID) : self.userID,
            Parameter(.focusLevel) : self.focusLevel
        ];
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        if let startDate = self.startDate {
            dic[Parameter(.startDate)] = formatter.string(from: startDate)
        }
        if let endDate = self.endDate {
            dic[Parameter(.endDate)] = formatter.string(from: endDate)
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "FocusUser"
    }
}

class YCFocusThemeRequest: YCBaseRequest {
    
    let themeID: String;
    let focusLevel: Int;
    let startDate: Date?;
    let endDate: Date?;
    
    init(themeID: String, focusLevel: Int, startDate: Date?, endDate: Date?){
        self.themeID = themeID;
        self.focusLevel = focusLevel;
        self.startDate = startDate;
        self.endDate = endDate;
    }
    
    override func urlPath() -> String {
        let urlPath = RequestURL.focusTheme.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [
            Parameter(.themeID) : self.themeID,
            Parameter(.focusLevel) : self.focusLevel
        ];
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        if let startDate = self.startDate {
            dic[Parameter(.startDate)] = formatter.string(from: startDate)
        }
        if let endDate = self.endDate {
            dic[Parameter(.endDate)] = formatter.string(from: endDate)
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "FocusTheme"
    }
}

class YCUploadTokenListRequest: YCBaseRequest {
    
    let tokenList: [YCTokenModel]
    
    init(tokenList: [YCTokenModel]){
        self.tokenList = tokenList;
    }
    
    override func urlPath() -> String {
        let urlPath = RequestURL.tokenList.description
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var tokenArray :Array<[String: Any]> = []
        let count = self.tokenList.count
        for i in 0..<count {
            let token = self.tokenList[i];
            let json = token.getData()
            tokenArray.append(json)
        }
        let dic:Dictionary<String, Any> = [
            Parameter(.tokens): tokenArray
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "TokenList"
    }
}
