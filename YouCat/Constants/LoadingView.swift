//
//  LoadingView.swift
//  YouCat
//
//  Created by ting on 2018/12/4.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit

class YCLoadingView: UIView {
    
    var loading: UIActivityIndicatorView!
    
    var style: YCLoadingStyle = .POP
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(style: YCLoadingStyle) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.style = style
        self.initView()
        self.changeViewStyle()
    }
    
    func initView() {
        self.loading = UIActivityIndicatorView(style: .gray)
        self.addSubview(self.loading)
        self.loading.snp.makeConstraints { (make) in
            make.center.equalTo(self).offset(0)
        }
        self.loading.hidesWhenStopped = true
    }
    
    func changeViewStyle() {
        if self.style == .POP {
            self.snp.makeConstraints({ (make) in
                make.width.equalTo(100)
                make.height.equalTo(75)
            })
            self.layer.cornerRadius = 10
            self.backgroundColor = YCStyleColor.blackAlpha
            self.loading.style = .white
        }else if self.style == .INSIDE {
            self.snp.makeConstraints({ (make) in
                make.width.equalTo(44)
                make.height.equalTo(44)
            })
            self.layer.cornerRadius = 0
            self.backgroundColor = UIColor.clear
            self.loading.style = .gray
        }else if self.style == .INSIDEWhite {
            self.snp.makeConstraints({ (make) in
                make.width.equalTo(44)
                make.height.equalTo(44)
            })
            self.layer.cornerRadius = 0
            self.backgroundColor = UIColor.clear
            self.loading.style = .white
        }
        self.stopAnimating()
    }
    
    func changeStyle(style: YCLoadingStyle){
        self.style = style
        self.changeViewStyle()
    }
    
    func startAnimating() {
        self.isHidden = false
        self.loading.startAnimating()
    }
    
    func stopAnimating() {
        self.loading.stopAnimating()
        self.isHidden = true
    }
}

enum YCLoadingStyle: String{
    case POP = "pop"
    case INSIDE = "inside"
    case INSIDEWhite = "inside_white"
}
