//
//  UploadDomain.swift
//  YouCat
//
//  Created by ting on 2018/12/3.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON

class YCUploadDomain: YCBaseDomain {
    
    func tokenList(tokenList: [YCTokenModel], completionBlock: @escaping (YCDomainListModel?) -> Void){
        YCUploadTokenListRequest(tokenList: tokenList).startWithComplete { (response) in
            switch response{
            case .success(let v):
                let json:JSON = JSON(v)
                if self.checkResult(json){
                    let listArray = json[Parameter(.list)].array
                    let total = json[Parameter(.total)].int ?? 0
                    var tokenArray: [YCTokenModel] = []
                    if listArray != nil {
                        let count = listArray!.count
                        for i in 0..<count {
                            let listJson = listArray![i]
                            let token = YCTokenModel(listJson)
                            tokenArray.append(token);
                        }
                    }
                    completionBlock(YCDomainListModel(result: true, modelArray: tokenArray, totoal: total))
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
    
    func uploadImageDate(_ image:UIImage, imageKey: String, imageType: String, progressBlock: ((Float) -> Void)?, completionBlock: ((Bool, String, UIImage?) -> Void)?){
        let token = YCTokenModel.init(tokenKey: imageKey, type: 0)
        self.tokenList(tokenList: [token]) { (modelList) in
            if let list = modelList, list.result, let modelList = list.modelArray {
                let newToken = modelList[0] as! YCTokenModel
                var imgData :Data? = nil
                if imageType == "jpg" {
                    imgData = UIImageJPEGRepresentation(image, 0.5)
                }else if imageType == "png" {
                    imgData = UIImagePNGRepresentation(image)
                }
                if let token = newToken.token, let data = imgData {
                    let uploadModel = YCUploadModel(key: imageKey, token: token, fileData: data)
                    YCUploadAction.getInstance().uploadFile(imageKey, uploadModel: uploadModel, progress: { (progress) in
                        if let proBlock = progressBlock, let pro = progress {
                            proBlock(pro.progress)
                        }
                    }, complete: { (info) in
                        if let comp = completionBlock {
                            if let compInfo = info, compInfo.result{
                                comp(true, imageKey, image)
                            }else {
                                comp(false, imageKey, nil)
                            }
                        }
                    })
                }else {
                    if let comp = completionBlock {
                        comp(false, imageKey, nil)
                    }
                }
            }else {
                if let comp = completionBlock {
                    comp(false, imageKey, nil)
                }
            }
        }
    }
}
