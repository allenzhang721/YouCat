//
//  URLRequest.swift
//  YouCat
//
//  Created by ting on 2018/9/5.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import Alamofire

extension UIDevice {
    //获取设备具体详细的型号
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "iPod5,1":
            return "iPod Touch 5"
        case "iPod7,1":
            return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":
            return "iPhone 4"
        case "iPhone4,1":
            return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":
            return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":
            return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":
            return "iPhone 5s"
        case "iPhone7,2":
            return "iPhone 6"
        case "iPhone7,1":
            return "iPhone 6 Plus"
        case "iPhone8,1":
            return "iPhone 6s"
        case "iPhone8,2":
            return "iPhone 6s Plus"
        case "iPhone8,4":
            return "iPhone SE"
        case "iPhone9,1":
            return "iPhone 7 (CDMA)"
        case "iPhone9,3":
            return "iPhone 7 (GSM)"
        case "iPhone9,2":
            return "iPhone 7 Plus (CDMA)"
        case "iPhone9,4":
            return "iPhone 7 Plus (GSM)"
        case "iPhone10,1":
            return "iPhone 8 (CDMA)"
        case "iPhone10,2":
            return "iPhone 8 Plus (CDMA)"
        case "iPhone10,3":
            return "iPhone X (CDMA)"
        case "iPhone10,4":
            return "iPhone 8 (GSM)"
        case "iPhone10,5":
            return "iPhone 8 Plus (GSM)"
        case "iPhone10,6":
            return "iPhone X (GSM)"
        case "iPhone11,1":
            return "iPhone Xs (CDMA)"
        case "iPhone11,4":
            return "iPhone Xs (GSM)"
        case "iPhone11,2":
            return "iPhone XR (CDMA)"
        case "iPhone11,5":
            return "iPhone XR (GSM)"
        case "iPhone11,3":
            return "iPhone Xs Max (CDMA)"
        case "iPhone11,6":
            return "iPhone Xs Max (GSM)"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
            return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":
            return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":
            return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":
            return "iPad Air"
        case "iPad5,3", "iPad5,4":
            return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":
            return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":
            return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":
            return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":
            return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":
            return "iPad Pro"
        case "iPad6,11", "iPad6,12":
            return "iPad 5"
        case "AppleTV5,3":
            return "Apple TV"
        case "i386", "x86_64":
            return "Simulator"
        default:
            return identifier
        }
    }
}

class YCURLRequest{
    
    let url: String;
    let method: HTTPMethod;
    let parameters: Parameters?
    
    var dependenceRequest: (Alamofire.Request)?
    
    init(url: String, parameters: Parameters?, method: HTTPMethod = .post) {
        self.url = url;
        self.method  = method;
        self.parameters = parameters;
    }
    
    func connectWithBlock(_ completionBlock: ((YCURLRequestResponse<Any>) -> Void)?) {
        
        Alamofire.request(self.url, method: self.method, parameters: self.parameters, encoding: URLEncoding.httpBody).responseJSON { response in
            switch response.result {
            case .success(let v):
                if let complete = completionBlock{
                    let res = YCURLRequestResponse(request: response.request, response: response.response, data: response.data, result: YCURLRequestResult<Any>.success(v))
                    complete(res)
                }
            case .failure(let error):
                if let complete = completionBlock{
                    let res = YCURLRequestResponse(request: response.request, response: response.response, data: response.data, result: YCURLRequestResult<Any>.failure(error))
                    complete(res)
                }
            }
        }
    }
}

public struct YCURLRequestResponse<Value> {
    /// The URL request sent to the server.
    public let request: URLRequest?
    
    /// The server's response to the URL request.
    public let response: HTTPURLResponse?
    
    /// The data returned by the server.
    public let data: Data?
    
    /// The result of response serialization.
    public let result: YCURLRequestResult<Value>
    
    /**
     Initializes the `Response` instance with the specified URL request, URL response, server data and response
     serialization result.
     
     - parameter request:  The URL request sent to the server.
     - parameter response: The server's response to the URL request.
     - parameter data:     The data returned by the server.
     - parameter result:   The result of response serialization.
     
     - returns: the new `Response` instance.
     */
    public init(request: URLRequest?, response: HTTPURLResponse?, data: Data?, result: YCURLRequestResult<Value>) {
        self.request = request
        self.response = response
        self.data = data
        self.result = result
    }
}


public enum YCURLRequestResult<Value> {
    case success(Value)
    case failure(Value)
    
    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .failure(let value):
            return value
        }
    }
}

class YCBaseRequest{
    
    var completionBlock:((YCURLRequestResult<Any>) -> Void)?
    
    var request: YCURLRequest?
    
    func baseParameter(dic: Dictionary<String, Any>) ->[String: Any]?{
        var parameterDic = [String: Any]()
        for (key,value) in dic {
            parameterDic[key] = value
        }
        parameterDic[Parameter(.deviceType)] = 2
        parameterDic[Parameter(.deviceModel)] = UIDevice.current.model
        parameterDic[Parameter(.deviceVersion)] = UIDevice.current.modelName
        parameterDic[Parameter(.deviceSystem)] = UIDevice.current.systemName
        parameterDic[Parameter(.systemVersion)] = UIDevice.current.systemVersion
       
        let softVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        parameterDic[Parameter(.softVersion)] = softVersion
        parameterDic[Parameter(.softLanguage)] = YCLanguageHelper.shareInstance.getUserLanguage()
        if let uuid = YCDeviceManager.UUID {
            parameterDic[Parameter(.deviceID)] = uuid
        }else {
            parameterDic[Parameter(.deviceID)] = ""
        }
        if let loginUser = YCUserManager.loginUser {
           parameterDic[Parameter(.loginUserID)] = loginUser.userID
        }else {
            parameterDic[Parameter(.loginUserID)] = ""
        }
        return self.requestParameters(parameterDic)
    }
    
    func requestParameters(_ dic: Any) ->[String: Any]?{
        do {
            let data = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions(rawValue: 0))
            if let nsStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                let dataStr = String(nsStr)
                return [ParameterKey.data.description : dataStr]
            }else {
                print("\(errorMessage) data String is error")
                return [ParameterKey.data.description : ""]
            }
        } catch let error {
            let errorMessage = self.errorMessage();
            print("\(errorMessage) is error, error message \(error)")
            return [ParameterKey.data.description : ""]
        }
    }
    
    func start(){
        if(request == nil){
            let parameters = self.requestParameters();
            let url = self.requestURL();
            let method = self.requestMethod();
            print("url = \(url)")
            print("parameters = \(String(describing: parameters))")
            request = YCURLRequest(url: url, parameters: parameters, method: method)
            request?.connectWithBlock({(response) in
                if let complete = self.completionBlock{
                    complete(response.result)
                }
            })
        }
    }
    
    func startWithComplete(_ completionBlock: ((YCURLRequestResult<Any>) -> Void)?) {
        self.completionBlock = completionBlock
        start()
    }
    
    func parameter() ->Dictionary<String, Any>{
        return [:];
    }
    
    func urlPath() -> String{
        return "";
    }
    
    func errorMessage() -> String{
        return "";
    }
}

extension YCBaseRequest{
    
    func requestMethod() -> HTTPMethod {
        return .post
    }
    
    func requestURL() -> String{
        let baseUrl = FilePath.baseURL;
        let urlPath = self.urlPath();
        let url = "\(baseUrl)\(urlPath)"
        return url;
    }
    
    func requestParameters() -> [String: Any]?{
        let para = parameter()
        return self.baseParameter(dic: para)
    }
}

class YCListRequest: YCBaseRequest {
    let start:Int;
    let count:Int;
    
    init(start: Int, count: Int){
        self.start = start;
        self.count = count;
    }
    
    override func urlPath() -> String {
        return ""
    }
    
    override func parameter() -> Dictionary<String, Any> {
        let dic:Dictionary<String, Any> = [
            Parameter(.start) : self.start,
            Parameter(.count) : self.count
        ];
        return dic;
    }
    
    override func errorMessage() -> String {
        return "list"
    }
}
