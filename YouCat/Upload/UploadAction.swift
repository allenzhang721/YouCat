//
//  UploadAction.swift
//  YouCat
//
//  Created by ting on 2018/12/3.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation

protocol YCUploadProtocol{
    func uploadStart(_ uploadModel:YCUploadModel)
    func uploadProgress(_ uploadModel:YCUploadModel, progress:Float)
    func uploadComplete(_ uploadModel:YCUploadModel)
    func uploadError(_ uploadModel:YCUploadModel, error:Error?)
}

class YCUploadAction: YCUploadProtocol {
    
    var uploadQueue:Array<YCUploadActionModel>
    
    init(){
        uploadQueue = []
    }
    
    static var _instance:YCUploadAction?;
    
    static func getInstance() -> YCUploadAction{
        if _instance == nil {
            _instance = YCUploadAction();
        }
        return _instance!;
    }
    
    func uploadStart(_ uploadModel:YCUploadModel){
        
    }
    
    func uploadProgress(_ uploadModel:YCUploadModel, progress:Float){
        uploadModel.uploadProgress = progress;
        self.uploadActionProgress(uploadModel)
    }
    
    func uploadComplete(_ uploadModel:YCUploadModel){
        uploadModel.uploadProgress = 1;
        uploadModel.uploadComplete = true
        self.uploadActionComplete(uploadModel)
    }
    
    func uploadError(_ uploadModel:YCUploadModel, error:Error?){
        uploadModel.uploadComplete = false
        self.uploadActionError(uploadModel, error: error)
    }
    
    func uploadActionProgress(_ uploadModel: YCUploadModel) {
        let uploadActionModel:YCUploadActionModel? = self.getUploadActionModel(uploadModel)
        if uploadActionModel != nil {
            self.progressAction(uploadActionModel!)
        }
    }
    
    func uploadActionComplete(_ uploadModel: YCUploadModel){
        let uploadActionModel:YCUploadActionModel? = self.getUploadActionModel(uploadModel)
        if uploadActionModel != nil {
            if self.checkPublishUploadComplete(uploadActionModel!) {
                self.completeAction(uploadActionModel!, uploadInfo: YCUploadInfo.init(result: true, uploadID: uploadActionModel!.uploadID))
            } else {
                self.progressAction(uploadActionModel!)
            }
        }
    }
    
    func uploadActionError(_ uploadModel: YCUploadModel, error: Error?){
        let uploadActionModel:YCUploadActionModel? = self.getUploadActionModel(uploadModel)
        if uploadActionModel != nil {
            self.completeAction(uploadActionModel!, uploadInfo: YCUploadInfo.init(result: false, uploadID:uploadActionModel!.uploadID , errorType: error))
        }
    }
    
    func completeAction(_ uploadActionModel:YCUploadActionModel, uploadInfo:YCUploadInfo) {
        uploadActionModel.complete(uploadInfo)
        var index:Int = -1
        for i in 0..<self.uploadQueue.count {
            let oldModel:YCUploadActionModel = self.uploadQueue[i];
            if oldModel.uploadID == uploadActionModel.uploadID {
                index = i;
                break;
            }
        }
        if index != -1{
            self.uploadQueue.remove(at: index)
        }
    }
    
    func progressAction(_ publishUploadModel:YCUploadActionModel) {
        let uploadArray = publishUploadModel.uploadArray
        let count:Int = uploadArray.count
        let rate:Float = 1/Float(count);
        var progress:Float = 0.0;
        for i in 0..<count {
            let model:YCUploadModel = uploadArray[i]
            progress = progress + model.uploadProgress * rate
        }
        publishUploadModel.progress(YCUploadProgressInfo.init(uploadID: publishUploadModel.uploadID, progress: progress))
    }
    
    func getUploadActionModel(_ uploadModel: YCUploadModel) -> YCUploadActionModel?{
        for i in 0..<self.uploadQueue.count {
            let uploadActionModel:YCUploadActionModel = self.uploadQueue[i]
            let uploadArray = uploadActionModel.uploadArray
            for j in 0..<uploadArray.count {
                let model:YCUploadModel = uploadArray[j]
                if(model.key == uploadModel.key){
                    return uploadActionModel
                }
            }
        }
        return nil
    }
    
    func checkPublishUploadComplete(_ uploadActionModel:YCUploadActionModel) -> Bool {
        let uploadArray = uploadActionModel.uploadArray
        for i in 0..<uploadArray.count {
            let model:YCUploadModel = uploadArray[i]
            if(!model.uploadComplete){
                return false
            }
        }
        return true
    }
    
    /**
     User to upload
     
     - parameter uploadID:       publishID
     - parameter uploadArray:    uploadArray description
     - parameter progressHandle:
     - parameter completeHandle:
     */
    func uploadFileArray(_ uploadID:String, uploadArray:Array<YCUploadModel>, progress progressHandle:@escaping (YCUploadProgressInfo?) -> Void, complete completeHandle:@escaping (YCUploadInfo?) -> Void){
        for i in 0..<uploadArray.count {
            let uploadMode:YCUploadModel = uploadArray[i]
            uploadMode.uploadID = uploadID
        }
        self.uploadQueue.append(YCUploadActionModel.init(uploadID: uploadID, uploadArray: uploadArray, progress: progressHandle, complete: completeHandle))
        YCUploadController.getInstance().delegate = self
        YCUploadController.getInstance().uploadFileArray(uploadArray)
    }
    
    func uploadFile(_ uploadID:String, uploadModel:YCUploadModel, progress progressHandle:@escaping (YCUploadProgressInfo?) -> Void, complete completeHandle:@escaping (YCUploadInfo?) -> Void){
        
        uploadModel.uploadID = uploadID
        var uploadArray:Array<YCUploadModel> = []
        uploadArray.append(uploadModel)
        self.uploadQueue.append(YCUploadActionModel.init(uploadID: uploadID, uploadArray: uploadArray, progress: progressHandle, complete: completeHandle))
        YCUploadController.getInstance().delegate = self
        YCUploadController.getInstance().uploadFile(uploadModel)
    }
}

class YCUploadInfo {
    
    let result:Bool
    let uploadID:String
    var errorType:Error?
    var data:AnyObject?
    
    init(result:Bool, uploadID:String, errorType:Error? = nil, data:AnyObject? = nil){
        self.result    = result
        self.uploadID  = uploadID
        self.errorType = errorType
        self.data      = data
    }
}

class YCUploadProgressInfo {
    let uploadID:String
    let progress:Float
    
    init(uploadID:String, progress:Float){
        self.uploadID = uploadID
        self.progress = progress
    }
}

class YCUploadActionModel {
    let uploadID:String
    let uploadArray:Array<YCUploadModel>
    let progress: (YCUploadProgressInfo?) -> Void
    let complete: (YCUploadInfo?) -> Void
    
    init(uploadID:String, uploadArray:Array<YCUploadModel>, progress:@escaping (YCUploadProgressInfo?) -> Void, complete:@escaping (YCUploadInfo?) -> Void){
        self.uploadID    = uploadID;
        self.uploadArray = uploadArray;
        self.progress    = progress;
        self.complete    = complete;
    }
}
