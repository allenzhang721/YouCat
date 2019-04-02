//
//  BaseModel.swift
//  YouCat
//
//  Created by ting on 2018/9/11.
//  Copyright © 2018年 Curios. All rights reserved.
//

import Foundation
import SwiftyJSON

class YCBaseModel {
    
    //static func generateFrom(_ json: JSON) throws -> Self
    init() {
        
    }
    
    convenience init(_ json: JSON){
        self.init()
    }
    
    func getData() -> [String: Any] {
        return [:]
    }
}
