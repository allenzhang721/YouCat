//
//  DetailViewController.swift
//  YouCat
//
//  Created by Emiaostein on 2018/3/31.
//  Copyright © 2018 Curios. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var contentUrl: URL?
    @IBOutlet weak var imgView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imgView.kf.setImage(with: contentUrl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
