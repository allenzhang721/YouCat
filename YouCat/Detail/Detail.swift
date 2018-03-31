//
//  Detail.swift
//  YouCat
//
//  Created by Emiaostein on 2018/3/31.
//  Copyright © 2018 Curios. All rights reserved.
//

import Foundation
import UIKit

class Detail {
    
    class func viewController(contentUrl: URL) -> UIViewController {
        let vc = UIStoryboard(name: "Detail", bundle: nil).instantiateInitialViewController() as! DetailViewController
        vc.contentUrl = contentUrl
        return vc
    }
}
