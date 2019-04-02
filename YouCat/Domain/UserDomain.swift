//
//  UserDomain.swift
//  YouCat
//
//  Created by ting on 2018/9/19.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON

class YCUserDomain: YCBaseDomain {
    
    func loginByPhoneAndPassword(areaCode: String, phone: String, password: String? = nil, completionBlock: @escaping (YCDomainModel?) -> Void) {
        if let a = password{
            YCLoginByPasswordRequest(areaCode: areaCode, phone: phone, password: a).startWithComplete { (response: YCURLRequestResult) in
                self.backLoginUserModel(response: response, completionBlock: completionBlock)
            }
        }else {
            YCLoginByPhoneRequest(areaCode: areaCode, phone: phone).startWithComplete { (response: YCURLRequestResult) in
                self.backLoginUserModel(response: response, completionBlock: completionBlock)
            }
        }
    }
    
    func loginByWeibo(weiboUser: YCWeiboUserModel, completionBlock: @escaping (YCDomainModel?) -> Void) {
        YCLoginByWeiboRequest(weiboUser: weiboUser).startWithComplete { (response: YCURLRequestResult) in
            self.backLoginUserModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func loginByWechat(wechatUser: YCWechatUserModel, completionBlock: @escaping (YCDomainModel?) -> Void) {
        YCLoginByWechatRequest(wechatUser: wechatUser).startWithComplete { (response: YCURLRequestResult) in
            self.backLoginUserModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func updatePassword(password: String, newPassword: String, completionBlock: @escaping (YCDomainResult?) -> Void) {
        YCUpdatePasswordRequest(password: password, newPassword: newPassword).startWithComplete { (response: YCURLRequestResult) in
            self.backUserResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func updateUniqueID(uniqueID: String, completionBlock: @escaping (YCDomainModel?) -> Void) {
        YCUpdateUniqueIDRequest(uniqueID: uniqueID).startWithComplete { (response: YCURLRequestResult) in
            self.backLoginUserModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func updateUserInfo(user: YCLoginUserModel, completionBlock: @escaping (YCDomainModel?) -> Void){
        
        let nikeName = user.nikeName;
        let signature = user.signature;
        let gender = user.gender;
        let birthday = user.birthday;
        let province = user.province;
        let city = user.city;
        let icon = user.icon;
        
        YCUpdateUserInfoRequest(nikeName: nikeName, signature: signature, gender: gender, birthday: birthday, province: province, city: city, icon: icon).startWithComplete { (response: YCURLRequestResult) in
            self.backLoginUserModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func updateNikeName(nikeName: String, completionBlock: @escaping (YCDomainModel?) -> Void){
        YCUpdateNikeNameRequest(nikeName: nikeName).startWithComplete { (response: YCURLRequestResult) in
            self.backLoginUserModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func updateSingature(singature: String, completionBlock: @escaping (YCDomainModel?) -> Void){
        YCUpdateSignRequest(signature: singature).startWithComplete { (response: YCURLRequestResult) in
            self.backLoginUserModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func updateGender(gender: String, completionBlock: @escaping (YCDomainModel?) -> Void){
        YCUpdateGenderRequest(gender: gender).startWithComplete { (response: YCURLRequestResult) in
            self.backLoginUserModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func updateBirthday(birthday: Date?, completionBlock: @escaping (YCDomainModel?) -> Void) {
        YCUpdateBirthdayRequest(birthday: birthday).startWithComplete { (response: YCURLRequestResult) in
            self.backLoginUserModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func updateIcon(icon: YCImageModel?, completionBlock: @escaping (YCDomainModel?) -> Void) {
        YCUpdateIconRequest(icon: icon).startWithComplete { (response: YCURLRequestResult) in
            self.backLoginUserModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func updateAddress(province: String, city: String, completionBlock: @escaping (YCDomainModel?) -> Void){
        YCUpdateAddressRequest(province: province, city: city).startWithComplete { (response: YCURLRequestResult) in
            self.backLoginUserModel(response: response, completionBlock: completionBlock)
        }
    }
    
    func userDetail(userID: String, completionBlock: @escaping (YCDomainModel?) -> Void){
        YCUserDetailRequest(userID: userID).startWithComplete { (response: YCURLRequestResult) in
            switch response{
            case .success(let v):
                let json:JSON = JSON(v)
                if self.checkResult(json){
                    let modelJSON = json[Parameter(.model)]
                    completionBlock(YCDomainModel(result: true, baseModel: YCUserDetailModel(modelJSON)))
                }else {
                    let errorMessage = self.codeMessage(json)
                    completionBlock(YCDomainModel(result: false, message: errorMessage))
                }
                break;
            case .failure:
                let errorMessage = CodeMessage(code: "000")
                completionBlock(YCDomainModel(result: false, message: errorMessage))
                break
            }
        }
    }
    
    func followUser(userID: String, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCFollowUserRequest(userID: userID).startWithComplete { (response: YCURLRequestResult) in
            self.backUserResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func unFollowUser(userID: String, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCUnFollowUserRequest(userID: userID).startWithComplete { (response: YCURLRequestResult) in
            self.backUserResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func blockUser(userID: String, completionBlock: @escaping (YCDomainResult?) -> Void){
        YCBlockUserRequest(userID: userID).startWithComplete { (response: YCURLRequestResult) in
            self.backUserResult(response: response, completionBlock: completionBlock)
        }
    }
    
    func userFollowingList(userID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void) {
        YCFollowingListRequest(userID: userID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backUserList(response: response, completionBlock: completionBlock)
        }
    }
    
    func userFollowerList(userID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCFollowersListRequest(userID: userID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backUserList(response: response, completionBlock: completionBlock)
        }
    }
    
    func userBlockList(userID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCBlockListRequest(userID: userID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backUserList(response: response, completionBlock: completionBlock)
        }
    }
    
    func themeAuthorList(themeID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCThemeAuthorListRequest(themeID: themeID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backUserList(response: response, completionBlock: completionBlock)
        }
    }
    
    func themeFollowerList(themeID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCThemeFollowerListRequest(themeID: themeID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backUserList(response: response, completionBlock: completionBlock)
        }
    }
    
    func blockThemeUserList(themeID: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCBlockThemeUserListRequest(themeID: themeID, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backUserList(response: response, completionBlock: completionBlock)
        }
    }
    
    func searchUserList(keyWord: String, start: Int, count: Int, completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCSearchUserListRequest(keyWord: keyWord, start: start, count: count).startWithComplete { (response: YCURLRequestResult) in
            self.backUserList(response: response, completionBlock: completionBlock)
        }
    }
    
    func backUserList(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainListModel?) -> Void) {
        switch response{
        case .success(let v):
            let json:JSON = JSON(v)
            if self.checkResult(json){
                let listArray = json[Parameter(.list)].array;
                let total = json[Parameter(.total)].int ?? 0;
                var userArray: [YCRelationUserModel] = [];
                if listArray != nil{
                    let count = listArray!.count
                    for i in 0..<count {
                        let listJson = listArray![i];
                        let user = YCRelationUserModel(listJson)
                        userArray.append(user);
                    }
                }
                completionBlock(YCDomainListModel(result: true, modelArray: userArray, totoal: total))
            }else {
                let errorMessage = self.codeMessage(json)
                completionBlock(YCDomainListModel(result: false, message: errorMessage))
            }
        case .failure:
            let errorMessage = CodeMessage(code: "000")
            completionBlock(YCDomainListModel(result: false, message: errorMessage))
        }
    }
    
    
    func backUserResult(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainResult?) -> Void){
        switch response{
        case .success(let v):
            let json:JSON = JSON(v)
            if self.checkResult(json){
                completionBlock(YCDomainResult(result: true, message: ""))
            }else {
                let errorMessage = self.codeMessage(json)
                completionBlock(YCDomainResult(result: false, message: errorMessage))
            }
            break;
        case .failure:
            let errorMessage = CodeMessage(code: "000")
            completionBlock(YCDomainResult(result: false, message: errorMessage))
            break
        }
    }
    
    func backLoginUserModel(response: YCURLRequestResult<Any>, completionBlock: @escaping (YCDomainModel?) -> Void) {
        switch response{
        case .success(let v):
            let json:JSON = JSON(v)
            if self.checkResult(json){
                let modelJSON = json[Parameter(.model)]
                completionBlock(YCDomainModel(result: true, baseModel: YCLoginUserModel(modelJSON)))
            }else {
                let errorMessage = self.codeMessage(json)
                completionBlock(YCDomainModel(result: false, message: errorMessage))
            }
            break;
        case .failure:
            let errorMessage = CodeMessage(code: "000")
            completionBlock(YCDomainModel(result: false, message: errorMessage))
            break
        }
    }
    
}
