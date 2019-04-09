//
//  ShareProtocol.swift
//  YouCat
//
//  Created by ting on 2019/1/16.
//  Copyright © 2019年 Curios. All rights reserved.
//

import Foundation

enum YCShareType: String{
    case weChat = "weChat"
    case moments = "moments"
    case weibo = "weibo"
}

protocol YCShareProtocol {
    func shareText(_ text: String, to scene: YCShareType) -> Bool
    func shareImage(_ data: Data, url: String, title: String, description: String, thumbImage: UIImage?, to scene: YCShareType) -> Bool
//    func shareMusic()
//    func shareVideo()
    func shareURL(_ url: String, title: String, description: String, thumbImage: UIImage?, to scene: YCShareType) -> Bool
    func shareEmoticon(_ data: Data, thumbImage: UIImage?, title: String, description: String, to scene: YCShareType) -> Bool
}

extension YCShareProtocol {
    func shareText(_ text: String, to scene: YCShareType) -> Bool {
        if scene == .weChat || scene == .moments {
            if WXApi.isWXAppInstalled() {
                let req = SendMessageToWXReq()
                req.text = text
                req.bText = true
                switch scene {
                case .weChat:
                    req.scene = Int32(WXSceneSession.rawValue)
                case .moments:
                    req.scene = Int32(WXSceneTimeline.rawValue)
                default:
                    break
                }
                WXApi.send(req)
                return true
            }
        }else if scene == .weibo {
            if WeiboSDK.isWeiboAppInstalled() {
                let authReq = WBAuthorizeRequest()
                authReq.redirectURI = YCSocialConfigs.weibo.redirectURI
                authReq.scope = "all"
                
                let message = WBMessageObject()
                message.text = text
                let req: WBSendMessageToWeiboRequest = WBSendMessageToWeiboRequest.request(withMessage: message, authInfo: authReq, access_token: nil) as! WBSendMessageToWeiboRequest
                req.userInfo = ["info": "分享文本"] // 自定义的请求信息字典， 会在响应中原样返回
                req.shouldOpenWeiboAppInstallPageIfNotInstalled = false // 当未安装客户端时是否显示下载页
                WeiboSDK.send(req)
                return true
            }
        }
        return false
    }
    
    func shareImage(_ data: Data, url: String, title: String, description: String, thumbImage: UIImage?, to scene: YCShareType) -> Bool {
        if scene == .weChat || scene == .moments {
            if WXApi.isWXAppInstalled() {
                let message = WXMediaMessage()
                //            if let img = thumbImage {
                //                message.setThumbImage(img)
                //            }
                message.title = title
                message.description = description
                
                let obj = WXImageObject()
                obj.imageData = data
                message.mediaObject = obj
                
                let req = SendMessageToWXReq()
                req.bText = false
                req.message = message
                
                switch scene {
                case .weChat:
                    req.scene = Int32(WXSceneSession.rawValue)
                case .moments:
                    req.scene = Int32(WXSceneTimeline.rawValue)
                default:
                    break
                }
                WXApi.send(req)
                return true
            }
        }else{
            if WeiboSDK.isWeiboAppInstalled() {
                let authReq = WBAuthorizeRequest()
                authReq.redirectURI = YCSocialConfigs.weibo.redirectURI
                authReq.scope = "all"
                
                let message = WBMessageObject()
                message.text = title + " " + url
                
                let img = WBImageObject()
                img.imageData = data
                message.imageObject = img
                
                let req: WBSendMessageToWeiboRequest = WBSendMessageToWeiboRequest.request(withMessage: message, authInfo: authReq, access_token: nil) as! WBSendMessageToWeiboRequest
                req.userInfo = ["info": "分享图片"] // 自定义的请求信息字典， 会在响应中原样返回
                req.shouldOpenWeiboAppInstallPageIfNotInstalled = false // 当未安装客户端时是否显示下载页
                
                WeiboSDK.send(req)
                return true
            }
        }
        return false
    }
    
    func shareURL(_ url: String, title: String, description: String, thumbImage: UIImage?, to scene: YCShareType) -> Bool {
        if scene == .weChat || scene == .moments {
            if WXApi.isWXAppInstalled() {
                let message = WXMediaMessage()
                message.title = title
                message.description = description
                if let img = thumbImage {
                    message.setThumbImage(img)
                }
                
                let obj = WXWebpageObject()
                obj.webpageUrl = url
                message.mediaObject = obj
                
                let req = SendMessageToWXReq()
                req.bText = false
                req.message = message
                
                switch scene {
                case .weChat:
                    req.scene = Int32(WXSceneSession.rawValue)
                case .moments:
                    req.scene = Int32(WXSceneTimeline.rawValue)
                default:
                    break
                }
                WXApi.send(req)
                return true
            }
        }else if scene == .weibo {
            if WeiboSDK.isWeiboAppInstalled() {
                let authReq = WBAuthorizeRequest()
                authReq.redirectURI = YCSocialConfigs.weibo.redirectURI
                authReq.scope = "all"
                
                let message = WBMessageObject()
                message.text = ""
                
                let web = WBWebpageObject()
                web.objectID = "YouCat"
                web.title = title
                web.description = description
                if let img = thumbImage {
                    let image = compressMaxImage(img, maxW: 50, maxH: 50)
                    web.thumbnailData = image.jpegData(compressionQuality: 0.5)
                }
                
                web.webpageUrl = url
                message.mediaObject = web
                
                let req: WBSendMessageToWeiboRequest = WBSendMessageToWeiboRequest.request(withMessage: message, authInfo: authReq, access_token: nil) as! WBSendMessageToWeiboRequest
                req.userInfo = ["info": "分享链接"] // 自定义的请求信息字典， 会在响应中原样返回
                req.shouldOpenWeiboAppInstallPageIfNotInstalled = false // 当未安装客户端时是否显示下载页
                
                WeiboSDK.send(req)
                return true
            }
        }
        return false
    }
    
    func shareEmoticon(_ data: Data, thumbImage: UIImage?, title: String, description: String, to scene: YCShareType) -> Bool {
        if scene == .weChat, WXApi.isWXAppInstalled(){
            let message =  WXMediaMessage()
            if let img = thumbImage {
                message.setThumbImage(img)
            }
            message.title = title
            message.description = description
            
            let ext =  WXEmoticonObject()
            ext.emoticonData = data
            message.mediaObject = ext
            
            let req =  SendMessageToWXReq()
            req.bText = false
            req.message = message
            req.scene = Int32(WXSceneSession.rawValue)
            WXApi.send(req)
            return true
        }
        return false
    }
}

