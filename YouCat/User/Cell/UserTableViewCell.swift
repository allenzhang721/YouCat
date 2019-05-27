//
//  UserListTableViewCell.swift
//  YouCat
//
//  Created by ting on 2019/4/29.
//  Copyright © 2019年 Curios. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class YCUserTableViewCell: UITableViewCell, YCImageProtocol, YCNumberStringProtocol, YCContentStringProtocol {
    
    var bgView: UIView!
    var userIcon: UIImageView!
    var userNameLabel: UILabel!
    var followButton: YCFollowButton!
    
    var delegate: YCUserTableViewCellDelegate?
    
    var userModel: YCRelationUserModel? {
        didSet{
            self.didSetUserModel()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.initView()
    }
    
    func initView(){
        self.bgView = UIView();
        self.addSubview(self.bgView)
        self.bgView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
        self.bgView.backgroundColor = YCStyleColor.white
        
        let userView = UIView()
        self.addSubview(userView)
        userView.snp.makeConstraints { (make) in
            make.left.equalTo(self.bgView).offset(20)
            make.top.equalTo(self.bgView).offset(10)
            make.right.equalTo(self.bgView).offset(-100)
            make.height.equalTo(44)
        }
        self.userIcon = UIImageView();
        userView.addSubview(self.userIcon)
        self.userIcon.snp.makeConstraints { (make) in
            make.left.equalTo(userView).offset(0)
            make.top.equalTo(userView).offset(0)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.cropImageCircle(self.userIcon, 22)
        self.userIcon.image = UIImage(named: "default_icon")
        
        self.userNameLabel = UILabel();
        self.userNameLabel.numberOfLines = 1
        userView.addSubview(self.userNameLabel)
        self.userNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.userIcon.snp.right).offset(10)
            make.right.equalTo(userView).offset(0)
            make.centerY.equalTo(self.userIcon).offset(0)
        }
        self.userNameLabel.textColor = YCStyleColor.black
        self.userNameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        self.userNameLabel.text = ""
        
        let iconTap = UITapGestureRecognizer(target: self, action: #selector(self.iconTapHandler))
        userView.isUserInteractionEnabled = true
        userView.addGestureRecognizer(iconTap)
        
        self.followButton = YCFollowButton(fontSize: 14)
        self.addSubview(self.followButton)
        self.followButton.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.width.equalTo(72)
            make.height.equalTo(32)
            make.centerY.equalTo(self.userIcon).offset(0)
        }
        let followTap = UITapGestureRecognizer(target: self, action: #selector(self.followButtonTap))
        self.followButton.addGestureRecognizer(followTap)
    }
    
    func didSetUserModel(){
        if let user = self.userModel{
            self.userNameLabel.text = self.getNicknameString(user: user)
            if let icon = user.icon {
                var imagePath = icon.imagePath
                if imagePath != "" {
                    imagePath = imagePath + "?imageView2/2/w/132"
                }
                if let imgURL = URL(string: imagePath) {
                    self.userIcon.kf.setImage(with: ImageResource(downloadURL: imgURL), placeholder: UIImage(named: "default_icon"), options: nil, progressBlock: nil, completionHandler: nil)
                }else {
                    self.userIcon.image = UIImage(named: "default_icon")
                }
            }else {
                self.userIcon.image = UIImage(named: "default_icon")
            }
            if user.relation == 1 {
                self.followButton.status = .Following
            }else {
                self.followButton.status = .Unfollow
            }
        }
    }
    
}

extension YCUserTableViewCell: YCAlertProtocol {
    
    @objc func iconTapHandler(sender:UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.cellUserIconTap(self)
        }
    }
    
    @objc func followButtonTap(sender:UITapGestureRecognizer){
        switch self.followButton.status {
        case .Unfollow:
            self.followHandler()
            break
        case .Following:
            self.unFollowHandler()
            break
        default:
            break
        }
    }
    
    func followHandler() {
        if let user = self.userModel {
            let oldStatus = self.followButton.status
            self.followButton.status = .Loading
            YCUserDomain().followUser(userID: user.userID) { (resultMode) in
                if let result = resultMode {
                    if result.result {
                        self.followButton.status = .Following
                        self.userModel!.relation = 1
                    }else {
                        self.followButton.status = oldStatus
                    }
                }else {
                    self.followButton.status = oldStatus
                }
            }
        }
    }
    
    func unFollowHandler() {
        if let user = self.userModel {
            let oldStatus = self.followButton.status
            self.followButton.status = .Loading
            YCUserDomain().unFollowUser(userID: user.userID) { (resultMode) in
                if let result = resultMode {
                    if result.result {
                        self.userModel!.relation = 0
                        self.followButton.status = .Unfollow
                    }else {
                        self.followButton.status = oldStatus
                    }
                }else {
                    self.followButton.status = oldStatus
                }
            }
        }
    }
}

protocol YCUserTableViewCellDelegate {
    func cellUserIconTap(_ cell:YCUserTableViewCell?)
}
