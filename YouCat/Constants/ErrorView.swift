//
//  ErrorView.swift
//  YouCat
//
//  Created by ting on 2019/6/12.
//  Copyright © 2019 Curios. All rights reserved.
//

import UIKit


class YCWifiErrorView: UIView {
    
    var refreshComplete: (() -> Void)?
    
    var errorLabel: UILabel!
    var refreshButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    init(refreshComplete: (() -> Void)?) {
        self.refreshComplete = refreshComplete
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.initView()
    }
    
    func initView() {
        let wifiErrorImg = UIImageView()
        self.addSubview(wifiErrorImg)
        wifiErrorImg.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.centerX.equalTo(self).offset(0)
            make.width.equalTo(80)
            make.height.equalTo(66)
        }
        wifiErrorImg.image = UIImage(named: "wifi_error_icon")
        
        self.errorLabel = UILabel()
        self.errorLabel.numberOfLines = 0
        self.addSubview(self.errorLabel)
        self.errorLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(wifiErrorImg.snp.bottom).offset(40)
        }
        self.errorLabel.textColor = YCStyleColor.gray
        self.errorLabel.textAlignment = .center
        self.errorLabel.font = UIFont.systemFont(ofSize: 14)
        self.errorLabel.text = YCLanguageHelper.getString(key: "WifiErrorMessage")
        
        self.refreshButton = UIButton()
        self.addSubview(self.refreshButton)
        self.refreshButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.errorLabel.snp.bottom).offset(60)
            make.centerX.equalTo(self).offset(0)
            make.width.equalTo(80)
            make.height.equalTo(32)
        }
        self.refreshButton.backgroundColor = YCStyleColor.red
        self.refreshButton.layer.borderColor = YCStyleColor.red.cgColor
        self.refreshButton.layer.borderWidth = 1
        self.refreshButton.layer.cornerRadius = 4
        self.refreshButton.setTitleColor(YCStyleColor.white, for: .normal)
        self.refreshButton.setTitle(YCLanguageHelper.getString(key: "RefreshButtonLabel"), for: .normal)
        self.refreshButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.refreshButton.addTarget(self, action: #selector(self.refreshButtonClick), for: .touchUpInside)
        
    }
    
}


extension YCWifiErrorView {
    
    @objc func refreshButtonClick() {
        if let refresh = self.refreshComplete {
            refresh()
        }
    }
}
