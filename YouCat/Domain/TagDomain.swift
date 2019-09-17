//
//  TagDomain.swift
//  YouCat
//
//  Created by ting on 2019/9/18.
//  Copyright © 2019 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON

struct YCTagFavoriteDomainModel {
    
    let result:Bool
    var modelArray:Array<YCBaseModel>?
    var message:String?
    let totoal: Int
    var tagText: String?
    var tags: [YCTagModel]?
    
    init(result:Bool, modelArray:Array<YCBaseModel>, message:String?, totoal: Int){
        self.result      = result
        self.modelArray  = modelArray
        self.message     = message
        self.totoal      = totoal
    }
    
    init(result:Bool, message:String?){
        self.result  = result
        self.message = message
        self.totoal  = 0
    }
    
    init(result:Bool, modelArray:Array<YCBaseModel>, totoal: Int){
        self.result     = result
        self.modelArray = modelArray
        self.totoal     = totoal
    }
    
    init(result:Bool, modelArray:Array<YCBaseModel>, totoal: Int, tagText: String, tags: [YCTagModel]){
        self.result     = result
        self.modelArray = modelArray
        self.totoal     = totoal
        self.tagText    = tagText
        self.tags       = tags
    }
}

class YCTagDomain: YCBaseDomain {

    func tagPublishList(tags: [YCTagModel], start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCTagPublishListRequest(tags: tags, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            switch response{
            case .success(let v):
                let json:JSON = JSON(v)
                if self.checkResult(json){
                    let publishList = self.publishListResult(json)
                    completionBlock(YCDomainListModel(result: true, modelArray: publishList.1, totoal: publishList.0))
                }else {
                    let errorMessage = self.codeMessage(json)
                    completionBlock(YCDomainListModel(result: false, message: errorMessage))
                }
            case .failure:
                let errorMessage = CodeMessage(code: "000")
                completionBlock(YCDomainListModel(result: false, message: errorMessage))
            }
        }
    }
    
    func tagFavoritePublishList(tagText: String, tagNameArray: [String], start: Int, count: Int, completionBlock: @escaping (YCTagFavoriteDomainModel?) -> Void){
        var tags: [YCTagModel] = []
        for tagName in tagNameArray {
            tags.append(YCTagModel(tagID: "", tagName: tagName))
        }
        YCTagFavoriteListRequest(tagText: tagText, tags: tags, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            switch response{
            case .success(let v):
                let json:JSON = JSON(v)
                if self.checkResult(json){
                    let tagText = json[Parameter(.tagText)].string ?? "";
                    let tagsArray = json[Parameter(.tags)].array;
                    var tags: [YCTagModel] = [];
                    if tagsArray != nil{
                        let count = tagsArray!.count
                        for i in 0..<count {
                            let tagJson = tagsArray![i];
                            tags.append(YCTagModel(tagJson));
                        }
                    }
                    let publishList = self.publishListResult(json)
                    completionBlock(YCTagFavoriteDomainModel(result: true, modelArray: publishList.1, totoal: publishList.0, tagText: tagText, tags: tags))
                }else {
                    let errorMessage = self.codeMessage(json)
                    completionBlock(YCTagFavoriteDomainModel(result: false, message: errorMessage))
                }
            case .failure:
                let errorMessage = CodeMessage(code: "000")
                completionBlock(YCTagFavoriteDomainModel(result: false, message: errorMessage))
            }
        }
    }
    
    func publishListResult(_ json:JSON) -> (Int, [YCPublishModel]){
        let listArray = json[Parameter(.list)].array;
        let total = json[Parameter(.total)].int ?? 0;
        var publishArray: [YCPublishModel] = [];
        if listArray != nil{
            let count = listArray!.count
            for i in 0..<count {
                let listJson = listArray![i];
                let publish = YCPublishModel(listJson)
                publishArray.append(publish);
            }
        }
        return (total, publishArray)
    }
}



//  使用样例
//YCTagDomain().tagFavoritePublishList(tagText: "美丽的布偶猫", tagNameArray: ["高颜值", "布偶猫"], start: 0, count: 20) { (tagFavorite) in
//    print("cccc")
//    if let list = tagFavorite, list.result{
//        let tagText = list.tagText
//        let tags = list.tags
//        let publish = list.modelArray
//    }
//}
