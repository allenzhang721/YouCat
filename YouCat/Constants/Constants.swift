//
//  Constants.swift
//  YouCat
//
//  Created by ting on 2018/9/4.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import UIKit

func gotoSetting(title: String, mesage: String, view: UIViewController) {
    let alert = UIAlertController(title: title, message: mesage, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: YCLanguageHelper.getString(key: "SetLabel"), style: .destructive, handler: { (_) -> Void in
        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: { (ist) in
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }))
    alert.addAction(UIAlertAction(title: YCLanguageHelper.getString(key: "CancelLabel"), style: UIAlertAction.Style.cancel, handler: { (_) -> Void in
    }))
    view.present(alert, animated: true, completion: nil)
}

func Parameter(_ key: ParameterKey) -> String {
    return key.description
}

struct LocalManager {
    static let service = "com.botai.YouCat"
    static let loginAccount = "com.botai.YouCat.LoginAccount"
    static let uuid = "com.botai.YouCat.UUID"
    static let home = "com.botai.YouCat.Home"
    static let theme = "com.botai.YouCat.Theme"
}

struct FilePath {
    static var baseURL = ""
}

struct YCScreen {
    static var bounds = CGRect(x: 0, y: 0, width: 0, height: 0)
    static var safeArea = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    static var fullScreenArea = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
}

struct YCSocialConfigs {
    
    static let universalLink = "https://oia.youcat.cn"
    
    struct weibo {
        static let appKey = "1479783390"
        static let appSecret = "d0e3f55717550bb32938d5b6c19c86ff"
        static let redirectURI = "http://api.weibo.com/oauth2/default.html"
    }
    
    struct weChat {
        static let appID = "wx78fe2e04c0038988"
        static let appSecret = "180e29ab108f3c0b13dde83e02c9d1b3"
    }
    
    struct SMS {
        static let appID = "3be50064be3b1dfa024b327c9be3eae9"
        static let appKey = "10a95e4bb9b32"
    }
}

enum RequestHost: CustomStringConvertible {
    case debug, production
    
    var description: String {
        switch self {
        case .debug:
            return "http://192.168.50.129:9909"
        case .production:
            return "https://www.youcat.cn"
        }
    }
}

enum PublishRequestURL: CustomStringConvertible {
    case removePublish, updatePublish, publishList, unCheckPublishList
    case topPublishList, userPublishList, themePublishList, publishMoreList
    case userLikePublishList, userFollowPublishList, tagPublishList
    case searchPublishList, searchUserPublishList, searchThemePublishList, searchTagPublishList
    case activePublish, inActivePublish, retryCrawlPublish
    case publishDetail, publishDetailByUUID
    var description: String {
        switch self {
        case .removePublish:
            return "/publish/removePublish"
        case .updatePublish:
            return "/publish/updatePublish"
        case .publishList:
            return "/publish/publishList"
        case .unCheckPublishList:
            return "/publish/unCheckPublishList"
        case .topPublishList:
            return "/publish/topPublishList"
        case .userPublishList:
            return "/publish/userPublishList"
        case .themePublishList:
            return "/publish/themePublishList"
        case .publishMoreList:
            return "/publish/publishMoreList"
        case .userLikePublishList:
            return "/publish/userLikePublishList"
        case .userFollowPublishList:
            return "/publish/userFollowPublishList"
        case .tagPublishList:
            return "/publish/tagPublishList"
        case .searchPublishList:
            return "/publish/searchPublishList"
        case .searchUserPublishList:
            return "/publish/searchUserPublishList"
        case .searchThemePublishList:
            return "/publish/searchThemePublishList"
        case .searchTagPublishList:
            return "/publish/searchTagPublishList"
        case .publishDetail:
            return "/publish/publishDetail"
        case .publishDetailByUUID:
            return "/publish/publishDetailByUUID"
        default:
            return ""
        }
    }
}

enum UserRequestURL: CustomStringConvertible {
    case setManager
    case loginByPassword, loginByPhone, loginByWeibo, loginByWeChat
    case updatePassword, updateUniqueID, updateUserInfo, updateNikeName, updateSign, updateGender, updateBirthday, updateIcon, updateAddress
    case userDetail, userDetailByUUID
    case followUser, unfollowUser, blockUser
    case followingList, followersList, blockList, themeAuthorList, followThemeUserList, blockThemeUserList
    case searchUserList
    var description: String {
        switch self {
        case .loginByPassword:
            return "/user/loginByPassword"
        case .loginByPhone:
            return "/user/loginByPhone"
        case .loginByWeibo:
            return "/user/loginByWeibo"
        case .loginByWeChat:
            return "/user/loginByWeChat"
        case .updatePassword:
            return "/user/updatePassword"
        case .updateUniqueID:
            return "/user/updateUniqueID"
        case .updateUserInfo:
            return "/user/updateUserInfo"
        case .updateNikeName:
            return "/user/updateNikeName"
        case .updateSign:
            return "/user/updateSign"
        case .updateGender:
            return "/user/updateGender"
        case .updateBirthday:
            return "/user/updateBirthday"
        case .updateIcon:
            return "/user/updateIcon"
        case .updateAddress:
            return "/user/updateAddress"
        case .userDetail:
            return "/user/userDetail"
        case .userDetailByUUID:
            return "/user/userDetailByUUID"
        case .followUser:
            return "/user/followUser"
        case .unfollowUser:
            return "/user/unfollowUser"
        case .blockUser:
            return "/user/blockUser"
        case .followingList:
            return "/user/followingList"
        case .followersList:
            return "/user/followersList"
        case .blockList:
            return "/user/blockList"
        case .themeAuthorList:
            return "/user/themeAuthorList"
        case .followThemeUserList:
            return "/user/followThemeUserList"
        case .blockThemeUserList:
            return "/user/blockThemeUserList"
        case .searchUserList:
            return "/user/searchUserList"
        default:
            return ""
        }
    }
}

enum ThemeRequestURL: CustomStringConvertible {
    case addTheme, updateTheme, removeTheme, themeDetail, themeDetailByUUID
    case tradeThemeCreator, addThemeAuthor, removeThemeAuthor
    case themeList, topThemeList, followThemeList, blockThemeList, publishThemeList, searchThemeList
    case addPublishToTheme, removeThemePublish
    case followTheme, unFollowTheme, blockTheme
    var description: String {
        switch self {
        case .addTheme:
            return "/theme/addTheme"
        case .updateTheme:
            return "/theme/updateTheme"
        case .removeTheme:
            return "/theme/removeTheme"
        case .themeDetail:
            return "/theme/themeDetail"
        case .themeDetailByUUID:
            return "/theme/themeDetailByUUID"
        case .themeList:
            return "/theme/themeList"
        case .topThemeList:
            return "/theme/topThemeList"
        case .followThemeList:
            return "/theme/followThemeList"
        case .blockThemeList:
            return "/theme/blockThemeList"
        case .publishThemeList:
            return "/theme/publishThemeList"
        case .searchThemeList:
            return "/theme/searchThemeList"
        case .addPublishToTheme:
            return "/theme/addPublishToTheme"
        case .removeThemePublish:
            return "/theme/removeThemePublish"
        case .followTheme:
            return "/theme/followTheme"
        case .unFollowTheme:
            return "/theme/unFollowTheme"
        case .blockTheme:
            return "/theme/blockTheme"
        default:
            return ""
        }
    }
}

enum LikeRequestURL: CustomStringConvertible {
    case likePublish, unLikePublish, likeUser, unLikeUser, likeTheme, unLikeTheme, likeComment, unLikeComment
    case publishLikeList, userLikeList, themeLikeList, commentLikeList
    var description: String {
        switch self {
        case .likePublish:
            return "/like/likePublish"
        case .unLikePublish:
            return "/like/unLikePublish"
        case .likeUser:
            return "/like/likeUser"
        case .unLikeUser:
            return "/like/unLikeUser"
        case .likeTheme:
            return "/like/likeTheme"
        case .unLikeTheme:
            return "/like/unLikeTheme"
        case .likeComment:
            return "/like/likeComment"
        case .unLikeComment:
            return "/like/unLikeComment"
        case .publishLikeList:
            return "/like/publishLikeList"
        case .userLikeList:
            return "/like/userLikeList"
        case .themeLikeList:
            return "/like/themeLikeList"
        case .commentLikeList:
            return "/like/commentLikeList"
        }
    }
}

enum CommentRequestURL: CustomStringConvertible {
    case commentPublish, commentTheme, replyComment
    case publishCommentList, themeCommentList, replyList, removeComment
    var description: String {
        switch self {
        case .commentPublish:
            return "/comment/commentPublish"
        case .commentTheme:
            return "/comment/commentTheme"
        case .replyComment:
            return "/comment/replyComment"
        case .publishCommentList:
            return "/comment/publishCommentList"
        case .themeCommentList:
            return "/comment/themeCommentList"
        case .replyList:
            return "/comment/replyList"
        case .removeComment:
            return "/comment/removeComment"
        }
    }
}

enum RequestURL: CustomStringConvertible {
    case sharePublish, shareUser, shareTheme, shareImage, shareVideo
    case reportPublish, reportUser, reportTheme, reportComment, updateReportStatus, ReportList
    case focusPublish, focusUser, focusTheme
    case tokenList
    var description: String {
        switch self {
        case .sharePublish:
            return "/share/sharePublish"
        case .shareUser:
            return "/share/shareUser"
        case .shareTheme:
            return "/share/shareTheme"
        case .shareImage:
            return "/share/shareImage"
        case .shareVideo:
            return "/share/shareVideo"
        case .reportPublish:
            return "/report/reportPublish"
        case .reportUser:
            return "/report/reportUser"
        case .reportTheme:
            return "/report/reportTheme"
        case .reportComment:
            return "/report/reportComment"
        case .focusPublish:
            return "/focus/focusPublish"
        case .focusUser:
            return "/focus/focusUser"
        case .focusTheme:
            return "/focus/focusTheme"
        case .tokenList:
            return "/upload/tokenList"
        default:
            return ""
        }
    }
}

enum ShareURL: CustomStringConvertible {
    case publish, user, theme
    var description: String {
        let baseUrl = FilePath.baseURL;
        switch self {
        case .publish:
            return baseUrl+"/share/publish"
        case .user:
            return baseUrl+"/share/user"
        case .theme:
            return baseUrl+"/share/theme"
        }
    }
}

enum ParameterKey: CustomStringConvertible{
    
    case data, code, status, start, count, total, model, list, loginUserID, deviceID, deviceType, deviceModel, deviceVersion, deviceSystem, systemVersion, softVersion, softLanguage
    case imageID, imagePath, snapShotPath, imageType, imageIndex, imageWidth, imageHeight
    case videoID, videoPath, videoURL, videoCover, videoDynamic, videoWidth, videoHeight, videoTime
    case dynamicID, dynamicStartTime, dynamicDuration, dynamicPath, dynamicWidth, dynamicHeight, dynamicType, dynamicIndex
    case userID, uuid, uniqueID, nikeName, signature, gender, birthday, province, city, icon, relation
    case areaCode, phone, active, setPassword, weiboUser, password, newPassword
    case followersCount, followingCount
    case publishID, content, contentType, fromType, fromID, fromURL, publishDate, user, medias, tags, publishType
    case themeID, creator, name, description, coverImage, coverVideo, themeType, styleType, publishCount, createDate
    case tagID, tagName
    case likeID, beLikedID, beLikedType, likeDate
    case commentID, beRepliedUser, beCommentedID, beCommentedType, beRepliedID, commentType, commentDate, replyCount, listCount, replyList, contentImages
    case modelID, likeCount, commentCount, shareCount, isLike, platform, shareType
    case weiboUserID, weiboID, weiboNikeName, weiboSignature, weiboGender, weiboURL, weiboIcon, tweetCount, followCount, fansCount
    case wechatUserID, wechatOpenID, wechatUnionID, wechatNikeName, wechatGender, wechatProvince, wechatCity, wechatCountry, wechatIcon
    case keyWord, type, reportType
    case focusLevel, startDate, endDate
    case token, tokenKey, tokens
    
    
    var description: String {
        switch self {
        case .data:
            return "Data"
        case .code:
            return "Code"
        case .status:
            return "Status"
        case .start:
            return "Start"
        case .count:
            return "Count"
        case .total:
            return "Total"
        case .model:
            return "Model"
        case .list:
            return "List"
        case .loginUserID:
            return "LoginUserID"
        case .deviceID:
            return "DeviceID"
        case .deviceType:
            return "DeviceType"
        case .deviceModel:
            return "DeviceModel"
        case .deviceVersion:
            return "DeviceVersion"
        case .deviceSystem:
            return "DeviceSystem"
        case .systemVersion:
            return "SystemVersion"
        case .softVersion:
            return "SoftVersion"
        case .softLanguage:
            return "SoftLanguage"
        case .imageID:
            return "ImageID"
        case .imagePath:
            return "ImagePath"
        case .snapShotPath:
            return "SnapShotPath"
        case .imageType:
            return "ImageType"
        case .imageIndex:
            return "ImageIndex"
        case .imageWidth:
            return "ImageWidth"
        case .imageHeight:
            return "ImageHeight"
        case .videoID:
            return "VideoID"
        case .videoPath:
            return "VideoPath"
        case .videoURL:
            return "VideoURL"
        case .videoCover:
            return "VideoCover"
        case .videoDynamic:
            return "VideoDynamic"
        case .videoWidth:
            return "VideoWidth"
        case .videoHeight:
            return "VideoHeight"
        case .videoTime:
            return "VideoTime"
        case .dynamicID:
            return "DynamicID"
        case .dynamicStartTime:
            return "DynamicStartTime"
        case .dynamicDuration:
            return "DynamicDuration"
        case .dynamicPath:
            return "DynamicPath"
        case .dynamicType:
            return "DynamicType"
        case .dynamicIndex:
            return "DynamicIndex"
        case .dynamicWidth:
            return "DynamicWidth"
        case .dynamicHeight:
            return "DynamicHeight"
        case .userID:
            return "UserID"
        case .uuid:
            return "UUID"
        case .uniqueID:
            return "UniqueID"
        case .nikeName:
            return "NikeName"
        case .signature:
            return "Signature"
        case .gender:
            return "Gender"
        case .birthday:
             return "Birthday"
        case .province:
            return "Province"
        case .city:
            return "City"
        case .icon:
            return "Icon"
        case .relation:
            return "Relation"
        case .areaCode:
            return "AreaCode"
        case .phone:
            return "Phone"
        case .active:
            return "Active"
        case .setPassword:
            return "SetPassword"
        case .password:
            return "Password"
        case .newPassword:
            return "NewPassword"
        case .weiboUser:
            return "WeiboUser"
        case .followersCount:
            return "FollowersCount"
        case .followingCount:
            return "FollowingCount"
        case .likeCount:
            return "LikeCount"
        case .publishID:
            return "PublishID"
        case .content:
            return "Content"
        case .contentType:
            return "ContentType"
        case .fromID:
            return "FromID"
        case .fromType:
            return "FromType"
        case .fromURL:
            return "FromURL"
        case .commentCount:
            return "CommentCount"
        case .shareCount:
            return "ShareCount"
        case .publishDate:
            return "PublishDate"
        case .isLike:
            return "IsLike"
        case .user:
            return "User"
        case .medias:
            return "Medias"
        case .publishType:
            return "PublishType"
        case .tags:
            return "Tags"
        case .tagID:
            return "TagID"
        case .tagName:
            return "TagName"
        case .themeID:
            return "ThemeID"
        case .creator:
            return "Creator"
        case .name:
            return "Name"
        case .description:
            return "Description"
        case .coverImage:
            return "CoverImage"
        case .coverVideo:
            return "CoverVideo"
        case .themeType:
            return "ThemeType"
        case .styleType:
            return "StyleType"
        case .publishCount:
            return "PublishCount"
        case .createDate:
            return "CreateDate"
        case .likeID:
            return "LikeID"
        case .beLikedID:
            return "BeLikedID"
        case .beLikedType:
            return "BeLikedType"
        case .likeDate:
            return "LikeDate"
        case .commentID:
            return "CommentID"
        case .beRepliedUser:
            return "BeRepliedUser"
        case .beCommentedID:
            return "BeCommentedID"
        case .beCommentedType:
            return "BeCommentedType"
        case .beRepliedID:
            return "BeRepliedID"
        case .commentType:
            return "CommentType"
        case .contentImages:
            return "ContentImages"
        case .commentDate:
            return "CommentDate"
        case .replyCount:
            return "ReplyCount"
        case .listCount:
            return "ListCount"
        case .replyList:
            return "ReplyList"
        case .weiboUserID:
            return "WeiboUserID"
        case .weiboID:
            return "WeiboID"
        case .weiboNikeName:
            return "WeiboNikeName"
        case .weiboSignature:
            return "WeiboSignature"
        case .weiboGender:
            return "WeiboGender"
        case .weiboIcon:
            return "WeiboIcon"
        case .weiboURL:
            return "WeiboURL"
        case .tweetCount:
            return "TweetCount"
        case .followCount:
            return "FollowCount"
        case .fansCount:
            return "FansCount"
        case .wechatUserID:
            return "WechatUserID"
        case .wechatOpenID:
            return "WechatOpenID"
        case .wechatUnionID:
            return "WechatUnionID"
        case .wechatNikeName:
            return "WechatNikeName"
        case .wechatGender:
            return "WechatGender"
        case .wechatIcon:
            return "WechatIcon"
        case .wechatCountry:
            return "WechatCountry"
        case .wechatProvince:
            return "WechatProvince"
        case .wechatCity:
            return "WechatCity"
            
        case .keyWord:
            return "KeyWord"
        case .type:
            return "Type"
        case .reportType:
            return "ReportType"
        case .platform:
            return "Platform"
        case .shareType:
            return "ShareType"
        case .focusLevel:
            return "FocusLevel"
        case .startDate:
            return "StartDate"
        case .endDate:
            return "EndDate"
        case .token:
            return "Token"
        case .tokenKey:
            return "TokenKey"
        case .tokens:
            return "Tokens"
//        default:
//            return ""
        case .modelID:
            return ""
        }
    }
}

enum YCResultStatus{
    static let success = 0
    static let failure = 1
}

func CodeMessage(code:String?) -> String {
    guard let s = code else {
        return ""
    }
    switch s {
    case "-001":
        return "未知错误，请联系我们!";
    case "000":
        return "网络链接失败，请稍后再试!";
    case "001":
        return "data为空";
    case "002":
        return "data格式不正确";
    case "003":
        return "设备信息不全";
    case "110":
        return "获取内容信息失败";
    case "111":
        return "获取微博内容信息失败";
    case "119":
        return "获取内容总数信息失败";
    case "120":
        return "更新内容失败";
    case "130":
        return "删除内容失败";
    case "131":
        return "内容ID不能为空";
    case "132":
        return "内容不存在";
    case "133":
        return "激活内容失败";
    case "134":
        return "反激活内容失败";
    case "135":
        return "设置内容重新抓取失败";
    case "200":
        return "注册用户失败";
    case "201":
        return "注册用户失败，请联系我们";
    case "210":
        return "获取用户信息失败";
    case "211":
        return "获取用户信息失败";
    case "219":
        return "获取用户信息失败";
    case "220":
        return "更新用户信息失败";
    case "221":
        return "更新用户信息失败";
    case "231":
        return "更新密码失败"
    case "232":
        return "更新喵萌号失败"
    case "233":
        return "更新用户资料错误"
    case "234":
        return "更新昵称失败"
    case "235":
        return "更新个性签名失败"
    case "236":
        return "关注失败，请稍后再试"
    case "237":
        return "取消关注失败，请稍后再试"
    case "238":
        return "拉黑失败，请稍后再试"
    case "241":
        return "密码错误，请确认后重新输入"
    case "242":
        return "喵萌号已被占用"
    case "252":
        return "用户不存在"
    case "253":
        return "抱歉，你的权限不足"
    case "261":
        return "用户ID不能为空"
    case "262":
        return "手机号不能为空"
    case "263":
        return "密码不能为空"
    case "264":
        return "新密码不能为空"
    case "265":
        return "喵萌号不能为空"
        
    case "300":
        return "添加主题失败"
    case "301":
        return "获取主题信息失败"
    case "302":
        return "更新主题失败"
    case "303":
        return "删除主题失败"
    case "311":
        return "主题ID不能为空"
    case "312":
        return "主题不存在"
    case "316":
        return "将内容添加到主题失败"
    case "317":
        return "从主题中删除内容失败"
    case "318":
        return "关注失败，请稍后再试"
    case "319":
        return "取消关注失败，请稍后再试"
    case "320":
        return "拉黑失败，请稍后再试"
    case "321":
        return "不能添加非主题作者创作内容到原创主题"
    
    case "400":
        return "添加用户关系失败"
    case "401":
        return "获取用户关系失败"
    case "402":
        return "更新用户关系失败"
    case "403":
        return "改变用户关系失败"
    case "404":
        return "无法改变同一个用户的关系"
        
    case "410":
        return "添加用户主题关系失败"
    case "411":
        return "获取用户主题关系失败"
    case "412":
        return "更新用户主题关系失败"
    case "413":
        return "改变用户主题关系失败"
        
    case "420":
        return "添加主题内容关系失败"
    case "421":
        return "获取主题内容关系失败"
    case "422":
        return "更新主题内容关系失败"
    case "433":
        return "改变主题内容关系失败"
        
    case "450":
        return "添加图片失败"
    case "451":
        return "获取图片信息失败"
    case "452":
        return "更新图片信息失败"
        
    case "460":
        return "添加视频失败"
    case "461":
        return "获取视频信息失败"
    case "462":
        return "更新视频信息失败"
        
    case "500":
        return "点赞失败"
    case "501":
        return "查询点赞失败"
    case "502":
        return "更新点赞失败"
    case "509":
        return "查询点赞数失败"
    case "511":
        return "点赞失败"
    case "512":
        return "取消点赞失败"
    case "513":
        return "点赞失败"
    case "514":
        return "取消点赞失败"
    case "515":
        return "点赞失败"
    case "516":
        return "取消点赞失败"
    case "517":
        return "点赞失败"
    case "518":
        return "取消点赞失败"
        
    case "550":
        return "分享失败"
    case "551":
        return "查询分享失败"
    case "552":
        return "更新分享失败"
    case "559":
        return "查询分享数失败"
        
    case "570":
        return "插入停留时间失败"
    case "571":
        return "查询停留时间失败"
    case "572":
        return "更新停留时间失败"
    case "573":
        return "时间格式不正确"
        
    case "600":
        return "评论失败"
    case "601":
        return "查询评论失败"
    case "602":
        return "更新评论失败"
    case "603":
        return "删除评论失败"
    case "608":
        return "查询评论数失败"
    case "609":
        return "查询回复数失败"
    case "611":
        return "评论ID不能为空"
    case "612":
        return "评论不存在"
    default:
        return "";
    }
}

enum Validate {
    case email(_: String)
    case phoneNum(_: String)
    case carNum(_: String)
    case username(_: String)
    case password(_: String)
    case nickname(_: String)
    
    case URL(_: String)
    case IP(_: String)
    
    
    var isRight: Bool {
        var predicateStr:String!
        var currObject:String!
        switch self {
        case let .email(str):
            predicateStr = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
            currObject = str
        case let .phoneNum(str):
            predicateStr = "^((13[0-9])|(15[0,0-9])|(17[0,0-9])|(18[0,0-9]))\\d{8}$"
            currObject = str
        case let .carNum(str):
            predicateStr = "^[A-Za-z]{1}[A-Za-z_0-9]{5}$"
            currObject = str
        case let .username(str):
            predicateStr = "^[A-Za-z0-9]{6,20}+$"
            currObject = str
        case let .password(str):
            predicateStr = "^[a-zA-Z0-9]{6,20}+$"
            currObject = str
        case let .nickname(str):
            predicateStr = "^[\\u4e00-\\u9fa5]{4,8}$"
            currObject = str
        case let .URL(str):
            predicateStr = "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
            currObject = str
        case let .IP(str):
            predicateStr = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
            currObject = str
        }
        
        let predicate =  NSPredicate(format: "SELF MATCHES %@" ,predicateStr)
        return predicate.evaluate(with: currObject)
    }
}

class YCIDGenerator {
    
    class func generateID() -> String {
        let id = UUID().uuidString.split(separator: "-").map{String($0)}.reduce("") {$0 + $1}
        return id.lowercased()
    }
}


