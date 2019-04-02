//
//  LikeModel.swift
//  YouCat
//
//  Created by ting on 2018/9/13.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON

class YCLikeModel: YCBaseModel {
    
    let likeID: String;
    let beLikedID: String;
    let beLikedType: Int;
    let likeDate: Date?
    let user: YCRelationUserModel?
    
    init(likeID: String, beLikedID: String, beLikedType: Int, likeDate: String, userJSON: JSON?) {
        self.likeID = likeID;
        self.beLikedID = beLikedID;
        self.beLikedType = beLikedType;
        if likeDate == ""{
            self.likeDate = nil;
        }else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            if let date = formatter.date(from: likeDate){
                self.likeDate = date
            }else {
                self.likeDate = nil;
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
    }
    
    convenience init(_ json: JSON) {
        let likeID:String    = json[Parameter(.likeID)].string ?? "";
        let beLikedID:String = json[Parameter(.beLikedID)].string ?? "";
        let beLikedType:Int  = json[Parameter(.beLikedType)].int ?? 0;
        let likeDate:String  = json[Parameter(.likeDate)].string ?? "";
        let user:JSON?       = json[Parameter(.user)]
        
        self.init(likeID: likeID, beLikedID: beLikedID, beLikedType: beLikedType, likeDate: likeDate, userJSON: user)
    }
    
    override func getData() -> [String : Any] {
        var parameterDic: [String: Any] = [
            Parameter(.likeID)  :self.likeID,
            Parameter(.beLikedID)       :self.beLikedID,
            Parameter(.beLikedType)    :self.beLikedType
        ]
        if let likeDate = self.likeDate{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            parameterDic[Parameter(.likeDate)] = formatter.string(from: likeDate)
        }
        if let user = self.user {
            parameterDic[Parameter(.user)] = user.getData();
        }
        return parameterDic
    }
}
