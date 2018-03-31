//
//  Collection.swift
//  YouCat
//
//  Created by Emiaostein on 21/02/2018.
//  Copyright © 2018 Curios. All rights reserved.
//

import Foundation
import UIKit

class Feed {
    
    class func viewController() -> UIViewController {
        let vc = UIStoryboard(name: "Feed", bundle: nil).instantiateInitialViewController()!
        return vc
    }
}
