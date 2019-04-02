//
//  UploadController.swift
//  YouCat
//
//  Created by ting on 2018/12/3.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import Qiniu

class YCUploadController {
    
    init(){
        self.uploadArray = [];
        do {
            let file:QNFileRecorder = try QNFileRecorder(folder: NSTemporaryDirectory() + "YouCat")
            self.uploadManager = QNUploadManager.init(recorder: file)
        } catch {
            self.uploadManager = QNUploadManager()
        }
    }
    
    static var _instance:YCUploadController?;
    
    var delegate:YCUploadProtocol?;
    
    var uploadArray:Array<YCUploadModel>;
    
    let uploadManager:QNUploadManager;
    
    static func getInstance() -> YCUploadController{
        if _instance == nil {
            _instance = YCUploadController();
        }
        return _instance!;
    }
    
    func uploadFile(_ uploadModel:YCUploadModel) {
        if !checkUploadModel(uploadModel) {
            self.uploadArray.append(uploadModel)
        }
        self.uploadAction(uploadModel.uploadID);
    }
    
    func uploadFileArray(_ uploadModelArray:Array<YCUploadModel>){
        if uploadModelArray.count > 0{
            for i in 0..<uploadModelArray.count {
                let uploadModel = uploadModelArray[i]
                if !checkUploadModel(uploadModel) {
                    self.uploadArray.append(uploadModel)
                }
            }
            let uploadModel:YCUploadModel = uploadModelArray[0]
            self.uploadAction(uploadModel.uploadID);
        }
    }
    
    func getUnUploadModel(_ uploadID:String = "") -> YCUploadModel?{
        var uploadModel:YCUploadModel?
        for i in 0..<self.uploadArray.count {
            let oldModel:YCUploadModel = self.uploadArray[i]
            if !oldModel.isUploading{
                if uploadID != "" {
                    if(oldModel.uploadID == uploadID){
                        uploadModel = oldModel
                        break;
                    }
                }else {
                    uploadModel = oldModel
                    break;
                }
            }
        }
        return uploadModel
    }
    
    func uploadAction(_ uploadID:String){
        if self.getUploadingCount() < 4{
            var uploadModel:YCUploadModel? = self.getUnUploadModel(uploadID);
            if uploadModel == nil{
                uploadModel = self.getUnUploadModel();
            }
            if let uploadModel = uploadModel {
                self.uploadStart(uploadModel.key)
                
                DispatchQueue.global(qos: .default).async {
                    let option = QNUploadOption(mime: nil, progressHandler: { (fileKey, progress) -> Void in
                        YCUploadController.getInstance().uploadProgress(fileKey!, progress: progress)
                    }, params: nil, checkCrc: true, cancellationSignal: nil)
                    var ainfo: QNResponseInfo!
                    var afileKey: String!
                    var aresponse:  [AnyHashable: Any]?
                    if uploadModel.isUploadData {
                        self.uploadManager.put(uploadModel.fileData, key: uploadModel.key, token: uploadModel.token, complete: { (info, fileKey, response) -> Void in
                            ainfo = info
                            afileKey = fileKey
                            aresponse = response
            
                            DispatchQueue.main.async {
                                self.uploadCompleted(ainfo, filekey: afileKey, response: aresponse)
                            }
                        }, option: option)
                    }else {
                        self.uploadManager.putFile(uploadModel.filePath, key: uploadModel.key, token: uploadModel.token, complete: { (info, fileKey, response) -> Void in
                            ainfo = info
                            afileKey = fileKey
                            aresponse = response
                            
                            DispatchQueue.main.async {
                                self.uploadCompleted(ainfo, filekey: afileKey, response: aresponse)
                            }
                        }, option: option)
                    }
                }
            }
        }
    }
    
    func uploadStart(_ fileKey:String){
        let uploadModel = self.getUploadModelByKey(fileKey)
        if uploadModel != nil {
            uploadModel!.isUploading = true
            if let delegate = self.delegate {
                delegate.uploadStart(uploadModel!)
            }
        }
    }
    
    func uploadProgress(_ fileKey:String, progress:Float){
        let uploadModel = self.getUploadModelByKey(fileKey)
        if uploadModel != nil {
            if let delegate = self.delegate {
                delegate.uploadProgress(uploadModel!, progress: progress)
            }
        }
    }
    
    func uploadCompleted(_ info: QNResponseInfo!, filekey: String!, response: [AnyHashable: Any]?) {
        let uploadModel = self.getUploadModelByKey(filekey)
        if uploadModel != nil {
            uploadModel!.isUploading = false
            let isUploadOk = info.isOK && response != nil
            if isUploadOk {
                uploadModel!.uploadComplete = true
                if let delegate = self.delegate {
                    delegate.uploadComplete(uploadModel!)
                }
                self.uploadModelComplete(uploadModel!)
            } else {
                uploadModel!.uploadComplete = false
                if let delegate = self.delegate {
                    delegate.uploadError(uploadModel!, error: nil)
                }
            }
        }
    }
    
    func uploadModelComplete(_ uploadModel:YCUploadModel) {
        var index:Int = -1
        for i in 0..<self.uploadArray.count {
            let oldModel:YCUploadModel = self.uploadArray[i];
            if oldModel.key == uploadModel.key {
                index = i;
            }
        }
        if index != -1{
            self.uploadArray.remove(at: index)
        }
        if self.uploadArray.count == 0{
            self.delegate = nil;
        }else {
            self.uploadAction(uploadModel.uploadID);
        }
    }
    
    func checkUploadModel(_ uploadModel:YCUploadModel) -> Bool{
        for i in 0..<self.uploadArray.count {
            let oldModel:YCUploadModel = self.uploadArray[i];
            if oldModel.key == uploadModel.key {
                return true
            }
        }
        return false
    }
    
    func getUploadModelByKey(_ fileKey:String) -> YCUploadModel? {
        var uploadModel:YCUploadModel?;
        for i in 0..<self.uploadArray.count {
            let oldModel:YCUploadModel = self.uploadArray[i]
            if oldModel.key == fileKey {
                uploadModel = oldModel
                break
            }
        }
        return uploadModel
    }
    
    func getUploadingCount() -> Int {
        var count:Int = 0
        for i in 0..<self.uploadArray.count {
            let oldModel:YCUploadModel = self.uploadArray[i]
            if oldModel.isUploading {
                count+=1
            }
        }
        return count;
    }
}

