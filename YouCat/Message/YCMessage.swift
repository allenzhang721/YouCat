//
//  YCMessage.swift
//  YouCat
//
//  Created by Emiaostein on 2019/12/1.
//  Copyright © 2019 Curios. All rights reserved.
//

import Foundation
import LeanCloud

class YCSearchResultMessage: IMCategorizedMessage {
    
    class override var messageType: IMCategorizedMessage.MessageType {
        return 100
    }
    
    var tagText: String?
    var models:[YCPublishModel]?
    
}
