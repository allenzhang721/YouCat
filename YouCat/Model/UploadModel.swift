//
//  UploadModel.swift
//  YouCat
//
//  Created by ting on 2018/12/3.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON

class YCTokenModel: YCBaseModel {
    let tokenKey: String;
    var token: String?
    let type: Int;
    
    init(tokenKey: String, token: String, type: Int) {
        self.tokenKey = tokenKey
        self.token = token
        self.type = type
    }
    
    init(tokenKey: String, type: Int) {
        self.tokenKey = tokenKey
        self.type = type
    }
    
    convenience init(_ json: JSON) {
        let token:String    = json[Parameter(.token)].string ?? "";
        let tokenKey:String = json[Parameter(.tokenKey)].string ?? "";
        let type:Int        = json[Parameter(.type)].int ?? 0;
        
        self.init(tokenKey: tokenKey, token: token, type: type)
    }
    
    override func getData() -> [String : Any] {
        var parameterDic: [String: Any] = [
            Parameter(.tokenKey) :self.tokenKey,
            Parameter(.type)     :self.type
        ]
        if let token = self.token{
            parameterDic[Parameter(.token)] = token
        }
        return parameterDic
    }
}

class YCUploadModel {
    
    let key:String; // Service relative path: /publishID/fileName.png --  Emiaostein, 1/02/16, 18:15
    let token:String;
    var filePath:String; // file's local absolute path --  Emiaostein, 1/02/16, 18:18
    var uploadID:String = "";
    var isUploading:Bool = false;
    var uploadProgress:Float = 0.0;
    var uploadComplete:Bool = false;
    var fileData:Data?
    let isUploadData:Bool
    
    init(key:String, token:String, filePath:String){
        self.key          = key;
        self.token        = token;
        self.filePath     = filePath;
        self.fileData     = nil;
        self.isUploadData = false;
    }
    
    init(key:String, token:String, fileData:Data){
        self.key          = key;
        self.token        = token;
        self.fileData     = fileData;
        self.filePath     = ""
        self.isUploadData = true;
    }
    
}
