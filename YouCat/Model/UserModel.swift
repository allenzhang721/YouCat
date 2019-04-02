//
//  UserModel.swift
//  YouCat
//
//  Created by ting on 2018/9/11.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON
import Locksmith

class YCUserModel: YCBaseModel {
    let userID: String;
    let uuid: String;
    let uniqueID: String;
    var nikeName: String;
    var signature: String;
    var gender: String;
    var province: String;
    var city: String;
    var birthday: Date?;
    var icon: YCImageModel?;
    
    init(userID: String, uuid:String, uniqueID:String, nikeName:String, signature:String, gender:String, birthday:String, province:String, city:String, iconJSON:JSON?) {
        self.userID = userID;
        self.uuid = uuid;
        self.uniqueID = uniqueID;
        self.nikeName = nikeName;
        self.signature = signature;
        self.gender = gender;
        self.province = province;
        self.city = city;
        if birthday == ""{
            self.birthday = nil;
        }else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            if let date = formatter.date(from: birthday){
                self.birthday = date
            }else {
                self.birthday = nil;
            }
        }
        if iconJSON != nil{
            if let s = iconJSON!.rawString(), s != "", s != "null" {
                self.icon = YCImageModel(iconJSON!)
            }else {
                self.icon = nil;
            }
        }else {
            self.icon = nil;
        }
    }
    
    convenience init(_ json: JSON) {
        let userID:String     = json[Parameter(.userID)].string ?? "";
        let uuid:String       = json[Parameter(.uuid)].string ?? "";
        let uniqueID:String   = json[Parameter(.uniqueID)].string ?? "";
        let nikeName:String   = json[Parameter(.nikeName)].string ?? "";
        let signature:String  = json[Parameter(.signature)].string ?? "";
        let gender:String     = json[Parameter(.gender)].string ?? "";
        let province:String   = json[Parameter(.province)].string ?? "";
        let city:String       = json[Parameter(.city)].string ?? "";
        let birthday:String   = json[Parameter(.birthday)].string ?? "";
        let iconJSON:JSON?    = json[Parameter(.icon)]
        
        self.init(userID: userID, uuid: uuid, uniqueID: uniqueID, nikeName: nikeName, signature: signature, gender: gender, birthday: birthday, province: province, city: city, iconJSON: iconJSON)
    }
    
    override func getData() -> [String: Any]{
        var parameterDic: [String: Any] = [
                Parameter(.userID)   :self.userID,
                Parameter(.uuid)     :self.uuid,
                Parameter(.uniqueID) :self.uniqueID,
                Parameter(.nikeName) :self.nikeName,
                Parameter(.signature):self.signature,
                Parameter(.gender)   :self.gender,
                Parameter(.province) :self.province,
                Parameter(.city)     :self.city
            ]
        if let birthday = self.birthday{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            parameterDic[Parameter(.birthday)] = formatter.string(from: birthday)
        }
        
        if let icon = self.icon {
            parameterDic[Parameter(.icon)] = icon.getData();
        }
        return parameterDic
    }
}

class YCRelationUserModel: YCUserModel {
    
    var relation: Int;
    
    init(userID: String, uuid:String, uniqueID:String, nikeName:String, signature:String, gender:String, birthday:String, province:String, city:String, iconJSON:JSON?, relation: Int) {
        self.relation = relation;
        super.init(userID: userID, uuid: uuid, uniqueID: uniqueID, nikeName: nikeName, signature: signature, gender: gender, birthday: birthday, province: province, city: city, iconJSON: iconJSON)
    }
    
    convenience init(_ json: JSON) {
        let userID:String     = json[Parameter(.userID)].string ?? "";
        let uuid:String       = json[Parameter(.uuid)].string ?? "";
        let uniqueID:String   = json[Parameter(.uniqueID)].string ?? "";
        let nikeName:String   = json[Parameter(.nikeName)].string ?? "";
        let signature:String  = json[Parameter(.signature)].string ?? "";
        let gender:String     = json[Parameter(.gender)].string ?? "";
        let province:String   = json[Parameter(.province)].string ?? "";
        let city:String       = json[Parameter(.city)].string ?? "";
        let relation:Int      = json[Parameter(.relation)].int ?? 0;
        let birthday:String   = json[Parameter(.birthday)].string ?? "";
        let iconJSON:JSON?    = json[Parameter(.icon)]
        
        self.init(userID: userID, uuid: uuid, uniqueID: uniqueID, nikeName: nikeName, signature: signature, gender: gender, birthday: birthday, province: province, city: city, iconJSON: iconJSON, relation: relation)
    }
    
    override func getData() -> [String: Any]{
        var parameterDic: [String: Any] = super.getData()
        parameterDic[Parameter(.relation)]  = self.relation
        return parameterDic
    }
}

class YCLoginUserModel: YCUserModel{
    
    let areaCode: String;
    let phone: String;
    let active: Int;
    let setPassword: Int;
    let weiboUser: YCWeiboUserModel?
    
    init(userID: String, uuid:String, uniqueID:String, nikeName:String, signature:String, gender:String, birthday:String, province:String, city:String, iconJSON:JSON?, areaCode: String, phone: String, active: Int, setPassword: Int, weiboUserJSON: JSON?) {
        self.areaCode = areaCode;
        self.phone    = phone;
        self.active   = active;
        self.setPassword = setPassword;
        if weiboUserJSON != nil{
            if let s = weiboUserJSON!.rawString(), s != "", s != "null" {
                self.weiboUser = YCWeiboUserModel(weiboUserJSON!)
            }else {
                self.weiboUser = nil;
            }
        }else {
            self.weiboUser = nil;
        }
        super.init(userID: userID, uuid: uuid, uniqueID: uniqueID, nikeName: nikeName, signature: signature, gender: gender, birthday: birthday, province: province, city: city, iconJSON: iconJSON)
    }
    
    convenience init(_ json: JSON) {
        let userID:String     = json[Parameter(.userID)].string ?? "";
        let uuid:String       = json[Parameter(.uuid)].string ?? "";
        let uniqueID:String   = json[Parameter(.uniqueID)].string ?? "";
        let nikeName:String   = json[Parameter(.nikeName)].string ?? "";
        let signature:String  = json[Parameter(.signature)].string ?? "";
        let gender:String     = json[Parameter(.gender)].string ?? "";
        let province:String   = json[Parameter(.province)].string ?? "";
        let city:String       = json[Parameter(.city)].string ?? "";
        let birthday:String   = json[Parameter(.birthday)].string ?? "";
        let iconJSON:JSON?    = json[Parameter(.icon)]
        
        let areaCode:String   = json[Parameter(.areaCode)].string ?? "";
        let phone:String      = json[Parameter(.phone)].string ?? "";
        let active:Int        = json[Parameter(.active)].int ?? 0;
        let setPassword:Int   = json[Parameter(.setPassword)].int ?? 0;
        let weiboUserJSON:JSON?    = json[Parameter(.weiboUser)]
        
        self.init(userID: userID, uuid: uuid, uniqueID: uniqueID, nikeName: nikeName, signature: signature, gender: gender, birthday: birthday, province: province, city: city, iconJSON: iconJSON, areaCode: areaCode, phone: phone, active: active, setPassword: setPassword, weiboUserJSON: weiboUserJSON)
    }
    
    override func getData() -> [String : Any] {
        
        var parameterDic: [String: Any] = super.getData()
        parameterDic[Parameter(.areaCode)]  = self.areaCode
        parameterDic[Parameter(.phone)]  = self.phone
        parameterDic[Parameter(.active)]  = self.active
        parameterDic[Parameter(.setPassword)]  = self.setPassword
        if let weiboUser = self.weiboUser {
            parameterDic[Parameter(.weiboUser)] = weiboUser.getData();
        }
        return parameterDic
    }
}

class YCUserDetailModel: YCRelationUserModel{
    
    let followersCount: Int;
    let followingCount: Int;
    let publishCount: Int;
    let likeCount: Int;
    let isLike: Int;
    let weiboUser: YCWeiboUserModel?
    
    init(userID: String, uuid:String, uniqueID:String, nikeName:String, signature:String, gender:String, birthday:String, province:String, city:String, iconJSON:JSON?, relation: Int, followersCount: Int, followingCount: Int, publishCount: Int, likeCount: Int, isLike: Int, weiboUserJSON: JSON?) {
        
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.publishCount = publishCount
        self.likeCount = likeCount
        self.isLike = isLike
        if weiboUserJSON != nil{
            if let s = weiboUserJSON!.rawString(), s != "", s != "null" {
                self.weiboUser = YCWeiboUserModel(weiboUserJSON!)
            }else {
                self.weiboUser = nil;
            }
        }else {
            self.weiboUser = nil;
        }
        super.init(userID: userID, uuid: uuid, uniqueID: uniqueID, nikeName: nikeName, signature: signature, gender: gender, birthday: birthday, province: province, city: city, iconJSON: iconJSON, relation: relation)
    }
    
    convenience init(_ json: JSON) {
        let userID:String     = json[Parameter(.userID)].string ?? "";
        let uuid:String       = json[Parameter(.uuid)].string ?? "";
        let uniqueID:String   = json[Parameter(.uniqueID)].string ?? "";
        let nikeName:String   = json[Parameter(.nikeName)].string ?? "";
        let signature:String  = json[Parameter(.signature)].string ?? "";
        let gender:String     = json[Parameter(.gender)].string ?? "";
        let province:String   = json[Parameter(.province)].string ?? "";
        let city:String       = json[Parameter(.city)].string ?? "";
        let relation:Int      = json[Parameter(.relation)].int ?? 0;
        let birthday:String   = json[Parameter(.birthday)].string ?? "";
        let iconJSON:JSON?    = json[Parameter(.icon)]
        
        let followersCount:Int = json[Parameter(.followersCount)].int ?? 0;
        let followingCount:Int = json[Parameter(.followingCount)].int ?? 0;
        let publishCount:Int   = json[Parameter(.publishCount)].int ?? 0;
        let likeCount:Int      = json[Parameter(.likeCount)].int ?? 0;
        let isLike:Int         = json[Parameter(.isLike)].int ?? 0;
        let weiboUserJSON:JSON?    = json[Parameter(.weiboUser)]
        
        self.init(userID: userID, uuid: uuid, uniqueID: uniqueID, nikeName: nikeName, signature: signature, gender: gender, birthday: birthday, province: province, city: city, iconJSON: iconJSON, relation: relation, followersCount: followersCount, followingCount: followingCount, publishCount: publishCount, likeCount: likeCount, isLike: isLike, weiboUserJSON: weiboUserJSON)
    }
    
    override func getData() -> [String : Any] {
        
        var parameterDic: [String: Any] = super.getData()
        parameterDic[Parameter(.followersCount)]  = self.followersCount
        parameterDic[Parameter(.followingCount)]  = self.followingCount
        parameterDic[Parameter(.publishCount)]  = self.publishCount
        parameterDic[Parameter(.likeCount)]  = self.likeCount
        parameterDic[Parameter(.isLike)]  = self.isLike
        if let weiboUser = self.weiboUser {
            parameterDic[Parameter(.weiboUser)] = weiboUser.getData();
        }
        return parameterDic
    }
}

class YCWeiboUserModel: YCBaseModel {
    let weiboUserID:String;
    let weiboID:String;
    let weiboNikeName:String;
    let weiboSignature:String;
    let weiboGender:String;
    let weiboURL:String;
    let weiboIcon:YCImageModel?
    let tweetCount: Int
    let followCount: Int
    let fansCount: Int
    
    init(weiboUserID: String, weiboID:String, weiboNikeName:String, weiboSignature:String, weiboGender:String, weiboURL:String, iconJSON:JSON?, tweetCount: Int, followCount: Int, fansCount: Int) {
        self.weiboUserID = weiboUserID;
        self.weiboID = weiboID;
        self.weiboNikeName = weiboNikeName;
        self.weiboSignature = weiboSignature;
        self.weiboGender = weiboGender;
        self.weiboURL = weiboURL;
        if iconJSON != nil{
            if let s = iconJSON!.rawString(), s != "", s != "null" {
                self.weiboIcon = YCImageModel(iconJSON!)
            }else {
                self.weiboIcon = nil;
            }
        }else {
            self.weiboIcon = nil;
        }
        self.tweetCount = tweetCount
        self.followCount = followCount
        self.fansCount = fansCount
    }
    
    convenience init(_ json: JSON) {
        let weiboUserID:String    = json[Parameter(.weiboUserID)].string ?? "";
        let weiboID:String        = json[Parameter(.weiboID)].string ?? "";
        let weiboNikeName:String  = json[Parameter(.weiboNikeName)].string ?? "";
        let weiboSignature:String = json[Parameter(.weiboSignature)].string ?? "";
        let weiboGender:String    = json[Parameter(.weiboGender)].string ?? "";
        let weiboURL:String       = json[Parameter(.weiboURL)].string ?? "";
        let iconJSON:JSON?        = json[Parameter(.weiboIcon)]
        
        let tweetCount:Int       = json[Parameter(.tweetCount)].int ?? 0;
        let followCount:Int      = json[Parameter(.followCount)].int ?? 0;
        let fansCount:Int        = json[Parameter(.fansCount)].int ?? 0;
        
        self.init(weiboUserID: weiboUserID, weiboID: weiboID, weiboNikeName: weiboNikeName, weiboSignature: weiboSignature, weiboGender: weiboGender, weiboURL: weiboURL, iconJSON: iconJSON, tweetCount: tweetCount, followCount: followCount, fansCount: fansCount)
    }
    
    override func getData() -> [String : Any] {
        var parameterDic: [String: Any] = [
            Parameter(.weiboUserID)    :self.weiboUserID,
            Parameter(.weiboID)        :self.weiboID,
            Parameter(.weiboNikeName)  :self.weiboNikeName,
            Parameter(.weiboSignature) :self.weiboSignature,
            Parameter(.weiboGender)    :self.weiboGender,
            Parameter(.weiboURL)       :self.weiboURL,
            Parameter(.tweetCount)     :self.tweetCount,
            Parameter(.followCount)    :self.followCount,
            Parameter(.fansCount)      :self.fansCount
        ]
        if let weiboIcon = self.weiboIcon {
            parameterDic[Parameter(.weiboIcon)] = weiboIcon.getData();
        }
        return parameterDic
    }
}

class YCWechatUserModel: YCBaseModel {
    let wechatUserID:String;
    let wechatOpenID:String;
    let wechatUnionID:String;
    let wechatNikeName:String;
    let wechatGender:String;
    let wechatCountry:String;
    let wechatProvince: String;
    let wechatCity: String;
    let wechatIcon:YCImageModel?
    
    init(wechatUserID: String, wechatOpenID:String, wechatUnionID:String, wechatNikeName:String, wechatGender:String, wechatCountry:String, wechatProvince: String, wechatCity: String, iconJSON:JSON?) {
        self.wechatUserID = wechatUserID;
        self.wechatOpenID = wechatOpenID;
        self.wechatUnionID = wechatUnionID;
        self.wechatNikeName = wechatNikeName;
        self.wechatGender = wechatGender;
        self.wechatCountry = wechatCountry;
        self.wechatProvince = wechatProvince
        self.wechatCity = wechatCity
        if iconJSON != nil{
            if let s = iconJSON!.rawString(), s != "", s != "null" {
                self.wechatIcon = YCImageModel(iconJSON!)
            }else {
                self.wechatIcon = nil;
            }
        }else {
            self.wechatIcon = nil;
        }
    }
    
    convenience init(_ json: JSON) {
        let wechatUserID:String   = json[Parameter(.wechatUserID)].string ?? "";
        let wechatOpenID:String   = json[Parameter(.wechatOpenID)].string ?? "";
        let wechatUnionID:String  = json[Parameter(.wechatUnionID)].string ?? "";
        let wechatNikeName:String = json[Parameter(.wechatNikeName)].string ?? "";
        let wechatGender:String   = json[Parameter(.wechatGender)].string ?? "";
        let wechatCountry:String  = json[Parameter(.wechatCountry)].string ?? "";
        let wechatProvince:String = json[Parameter(.wechatProvince)].string ?? "";
        let wechatCity:String     = json[Parameter(.wechatCity)].string ?? "";
        let iconJSON:JSON?        = json[Parameter(.wechatIcon)]
        
        self.init(wechatUserID: wechatUserID, wechatOpenID: wechatOpenID, wechatUnionID: wechatUnionID, wechatNikeName: wechatNikeName, wechatGender: wechatGender, wechatCountry: wechatCountry, wechatProvince: wechatProvince, wechatCity: wechatCity, iconJSON: iconJSON)
    }
    
    override func getData() -> [String : Any] {
        var parameterDic: [String: Any] = [
            Parameter(.wechatUserID)   :self.wechatUserID,
            Parameter(.wechatOpenID)   :self.wechatOpenID,
            Parameter(.wechatUnionID)  :self.wechatUnionID,
            Parameter(.wechatNikeName) :self.wechatNikeName,
            Parameter(.wechatGender)   :self.wechatGender,
            Parameter(.wechatCountry)  :self.wechatCountry,
            Parameter(.wechatProvince) :self.wechatProvince,
            Parameter(.wechatCity)     :self.wechatCity
        ]
        if let wechatIcon = self.wechatIcon {
            parameterDic[Parameter(.wechatIcon)] = wechatIcon.getData();
        }
        return parameterDic
    }
}
