//
//  UserRequest.swift
//  YouCat
//
//  Created by ting on 2018/9/14.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation


class YCLoginByPasswordRequest: YCBaseRequest {
    
    let areaCode: String;
    let phone: String;
    let uniqueID: String;
    let password: String;
    
    init(areaCode: String, phone: String, uniqueID: String, password: String) {
        self.areaCode = areaCode;
        self.phone = phone;
        self.uniqueID = uniqueID;
        self.password = password;
    }
    
    init(areaCode: String, phone: String, password: String){
        self.areaCode = areaCode;
        self.phone = phone;
        self.password = password
        self.uniqueID = "";
    }
    
    init(uniqueID: String, password: String){
        self.uniqueID = uniqueID;
        self.password = password;
        self.areaCode = "";
        self.phone = "";
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.loginByPassword.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.areaCode): self.areaCode,
            Parameter(.phone): self.phone,
            Parameter(.uniqueID): self.uniqueID,
            Parameter(.password): self.password
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "LoginByPassword"
    }
}

class YCLoginByPhoneRequest:YCBaseRequest{
    
    let areaCode: String;
    let phone: String;
    
    init(areaCode: String, phone: String){
        self.areaCode = areaCode;
        self.phone = phone;
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.loginByPhone.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.areaCode): self.areaCode,
            Parameter(.phone): self.phone
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "LoginByPhone"
    }
}

class YCLoginByWeiboRequest: YCBaseRequest {
    
    let weiboUser: YCWeiboUserModel
    
    init(weiboUser: YCWeiboUserModel) {
        self.weiboUser = weiboUser
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.loginByWeibo.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.weiboID)        :self.weiboUser.weiboID,
            Parameter(.weiboNikeName)  :self.weiboUser.weiboNikeName,
            Parameter(.weiboSignature) :self.weiboUser.weiboSignature,
            Parameter(.weiboGender)    :self.weiboUser.weiboGender,
            Parameter(.tweetCount)     :self.weiboUser.tweetCount,
            Parameter(.followCount)    :self.weiboUser.followCount,
            Parameter(.fansCount)      :self.weiboUser.fansCount
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "LoginByWeiBo"
    }
}

class YCLoginByWechatRequest: YCBaseRequest {
    
    let wechatUser: YCWechatUserModel
    
    init(wechatUser: YCWechatUserModel) {
        self.wechatUser = wechatUser
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.loginByWeChat.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.wechatOpenID)   :self.wechatUser.wechatOpenID,
            Parameter(.wechatUnionID)  :self.wechatUser.wechatUnionID,
            Parameter(.wechatNikeName) :self.wechatUser.wechatNikeName,
            Parameter(.wechatGender)   :self.wechatUser.wechatGender,
            Parameter(.wechatCountry)  :self.wechatUser.wechatCountry,
            Parameter(.wechatProvince) :self.wechatUser.wechatProvince,
            Parameter(.wechatCity)     :self.wechatUser.wechatCity
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "LoginByWechat"
    }
}

class YCUpdatePasswordRequest: YCBaseRequest {
    
    let userID: String;
    let password: String;
    let newPassword: String;
    
    init(userID: String, password: String, newPassword: String){
        self.userID = userID;
        self.password = password;
        self.newPassword = newPassword;
    }
    
    init(password: String, newPassword: String){
        self.userID = ""
        self.password = password;
        self.newPassword = newPassword;
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.updatePassword.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.userID): self.userID,
            Parameter(.password): self.password,
            Parameter(.newPassword): self.newPassword
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UpdatePassword"
    }
}

class YCUpdateUniqueIDRequest: YCBaseRequest {
    
    let userID: String;
    let uniqueID: String;
    
    init(userID: String, uniqueID: String){
        self.userID = userID;
        self.uniqueID = uniqueID;
    }
    
    init(uniqueID: String){
        self.userID = ""
        self.uniqueID = uniqueID;
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.updateUniqueID.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.userID): self.userID,
            Parameter(.uniqueID): self.uniqueID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UpdateUniqueID"
    }
}

class YCUpdateUserInfoRequest: YCBaseRequest {
 
    let userID: String;
    let nikeName: String;
    let signature: String;
    let gender: String;
    let birthday: Date?
    let province: String;
    let city: String;
    let icon: YCImageModel?
    
    init(userID: String, nikeName: String, signature: String, gender: String, birthday: Date?, province: String, city: String, icon: YCImageModel?){
        self.userID = userID;
        self.nikeName = nikeName;
        self.signature = signature;
        self.gender = gender;
        self.birthday = birthday;
        self.province = province;
        self.city = city;
        self.icon = icon;
    }
    
    init(nikeName: String, signature: String, gender: String, birthday: Date?, province: String, city: String, icon: YCImageModel?){
        self.userID = "";
        self.nikeName = nikeName;
        self.signature = signature;
        self.gender = gender;
        self.birthday = birthday;
        self.province = province;
        self.city = city;
        self.icon = icon;
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.updateUserInfo.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic: [String: Any] = [
            Parameter(.userID): self.userID,
            Parameter(.gender): self.gender,
            Parameter(.province): self.province,
            Parameter(.city): self.city
        ];
        if let nikeNameEncode = self.nikeName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            dic[Parameter(.nikeName)] = nikeNameEncode
        }
        if let signEncode = self.signature.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            dic[Parameter(.signature)] = signEncode
        }
        if let birthday = self.birthday{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            dic[Parameter(.birthday)] = formatter.string(from: birthday)
        }
        if let icon = self.icon {
            dic[Parameter(.icon)] = icon.getData();
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UpdateUserInfo"
    }
}

class YCUpdateNikeNameRequest: YCBaseRequest {
    
    let userID: String;
    let nikeName: String;
    
    init(userID: String, nikeName: String){
        self.userID = userID;
        self.nikeName = nikeName;
    }
    
    init(nikeName: String){
        self.userID = "";
        self.nikeName = nikeName;
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.updateNikeName.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic: [String: Any] = [
            Parameter(.userID): self.userID
        ];
        if let nikeNameEncode = self.nikeName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            dic[Parameter(.nikeName)] = nikeNameEncode
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UpdateNikeName"
    }
}

class YCUpdateSignRequest: YCBaseRequest {
    
    let userID: String;
    let signature: String;
    
    init(userID: String, signature: String){
        self.userID = userID;
        self.signature = signature;
    }
    
    init(signature: String){
        self.userID = "";
        self.signature = signature;
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.updateSign.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic: [String: Any] = [
            Parameter(.userID): self.userID
        ];
        if let signEncode = self.signature.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            dic[Parameter(.signature)] = signEncode
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UpdateSign"
    }
}

class YCUpdateGenderRequest: YCBaseRequest {
    
    let userID: String;
    let gender: String;
    
    init(userID: String, gender: String){
        self.userID = userID;
        self.gender = gender;
    }
    
    init(gender: String){
        self.userID = "";
        self.gender = gender;
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.updateGender.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic: [String: Any] = [
            Parameter(.userID): self.userID,
            Parameter(.gender): self.gender
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UpdateGender"
    }
}

class YCUpdateBirthdayRequest: YCBaseRequest {
    
    let userID: String;
    let birthday: Date?
    
    init(userID: String, birthday: Date?){
        self.userID = userID;
        self.birthday = birthday;
    }
    
    init(birthday: Date?){
        self.userID = "";
        self.birthday = birthday;
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.updateBirthday.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic: [String: Any] = [
            Parameter(.userID): self.userID
        ];
        if let birthday = self.birthday{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            dic[Parameter(.birthday)] = formatter.string(from: birthday)
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UpdateBirthday"
    }
}

class YCUpdateIconRequest: YCBaseRequest {
    
    let userID: String;
    let icon: YCImageModel?
    
    init(userID: String, icon: YCImageModel?){
        self.userID = userID;
        self.icon = icon;
    }
    
    init(icon: YCImageModel?){
        self.userID = "";
        self.icon = icon;
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.updateIcon.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        var dic: [String: Any] = [
            Parameter(.userID): self.userID
        ];
        if let icon = self.icon {
            dic[Parameter(.icon)] = icon.getData();
        }
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UpdateIcon"
    }
}

class YCUpdateAddressRequest: YCBaseRequest {
    
    let userID: String;
    let province: String;
    let city: String;
    
    init(userID: String, province: String, city: String){
        self.userID = userID;
        self.province = province;
        self.city = city;
    }
    
    init(province: String, city: String){
        self.userID = "";
        self.province = province;
        self.city = city;
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.updateAddress.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic: [String: Any] = [
            Parameter(.userID): self.userID,
            Parameter(.province): self.province,
            Parameter(.city): self.city
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UpdateAddress"
    }
}

class YCUserDetailRequest: YCBaseRequest {
    
    let userID: String;
    
    init(userID: String){
        self.userID = userID
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.userDetail.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic: [String: Any] = [
            Parameter(.userID): self.userID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UserDetail"
    }
}

class YCFollowUserRequest: YCBaseRequest {
    
    let userID: String;
    
    init(userID: String){
        self.userID = userID
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.followUser.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic: [String: Any] = [
            Parameter(.userID): self.userID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "FollowUser"
    }
}

class YCUnFollowUserRequest: YCBaseRequest {
    
    let userID: String;
    
    init(userID: String){
        self.userID = userID
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.unfollowUser.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic: [String: Any] = [
            Parameter(.userID): self.userID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "UnFollowUser"
    }
}

class YCBlockUserRequest: YCBaseRequest {
    
    let userID: String;
    
    init(userID: String){
        self.userID = userID
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.blockUser.description
        return urlPath
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic: [String: Any] = [
            Parameter(.userID): self.userID
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "BlockUser"
    }
}

class YCFollowingListRequest: YCListRequest {
    
    let userID: String;
    
    init(userID: String, start: Int, count: Int){
        self.userID = userID
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.followingList.description
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
        return "FollowingList"
    }
}

class YCFollowersListRequest: YCListRequest {
    
    let userID: String;
    
    init(userID: String, start: Int, count: Int){
        self.userID = userID
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.followersList.description
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
        return "FollowersList"
    }
}

class YCBlockListRequest: YCListRequest {
    
    let userID: String;
    
    init(userID: String, start: Int, count: Int){
        self.userID = userID
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.blockList.description
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
        return "BlockList"
    }
}

class YCThemeAuthorListRequest: YCListRequest {
    
    let themeID: String;
    
    init(themeID: String, start: Int, count: Int){
        self.themeID = themeID
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.themeAuthorList.description
        return urlPath
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
        return "ThemeAuthorList"
    }
}

class YCThemeFollowerListRequest: YCListRequest {
    
    let themeID: String;
    
    init(themeID: String, start: Int, count: Int){
        self.themeID = themeID
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.followThemeUserList.description
        return urlPath
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
        return "FollowThemeUserList"
    }
}

class YCBlockThemeUserListRequest: YCListRequest {
    
    let themeID: String;
    
    init(themeID: String, start: Int, count: Int){
        self.themeID = themeID
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.blockThemeUserList.description
        return urlPath
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
        return "BlockThemeUserList"
    }
}

class YCSearchUserListRequest: YCListRequest {
    
    let keyWord: String;
    
    init(keyWord: String, start: Int, count: Int){
        self.keyWord = keyWord
        super.init(start: start, count: count)
    }
    
    override func urlPath() -> String {
        let urlPath = UserRequestURL.searchUserList.description
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
        return "SearchUserList"
    }
}
