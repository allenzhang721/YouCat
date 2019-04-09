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
    var lineLabel: UILabel!
    
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
        let wGap = YCScreen.bounds.width * 0.06
        self.bgView.snp.makeConstraints { (make) in
            make.left.equalTo(wGap)
            make.right.equalTo(0-wGap).priority(999)
            make.top.equalTo(10)
            make.bottom.equalTo(-20).priority(999)
        }
        self.bgView.backgroundColor = YCStyleColor.white
        self.bgView.layer.cornerRadius = 14;
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
        shadowView.layer.cornerRadius = 14;
        self.addShadow(shadowView, 8, 4)
        
        self.themeCover = YCImageView()
        self.bgView.addSubview(self.themeCover)
        self.themeCover.snp.makeConstraints { (make) in
            make.left.equalTo(0-wGap)
            make.top.equalTo(0-wGap)
            make.width.equalTo(YCScreen.bounds.width)
            make.height.equalTo(YCScreen.bounds.width)
        }
        
        self.titleLabel = UILabel();
        self.titleLabel.numberOfLines = 0
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.bgView).offset(20)
            make.right.equalTo(self.bgView).offset(-150)
            make.top.equalTo(self.themeCover.snp.bottom).offset(10)
        }
        self.titleLabel.numberOfLines = 0
        self.titleLabel.textColor = YCStyleColor.black
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        self.titleLabel.text = ""
        
        self.descLabel = UILabel();
        self.descLabel.numberOfLines = 0
        self.addSubview(self.descLabel)
        self.descLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.bgView).offset(20)
            make.right.equalTo(self.bgView).offset(-20)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
        }
        self.descLabel.textColor = YCStyleColor.gray
        self.descLabel.font = UIFont.systemFont(ofSize: 16)
        self.descLabel.text = ""
        
        self.lineLabel = UILabel();
        self.lineLabel.numberOfLines = 0
        self.addSubview(self.lineLabel)
        self.lineLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.bgView).offset(20)
            make.right.equalTo(self.bgView).offset(-20)
            make.top.equalTo(self.descLabel.snp.bottom).offset(0)
            make.bottom.equalTo(-30)
        }
        self.lineLabel.textColor = YCStyleColor.gray
        self.lineLabel.font = UIFont.systemFont(ofSize: 16)
        self.lineLabel.text = ""
        
    }
    
    func didSetThemeModel() {
        if let theme = self.themeModel, self.preThemeID != theme.themeID{
            self.setCellValue()
            self.preThemeID = theme.themeID
        }
    }
    
    func setCellValue(){
        if let theme = self.themeModel {
            var rate: CGFloat = 1
            let wGap = YCScreen.bounds.width * 0.06
            if let cover = theme.coverImage {
                let imgW = cover.imageWidth
                let imgH = cover.imageHeight
                rate = CGFloat(imgH/imgW)
                if rate > 4/3 {
                    rate = 4/3
                }
                self.themeCover.snp.remakeConstraints { (make) in
                    make.left.equalTo(0-wGap)
                    make.top.equalTo(0-YCScreen.safeArea.top)
                    make.width.equalTo(YCScreen.bounds.width)
                    make.height.equalTo(YCScreen.bounds.width).multipliedBy(rate)
                }
                self.themeCover.loadSnapImage(cover, snapShot: false)
            }
            self.titleLabel.text = self.getContentString(content: theme.name)
            self.descLabel.text = self.getContentString(content: theme.description)
            var stypleType = theme.styleType
            if stypleType == 0{
                stypleType = 1
            }
            switch stypleType {
            case 1:
                self.titleLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.bgView).offset(20)
                    make.right.equalTo(self.bgView).offset(-150)
                    make.top.equalTo(self.themeCover.snp.bottom).offset(10)
                }
                self.titleLabel.textColor = YCStyleColor.black
                self.descLabel.textColor = YCStyleColor.gray
                self.lineLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.bgView).offset(20)
                    make.right.equalTo(self.bgView).offset(-20)
                    make.top.equalTo(self.descLabel.snp.bottom).offset(0)
                    make.bottom.equalTo(-30)
                }
                break;
            case 2:
                let h = YCScreen.bounds.width * rate
                self.lineLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.bgView).offset(20)
                    make.right.equalTo(self.bgView).offset(-20)
                    make.top.equalTo(h-YCScreen.safeArea.top)
                    make.bottom.equalTo(0)
                }
                self.titleLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.bgView).offset(20)
                    make.right.equalTo(self.bgView).offset(-150)
                    make.top.equalTo(self.bgView).offset(34)
                }
                self.titleLabel.textColor = YCStyleColor.white
                self.descLabel.textColor = YCStyleColor.grayWhite
                break;
            case 3:
                let h = YCScreen.bounds.width * rate
                self.lineLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.bgView).offset(20)
                    make.right.equalTo(self.bgView).offset(-20)
                    make.top.equalTo(h-YCScreen.safeArea.top)
                    make.bottom.equalTo(0)
                }
                self.titleLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.bgView).offset(20)
                    make.right.equalTo(self.bgView).offset(-150)
                    make.top.equalTo(self.bgView).offset(34)
                }
                self.titleLabel.textColor = YCStyleColor.black
                self.descLabel.textColor = YCStyleColor.gray
                break;
            default:
                break;
            }
        }
    }
}
