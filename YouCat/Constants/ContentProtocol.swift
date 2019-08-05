//
//  NumberStringController.swift
//  YouCat
//
//  Created by ting on 2018/10/19.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation

protocol YCNumberStringProtocol {
    func getNumberString(number: Int) -> String;
}

extension YCNumberStringProtocol{
    
    func getNumberString(number: Int) -> String{
        let a = YCLanguageHelper.shareInstance.getUserLanguage()
        if a == "zh-Hans"{
            if number < 10000 {
                return "\(number)"
            }else if number < 100000000{
                let tenT = Int(number/10000);
                let thou = Int((number%10000)/1000)
                if tenT < 100 {
                    return "\(tenT).\(thou)万"
                }else {
                    return "\(tenT)万"
                }
            }else {
                let hundredMil = Int(number/100000000);
                return "\(hundredMil)亿"
            }
        }else {
            if number < 1000 {
                return "\(number)"
            }else if number < 1000000{
                let tenT = Int(number/1000);
                let thou = Int((number%1000)/100)
                if tenT < 10 {
                    return "\(tenT).\(thou)k"
                }else {
                    return "\(tenT)k"
                }
            }else if number < 1000000000{
                let tenT = Int(number/1000000);
                let thou = Int((number%1000000)/100)
                if tenT < 10 {
                    return "\(tenT).\(thou)m"
                }else {
                    return "\(tenT)m"
                }
            }else {
                let hundredMil = Int(number/1000000000);
                return "\(hundredMil)b"
            }
        }
        
    }
    
}


protocol YCContentStringProtocol {
    func getNicknameString(user: YCUserModel?) -> String;
    func getSignString(sign: String) -> String;
    func getGenderString(gender: String) -> String;
    func getPhoneString(phone: String) -> String;
    func getContentString(content: String) -> String;
    func getDateString(date: Date?) -> String;
}

extension YCContentStringProtocol {
    
    func getNicknameString(user: YCUserModel?) -> String {
        if let us = user {
            let nikename = us.nikeName
            if nikename == "" {
                let uuid = us.uuid
                let a = uuid.index(uuid.startIndex, offsetBy: 0)
                let b = uuid.index(uuid.startIndex, offsetBy: 6)
                let first = uuid[a..<b]
                
                return YCLanguageHelper.getString(key: "DefaultUserName")+String(first)
            }
            return nikename
        }else {
            return YCLanguageHelper.getString(key: "DefaultUserName")
        }
    }
    
    func getSignString(sign: String) -> String{
        return sign
    }
    
    func getGenderString(gender: String) -> String{
        if gender == "male" {
            return YCLanguageHelper.getString(key: "MaleLabel")
        }else if gender == "female" {
            return YCLanguageHelper.getString(key: "FemaleLabel")
        }else {
            return YCLanguageHelper.getString(key: "NotSetLabel")
        }
    }
    
    func getPhoneString(phone: String) -> String{
        if phone == "" {
            return YCLanguageHelper.getString(key: "NotConnectedLabel")
        }
        return phone
    }
    
    func getContentString(content: String) -> String{
        if content == "" {
            return " "
        }else {
            return content
        }
    }
    
    func getDateString(date: Date?) -> String{
        if let d = date{
            let sinceNow = 0 - Int(d.timeIntervalSinceNow)
            if sinceNow < 60 {
                return YCLanguageHelper.getString(key: "JustNowLabel")
            }else if sinceNow < 60 * 60 {
                let minuteCount = Int(sinceNow/(60))
                if minuteCount > 1 {
                    return "\(minuteCount)"+YCLanguageHelper.getString(key: "MinutesLabel")+YCLanguageHelper.getString(key: "AgoLabel")
                }else {
                    return "\(minuteCount)"+YCLanguageHelper.getString(key: "MinuteLabel")+YCLanguageHelper.getString(key: "AgoLabel")
                }
            }else if sinceNow < 60 * 60 * 24 {
                let hourCount = Int(sinceNow/(60 * 60))
                if hourCount > 1 {
                    return "\(hourCount)"+YCLanguageHelper.getString(key: "HoursLabel")+YCLanguageHelper.getString(key: "AgoLabel")
                }else {
                    return "\(hourCount)"+YCLanguageHelper.getString(key: "HourLabel")+YCLanguageHelper.getString(key: "AgoLabel")
                }
            }else if sinceNow < 60 * 60 * 2 {
               return YCLanguageHelper.getString(key: "YesterdayLabel")
            }else if sinceNow < 60 * 60 * 24 * 10 {
                let dayCount = Int(sinceNow/(60 * 60 * 24))
                if dayCount > 1 {
                    return "\(dayCount)"+YCLanguageHelper.getString(key: "DaysLabel")+YCLanguageHelper.getString(key: "AgoLabel")
                }else {
                    return "\(dayCount)"+YCLanguageHelper.getString(key: "DayLabel")+YCLanguageHelper.getString(key: "AgoLabel")
                }
            }else {
                let formatter = DateFormatter()
                let format = YCLanguageHelper.getString(key: "DateFormatLabel")
                formatter.dateFormat = format
                let dateString = formatter.string(from: d)
                return dateString
            }
        }else {
            return ""
        }
    }
}
