//
//  ThemeTableViewCell.swift
//  YouCat
//
//  Created by ting on 2018/10/19.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit

class YCThemeTableViewCell: UITableViewCell, YCImageProtocol, YCContentStringProtocol{
    
    var bgView: UIView!
    
    var themeCover: YCImageView!
    var titleLabel: UILabel!
    var descLabel: UILabel!
    
    var themeModel: YCThemeModel? {
        didSet{
            self.didSetThemeModel();
        }
    }
    
    var preThemeID: String = ""
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.initView()
    }
    
    
    func initView() {
        self.bgView = UIView()
        self.addSubview(self.bgView)
        self.bgView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10).priority(999)
            make.top.equalTo(5)
            make.bottom.equalTo(-25).priority(999)
        }
        self.bgView.backgroundColor = YCStyleColor.white
        self.bgView.layer.cornerRadius = 8;
        self.bgView.clipsToBounds = true
        
        let shadowView = UIView()
        self.addSubview(shadowView)
        self.sendSubviewToBack(shadowView)
        shadowView.snp.makeConstraints { (make) in
            make.left.equalTo(self.bgView)
            make.right.equalTo(self.bgView)
            make.top.equalTo(self.bgView)
            make.bottom.equalTo(self.bgView)
        }
        shadowView.backgroundColor = YCStyleColor.white
        shadowView.layer.cornerRadius = 8;
        self.addShadow(shadowView, 8, 4)
        
        self.themeCover = YCImageView()
        self.bgView.addSubview(self.themeCover)
        self.themeCover.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.width.equalTo(self.bgView)
            make.height.equalTo(self.bgView.snp.width)
        }
        
        self.titleLabel = UILabel();
        self.titleLabel.numberOfLines = 0
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.bgView).offset(10)
            make.right.equalTo(self.bgView).offset(-10)
            make.top.equalTo(self.themeCover.snp.bottom).offset(10)
        }
        self.titleLabel.textColor = YCStyleColor.black
        self.titleLabel.font = UIFont.systemFont(ofSize: 24)
        self.titleLabel.text = ""
        
        self.descLabel = UILabel();
        self.descLabel.numberOfLines = 0
        self.addSubview(self.descLabel)
        self.descLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.bgView).offset(10)
            make.right.equalTo(self.bgView).offset(-10)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.bottom.equalTo(-35)
        }
        self.descLabel.textColor = YCStyleColor.gray
        self.descLabel.font = UIFont.systemFont(ofSize: 16)
        self.descLabel.text = ""
    }
    
    func didSetThemeModel() {
        if let theme = self.themeModel, self.preThemeID != theme.themeID{
            self.setCellValue()
            self.preThemeID = theme.themeID
        }
    }
    
    func setCellValue(){
        if let theme = self.themeModel {
            if let cover = theme.coverImage {
                let imgW = cover.imageWidth
                let imgH = cover.imageHeight
                var rate = imgH/imgW
                if rate > 4/3 {
                    rate = 4/3
                }
                self.themeCover.snp.remakeConstraints { (make) in
                    make.left.equalTo(0)
                    make.top.equalTo(0)
                    make.width.equalTo(self.bgView)
                    make.height.equalTo(self.bgView.snp.width).multipliedBy(rate)
                }
                self.themeCover.loadSnapImage(cover, snapShot: false)
            }
            self.titleLabel.text = self.getContentString(content: theme.name)
            self.descLabel.text = self.getContentString(content: theme.description)
        }
    }
}
