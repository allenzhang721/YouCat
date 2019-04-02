//
//  FollowButton.swift
//  YouCat
//
//  Created by ting on 2018/10/22.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit

public extension UIButton{
    
    public struct AssociatedKeys{
        static var defaultInterval : TimeInterval = 1 //间隔时间
        static var A_customInterval = "customInterval"
        static var A_ignoreInterval = "ignoreInterval"
    }
    
    var customInterval: TimeInterval{
        get{
            let A_customInterval = objc_getAssociatedObject(self, &AssociatedKeys.A_customInterval)
            if let time = A_customInterval{
                return time as! TimeInterval
            }else{
                return AssociatedKeys.defaultInterval
            }
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.A_customInterval, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var ignoreInterval: Bool{
        get{
            return (objc_getAssociatedObject(self, &AssociatedKeys.A_ignoreInterval) != nil)
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.A_ignoreInterval, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public class func initializeMethod(){
        if self == UIButton.self{
            let systemSel = #selector(UIButton.sendAction(_:to:for:))
            let sSel = #selector(UIButton.mySendAction(_: to: for:))
            let systemMethod = class_getInstanceMethod(self, systemSel)
            let sMethod = class_getInstanceMethod(self, sSel)
            let isTrue = class_addMethod(self, systemSel, method_getImplementation(sMethod!), method_getTypeEncoding(sMethod!))
            if isTrue{
                class_replaceMethod(self, sSel, method_getImplementation(systemMethod!), method_getTypeEncoding(systemMethod!))
            }else{
                method_exchangeImplementations(systemMethod!, sMethod!)
            }
        }
    }
    
    @objc private dynamic func mySendAction(_ action: Selector, to target: Any?, for event: UIEvent?){
        if !ignoreInterval{
            isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+customInterval, execute: {
                self.isUserInteractionEnabled = true
            })
        }
        mySendAction(action, to: target, for: event)
    }
}

enum YCFollowButtonStatus: Int {
    case Loading = -2
    case EditProfile = -1
    case Unfollow = 0
    case Following = 1
    case Unblock = 2
}

class YCFollowButton: UIView {
    
    var bgView: UIView!
    var bgLabel: UILabel!
    var loadingView: UIActivityIndicatorView!
    
    var fontSize: Int = 16
    
    var status: YCFollowButtonStatus = .Loading {
        didSet{
            if self.status != oldValue {
                self.didStatuChange()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
        self.isUserInteractionEnabled = true
    }
    
    init(fontSize: Int) {
        self.fontSize = fontSize
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.initView()
    }
    
    
    func initView(){
        self.bgView = UIView()
        self.addSubview(self.bgView)
        self.bgView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
        self.bgView.layer.cornerRadius = 8
        self.bgView.layer.borderWidth = 1
        
        self.bgLabel = UILabel()
        self.addSubview(self.bgLabel)
        self.bgLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.centerY.equalTo(self).offset(0)
            make.height.equalTo(22)
        }
        self.bgLabel.textColor = YCStyleColor.white
        self.bgLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(self.fontSize))
        self.bgLabel.textAlignment = .center
        self.bgLabel.text = ""
        
        self.loadingView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(self).offset(0)
        }
        self.loadingView.hidesWhenStopped = true
        
        self.status = .Unfollow
    }
    
    func didStatuChange() {
        switch self.status {
        case .Loading:
            self.setLoadingStatus();
            break;
        case .EditProfile:
            self.setEditProfileStatus();
            break;
        case .Unfollow:
            self.setUnFollowStatus();
            break;
        case .Following:
            self.setFollowingStatus();
            break;
        case .Unblock:
            self.setUnblockStatus();
            break;
        }
    }
    
    func setLoadingStatus() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: {
            if self.status == .Loading {
                self.bgLabel.text = ""
                self.bgView.backgroundColor = YCStyleColor.white
                self.bgView.layer.borderColor = YCStyleColor.grayWhite.cgColor
                self.loadingView.startAnimating()
            }
        })
    }
    
    func setEditProfileStatus() {
        self.bgView.backgroundColor = YCStyleColor.red
        self.bgView.layer.borderColor = YCStyleColor.red.cgColor
        self.bgLabel.text = YCLanguageHelper.getString(key: "EditProfileButtonLabel")
        self.bgLabel.textColor = YCStyleColor.white
        self.loadingView.stopAnimating()
    }
    
    func setFollowingStatus(){
        self.bgView.backgroundColor = YCStyleColor.white
        self.bgView.layer.borderColor = YCStyleColor.grayWhite.cgColor
        self.bgLabel.text = YCLanguageHelper.getString(key: "FollowingButtonLabel")
        self.bgLabel.textColor = YCStyleColor.black
        self.loadingView.stopAnimating()
    }
    
    func setUnFollowStatus(){
        self.bgView.backgroundColor = YCStyleColor.red
        self.bgView.layer.borderColor = YCStyleColor.red.cgColor
        self.bgLabel.text = YCLanguageHelper.getString(key: "FollowButtonLabel")
        self.bgLabel.textColor = YCStyleColor.white
        self.loadingView.stopAnimating()
    }
    
    func setUnblockStatus(){
        self.bgView.backgroundColor = YCStyleColor.red
        self.bgView.layer.borderColor = YCStyleColor.red.cgColor
        self.bgLabel.text = YCLanguageHelper.getString(key: "UnBlockButtonLabel")
        self.bgLabel.textColor = YCStyleColor.white
        self.loadingView.stopAnimating()
    }
}

enum YCSelectedButtonStatus: Int {
    case Default = 0
    case Selected = 1
}

class YCSelectedButton: UIView{
    var bgView: UIView!
    var bgLabel: UILabel!
    var bottomLine: UIView!
    var fontSize: Int = 16
    
    var fontText: String = ""
    
    var status: YCSelectedButtonStatus = .Default {
        didSet{
            if self.status != oldValue {
                self.didStatuChange()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
        self.isUserInteractionEnabled = true
    }
    
    init(fontText: String, fontSize: Int) {
        self.fontText = fontText
        self.fontSize = fontSize
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.initView()
    }
    
    func initView() {
        self.bgView = UIView()
        self.addSubview(self.bgView)
        self.bgView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
        self.bgView.backgroundColor = YCStyleColor.white
        
        self.bgLabel = UILabel()
        self.addSubview(self.bgLabel)
        self.bgLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.centerY.equalTo(self).offset(0)
            make.height.equalTo(22)
        }
        self.bgLabel.textColor = YCStyleColor.gray
        self.bgLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(self.fontSize))
        self.bgLabel.textAlignment = .center
        self.bgLabel.text = self.fontText
        
        self.bottomLine = UIView()
        self.addSubview(self.bottomLine)
        self.bottomLine.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(1)
            make.bottom.equalTo(0)
        }
        self.bottomLine.backgroundColor = YCStyleColor.gray
        
        self.status = .Default
    }
 
    func didStatuChange() {
        switch self.status {
        case .Default:
            self.setDefaultStatus();
            break;
        case .Selected:
            self.setSelectedStatus();
            break;
        }
    }
    
    func setDefaultStatus(){
        self.bgView.backgroundColor = YCStyleColor.white
        self.bgLabel.textColor = YCStyleColor.gray
        self.bottomLine.backgroundColor = YCStyleColor.grayWhite
        self.bottomLine.snp.remakeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(1)
            make.bottom.equalTo(0)
        }
    }
    
    func setSelectedStatus(){
        self.bgView.backgroundColor = YCStyleColor.white
        self.bgLabel.textColor = YCStyleColor.red
        self.bottomLine.backgroundColor = YCStyleColor.red
        self.bottomLine.snp.remakeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(2)
            make.bottom.equalTo(0)
        }
    }
}
