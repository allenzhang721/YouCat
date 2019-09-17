//
//  TagRequest.swift
//  YouCat
//
//  Created by ting on 2019/9/17.
//  Copyright © 2019 Curios. All rights reserved.
//

import Foundation


class YCTagPublishListRequest: YCListRequest {
    
    let tags: [YCTagModel]
    
    init(tags: [YCTagModel], start: Int, count: Int) {
        self.tags = tags;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = TagURL.tagPublishList.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var tagArray :Array<[String: Any]> = []
        let a = self.tags.count
        for i in 0..<a {
            let tag = self.tags[i];
            let tagJson = tag.getData()
            tagArray.append(tagJson)
        }
        let dic:Dictionary<String, Any> = [
            Parameter(.tags)  : tagArray,
            Parameter(.start)  : self.start,
            Parameter(.count)  : self.count
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "TagPublishList"
    }
}

class YCTagFavoriteListRequest: YCListRequest {
    
    let tags: [YCTagModel]
    let tagText: String
    
    init(tagText: String, tags: [YCTagModel], start: Int, count: Int) {
        self.tagText = tagText
        self.tags = tags;
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = TagURL.favoriteList.description;
        return urlPath;
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var tagArray :Array<[String: Any]> = []
        let a = self.tags.count
        for i in 0..<a {
            let tag = self.tags[i];
            let tagJson = tag.getData()
            tagArray.append(tagJson)
        }
        let dic:Dictionary<String, Any> = [
            Parameter(.tags)    : tagArray,
            Parameter(.tagText) : self.tagText,
            Parameter(.start)   : self.start,
            Parameter(.count)   : self.count
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "TagPublishList"
    }
}

