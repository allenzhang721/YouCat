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
        
        if let imgs = message.models?.compactMap({ (publishModel) -> YCImageModel? in
            return publishModel.medias.first as? YCImageModel
        }), imgs.count > 0 {
            
            let imgViews = [imageView1, imageView2, imageView3]
            let maxIndex = imgs.count - 1
            for (i, imgView) in imgViews.enumerated() {
                imgView?.kf.setImage(with: URL(string: imgs[min(i, maxIndex)].imagePath))
            }
        }
        
        if let tagText = message.tagText, !tagText.isEmpty {
            self.contentLabel.text = "来看看\(tagText)吧～" 
        } else {
            if let tagModel = message.models?.first?.tags.first {
                self.contentLabel.text = "来看看\(tagModel.tagName)吧～"
    //            imageView1?.kf.setImage(with: URL(string: imgModel.imagePath))
            }
        }

        
    }
    
}
