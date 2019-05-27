//
//  LoginViewController.swift
//  YouCat
//
//  Created by ting on 2018/11/23.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
import SnapKit

class YCLoginViewController: UIViewController, YCAlertProtocol {
    
    static var _instaceArray: [YCLoginViewController] = [];
    
    static func getInstance() -> YCLoginViewController{
        var _instance: YCLoginViewController
        if _instaceArray.count > 0 {
            _instance = _instaceArray[0]
            _instaceArray.remove(at: 0)
            _instance.isShow = true
            return _instance
        }else {
            _instance = YCLoginViewController()
            _instance.isShow = true
        }
        return _instance
    }
    
    static func addInstance(instace: YCLoginViewController) {
        _instaceArray.append(instace)
    }
    
    var completeBlock: (() -> Void)?
    
    var currentTextInput: UITextField?
    
    var passwordLoginButton: UIButton!
    var codeLoginButton: UIButton!
    
    var titleLabel: UILabel!
    var areaCodeLabel: UILabel!
    var phoneTextInput: UITextField!
    
    var codeLoginView: UIView!
    var codeTextInput: UITextField!
    var sendCodeLabel: UILabel!
    
    var passwordLoginView: UIView!
    var passwordTextInput: UITextField!
    
    var loginButton: UIButton!
    var weiboLoginButton: UIButton!
    var wechatLoginButton: UIButton!
    var loginOtherLabel: UILabel!
    
    var isCodeLogin: Bool = true
    var isTiming: Bool = false
    var sendCodeTime: DispatchSourceTimer?
    
    var loadingView: YCLoadingView!
    var isShow = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
        if(YCScreen.bounds.height > 568) {
            self.phoneTextInput.becomeFirstResponder()
        }
        
        if WXApi.isWXAppInstalled() {
            self.wechatLoginButton.isHidden = false
        }else {
            self.wechatLoginButton.isHidden = true
        }
        if WeiboSDK.isWeiboAppInstalled() {
            self.weiboLoginButton.isHidden = false
        }else {
            self.weiboLoginButton.isHidden = true
        }
        if !self.weiboLoginButton.isHidden && !self.wechatLoginButton.isHidden {
            let centXGap = YCScreen.bounds.width/8
            self.weiboLoginButton.snp.updateConstraints { (make) in
                make.centerX.equalTo(self.loginButton).offset(centXGap)
            }
            self.wechatLoginButton.snp.updateConstraints { (make) in
                make.centerX.equalTo(self.loginButton).offset(0-centXGap)
            }
            self.loginOtherLabel.isHidden = false
        }else if !self.weiboLoginButton.isHidden {
            self.weiboLoginButton.snp.updateConstraints { (make) in
                make.centerX.equalTo(self.loginButton).offset(0)
            }
            self.loginOtherLabel.isHidden = false
        }else if !self.wechatLoginButton.isHidden {
            self.wechatLoginButton.snp.updateConstraints { (make) in
                make.centerX.equalTo(self.loginButton).offset(0)
            }
            self.loginOtherLabel.isHidden = false
        }else {
            self.loginOtherLabel.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        self.view.backgroundColor = YCStyleColor.white
        self.initOperateButton()
        self.initLoginView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.weiboLoginComplete), name:
            NSNotification.Name("WeiboLoginComplete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.weChatLoginComplet), name: NSNotification.Name("WeChatLoginComplete"), object: nil)
    }
    
    func initOperateButton() {
        let operateView = UIView()
        self.view.addSubview(operateView)
        operateView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(YCScreen.safeArea.top)
            make.height.equalTo(44)
        }
        let closeButton = UIButton()
        closeButton.setImage(UIImage(named: "close_black"), for: .normal)
        closeButton.setImage(UIImage(named: "close_black"), for: .highlighted)
        closeButton.addTarget(self, action: #selector(self.closeButtonClick), for: .touchUpInside)
        operateView.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        self.passwordLoginButton = UIButton()
        operateView.addSubview(self.passwordLoginButton)
        self.passwordLoginButton.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(0)
            make.height.equalTo(44)
        }
        self.passwordLoginButton.setTitleColor(YCStyleColor.black, for: .normal)
        self.passwordLoginButton.setTitle(YCLanguageHelper.getString(key: "PasswordLoginLabel"), for: .normal)
        self.passwordLoginButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.passwordLoginButton.addTarget(self, action: #selector(self.passwordLoginButtonClick), for: .touchUpInside)
        self.passwordLoginButton.alpha = 1
        self.passwordLoginButton.isHidden = true
        
        self.codeLoginButton = UIButton()
        operateView.addSubview(self.codeLoginButton)
        self.codeLoginButton.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(0)
            make.height.equalTo(44)
        }
        self.codeLoginButton.setTitleColor(YCStyleColor.black, for: .normal)
        self.codeLoginButton.setTitle(YCLanguageHelper.getString(key: "CodeLoginLabel"), for: .normal)
        self.codeLoginButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.codeLoginButton.addTarget(self, action: #selector(self.codeLoginButtonClick), for: .touchUpInside)
        self.codeLoginButton.alpha = 0
    }
    
    func initLoginView(){
        
        self.titleLabel = UILabel()
        self.view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.passwordLoginButton.snp.bottom).offset(5)
            make.right.equalTo(0)
            make.left.equalTo(0)
        }
        titleLabel.textColor = YCStyleColor.black
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.text = YCLanguageHelper.getString(key: "LoginTitle")
        
        let phoneView = UIView()
        self.view.addSubview(phoneView)
        phoneView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.centerX.equalTo(titleLabel).offset(0)
            make.width.equalTo(280)
            make.height.equalTo(44)
        }
        phoneView.layer.borderColor = YCStyleColor.gray.cgColor
        phoneView.layer.borderWidth = 1
        phoneView.layer.cornerRadius = 4
        
        self.areaCodeLabel = UILabel()
        self.view.addSubview(self.areaCodeLabel)
        self.areaCodeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(phoneView).offset(0)
            make.centerY.equalTo(phoneView).offset(0)
            make.width.equalTo(60)
            make.height.equalTo(44)
        }
        self.areaCodeLabel.textColor = YCStyleColor.black
        self.areaCodeLabel.font = UIFont.systemFont(ofSize: 18)
        self.areaCodeLabel.textAlignment = .center
        self.areaCodeLabel.text = "+86"
        
        let lineView = UIView()
        self.view.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(phoneView).offset(60)
            make.centerY.equalTo(phoneView).offset(0)
            make.width.equalTo(1)
            make.height.equalTo(28)
        }
        lineView.backgroundColor = YCStyleColor.gray
        
        self.phoneTextInput = UITextField()
        self.view.addSubview(self.phoneTextInput)
        self.phoneTextInput.snp.makeConstraints { (make) in
            make.right.equalTo(phoneView).offset(-10)
            make.centerY.equalTo(phoneView).offset(0)
            make.width.equalTo(200)
            make.height.equalTo(44)
        }
        self.phoneTextInput.borderStyle = .none
        self.phoneTextInput.placeholder = YCLanguageHelper.getString(key: "PhonePlaceholder")
        self.phoneTextInput.font = UIFont.systemFont(ofSize: 18)
        self.phoneTextInput.textColor = YCStyleColor.black
        self.phoneTextInput.keyboardType = .numberPad
        self.phoneTextInput.clearButtonMode = .whileEditing
        self.phoneTextInput.delegate = self
        
        self.codeLoginView = UIView()
        self.view.addSubview(self.codeLoginView)
        self.codeLoginView.snp.makeConstraints { (make) in
            make.top.equalTo(phoneView.snp.bottom).offset(20)
            make.centerX.equalTo(titleLabel).offset(0)
            make.width.equalTo(280)
            make.height.equalTo(44)
        }
        
        let codeInputView = UIView()
        self.codeLoginView.addSubview(codeInputView)
        codeInputView.snp.makeConstraints { (make) in
            make.top.equalTo(self.codeLoginView)
            make.left.equalTo(self.codeLoginView)
            make.height.equalTo(self.codeLoginView)
            make.width.equalTo(190)
        }
        codeInputView.layer.borderColor = YCStyleColor.gray.cgColor
        codeInputView.layer.borderWidth = 1
        codeInputView.layer.cornerRadius = 4
        
        self.codeTextInput = UITextField()
        self.view.addSubview(self.codeTextInput)
        self.codeTextInput.snp.makeConstraints { (make) in
            make.left.equalTo(codeInputView).offset(10)
            make.centerY.equalTo(codeInputView).offset(0)
            make.width.equalTo(codeInputView).offset(-20)
            make.height.equalTo(codeInputView)
        }
        self.codeTextInput.borderStyle = .none
        self.codeTextInput.placeholder = YCLanguageHelper.getString(key: "CodePlaceholder")
        self.codeTextInput.font = UIFont.systemFont(ofSize: 18)
        self.codeTextInput.textColor = YCStyleColor.black
        self.codeTextInput.keyboardType = .numberPad
        self.codeTextInput.clearButtonMode = .whileEditing
        self.codeTextInput.delegate = self
        
        let sendCodeLabelView = UIView()
        self.codeLoginView.addSubview(sendCodeLabelView)
        sendCodeLabelView.snp.makeConstraints { (make) in
            make.top.equalTo(self.codeLoginView)
            make.right.equalTo(self.codeLoginView)
            make.height.equalTo(self.codeLoginView)
            make.width.equalTo(85)
        }
        sendCodeLabelView.layer.borderColor = YCStyleColor.gray.cgColor
        sendCodeLabelView.layer.borderWidth = 1
        sendCodeLabelView.layer.cornerRadius = 4
        
        self.sendCodeLabel = UILabel()
        sendCodeLabelView.addSubview(self.sendCodeLabel)
        self.sendCodeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(sendCodeLabelView)
            make.right.equalTo(sendCodeLabelView)
            make.height.equalTo(sendCodeLabelView)
            make.width.equalTo(sendCodeLabelView)
        }
        self.sendCodeLabel.textColor = YCStyleColor.black
        self.sendCodeLabel.font = UIFont.systemFont(ofSize: 14)
        self.sendCodeLabel.textAlignment = .center
        self.sendCodeLabel.text = YCLanguageHelper.getString(key: "SendCodeLabel")
        
        let sendCodeTap = UITapGestureRecognizer(target: self, action: #selector(self.sendCodeTapHandler))
        self.sendCodeLabel.isUserInteractionEnabled = true
        self.sendCodeLabel.addGestureRecognizer(sendCodeTap)
        
        self.passwordLoginView = UIView()
        self.view.addSubview(self.passwordLoginView)
        self.passwordLoginView.snp.makeConstraints { (make) in
            make.top.equalTo(phoneView.snp.bottom).offset(20)
            make.centerX.equalTo(titleLabel).offset(0)
            make.width.equalTo(280)
            make.height.equalTo(44)
        }
        self.passwordLoginView.layer.borderColor = YCStyleColor.gray.cgColor
        self.passwordLoginView.layer.borderWidth = 1
        self.passwordLoginView.layer.cornerRadius = 4
        self.passwordLoginView.alpha = 0
        
        self.passwordTextInput = UITextField()
        self.view.addSubview(self.passwordTextInput)
        self.passwordTextInput.snp.makeConstraints { (make) in
            make.left.equalTo(self.passwordLoginView).offset(10)
            make.centerY.equalTo(self.passwordLoginView).offset(0)
            make.width.equalTo(self.passwordLoginView).offset(-20)
            make.height.equalTo(self.passwordLoginView)
        }
        self.passwordTextInput.borderStyle = .none
        self.passwordTextInput.placeholder = YCLanguageHelper.getString(key: "PasswordPlcceholder")
        self.passwordTextInput.font = UIFont.systemFont(ofSize: 18)
        self.passwordTextInput.textColor = YCStyleColor.black
        self.passwordTextInput.alpha = 0
        self.passwordTextInput.clearButtonMode = .whileEditing
        self.passwordTextInput.isSecureTextEntry = true
        self.passwordTextInput.keyboardType = .asciiCapable
        self.passwordTextInput.delegate = self
        
        self.loginButton = UIButton()
        self.view.addSubview(self.loginButton)
        self.loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.codeLoginView.snp.bottom).offset(20)
            make.centerX.equalTo(self.codeLoginView).offset(0)
            make.width.equalTo(280)
            make.height.equalTo(44)
        }
        self.loginButton.backgroundColor = YCStyleColor.red
        self.loginButton.layer.borderColor = YCStyleColor.red.cgColor
        self.loginButton.layer.borderWidth = 1
        self.loginButton.layer.cornerRadius = 4
        self.loginButton.setTitleColor(YCStyleColor.white, for: .normal)
        self.loginButton.setTitle(YCLanguageHelper.getString(key: "LoginLabel"), for: .normal)
        self.loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        self.loginButton.addTarget(self, action: #selector(self.loginButtonClick), for: .touchUpInside)
        self.loginOtherLabel = UILabel()
        self.view.addSubview(self.loginOtherLabel)
        self.loginOtherLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.loginButton.snp.bottom).offset(50)
            make.right.equalTo(0)
            make.left.equalTo(0)
        }
        self.loginOtherLabel.textAlignment = .center
        self.loginOtherLabel.textColor = YCStyleColor.gray
        self.loginOtherLabel.font = UIFont.systemFont(ofSize: 12)
        self.loginOtherLabel.text = YCLanguageHelper.getString(key: "LoginOtherAccountLabel")
        
        let centXGap = YCScreen.bounds.width / 4
        self.weiboLoginButton = UIButton()
        self.view.addSubview(self.weiboLoginButton)
        self.weiboLoginButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.loginOtherLabel.snp.bottom).offset(20)
            make.centerX.equalTo(self.loginButton).offset(centXGap)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.weiboLoginButton.setImage(UIImage(named: "weibo_icon"), for: .normal)
        self.weiboLoginButton.setImage(UIImage(named: "weibo_icon"), for: .highlighted)
        self.weiboLoginButton.addTarget(self, action: #selector(self.weiboLoginButtonClick), for: .touchUpInside)
        
        self.wechatLoginButton = UIButton()
        self.view.addSubview(self.wechatLoginButton)
        self.wechatLoginButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.loginOtherLabel.snp.bottom).offset(20)
            make.centerX.equalTo(self.loginButton).offset(0-centXGap)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.wechatLoginButton.setImage(UIImage(named: "wechat_icon"), for: .normal)
        self.wechatLoginButton.setImage(UIImage(named: "wechat_icon"), for: .highlighted)
        self.wechatLoginButton.addTarget(self, action: #selector(self.weChatLoginButtonClick), for: .touchUpInside)
        
        self.loadingView = YCLoadingView(style: .INSIDE)
        self.view.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(self.loginButton).offset(0)
        }
    }
    
    func hideLoadingView() {
        self.loginButton.isHidden = false
        self.view.isUserInteractionEnabled = true
        self.loadingView.stopAnimating()
    }
    
    func showLoadingView() {
        self.loginButton.isHidden = true
        self.view.isUserInteractionEnabled = false
        self.loadingView.startAnimating()
    }
    
    func resetViewController() {
        self.isCodeLogin = true
        self.isTiming = false
        if let time = self.sendCodeTime {
            time.cancel()
        }
        self.sendCodeTime = nil
        
        self.phoneTextInput.text = ""
        self.codeTextInput.text = ""
        self.passwordTextInput.text = ""
        self.sendCodeLabel.text = YCLanguageHelper.getString(key: "SendCodeLabel")
        self.currentTextInput = nil
        
        self.passwordLoginButton.alpha = 1
        self.codeLoginView.alpha = 1
        self.codeTextInput.alpha = 1
        self.codeLoginButton.alpha = 0
        self.passwordLoginView.alpha = 0
        self.passwordTextInput.alpha = 0
        self.isShow = false
    }
}

extension YCLoginViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.currentTextInput = textField
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.codeTextInput {
            if string.count == 0 {
                return true
            }else if range.length > 0 && string.count < 4 {
                return true
            }else if let text = self.codeTextInput.text, text.count > 3 {
                self.codeTextInput.text = String(text.prefix(4))
                return false
            }
        }else if textField == self.phoneTextInput {
            if let text = self.phoneTextInput.text{
                var isNeedReselect = false
                if string.count == 0 {
                    if range.location == (text.count-1) {
                        if text.count == 5 {
                            self.phoneTextInput.text = String(text.prefix(4))
                        }else if text.count == 10 {
                            self.phoneTextInput.text = String(text.prefix(9))
                        }
                        return true
                    }else{
                        isNeedReselect = true
                    }
                }else{
                    if range.location == text.count {
                        if text.count == 3 {
                            self.phoneTextInput.text = text+" "
                            return true
                        }else if text.count == 8 {
                            self.phoneTextInput.text = text+" "
                            return true
                        }else if text.count > 12 {
                            self.phoneTextInput.text = String(text.prefix(13))
                            if self.codeTextInput.alpha == 1 {
                                self.codeTextInput.becomeFirstResponder()
                            }else if self.passwordTextInput.alpha == 1{
                                self.passwordTextInput.becomeFirstResponder()
                            }
                            return false
                        }
                    }else {
                        isNeedReselect = true
                    }
                }
                if isNeedReselect {
                    let a = text.index(text.startIndex, offsetBy: 0)
                    let b = text.index(text.startIndex, offsetBy: range.location)
                    let end = text.count - (range.location + range.length)
                    let first = text[a..<b]
                    let secnd = text.suffix(end)
                    var newString = String(first) + string + String(secnd)
                    newString = newString.replacingOccurrences(of: " ", with: "")
                    var newS = ""
                    for (i, s) in newString.enumerated() {
                        if i > 10 {
                            break
                        }
                        newS = newS + String(s)
                        if (i == 2 || i == 6) && i < newString.count {
                            newS = newS + " "
                        }
                    }
                    self.phoneTextInput.text = newS
                    var startPosition = range.location
                    let position = newS.index(text.startIndex, offsetBy: startPosition)
                    let positionS = String(newS[position])
                    if string != "" {
                        startPosition = startPosition + 1
                    }
                    if positionS == " "{
                        startPosition = startPosition + 1
                    }
                    if let selectePosition = self.phoneTextInput.position(from: self.phoneTextInput.beginningOfDocument, offset: startPosition) {
                        if let selectRange = self.phoneTextInput.textRange(from: selectePosition, to: selectePosition) {
                            self.phoneTextInput.selectedTextRange = selectRange
                        }
                    }
                    return false
                }
            }
        }
        return true
    }
    
}

extension YCLoginViewController {
    
    @objc func closeButtonClick() {
        self.closeLoginView(loginSuccess: false)
    }
    
    @objc func sendCodeTapHandler() {
        if let phone = self.phoneTextInput.text, let zone = self.areaCodeLabel.text, !self.isTiming {
            let newPhone = phone.replacingOccurrences(of: " ", with: "")
            let newZone = zone.replacingOccurrences(of: "+", with: "")
            if Validate.phoneNum(newPhone).isRight {
                SMSSDK.getVerificationCode(by: .SMS, phoneNumber: newPhone, zone: newZone, template: "16259686") { (error) in
                    if error == nil {
                        
                    }else {
                        
                    }
                }
                self.codeTextInput.becomeFirstResponder()
                self.startTimer()
            }else {
                self.showTempAlert("", alertMessage: YCLanguageHelper.getString(key: "EnterIncorrectPhoneMessage"), view: self, completionBlock: {
                    self.phoneTextInput.becomeFirstResponder()
                })
            }
        }
    }
    
    func startTimer() {
        if self.sendCodeTime == nil {
            self.isTiming = true
            var timeCount = 60
            self.sendCodeTime = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            self.sendCodeTime!.schedule(deadline: .now(), repeating: .seconds(1))
            self.sendCodeTime!.setEventHandler {
                DispatchQueue.main.async {
                    if timeCount < 0 {
                        self.sendCodeLabel.text = YCLanguageHelper.getString(key: "ResendCodelLabel")
                    }else {
                        self.sendCodeLabel.text = "\(timeCount)s"
                    }
                    timeCount = timeCount - 1
                }
                if timeCount < -1 {
                    self.isTiming = false
                    self.sendCodeTime!.cancel()
                    self.sendCodeTime = nil
                }
            }
            self.sendCodeLabel.text = "\(timeCount)s"
            self.sendCodeTime!.resume()
        }
    }
    
    func stopTimer() {
        self.isTiming = false
        if self.sendCodeTime != nil {
            self.sendCodeTime!.cancel()
            self.sendCodeTime = nil
        }
        self.sendCodeLabel.text = YCLanguageHelper.getString(key: "ResendCodelLabel")
    }
    
    @objc func passwordLoginButtonClick() {
        UIView.animate(withDuration: 0.5, animations: {
            self.passwordLoginButton.alpha = 0
            self.codeLoginView.alpha = 0
            self.codeTextInput.alpha = 0
            
            self.codeLoginButton.alpha = 1
            self.passwordLoginView.alpha = 1
            self.passwordTextInput.alpha = 1
        }) { (_) in
            if YCScreen.bounds.height > 568 {
                self.phoneTextInput.becomeFirstResponder()
            }else {
                if self.phoneTextInput.isFirstResponder {
                    self.phoneTextInput.resignFirstResponder()
                }
                if self.codeTextInput.isFirstResponder {
                    self.codeTextInput.resignFirstResponder()
                }
            }
            self.isCodeLogin = false
        }
    }
    
    @objc func codeLoginButtonClick() {
        UIView.animate(withDuration: 0.5, animations: {
            self.passwordLoginButton.alpha = 1
            self.codeLoginView.alpha = 1
            self.codeTextInput.alpha = 1
            
            self.codeLoginButton.alpha = 0
            self.passwordLoginView.alpha = 0
            self.passwordTextInput.alpha = 0
        }) { (_) in
            if YCScreen.bounds.height > 568 {
                self.phoneTextInput.becomeFirstResponder()
            }else {
                if self.phoneTextInput.isFirstResponder {
                    self.phoneTextInput.resignFirstResponder()
                }
                if self.passwordTextInput.isFirstResponder {
                    self.passwordTextInput.resignFirstResponder()
                }
            }
            self.isCodeLogin = true
        }
    }
    
    @objc func loginButtonClick() {
        if let phone = self.phoneTextInput.text, let zone = self.areaCodeLabel.text {
            let newPhone = phone.replacingOccurrences(of: " ", with: "")
            let newZone = zone.replacingOccurrences(of: "+", with: "")
            if Validate.phoneNum(newPhone).isRight {
                if self.isCodeLogin {
                    if let code = self.codeTextInput.text {
                        if code.count < 4 {
                            self.showTempAlert("", alertMessage: YCLanguageHelper.getString(key: "EnterIncorrectCodeMessage"), view: self, completionBlock: {
                                self.codeTextInput.becomeFirstResponder()
                            })
                        }else {
                            self.showLoadingView()
                            SMSSDK.commitVerificationCode(code, phoneNumber: newPhone, zone: newZone, result: { (error) in
                                if error == nil {
                                    YCUserDomain().loginByPhoneAndPassword(areaCode: newZone, phone: newPhone, completionBlock: { (modelMode) in
                                        self.hideLoadingView()
                                        self.stopTimer()
                                        if let model = modelMode{
                                            if model.result {
                                                self.loginCompleteHandler(model)
                                            }else {
                                                if let message = model.message {
                                                    self.showSingleAlert("", alertMessage: message, view: self, compelecationBlock: {
                                                        self.codeTextInput.becomeFirstResponder()
                                                    })
                                                }
                                            }
                                        }
                                    })
                                }else {
                                    self.hideLoadingView()
                                    self.stopTimer()
                                    self.showSingleAlert("", alertMessage: YCLanguageHelper.getString(key: "IncorrectCodeMessage"), view: self, compelecationBlock: {
                                        self.codeTextInput.becomeFirstResponder()
                                    })
                                }
                            })
                        }
                    }
                }else {
                    if let pss = self.passwordTextInput.text {
                        self.showLoadingView()
                        YCUserDomain().loginByPhoneAndPassword(areaCode: newZone, phone: newPhone, password: pss, completionBlock: { (modelMode) in
                            self.hideLoadingView()
                            if let model = modelMode{
                                if model.result {
                                    self.loginCompleteHandler(model)
                                }else {
                                    if let message = model.message {
                                        self.showSingleAlert("", alertMessage: message, view: self, compelecationBlock: {
                                            self.passwordTextInput.becomeFirstResponder()
                                        })
                                    }
                                }
                            }
                        })
                    }
                }
            }else {
                self.showTempAlert("", alertMessage: YCLanguageHelper.getString(key: "EnterIncorrectPhoneMessage"), view: self, completionBlock: {
                    self.phoneTextInput.becomeFirstResponder()
                })
            }
        }
    }
    
    func loginCompleteHandler(_ model: YCDomainModel!, preUserIconURL: String = "") {
        if let loginUser = model.baseModel as? YCLoginUserModel {
            if YCUserManager.save(loginUser) {
                NotificationCenter.default.post(name: NSNotification.Name("LoginUserChange"), object: loginUser)
                if loginUser.active == 0{
                    if let nav = self.navigationController {
                        let setUserIcon = YCSetUserIconViewController.getInstance()
                        setUserIcon.completeBlock = self.completeBlock
                        setUserIcon.preUserIconURL = preUserIconURL
                        nav.pushViewController(setUserIcon, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            self.resetViewController()
                            YCLoginViewController.addInstance(instace: self)
                        }
                    }
                }else {
                    self.closeLoginView(loginSuccess: true)
                }
            }else {
                self.showSingleAlert("", alertMessage:  YCLanguageHelper.getString(key: "LoginFailedMessage"), view: self, compelecationBlock: {
                    self.phoneTextInput.becomeFirstResponder()
                })
            }
        }
    }
    
    @objc func weiboLoginButtonClick() {
        if WeiboSDK.isWeiboAppInstalled() {
            let request = WBAuthorizeRequest()
            request.scope = "all"
            // 此字段的内容可自定义, 在请求成功后会原样返回, 可用于校验或者区分登录来源
            //        request.userInfo = ["": ""]
            request.redirectURI = YCSocialConfigs.weibo.redirectURI
            WeiboSDK.send(request)
        }else {
            self.showSingleAlert(YCLanguageHelper.getString(key: "LoginFailedWeiboUninstall"), alertMessage: nil, view: self, compelecationBlock: nil)
        }
    }
    
    @objc func weiboLoginComplete(_ notify: Notification) {
        if self.isShow {
            if let dic = notify.object as? Dictionary<String, Any> {
                let weiboID = dic["idstr"] as! String
                let weiboNikeName = dic["name"] as! String
                let weiboSign = dic["description"] as! String
                var weiboGender = dic["gender"] as! String
                if weiboGender == "m" {
                    weiboGender = "male"
                }else if weiboGender == "f" {
                    weiboGender = "female"
                }else {
                    weiboGender = ""
                }
                let tweetCount = dic["statuses_count"] as! Int
                let followCount = dic["friends_count"] as! Int
                let fansCount = dic["followers_count"] as! Int
                
                let iconURL = dic["avatar_hd"] as! String
                
                let weiboUser = YCWeiboUserModel(weiboUserID: "", weiboID: weiboID, weiboNikeName: weiboNikeName, weiboSignature: weiboSign, weiboGender: weiboGender, weiboURL: "", iconJSON: nil, tweetCount: tweetCount, followCount: followCount, fansCount: fansCount)
                self.showLoadingView()
                YCUserDomain().loginByWeibo(weiboUser: weiboUser) { (modelMode) in
                    self.hideLoadingView()
                    if let model = modelMode{
                        if model.result {
                            self.loginCompleteHandler(model, preUserIconURL: iconURL)
                        }else {
                            if let message = model.message {
                                self.showSingleAlert("", alertMessage: message, view: self, compelecationBlock: {
                                    self.phoneTextInput.becomeFirstResponder()
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func weChatLoginButtonClick() {
        if WXApi.isWXAppInstalled() {
            let req = SendAuthReq()
            req.scope = "snsapi_userinfo"
            req.state = "default_state"
            WXApi.send(req)
        }else {
            self.showSingleAlert(YCLanguageHelper.getString(key: "LoginFailedWeChatUninstall"), alertMessage: nil, view: self, compelecationBlock: nil)
        }
    }
    
    @objc func weChatLoginComplet(_ notify: Notification) {
        if self.isShow {
            if let dic = notify.object as? Dictionary<String, Any> {
                let wechatOpenID = dic["openid"] as! String
                let wechatUnionID = dic["unionid"] as! String
                let wechatNikeName = dic["nickname"] as! String
                let gender = dic["sex"] as! Int
                var wechatGender = ""
                if gender == 1 {
                    wechatGender = "male"
                }else if gender == 2 {
                    wechatGender = "female"
                }else {
                    wechatGender = ""
                }
                let country = dic["country"] as! String
                let province = dic["province"] as! String
                let city = dic["city"] as! String
                
                let iconURL = dic["headimgurl"] as! String
                
                let wechatUser = YCWechatUserModel(wechatUserID: "", wechatOpenID: wechatOpenID, wechatUnionID: wechatUnionID, wechatNikeName: wechatNikeName, wechatGender: wechatGender, wechatCountry: country, wechatProvince: province, wechatCity: city, iconJSON: nil)
                
                self.showLoadingView()
                YCUserDomain().loginByWechat(wechatUser: wechatUser) { (modelMode) in
                    self.hideLoadingView()
                    if let model = modelMode{
                        if model.result {
                            self.loginCompleteHandler(model, preUserIconURL: iconURL)
                        }else {
                            if let message = model.message {
                                self.showSingleAlert("", alertMessage: message, view: self, compelecationBlock: {
                                    self.phoneTextInput.becomeFirstResponder()
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    func closeLoginView(loginSuccess: Bool) {
        if let currentText = self.currentTextInput {
            currentText.resignFirstResponder()
        }
        if loginSuccess, let complete = self.completeBlock {
            complete()
        }
        if let nv = self.navigationController {
            nv.dismiss(animated: true, completion: {
                self.resetViewController()
                YCLoginViewController.addInstance(instace: self)
            })
        }
        
    }
}
