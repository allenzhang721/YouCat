//
//  LikeRequest.swift
//  YouCat
//
//  Created by ting on 2018/9/17.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation

class YCLikePublishRequest: YCBaseRequest {
    
    let publishID: String;
    
    init(publishID: String){
        self.publishID = publishID;
    }
    
    override func urlPath() -> String {
        let urlPath = LikeRequestURL.likePublish.description
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.publishID): self.publishID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "LikePublish"
    }
}

class YCUnlikePublishRequest: YCBaseRequest {
    
    let publishID: String;
    
    init(publishID: String){
        self.publishID = publishID;
    }
    
    override func urlPath() -> String {
        let urlPath = LikeRequestURL.unLikePublish.description
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.publishID): self.publishID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "LikePublish"
    }
}

class YCPublishLikeListRequest: YCListRequest {
    
    let publishID: String;
    
    init(publishID: String, start: Int, count: Int){
        self.publishID = publishID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = LikeRequestURL.publishLikeList.description
        return urlPath;
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
        return "PublishLikeList"
    }
}

class YCLikeUserRequest: YCBaseRequest {
    
    let userID: String;
    
    init(userID: String){
        self.userID = userID;
    }
    
    override func urlPath() -> String {
        let urlPath = LikeRequestURL.likeUser.description
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.userID): self.userID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "LikeUser"
    }
}

class YCUnlikeUserRequest: YCBaseRequest {
    
    let userID: String;
    
    init(userID: String){
        self.userID = userID;
    }
    
    override func urlPath() -> String {
        let urlPath = LikeRequestURL.unLikeUser.description
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.userID): self.userID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UnlikeUser"
    }
}

class YCUserLikeListRequest: YCListRequest {
    
    let userID: String;
    
    init(userID: String, start: Int, count: Int){
        self.userID = userID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = LikeRequestURL.userLikeList.description
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
        return "UserLikeList"
    }
}

class YCLikeThemeRequest: YCBaseRequest {
    
    let themeID: String;
    
    init(themeID: String){
        self.themeID = themeID;
    }
    
    override func urlPath() -> String {
        let urlPath = LikeRequestURL.likeTheme.description
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.themeID): self.themeID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "LikeTheme"
    }
}

class YCUnlikeThemeRequest: YCBaseRequest {
    
    let themeID: String;
    
    init(themeID: String){
        self.themeID = themeID;
    }
    
    override func urlPath() -> String {
        let urlPath = LikeRequestURL.unLikeTheme.description
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.themeID): self.themeID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UnlikeTheme"
    }
}

class YCThemeLikeListRequest: YCListRequest {
    
    let themeID: String;
    
    init(themeID: String, start: Int, count: Int){
        self.themeID = themeID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = LikeRequestURL.themeLikeList.description
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.themeID): self.themeID,
            Parameter(.start) : self.start,
            Parameter(.count) : self.count
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "ThemeLikeList"
    }
}


class YCLikeCommentRequest: YCBaseRequest {
    
    let commentID: String;
    
    init(commentID: String){
        self.commentID = commentID;
    }
    
    override func urlPath() -> String {
        let urlPath = LikeRequestURL.likeComment.description
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.commentID): self.commentID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "LikeComment"
    }
}

class YCUnlikeCommentRequest: YCBaseRequest {
    
    let commentID: String;
    
    init(commentID: String){
        self.commentID = commentID;
    }
    
    override func urlPath() -> String {
        let urlPath = LikeRequestURL.unLikeComment.description
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.commentID): self.commentID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UnlikeComment"
    }
}

class YCCommentLikeListRequest: YCListRequest {
    
    let commentID: String;
    
    init(commentID: String, start: Int, count: Int){
        self.commentID = commentID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = LikeRequestURL.commentLikeList.description
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.commentID): self.commentID,
            Parameter(.start) : self.start,
            Parameter(.count) : self.count
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "CommentLikeList"
    }
}
