//
//  ImageModel.swift
//  YouCat
//
//  Created by ting on 2018/9/11.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON


class YCMediaModel: YCBaseModel{
    
    override func getData() -> [String: Any]{
        return [:]
    }
    
}

class YCImageModel: YCMediaModel {
    let imageID: String;
    let imagePath: String;
    let snapShotPath: String;
    let imageType: String;
    let imageIndex: Int;
    let imageWidth: Float;
    let imageHeight: Float;
    
    init(imageID: String, imagePath: String, snapShotPath: String, imageType: String, imageIndex: Int, imageWidth: Float, imageHeight: Float) {
        self.imageID = imageID;
        self.imagePath = imagePath;
        self.snapShotPath = snapShotPath;
        self.imageType = imageType;
        self.imageIndex = imageIndex;
        self.imageWidth = imageWidth;
        self.imageHeight = imageHeight;
    }
    
    convenience init(_ json: JSON) {
        let imageID:String      = json[Parameter(.imageID)].string ?? "";
        let imagePath:String    = json[Parameter(.imagePath)].string ?? "";
        let snapShotPath:String = json[Parameter(.snapShotPath)].string ?? "";
        let imageType:String    = json[Parameter(.imageType)].string ?? "";
        let imageIndex:Int      = json[Parameter(.imageIndex)].int ?? 0;
        let imageWidth:Float  = json[Parameter(.imageWidth)].float ?? 0;
        let imageHeight:Float = json[Parameter(.imageHeight)].float ?? 0;
        
        self.init(imageID: imageID, imagePath: imagePath, snapShotPath: snapShotPath, imageType: imageType, imageIndex: imageIndex, imageWidth: imageWidth, imageHeight: imageHeight)
    }
    
    override func getData() -> [String: Any]{
        return [
            Parameter(.imageID)  :self.imageID,
            Parameter(.imagePath):self.imagePath,
            Parameter(.snapShotPath):self.snapShotPath,
            Parameter(.imageType):self.imageType,
            Parameter(.imageIndex):self.imageIndex,
            Parameter(.imageWidth):self.imageWidth,
            Parameter(.imageHeight):self.imageHeight
        ]
    }
}

class YCVideoModel: YCMediaModel {
    
    let videoID: String;
    let videoPath: String;
    let videoURL: String;
    let videoCover: YCImageModel?
    let videoWidth: Float;
    let videoHeight: Float;
    let videoTime: String
    
    init(videoID: String, videoPath: String, videoURL: String, videoWidth: Float, videoHeight: Float, videoTime: String, videoCoverJSON: JSON?) {
        self.videoID = videoID;
        self.videoPath = videoPath;
        self.videoURL = videoURL;
        self.videoWidth = videoWidth;
        self.videoHeight = videoHeight;
        self.videoTime = videoTime;
        if videoCoverJSON != nil{
            if let s = videoCoverJSON!.rawString(), s != "", s != "null" {
                self.videoCover = YCImageModel(videoCoverJSON!)
            }else {
                self.videoCover = nil;
            }
        }else {
            self.videoCover = nil;
        }
    }
    
    convenience init(_ json: JSON){
        let videoID:String      = json[Parameter(.videoID)].string ?? "";
        let videoPath:String    = json[Parameter(.videoPath)].string ?? "";
        let videoURL:String     = json[Parameter(.videoURL)].string ?? "";
        let videoWidth:Float    = json[Parameter(.videoWidth)].float ?? 0;
        let videoHeight:Float   = json[Parameter(.videoHeight)].float ?? 0;
        let videoTime:String    = json[Parameter(.videoTime)].string ?? "";
        let videoCoverJSON      = json[Parameter(.videoCover)]
        
        self.init(videoID: videoID, videoPath: videoPath, videoURL: videoURL, videoWidth: videoWidth, videoHeight: videoHeight, videoTime: videoTime, videoCoverJSON: videoCoverJSON)
    }
    
    override func getData() -> [String: Any]{
        var parameterDic: [String: Any] = [
            Parameter(.videoID)   :self.videoID,
            Parameter(.videoPath) :self.videoPath,
            Parameter(.videoURL)  :self.videoURL,
            Parameter(.videoWidth)  :self.videoWidth,
            Parameter(.videoHeight)  :self.videoHeight,
            Parameter(.videoTime)  :self.videoTime
        ]
        if let cover = self.videoCover {
            parameterDic[Parameter(.videoCover)] = cover.getData();
        }
        return parameterDic
    }
}
