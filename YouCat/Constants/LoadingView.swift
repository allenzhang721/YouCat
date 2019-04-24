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
    }
    
    func initView() {
        if self.style == .POP {
            self.snp.makeConstraints({ (make) in
                make.width.equalTo(100)
                make.height.equalTo(75)
            })
            self.layer.cornerRadius = 10
            self.backgroundColor = YCStyleColor.blackAlpha
            
            self.loading = UIActivityIndicatorView(style: .white)
            self.addSubview(self.loading)
            self.loading.snp.makeConstraints { (make) in
                make.center.equalTo(self).offset(0)
            }
            self.loading.hidesWhenStopped = true
        }else {
            self.snp.makeConstraints({ (make) in
                make.width.equalTo(44)
                make.height.equalTo(44)
            })
            self.loading = UIActivityIndicatorView(style: .gray)
            self.addSubview(self.loading)
            self.loading.snp.makeConstraints { (make) in
                make.center.equalTo(self).offset(0)
            }
            self.loading.hidesWhenStopped = true
        }
        self.stopAnimating()
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
}
