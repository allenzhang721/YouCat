//
//  SettingViewController.swift
//  YouCat
//
//  Created by ting on 2018/11/29.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
import Kingfisher
import Photos
import AVFoundation
import Qiniu

class YCSettingViewController: UIViewController, YCImageProtocol, YCContentStringProtocol, YCAlertProtocol {
    
    static var _instaceArray: [YCSettingViewController] = [];
    
    static func getInstance() -> YCSettingViewController{
        var _instance: YCSettingViewController
        if _instaceArray.count > 0 {
            _instance = _instaceArray[0]
            _instaceArray.remove(at: 0)
            return _instance
        }else {
            _instance = YCSettingViewController();
        }
        return _instance
    }
    
    static func addInstance(instace: YCSettingViewController) {
        _instaceArray.append(instace)
    }
    
    var userIcon: UIImageView!
    var nicknameLabel: UILabel!
    var signLabel: UILabel!
    var genderLabel: UILabel!
    var phoneLabel: UILabel!
    var logoutButton: UIButton!
    
    var loadingView: YCLoadingView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
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
            if let icon = user.icon {
                let imgPath = icon.imagePath
                if imgPath != "", let imgURL = URL(string: imgPath){
                    self.userIcon.kf.setImage(with: ImageResource(downloadURL: imgURL), placeholder: UIImage(named: "default_icon"), options: nil, progressBlock: nil, completionHandler: nil)
                }else {
                    self.userIcon.image = UIImage(named: "default_icon")
                }
            }
            self.nicknameLabel.text = self.getNicknameString(user: user)
            let sign = self.getSignString(sign: user.signature)
            if sign == "" {
                self.signLabel.text = YCLanguageHelper.getString(key: "BioPlaceholder")
            }else {
                self.signLabel.text = sign
            }
            self.genderLabel.text = self.getGenderString(gender: user.gender)
            self.phoneLabel.text = self.getPhoneString(phone: user.phone)
        }else {
            self.resetViewController()
        }
    }
    
    func initView() {
        self.view.backgroundColor = YCStyleColor.white
        
        let closeButton = UIButton()
        closeButton.setImage(UIImage(named: "close_black"), for: .normal)
        closeButton.setImage(UIImage(named: "close_black"), for: .highlighted)
        closeButton.addTarget(self, action: #selector(self.closeButtonClick), for: .touchUpInside)
        self.view.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(YCScreen.safeArea.top)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        self.userIcon = UIImageView()
        self.view.addSubview(self.userIcon)
        self.userIcon.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(YCScreen.safeArea.top+10)
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
        
        let lineView_1 = UIView()
        self.view.addSubview(lineView_1)
        lineView_1.snp.makeConstraints { (make) in
            make.top.equalTo(self.userIcon.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(1)
        }
        lineView_1.backgroundColor = YCStyleColor.gray
        
        let nicknameTitleLabel = UILabel()
        self.view.addSubview(nicknameTitleLabel)
        nicknameTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lineView_1.snp.bottom).offset(5)
            make.left.equalTo(25)
            make.width.equalTo(60)
            make.height.equalTo(44)
        }
        nicknameTitleLabel.textColor = YCStyleColor.black
        nicknameTitleLabel.font = UIFont.systemFont(ofSize: 18)
        nicknameTitleLabel.text = YCLanguageHelper.getString(key: "NicknameLabel")
        
        let nicknameNextImage = UIImageView()
        nicknameNextImage.image = UIImage(named: "next_black")
        self.view.addSubview(nicknameNextImage)
        nicknameNextImage.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalTo(nicknameTitleLabel).offset(0)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        self.nicknameLabel = UILabel()
        self.view.addSubview(self.nicknameLabel)
        self.nicknameLabel.numberOfLines = 1
        self.nicknameLabel.snp.makeConstraints { (make) in
            make.right.equalTo(nicknameNextImage.snp.left).offset(10)
            make.left.equalTo(nicknameTitleLabel.snp.right).offset(0)
            make.centerY.equalTo(nicknameTitleLabel).offset(0)
            make.height.equalTo(44)
        }
        self.nicknameLabel.textAlignment = .right
        self.nicknameLabel.textColor = YCStyleColor.gray
        self.nicknameLabel.font = UIFont.systemFont(ofSize: 18)
        self.nicknameLabel.text = ""
        let nicknameTap = UITapGestureRecognizer(target: self, action: #selector(self.nicknameTapHandler))
        self.nicknameLabel.isUserInteractionEnabled = true
        self.nicknameLabel.addGestureRecognizer(nicknameTap)
        
        let signTitleLabel = UILabel()
        self.view.addSubview(signTitleLabel)
        signTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nicknameTitleLabel.snp.bottom).offset(5)
            make.left.equalTo(25)
            make.width.equalTo(60)
            make.height.equalTo(44)
        }
        signTitleLabel.textColor = YCStyleColor.black
        signTitleLabel.font = UIFont.systemFont(ofSize: 18)
        signTitleLabel.text = YCLanguageHelper.getString(key: "BioLabel")
        
        let signNextImage = UIImageView()
        signNextImage.image = UIImage(named: "next_black")
        self.view.addSubview(signNextImage)
        signNextImage.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalTo(signTitleLabel).offset(0)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        self.signLabel = UILabel()
        self.view.addSubview(self.signLabel)
        self.signLabel.numberOfLines = 1
        self.signLabel.snp.makeConstraints { (make) in
            make.right.equalTo(signNextImage.snp.left).offset(10)
            make.left.equalTo(signTitleLabel.snp.right).offset(0)
            make.centerY.equalTo(signTitleLabel).offset(0)
            make.height.equalTo(44)
        }
        self.signLabel.textAlignment = .right
        self.signLabel.textColor = YCStyleColor.gray
        self.signLabel.font = UIFont.systemFont(ofSize: 18)
        self.signLabel.text = ""
        let signTap = UITapGestureRecognizer(target: self, action: #selector(self.signTapHandler))
        self.signLabel.isUserInteractionEnabled = true
        self.signLabel.addGestureRecognizer(signTap)
        
        
        let genderTitleLabel = UILabel()
        self.view.addSubview(genderTitleLabel)
        genderTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(signTitleLabel.snp.bottom).offset(5)
            make.left.equalTo(25)
            make.width.equalTo(60)
            make.height.equalTo(44)
        }
        genderTitleLabel.textColor = YCStyleColor.black
        genderTitleLabel.font = UIFont.systemFont(ofSize: 18)
        genderTitleLabel.text = YCLanguageHelper.getString(key: "GenderLabel")
        
        let genderNextImage = UIImageView()
        genderNextImage.image = UIImage(named: "next_black")
        self.view.addSubview(genderNextImage)
        genderNextImage.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalTo(genderTitleLabel).offset(0)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        self.genderLabel = UILabel()
        self.view.addSubview(self.genderLabel)
        self.genderLabel.numberOfLines = 1
        self.genderLabel.snp.makeConstraints { (make) in
            make.right.equalTo(genderNextImage.snp.left).offset(10)
            make.left.equalTo(genderTitleLabel.snp.right).offset(0)
            make.centerY.equalTo(genderTitleLabel).offset(0)
            make.height.equalTo(44)
        }
        self.genderLabel.textAlignment = .right
        self.genderLabel.textColor = YCStyleColor.gray
        self.genderLabel.font = UIFont.systemFont(ofSize: 18)
        self.genderLabel.text = ""
        let genderTap = UITapGestureRecognizer(target: self, action: #selector(self.genderTapHandler))
        self.genderLabel.isUserInteractionEnabled = true
        self.genderLabel.addGestureRecognizer(genderTap)
        
        let phoneTitleLabel = UILabel()
        self.view.addSubview(phoneTitleLabel)
        phoneTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(genderTitleLabel.snp.bottom).offset(5)
            make.left.equalTo(25)
            make.width.equalTo(60)
            make.height.equalTo(44)
        }
        phoneTitleLabel.textColor = YCStyleColor.black
        phoneTitleLabel.font = UIFont.systemFont(ofSize: 18)
        phoneTitleLabel.text = YCLanguageHelper.getString(key: "PhoneLabel")
        
        let phoneNextImage = UIImageView()
        phoneNextImage.image = UIImage(named: "next_black")
        self.view.addSubview(phoneNextImage)
        phoneNextImage.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalTo(phoneTitleLabel).offset(0)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        phoneNextImage.isHidden = true
        
        self.phoneLabel = UILabel()
        self.view.addSubview(self.phoneLabel)
        self.phoneLabel.numberOfLines = 1
        self.phoneLabel.snp.makeConstraints { (make) in
            make.right.equalTo(phoneNextImage.snp.left).offset(10)
            make.left.equalTo(phoneTitleLabel.snp.right).offset(0)
            make.centerY.equalTo(phoneTitleLabel).offset(0)
            make.height.equalTo(44)
        }
        self.phoneLabel.textAlignment = .right
        self.phoneLabel.textColor = YCStyleColor.gray
        self.phoneLabel.font = UIFont.systemFont(ofSize: 18)
        self.phoneLabel.text = ""
        
        let lineView_2 = UIView()
        self.view.addSubview(lineView_2)
        lineView_2.snp.makeConstraints { (make) in
            make.top.equalTo(phoneTitleLabel.snp.bottom).offset(5)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(1)
        }
        lineView_2.backgroundColor = YCStyleColor.gray
        lineView_2.isHidden = true
        
        self.logoutButton = UIButton()
        self.view.addSubview(self.logoutButton)
        self.logoutButton.snp.makeConstraints { (make) in
            make.top.equalTo(lineView_2.snp.bottom).offset(20)
            make.centerX.equalTo(lineView_2).offset(0)
            make.width.equalTo(100)
            make.height.equalTo(44)
        }
        self.logoutButton.setTitleColor(YCStyleColor.red, for: .normal)
        
        self.logoutButton.setTitle(YCLanguageHelper.getString(key: "LogoutLabel"), for: .normal)
        self.logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        
        self.logoutButton.addTarget(self, action: #selector(self.logoutButtonClick), for: .touchUpInside)
        self.logoutButton.isHidden = true
        
        self.loadingView = YCLoadingView(style: .POP)
        self.view.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(self.view).offset(0)
        }
    }
}

extension YCSettingViewController {
    
    @objc func closeButtonClick() {
        self.closeLoginView()
    }
    
    @objc func changeIconButtonClick() {
        var alertArray:Array<[String : Any]> = []
        alertArray.append(["title":YCLanguageHelper.getString(key: "PhotoLabel")])
        alertArray.append(["title":YCLanguageHelper.getString(key: "LibraryLabel")])
        self.showSheetAlert("", alertMessage: YCLanguageHelper.getString(key: "IconTitle"), okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
            if index == 0 {
                self.openCamera()
            }else if index == 1 {
                self.openPhoteLibrary()
            }
        }
    }
    
    @objc func logoutButtonClick() {
        var alertArray:Array<[String : Any]> = []
        alertArray.append(["title":YCLanguageHelper.getString(key: "ConfirmLabel"), "textColor":YCStyleColor.red])
        self.showSheetAlert("", alertMessage: YCLanguageHelper.getString(key: "LogoutTitle"), okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
            if index == 0 {
                if YCUserManager.logout() {
                    NotificationCenter.default.post(name: NSNotification.Name("LoginUserChange"), object: nil)
                    self.closeLoginView(animated: true)
                }
            }
        }
    }
    
    @objc func nicknameTapHandler() {
        let nicknameView = YCUpdateNicknameViewController.getInstance()
        if let navi = self.navigationController {
            navi.pushViewController(nicknameView, animated: true)
        }
    }
    
    @objc func signTapHandler() {
        let signView = YCUpdateSignViewController.getInstance()
        if let navi = self.navigationController {
            navi.pushViewController(signView, animated: true)
        }
    }
    
    @objc func genderTapHandler() {
        var alertArray:Array<[String : Any]> = []
        alertArray.append(["title":YCLanguageHelper.getString(key: "MaleLabel")])
        alertArray.append(["title":YCLanguageHelper.getString(key: "FemaleLabel"), "textColor":YCStyleColor.red])
        self.showSheetAlert(nil, alertMessage: nil, okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
            if index == 0 {
                if let user = YCUserManager.loginUser, user.gender != "male" {
                    self.showLoadingView()
                    YCUserDomain().updateGender(gender: "male", completionBlock: { (modelMode) in
                        self.hideLoadingView()
                        if let model = modelMode {
                            if model.result {
                                if let user = model.baseModel as? YCLoginUserModel {
                                    if YCUserManager.save(user) {
                                        self.genderLabel.text = self.getGenderString(gender: user.gender)
                                    }
                                }
                            }else {
                                if let message = model.message {
                                    self.showTempAlert("", alertMessage: message, view: self, completionBlock: nil)
                                }
                            }
                        }
                    })
                }
            }else if index == 1 {
                if let user = YCUserManager.loginUser, user.gender != "female" {
                    self.showLoadingView()
                    YCUserDomain().updateGender(gender: "female", completionBlock: { (modelMode) in
                        self.hideLoadingView()
                        if let model = modelMode {
                            if model.result {
                                if let user = model.baseModel as? YCLoginUserModel {
                                    if YCUserManager.save(user) {
                                        self.genderLabel.text = self.getGenderString(gender: user.gender)
                                    }
                                }
                            }else {
                                if let message = model.message {
                                    self.showTempAlert("", alertMessage: message, view: self, completionBlock: nil)
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    func closeLoginView(animated: Bool = true) {
        self.navigationController?.dismiss(animated: animated, completion: { () -> Void in
            self.resetViewController()
            YCSettingViewController.addInstance(instace: self)
        })
    }
    
    func resetViewController() {
        self.userIcon.image = UIImage(named: "default_icon")
        self.nicknameLabel.text = ""
        self.signLabel.text = ""
        self.genderLabel.text = ""
        self.phoneLabel.text = ""
    }
    
    func hideLoadingView() {
        self.view.isUserInteractionEnabled = true
        self.loadingView.stopAnimating()
    }
    
    func showLoadingView() {
        self.view.isUserInteractionEnabled = false
        self.loadingView.startAnimating()
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

extension YCSettingViewController: YCLoginProtocol {
    func showLoginCompleteView() {
        
    }
}

extension YCSettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.changeUserIcon(pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func changeUserIcon(_ icon:UIImage){
        let imageName = YCIDGenerator.generateID()
        let userIconKey = imageName+".jpg"
        self.showLoadingView()
        let cropImg = compressIconImage(icon)
        YCUploadDomain().uploadImageDate(cropImg, imageKey: userIconKey, imageType: "jpg", progressBlock: nil) { (result, key, img) in
            if result, let image = img {
                let imgW = Float(image.size.width)
                let imgH = Float(image.size.height)
                let iconModel = YCImageModel(imageID: "", imagePath: key, snapShotPath: "", imageType: "jpg", imageIndex: 0, imageWidth: imgW, imageHeight: imgH)
                YCUserDomain().updateIcon(icon: iconModel, completionBlock: { (modelMode) in
                    if let model = modelMode, model.result, let loginUser = model.baseModel as? YCLoginUserModel{
                        if YCUserManager.save(loginUser) {
                            if let imgPath = loginUser.icon?.imagePath, let imgURL = URL(string: imgPath){
                                self.userIcon.kf.setImage(with: ImageResource(downloadURL: imgURL), placeholder: image, options: nil, progressBlock: nil, completionHandler: nil)
                            }else {
                                self.userIcon.image = image
                            }
                            self.hideLoadingView()
                        }else {
                            self.uploadIconFailed()
                        }
                    }else {
                        self.uploadIconFailed()
                    }
                })
            }else {
                self.uploadIconFailed()
            }
        }
    }
    
    func uploadIconFailed() {
        self.hideLoadingView()
        self.showSingleAlert("", alertMessage: YCLanguageHelper.getString(key: "UploadIconErrorMessage"), view: self, compelecationBlock: nil)
    }
}
