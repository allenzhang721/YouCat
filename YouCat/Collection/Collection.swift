//
//  Collection.swift
//  YouCat
//
//  Created by Emiaostein on 21/02/2018.
//  Copyright © 2018 Curios. All rights reserved.
//

import Foundation
import UIKit

class Collection {
    
    class func viewController() -> UIViewController {
        let vc = UIStoryboard(name: "Collection", bundle: nil).instantiateInitialViewController()!
        return vc
    }
}
