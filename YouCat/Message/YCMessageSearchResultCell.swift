//
//  YCMessageSearchResultCell.swift
//  YouCat
//
//  Created by Emiaostein on 2019/12/1.
//  Copyright © 2019 Curios. All rights reserved.
//

import UIKit
import Kingfisher

class YCMessageSearchResultCell: UITableViewCell {
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowView.layer.shadowRadius = 10
        shadowView.layer.shadowOpacity = 0.1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(with message: YCSearchResultMessage) {
        print("hshshshshsh")
        if let imgModel = message.models?.first?.medias.first as? YCImageModel {
            print("hshshshshsh2")
            imageView1?.kf.setImage(with: URL(string: imgModel.imagePath))
        }
        
        if let imgModel = message.models?[1].medias.first as? YCImageModel {
            print("hshshshshsh2")
            imageView2?.kf.setImage(with: URL(string: imgModel.imagePath))
        }
        
        if let imgModel = message.models?[2].medias.first as? YCImageModel {
            print("hshshshshsh2")
            imageView3?.kf.setImage(with: URL(string: imgModel.imagePath))
        }
        
        if let tagText = message.tagText {
            self.contentLabel.text = "来看看\(tagText)吧～"
        } else {
            if let tagModel = message.models?.first?.tags.first {
                self.contentLabel.text = "来看看\(tagModel.tagName)吧～"
    //            imageView1?.kf.setImage(with: URL(string: imgModel.imagePath))
            }
        }

        
    }
    
}
