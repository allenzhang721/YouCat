//
//  SetUserIconViewController.swift
//  YouCat
//
//  Created by ting on 2018/11/24.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
import Photos
import AVKit
import Kingfisher
import SwiftyJSON

class YCSetUserIconViewController: UIViewController, YCImageProtocol, YCContentStringProtocol {
    
    static var _instaceArray: [YCSetUserIconViewController] = [];
    
    static func getInstance() -> YCSetUserIconViewController{
        var _instance: YCSetUserIconViewController
        if _instaceArray.count > 0 {
            _instance = _instaceArray[0]
            _instaceArray.remove(at: 0)
            return _instance
        }else {
            _instance = YCSetUserIconViewController();
        }
        return _instance
    }
    
    static func addInstance(instace: YCSetUserIconViewController) {
        _instaceArray.append(instace)
    }
    
    var completeBlock: (() -> Void)?

    
    var preUserIconURL: String = ""
    var userIcon: UIImageView!
    var nickNameTextInput: UITextField!
    var saveButton: UIButton!
    
    var textNumberLabel: UILabel!
    let maxText = 20
    var loadingView:YCLoadingView!
    
    var changeIcon: UIImage? = nil
    var oldValue:String = ""
    
    var isFirst = true
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
        self.setValue()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isFirst = false
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
        if self.isFirst {
            if let user = YCUserManager.loginUser {
                if self.preUserIconURL == "" {
                    if let icon = user.icon {
                        let imgPath = icon.imagePath
                        if imgPath != "", let imgURL = URL(string: imgPath){
                            self.userIcon.kf.setImage(with: ImageResource(downloadURL: imgURL), placeholder: UIImage(named: "default_icon"), options: nil, progressBlock: nil, completionHandler: nil)
                        }else {
                            self.userIcon.image = UIImage(named: "default_icon")
                        }
                    }
                    self.saveButton.isEnabled = false
                }else if let imgURL = URL(string: self.preUserIconURL){
                    self.userIcon.kf.setImage(with: ImageResource(downloadURL: imgURL), placeholder: UIImage(named: "default_icon"), options: nil, progressBlock: nil) { (img, err, type, url) in
                        if let _ = err {
                            
                        }else if let image = img {
                            self.changeIcon = image
                            self.saveButton.isEnabled = true
                        }
                    }
                }else {
                    self.userIcon.image = UIImage(named: "default_icon")
                    self.saveButton.isEnabled = false
                }
                self.oldValue =  user.nikeName//self.getNicknameString(user: user)
                self.nickNameTextInput.text = self.oldValue
                self.textNumberLabel.text = "\(self.oldValue.count)/\(maxText)"
            }else {
                self.resetViewController()
                self.saveButton.isEnabled = false
            }
            self.nickNameTextInput.becomeFirstResponder()
        }
    }
    
    func initView() {
        self.view.backgroundColor = YCStyleColor.white
        self.initOperateButton()
        self.initSetUserIconView()
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
        let titleLabel = UILabel()
        operateView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(0)
            make.width.equalTo(100)
            make.height.equalTo(44)
        }
        titleLabel.text = YCLanguageHelper.getString(key: "SettingLabel")
        titleLabel.textColor = YCStyleColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 26)
        
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
    }
    
    func initSetUserIconView() {
        
        self.userIcon = UIImageView()
        self.view.addSubview(self.userIcon)
        self.userIcon.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view).offset(0)
            make.top.equalTo(YCScreen.safeArea.top + 54)
            make.width.equalTo(88)
            make.height.equalTo(88)
        }
        self.cropImageCircle(self.userIcon, 44)
        self.userIcon.image = UIImage(named: "default_icon")
        
        let iconChangeButton = UIButton()
        self.view.addSubview(iconChangeButton)
        iconChangeButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.userIcon).offset(0)
            make.centerY.equalTo(self.userIcon).offset(0)
            make.width.equalTo(self.userIcon).offset(0)
            make.height.equalTo(self.userIcon).offset(0)
        }
        iconChangeButton.setImage(UIImage(named: "icon_change"), for: .normal)
        iconChangeButton.addTarget(self, action: #selector(self.changeIconButtonClick), for: .touchUpInside)
        
        self.nickNameTextInput = UITextField()
        self.view.addSubview(self.nickNameTextInput)
        self.nickNameTextInput.snp.makeConstraints { (make) in
            make.top.equalTo(self.userIcon.snp.bottom).offset(20)
            make.left.equalTo(22)
            make.right.equalTo(-22)
            make.height.equalTo(38)
        }
        self.nickNameTextInput.borderStyle = .none
        self.nickNameTextInput.placeholder = YCLanguageHelper.getString(key: "NicknamePlaceholder")
        self.nickNameTextInput.font = UIFont.systemFont(ofSize: 18)
        self.nickNameTextInput.textColor = YCStyleColor.black
        self.nickNameTextInput.clearButtonMode = .whileEditing
        self.nickNameTextInput.delegate = self
        
        let lineView = UIView()
        self.view.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(self.nickNameTextInput.snp.bottom).offset(0)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(1)
        }
        lineView.backgroundColor = YCStyleColor.red
        
        self.textNumberLabel = UILabel()
        self.view.addSubview(self.textNumberLabel)
        self.textNumberLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(8)
            make.left.equalTo(22)
            make.right.equalTo(-22)
        }
        self.textNumberLabel.textColor = YCStyleColor.black
        self.textNumberLabel.font = UIFont.systemFont(ofSize: 12)
        
        self.saveButton = UIButton()
        self.view.addSubview(self.saveButton)
        self.saveButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.textNumberLabel.snp.bottom).offset(20)
            make.centerX.equalTo(self.view).offset(0)
            make.width.equalTo(150)
            make.height.equalTo(44)
        }
        self.saveButton.setTitleColor(YCStyleColor.red, for: .normal)
        self.saveButton.setTitleColor(YCStyleColor.grayWhite, for: .disabled)
        self.saveButton.setTitle(YCLanguageHelper.getString(key: "SaveLabel"), for: .normal)
        self.saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        self.saveButton.addTarget(self, action: #selector(self.saveButtonClick), for: .touchUpInside)
        
        self.loadingView = YCLoadingView(style: .INSIDE)
        self.view.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(self.saveButton).offset(0)
        }
    }
    
    func hideLoadingView() {
        self.saveButton.isHidden = false
        self.view.isUserInteractionEnabled = true
        self.loadingView.stopAnimating()
    }
    
    func showLoadingView() {
        self.saveButton.isHidden = true
        self.view.isUserInteractionEnabled = false
        self.loadingView.startAnimating()
    }
}

extension YCSetUserIconViewController: YCAlertProtocol {
    
    @objc func closeButtonClick() {
        self.closeView()
    }
    
    @objc func saveButtonClick() {
        self.saveHandler(true)
    }
    
    func saveHandler(_ saveAll: Bool) {
        if let user = YCUserManager.loginUser, let nickName = self.nickNameTextInput.text {
            let dic = user.getData()
            let newUser = YCLoginUserModel(JSON(dic))
            if let icon = self.changeIcon {
                self.nickNameTextInput.resignFirstResponder()
                let imageName = YCIDGenerator.generateID()
                let userIconKey = imageName+".jpg"
                self.showLoadingView()
                let cropImg = compressIconImage(icon)
                YCUploadDomain().uploadImageDate(cropImg, imageKey: userIconKey, imageType: "jpg", progressBlock: nil) { (result, key, img) in
                    if result, let image = img {
                        let imgW = Float(image.size.width)
                        let imgH = Float(image.size.height)
                        let iconModel = YCImageModel(imageID: "", imagePath: key, snapShotPath: "", imageType: "jpg", imageIndex: 0, imageWidth: imgW, imageHeight: imgH)
                        newUser.icon = iconModel
                        if saveAll {
                           newUser.nikeName = nickName
                        }
                        self.preUserIconURL = ""
                        self.changeIcon = nil
                        YCUserDomain().updateUserInfo(user: newUser, completionBlock: { (modelMode) in
                            if let model = modelMode, model.result, let loginUser = model.baseModel as? YCLoginUserModel{
                                if YCUserManager.save(loginUser) {
                                    self.hideLoadingView()
                                    self.closeView()
                                }else {
                                    self.uploadFailed()
                                }
                            }else {
                                self.uploadFailed()
                            }
                        })
                    }else {
                        self.uploadFailed()
                    }
                }
            }else if saveAll {
                newUser.nikeName = nickName
                self.showLoadingView()
                YCUserDomain().updateUserInfo(user: newUser, completionBlock: { (modelMode) in
                    if let model = modelMode, model.result, let loginUser = model.baseModel as? YCLoginUserModel{
                        if YCUserManager.save(loginUser) {
                            self.hideLoadingView()
                            self.closeView()
                        }else {
                            self.uploadFailed()
                        }
                    }else {
                        self.uploadFailed()
                    }
                })
            }
        }
    }
    
    func uploadFailed() {
        self.hideLoadingView()
        self.showSingleAlert("", alertMessage: YCLanguageHelper.getString(key: "SettingUserInfoErrorMessage"), view: self) {
            self.nickNameTextInput.becomeFirstResponder()
        }
    }
    
    @objc func changeIconButtonClick() {
        self.nickNameTextInput.resignFirstResponder()
        var alertArray:Array<[String : String]> = []
        alertArray.append(["title":YCLanguageHelper.getString(key: "PhotoLabel")])
        alertArray.append(["title":YCLanguageHelper.getString(key: "LibraryLabel")])
        self.showSheetAlert("", alertMessage: YCLanguageHelper.getString(key: "IconTitle"), okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
            if index == 0 {
                self.openCamera()
            }else if index == 1 {
                self.openPhoteLibrary()
            }else if index == -1 {
                self.nickNameTextInput.becomeFirstResponder()
            }
        }
    }
    
    func closeView() {
        if self.preUserIconURL != "" {
            self.saveHandler(false)
        }else {
            if let complete = self.completeBlock {
                complete()
            }
            self.navigationController?.dismiss(animated: true, completion: { () -> Void in
                self.resetViewController()
                YCSetUserIconViewController.addInstance(instace: self)
            })
        }
    }
    
    func resetViewController() {
        self.isFirst = true
        self.nickNameTextInput.text = ""
        self.nickNameTextInput.resignFirstResponder()
        self.changeIcon = nil
        self.userIcon.image = UIImage(named: "default_icon")
        self.completeBlock = nil
        self.preUserIconURL = ""
    }
    
    func openPhoteLibrary() {
        let pick: UIImagePickerController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .notDetermined:
                    break
                case .restricted: //此应用程序没有被授权访问的照片数据
                    gotoSetting(title: "", mesage: YCLanguageHelper.getString(key: "LibraryAccessTitle"), view: self)
                    break
                case .denied: //用户已经明确否认了这一照片数据的应用程序
                    gotoSetting(title: "", mesage: YCLanguageHelper.getString(key: "LibraryAccessTitle"), view: self)
                    break
                case .authorized: //已经有权限
                    pick.delegate = self
                    pick.allowsEditing = true
                    pick.sourceType = .photoLibrary
                    self.present(pick, animated: true, completion: {
                        
                    })
                    break;
                }
            })
        }
    }
    
    func openCamera(){
        let pick: UIImagePickerController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (ist) in
                let status = AVCaptureDevice.authorizationStatus(for: .video)
                if status == .authorized{ //获得权限
                    pick.delegate = self
                    pick.allowsEditing = true
                    pick.sourceType = .camera
                    self.present(pick, animated: true, completion: {
                        
                    })
                }else if status == .denied || status == .restricted {
                    gotoSetting(title: "", mesage: YCLanguageHelper.getString(key: "CameraAccessTitle"), view: self)
                }
            })
        }
    }
}

extension YCSetUserIconViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            self.changeUserIcon(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            self.changeUserIcon(originalImage)
        }
        dismiss(animated: true, completion: nil)
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func changeUserIcon(_ icon:UIImage){
        self.changeIcon = icon
        self.userIcon.image = icon
        self.nickNameTextInput.becomeFirstResponder()
        if let newText = self.nickNameTextInput.text {
            if newText == "" || (newText == self.oldValue && self.changeIcon == nil) {
                self.saveButton.isEnabled = false
            }else {
                self.saveButton.isEnabled = true
            }
        }else {
            self.saveButton.isEnabled = false
        }
        self.preUserIconURL = ""
    }
}

extension YCSetUserIconViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.nickNameTextInput, let text = textField.text {
            let newText = NSString(string: text).replacingCharacters(in: range, with: string)
            if string.count == 0 {
                
            }else if newText.count > maxText {
                return false
            }
            if newText == "" || (newText == self.oldValue && self.changeIcon == nil) {
                self.saveButton.isEnabled = false
            }else {
                self.saveButton.isEnabled = true
            }
            self.textNumberLabel.text = "\(newText.count)/\(maxText)"
        }
        return true
    }
}
