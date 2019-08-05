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


class YCMediaLoadingView: UIView {
    
    var loadingView:UIView!
    
    var loadingTimer: DispatchSourceTimer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    func initView() {
        let bounds = self.frame
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 0.5))
        self.addSubview(bgView)
        bgView.backgroundColor = YCStyleColor.grayWhiteAlpha
        self.loadingView = UIView(frame: CGRect(x: (bounds.width-50)/2, y: 0, width: 50, height: 0.5))
        self.addSubview(self.loadingView)
        self.loadingView.backgroundColor = YCStyleColor.white
        self.loadingView.isHidden = true
    }
    
    func startAnimating() {
        if self.loadingView.isHidden && self.loadingTimer == nil {
            self.isHidden = false
            self.loadingView.isHidden = false
            let bounds = self.frame
            let gap = (bounds.width - 20)/12
            self.loadingTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            self.loadingTimer!.schedule(deadline: .now(), repeating: .milliseconds(40))
            self.loadingTimer!.setEventHandler {
                DispatchQueue.main.async {
                    let w = self.loadingView.frame.size.width
                    if w + 20 > bounds.width {
                        self.loadingView.frame.size.width = 20
                        self.loadingView.frame.origin.x = (bounds.width-20)/2
                    }else {
                        self.loadingView.frame.size.width = self.loadingView.frame.width + gap
                        self.loadingView.frame.origin.x = self.loadingView.frame.origin.x - gap/2
                    }
                }
            }
            self.loadingTimer!.resume()
        }
    }
    
    func stopAnimating() {
        if !self.loadingView.isHidden{
            self.loadingView.layer.removeAllAnimations()
            self.loadingView.isHidden = true
            self.isHidden = true
            if let time = self.loadingTimer {
                time.cancel()
            }
            self.loadingTimer = nil
        }
    }
}
