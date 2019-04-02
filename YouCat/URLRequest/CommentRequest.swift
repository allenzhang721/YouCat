//
//  CommentRequest.swift
//  YouCat
//
//  Created by ting on 2018/9/17.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation

class YCRemoveCommentRequest: YCBaseRequest {
    
    let commentID: String
    
    init(commentID: String){
        self.commentID = commentID;
    }
    
    override func urlPath() -> String {
        let urlPath = CommentRequestURL.removeComment.description
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.commentID): self.commentID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "RemoveComment"
    }
    
}

class YCCommentPublishRequest: YCBaseRequest {
    
    let publishID: String;
    let content: String;
    let contentImages: [YCImageModel]?
    
    init(publishID: String, content: String, contentImages: [YCImageModel]?){
        self.publishID = publishID;
        self.content = content;
        self.contentImages = contentImages;
    }
    
    override func urlPath() -> String {
        let urlPath = CommentRequestURL.commentPublish.description
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [
            Parameter(.publishID): self.publishID
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
        return "CommentPublish"
    }
}

class YCCommentThemeRequest: YCBaseRequest {
    
    let themeID: String;
    let content: String;
    let contentImages: [YCImageModel]?
    
    init(themeID: String, content: String, contentImages: [YCImageModel]?){
        self.themeID = themeID;
        self.content = content;
        self.contentImages = contentImages;
    }
    
    override func urlPath() -> String {
        let urlPath = CommentRequestURL.commentTheme.description
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [
            Parameter(.themeID): self.themeID
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
        return "CommentTheme"
    }
}

class YCReplyCommentRequest: YCBaseRequest {
    
    let commentID: String;
    let content: String;
    let contentImages: [YCImageModel]?
    
    init(commentID: String, content: String, contentImages: [YCImageModel]?){
        self.commentID = commentID;
        self.content = content;
        self.contentImages = contentImages;
    }
    
    override func urlPath() -> String {
        let urlPath = CommentRequestURL.replyComment.description
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic:Dictionary<String, Any> = [
            Parameter(.commentID): self.commentID
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
        return "ReplyComment"
    }
}

class YCPublishCommentListRequest: YCListRequest {
    
    let publishID: String
    
    init(publishID: String, start: Int, count: Int){
        self.publishID = publishID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = CommentRequestURL.publishCommentList.description
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
        return "PublishCommentList"
    }
}

class YCThemeCommentListRequest: YCListRequest {
    
    let themeID: String
    
    init(themeID: String, start: Int, count: Int){
        self.themeID = themeID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = CommentRequestURL.themeCommentList.description
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
        return "ThemeCommentList"
    }
}

class YCReplyListRequest: YCListRequest {
    
    let commentID: String
    
    init(commentID: String, start: Int, count: Int){
        self.commentID = commentID;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = CommentRequestURL.replyList.description
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
        return "ReplyList"
    }
}
