//
//  LanguageHelper.swift
//  YouCat
//
//  Created by ting on 2018/11/29.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit

let UserLanguage = "UserLanguage"

let AppleLanguages = "AppleLanguages"

class YCLanguageHelper: NSObject {
    
    static let shareInstance = YCLanguageHelper()
    
    let def = UserDefaults.standard
    
    var bundle : Bundle?
    
    class func getString(key:String) -> String{
        
        if let bundle = YCLanguageHelper.shareInstance.bundle {
            let str = bundle.localizedString(forKey: key, value: nil, table: nil)
            return str
        }
        return ""
    }
    
    func getUserLanguage() -> String {
        let string:String = def.value(forKey: UserLanguage) as! String? ?? ""
        return string
    }
    
    func initUserLanguage() {
        
        var string:String = "" //def.value(forKey: UserLanguage) as! String? ?? ""
        
        if string == "" {
            
            let languages = def.object(forKey: AppleLanguages) as? NSArray
            
            if languages?.count != 0 {
                
                let current = languages?.object(at: 0) as? String
                
                if current != nil {
                    
                    string = current!
                    
                    def.set(current, forKey: UserLanguage)
                    
                    def.synchronize()
                    
                }
                
            }
            
        }
        
        string = string.replacingOccurrences(of: "-CN", with: "")
        
        string = string.replacingOccurrences(of: "-US", with: "")
        
        setLanguage(langeuage: string)
    }
    
    func setLanguage(langeuage:String) {
        var lang = langeuage
        var path = Bundle.main.path(forResource:lang , ofType: "lproj")
        
        if path == nil {
            path = Bundle.main.path(forResource:"en" , ofType: "lproj")
            lang = "en"
        }
        
        bundle = Bundle(path: path!)
        def.set(lang, forKey: UserLanguage)
        def.synchronize()
    }
}
