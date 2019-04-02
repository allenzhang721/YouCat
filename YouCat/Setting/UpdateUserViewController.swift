//
//  UpdateUserViewController.swift
//  YouCat
//
//  Created by ting on 2018/12/3.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit

class YCUpdateNicknameViewController: UIViewController, YCContentStringProtocol, YCAlertProtocol {
    
    static var _instaceArray: [YCUpdateNicknameViewController] = [];
    
    static func getInstance() -> YCUpdateNicknameViewController{
        var _instance: YCUpdateNicknameViewController
        if _instaceArray.count > 0 {
            _instance = _instaceArray[0]
            _instaceArray.remove(at: 0)
            return _instance
        }else {
            _instance = YCUpdateNicknameViewController();
        }
        return _instance
    }
    
    static func addInstance(instace: YCUpdateNicknameViewController) {
        _instaceArray.append(instace)
    }
    
    var nicknameTextField:UITextField!
    var textNumberLabel: UILabel!
    var saveButton: UIButton!
    var oldValue: String = ""
    
    var loadingView: YCLoadingView!
    
    let maxText = 20
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        super.viewWillAppear(animated)
        self.setValue()
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
    
    func setValue() {
        if let user = YCUserManager.loginUser {
            self.oldValue = self.getNicknameString(user: user)
            self.nicknameTextField.text = self.oldValue
            self.textNumberLabel.text = "\(self.oldValue.count)/\(maxText)"
        }else {
            self.resetViewController()
        }
        self.saveButton.isEnabled = false
        self.nicknameTextField.becomeFirstResponder()
    }
    
    func initView() {
        self.view.backgroundColor = YCStyleColor.white
        self.initOperateButton()
        self.nicknameTextField = UITextField()
        self.view.addSubview(self.nicknameTextField)
        self.nicknameTextField.snp.makeConstraints { (make) in
            make.left.equalTo(22)
            make.right.equalTo(-22)
            make.top.equalTo(YCScreen.safeArea.top+54)
            make.height.equalTo(38)
        }
        self.nicknameTextField.delegate = self
        self.nicknameTextField.borderStyle = .none
        self.nicknameTextField.placeholder = YCLanguageHelper.getString(key: "NicknamePlaceholder")
        self.nicknameTextField.font = UIFont.systemFont(ofSize: 18)
        self.nicknameTextField.textColor = YCStyleColor.black
        self.nicknameTextField.clearButtonMode = .whileEditing
        
        
        let lineView = UIView()
        self.view.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(self.nicknameTextField.snp.bottom).offset(0)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(1)
        }
        lineView.backgroundColor = YCStyleColor.grayWhite
        
        self.textNumberLabel = UILabel()
        self.view.addSubview(self.textNumberLabel)
        self.textNumberLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(8)
            make.left.equalTo(22)
            make.right.equalTo(-22)
        }
        self.textNumberLabel.textColor = YCStyleColor.black
        self.textNumberLabel.font = UIFont.systemFont(ofSize: 12)
        
        self.loadingView = YCLoadingView(style: .POP)
        self.view.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(self.view).offset(0)
        }
    }
    
    func hideLoadingView() {
        self.view.isUserInteractionEnabled = true
        self.loadingView.stopAnimating()
    }
    
    func showLoadingView() {
        self.view.isUserInteractionEnabled = false
        self.loadingView.startAnimating()
    }
    
    func initOperateButton() {
        let backButton=UIButton()
        backButton.setImage(UIImage(named: "back_black"), for: .normal)
        backButton.setImage(UIImage(named: "back_black"), for: .highlighted)
        backButton.addTarget(self, action: #selector(self.backButtonClick), for: .touchUpInside)
        self.view.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.top.equalTo(YCScreen.safeArea.top)
            make.left.equalTo(10)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        self.saveButton=UIButton()
        self.saveButton.addTarget(self, action: #selector(self.saveButtonClick), for: .touchUpInside)
        self.view.addSubview(self.saveButton)
        self.saveButton.snp.makeConstraints { (make) in
            make.top.equalTo(YCScreen.safeArea.top)
            make.right.equalTo(-10)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.saveButton.setTitle(YCLanguageHelper.getString(key: "SaveLabel"), for: .normal)
        self.saveButton.setTitle(YCLanguageHelper.getString(key: "SaveLabel"), for: .highlighted)
        self.saveButton.setTitleColor(YCStyleColor.red, for: .normal)
        self.saveButton.setTitleColor(YCStyleColor.grayWhite, for: .disabled)
        
        let title = UILabel()
        self.view.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.centerY.equalTo(saveButton).offset(0)
            make.centerX.equalTo(self.view).offset(0)
        }
        title.textColor = YCStyleColor.black
        title.font = UIFont.systemFont(ofSize: 18)
        title.textAlignment = .center
        title.text = YCLanguageHelper.getString(key: "EditNicknameTitle")
    }
}

extension YCUpdateNicknameViewController: UITextFieldDelegate {
    
    @objc func backButtonClick() {
        self.nicknameTextField.resignFirstResponder()
        if let text = self.nicknameTextField.text {
            if text != self.oldValue && text != "" {
                self.showSelectedAlert("", alertMessage: YCLanguageHelper.getString(key: "SaveChangeTitle"), okAlertLabel: YCLanguageHelper.getString(key: "SaveLabel"), cancelAlertLabel: YCLanguageHelper.getString(key: "QuitLabel"), view: self, compelecationBlock: { (result) in
                    if result {
                        self.saveButtonClick()
                    }else {
                        self.backHandler()
                    }
                })
            }else {
                self.backHandler()
            }
        }else {
            self.backHandler()
        }
    }
    
    func backHandler() {
        self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.resetViewController()
            YCUpdateNicknameViewController.addInstance(instace: self)
        }
    }
    
    @objc func saveButtonClick() {
        self.nicknameTextField.resignFirstResponder()
        self.saveHandler({ (result) in
            if result {
                self.backHandler()
            }else {
                self.showSingleAlert("", alertMessage: YCLanguageHelper.getString(key: "EditNicknameErrorMessage"), view: self, compelecationBlock: {
                    self.nicknameTextField.becomeFirstResponder()
                })
            }
        })
    }
    
    func saveHandler(_ completeBlock: ((Bool)->Void)?) {
        if let nickName = self.nicknameTextField.text {
            self.showLoadingView()
            YCUserDomain().updateNikeName(nikeName: nickName) { (modelMode) in
                self.hideLoadingView()
                if let model = modelMode, model.result, let user = model.baseModel as? YCLoginUserModel {
                    if YCUserManager.save(user) {
                        if let complete = completeBlock{
                            complete(true)
                        }
                    }else {
                        if let complete = completeBlock{
                            complete(false)
                        }
                    }
                }else {
                    if let complete = completeBlock{
                        complete(false)
                    }
                }
            }
        }
    }
    
    func resetViewController() {
        self.oldValue = ""
        self.nicknameTextField.text = ""
        self.textNumberLabel.text = "\(0)/\(maxText)"
        self.saveButton.isEnabled = false
        self.nicknameTextField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.nicknameTextField, let text = textField.text {
            let newText = NSString(string: text).replacingCharacters(in: range, with: string)
            if string.count == 0 {
                
            }else if newText.count > maxText {
                return false
            }
            if newText == self.oldValue || newText == "" {
                self.saveButton.isEnabled = false
            }else {
                self.saveButton.isEnabled = true
            }
            self.textNumberLabel.text = "\(newText.count)/\(maxText)"
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.textNumberLabel.text = "\(0)/\(maxText)"
        self.saveButton.isEnabled = false
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.saveButton.isEnabled {
            self.saveButtonClick()
        }
        return true
    }
}

extension YCUpdateNicknameViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
    
}


class YCUpdateSignViewController: UIViewController, YCContentStringProtocol, YCAlertProtocol {
    
    static var _instaceArray: [YCUpdateSignViewController] = [];
    
    static func getInstance() -> YCUpdateSignViewController{
        var _instance: YCUpdateSignViewController
        if _instaceArray.count > 0 {
            _instance = _instaceArray[0]
            _instaceArray.remove(at: 0)
            return _instance
        }else {
            _instance = YCUpdateSignViewController();
        }
        return _instance
    }
    
    static func addInstance(instace: YCUpdateSignViewController) {
        _instaceArray.append(instace)
    }
    
    var signTextView: UITextView!
    var textNumberLabel: UILabel!
    var saveButton: UIButton!
    var oldValue: String = ""
    
    var loadingView: YCLoadingView!
    
    let maxText = 60
    
    var placeholderLabel:UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        super.viewWillAppear(animated)
        self.setValue()
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
    
    func setValue() {
        if let user = YCUserManager.loginUser {
            self.oldValue = self.getSignString(sign: user.signature)
            self.signTextView.text = self.oldValue
            self.textNumberLabel.text = "\(self.oldValue.count)/\(maxText)"
        }else {
            self.resetViewController()
        }
        if self.oldValue == "" {
            self.placeholderLabel.isHidden = false
        }
        self.saveButton.isEnabled = false
        self.signTextView.becomeFirstResponder()
    }
    
    func initView() {
        self.view.backgroundColor = YCStyleColor.white
        self.initOperateButton()
        self.signTextView = UITextView()
        self.view.addSubview(self.signTextView)
        self.signTextView.snp.makeConstraints { (make) in
            make.left.equalTo(22)
            make.right.equalTo(-22)
            make.top.equalTo(YCScreen.safeArea.top+54)
        }
        self.signTextView.delegate = self
        self.signTextView.isScrollEnabled = false
        self.signTextView.backgroundColor = YCStyleColor.white
        self.signTextView.font = UIFont.systemFont(ofSize: 18)
        self.signTextView.textColor = YCStyleColor.black
        
        self.placeholderLabel = UILabel()
        self.view.addSubview(self.placeholderLabel)
        self.placeholderLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.signTextView).offset(5)
            make.right.equalTo(self.signTextView).offset(-5)
            make.centerY.equalTo(self.signTextView).offset(0)
        }
        self.placeholderLabel.font = UIFont.systemFont(ofSize: 18)
        self.placeholderLabel.textColor = YCStyleColor.grayWhite
        self.placeholderLabel.isHidden = true
        self.placeholderLabel.text = YCLanguageHelper.getString(key: "BioPlaceholder")
        
        let lineView = UIView()
        self.view.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(self.signTextView.snp.bottom).offset(0)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(1)
        }
        lineView.backgroundColor = YCStyleColor.grayWhite
        
        self.textNumberLabel = UILabel()
        self.view.addSubview(self.textNumberLabel)
        self.textNumberLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(8)
            make.left.equalTo(22)
            make.right.equalTo(-22)
        }
        self.textNumberLabel.textColor = YCStyleColor.black
        self.textNumberLabel.font = UIFont.systemFont(ofSize: 12)
        
        self.loadingView = YCLoadingView(style: .POP)
        self.view.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(self.view).offset(0)
        }
    }
    
    func hideLoadingView() {
        self.view.isUserInteractionEnabled = true
        self.loadingView.stopAnimating()
    }
    
    func showLoadingView() {
        self.view.isUserInteractionEnabled = false
        self.loadingView.startAnimating()
    }
    
    func initOperateButton() {
        let backButton=UIButton()
        backButton.setImage(UIImage(named: "back_black"), for: .normal)
        backButton.setImage(UIImage(named: "back_black"), for: .highlighted)
        backButton.addTarget(self, action: #selector(self.backButtonClick), for: .touchUpInside)
        self.view.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.top.equalTo(YCScreen.safeArea.top)
            make.left.equalTo(10)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        self.saveButton=UIButton()
        self.saveButton.addTarget(self, action: #selector(self.saveButtonClick), for: .touchUpInside)
        self.view.addSubview(self.saveButton)
        self.saveButton.snp.makeConstraints { (make) in
            make.top.equalTo(YCScreen.safeArea.top)
            make.right.equalTo(-10)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.saveButton.setTitle(YCLanguageHelper.getString(key: "SaveLabel"), for: .normal)
        self.saveButton.setTitle(YCLanguageHelper.getString(key: "SaveLabel"), for: .highlighted)
        self.saveButton.setTitleColor(YCStyleColor.red, for: .normal)
        self.saveButton.setTitleColor(YCStyleColor.grayWhite, for: .disabled)
        
        let title = UILabel()
        self.view.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.centerY.equalTo(saveButton).offset(0)
            make.centerX.equalTo(self.view).offset(0)
        }
        title.textColor = YCStyleColor.black
        title.font = UIFont.systemFont(ofSize: 18)
        title.textAlignment = .center
        title.text = YCLanguageHelper.getString(key: "EditBioTitle")
    }
}


extension YCUpdateSignViewController: UITextViewDelegate {
    
    @objc func backButtonClick() {
        self.signTextView.resignFirstResponder()
        if let text = self.signTextView.text {
            if text != self.oldValue && text != "" {
                self.showSelectedAlert("", alertMessage: YCLanguageHelper.getString(key: "SaveChangeTitle"), okAlertLabel: YCLanguageHelper.getString(key: "SaveLabel"), cancelAlertLabel: YCLanguageHelper.getString(key: "QuitLabel"), view: self, compelecationBlock: { (result) in
                    if result {
                        self.saveButtonClick()
                    }else {
                        self.backHandler()
                    }
                })
            }else {
                self.backHandler()
            }
        }else {
            self.backHandler()
        }
    }
    
    func backHandler() {
        self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.resetViewController()
            YCUpdateSignViewController.addInstance(instace: self)
        }
    }
    
    @objc func saveButtonClick() {
        self.signTextView.resignFirstResponder()
        self.saveHandler({ (result) in
            if result {
                self.backHandler()
            }else {
                self.showSingleAlert("", alertMessage: YCLanguageHelper.getString(key: "EditBioErrorMessage"), view: self, compelecationBlock: {
                    self.signTextView.becomeFirstResponder()
                })
            }
        })
    }
    
    func saveHandler(_ completeBlock: ((Bool)->Void)?) {
        if let sign = self.signTextView.text {
            var chaIndex = 0
            for character in sign{
                if character != "\n" {
                    break
                }
                chaIndex = chaIndex + 1
            }
            var newSign = sign
            if chaIndex > 0 {
                let newCount = sign.count - chaIndex
                newSign = String(sign.suffix(newCount))
            }
            self.showLoadingView()
            YCUserDomain().updateSingature(singature: newSign, completionBlock: { (modelMode) in
                self.hideLoadingView()
                if let model = modelMode, model.result, let user = model.baseModel as? YCLoginUserModel {
                    if YCUserManager.save(user) {
                        if let complete = completeBlock{
                            complete(true)
                        }
                    }else {
                        if let complete = completeBlock{
                            complete(false)
                        }
                    }
                }else {
                    if let complete = completeBlock{
                        complete(false)
                    }
                }
            })
        }
    }
    
    func resetViewController() {
        self.signTextView.text = ""
        self.textNumberLabel.text = "\(0)/\(maxText)"
        self.saveButton.isEnabled = false
        self.signTextView.resignFirstResponder()
        self.oldValue = ""
        self.placeholderLabel.isHidden = true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let nowText = textView.text {
            let newText = NSString(string: nowText).replacingCharacters(in: range, with: text)
            if text.count == 0 {
            }else {
                if newText.count > self.maxText {
                    return false
                }
                var chaIndex = 0
                for character in newText{
                    if character == "\n" {
                        chaIndex = chaIndex + 1
                    }
                }
                if chaIndex > 4 {
                    return false
                }
            }
            if newText == self.oldValue {
                self.saveButton.isEnabled = false
            }else {
                self.saveButton.isEnabled = true
            }
            if newText == "" {
                self.placeholderLabel.isHidden = false
                self.saveButton.isEnabled = false
            }else {
                self.placeholderLabel.isHidden = true
            }
            self.textNumberLabel.text = "\(newText.count)/\(maxText)"
        }
        return true
    }
}

extension YCUpdateSignViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
    
}
