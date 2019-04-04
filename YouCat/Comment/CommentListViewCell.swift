//
//  CommentListViewCell.swift
//  YouCat
//
//  Created by ting on 2018/12/18.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
import Kingfisher

enum YCCommentListCellStyle: String{
    case Default = "Default"
    case Dark = "Dark"
}

class YCCommentListViewCell: UITableViewCell, YCImageProtocol, YCNumberStringProtocol, YCContentStringProtocol  {
    
    var style: YCCommentListCellStyle = .Default
    
    var commentModel: YCCommentModel? {
        didSet{
            self.didSetCommentModel()
        }
    }
    
    var userIcon: UIImageView!
    var iconView: UIView!
    var userNameLabel: UILabel!
    var contentLabel: UILabel!
    
    var timeLabel: UILabel!
    var likeBtn: UIButton!
    var likeCountLabel: UILabel!
    
    var contentColor = YCStyleColor.black
    var replyColor = YCStyleColor.gray
    
    var delegate: YCCommentListViewCellDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        self.initView()
    }
    
    func initView() {

        let tapView = UIView()
        self.addSubview(tapView)
        tapView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.bottom.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(-54)
        }
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapHandler))
        tapView.isUserInteractionEnabled = true
        tapView.addGestureRecognizer(viewTap)
        
        self.iconView = UIView()
        self.addSubview(self.iconView)
        self.iconView.snp.makeConstraints { (make) in
            make.left.equalTo(6)
            make.top.equalTo(6)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.userIcon = UIImageView();
        self.iconView.addSubview(self.userIcon)
        self.userIcon.snp.makeConstraints { (make) in
            make.left.equalTo(4)
            make.top.equalTo(4)
            make.width.equalTo(36)
            make.height.equalTo(36)
        }
        self.cropImageCircle(self.userIcon, 18)
        self.userIcon.image = UIImage(named: "default_icon")
        let iconTap = UITapGestureRecognizer(target: self, action: #selector(self.iconTapHandler))
        iconView.isUserInteractionEnabled = true
        iconView.addGestureRecognizer(iconTap)
        
        self.userNameLabel = UILabel()
        self.userNameLabel.numberOfLines = 1
        self.addSubview(self.userNameLabel)
        self.userNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.userIcon.snp.right).offset(10)
            make.top.equalTo(self.userIcon.snp.top).offset(-3)
            make.right.equalTo(-54)
            make.height.equalTo(22)
        }
        self.userNameLabel.textColor = YCStyleColor.gray
        self.userNameLabel.font = UIFont.systemFont(ofSize: 14)
        self.userNameLabel.text = ""
        
        let nikeNameTap = UITapGestureRecognizer(target: self, action: #selector(self.iconTapHandler))
        self.userNameLabel.isUserInteractionEnabled = true
        self.userNameLabel.addGestureRecognizer(nikeNameTap)
        
        self.contentLabel = UILabel()
        self.addSubview(self.contentLabel)
        self.contentLabel.numberOfLines = 0
        self.contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.userIcon.snp.right).offset(10)
            make.right.equalTo(self.userNameLabel.snp.right)
            make.top.equalTo(self.userNameLabel.snp.bottom).offset(3)
            make.bottom.equalTo(-10)
        }
        self.contentLabel.textColor = YCStyleColor.black
        self.contentLabel.font = UIFont.systemFont(ofSize: 16)
        self.contentLabel.text = ""
        
        self.timeLabel = UILabel()
        self.addSubview(self.timeLabel)
        self.timeLabel.numberOfLines = 1
        self.timeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.userNameLabel.snp.right)
            make.top.equalTo(self.userNameLabel.snp.top).offset(0)
            make.height.equalTo(22)
        }
        self.timeLabel.textColor = YCStyleColor.gray
        self.timeLabel.font = UIFont.systemFont(ofSize: 10)
        self.timeLabel.textAlignment = .right
        self.timeLabel.text = ""
        
        self.likeBtn = UIButton();
        self.addSubview(self.likeBtn)
        self.likeBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(self.userIcon.snp.top).offset(-8)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.likeBtn.setImage(UIImage(named: "like_black"), for: .normal)
        self.likeBtn.setImage(UIImage(named: "like_black"), for: .highlighted)
        self.likeBtn.addTarget(self, action: #selector(self.likeButtonClick), for: .touchUpInside)
        
        self.likeCountLabel = UILabel();
        self.addSubview(self.likeCountLabel)
        self.likeCountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.likeBtn).offset(0)
            make.left.equalTo(self.likeBtn).offset(0)
            make.top.equalTo(self.likeBtn.snp.bottom).offset(-5)
        }
        self.likeCountLabel.textColor = YCStyleColor.black
        self.likeCountLabel.font = UIFont.systemFont(ofSize: 12)
        self.likeCountLabel.text = "0"
        self.likeCountLabel.textAlignment = .center
        
        
    }
    
    func didSetCommentModel() {
        self.setCellStyle()
        self.setCellValue()
    }
    
    func setCellStyle() {
        if self.style == .Default {
            self.userNameLabel.textColor = YCStyleColor.gray
            self.contentColor = YCStyleColor.black
            self.replyColor = YCStyleColor.gray
            self.timeLabel.textColor = YCStyleColor.gray
            self.likeCountLabel.textColor = YCStyleColor.gray
            self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
            self.likeBtn.setImage(UIImage(named: "like_gray"), for: .highlighted)
        }else if self.style == .Dark {
            self.userNameLabel.textColor = YCStyleColor.gray
            self.contentColor = YCStyleColor.white
            self.replyColor = YCStyleColor.gray
            self.timeLabel.textColor = YCStyleColor.gray
            self.likeCountLabel.textColor = YCStyleColor.white
            self.likeBtn.setImage(UIImage(named: "like_white"), for: .normal)
            self.likeBtn.setImage(UIImage(named: "like_white"), for: .highlighted)
        }
    }
    
    func setCellValue(){
        if let comment = self.commentModel {
            if comment.commentType == 0 || comment.commentType == 1 {
                self.userNameLabel.isHidden = false
                self.userIcon.isHidden = false
                self.timeLabel.isHidden = false
                self.likeBtn.isHidden = false
                self.likeCountLabel.isHidden = false
                self.contentLabel.textAlignment = .left
                if comment.commentType == 0 {
                    self.iconView.snp.remakeConstraints { (make) in
                        make.left.equalTo(6)
                        make.top.equalTo(6)
                        make.width.equalTo(44)
                        make.height.equalTo(44)
                    }
                    self.userIcon.snp.remakeConstraints { (make) in
                        make.left.equalTo(4)
                        make.top.equalTo(4)
                        make.width.equalTo(36)
                        make.height.equalTo(36)
                    }
                    self.cropImageCircle(self.userIcon, 18)
                }else if comment.commentType == 1 {
                    self.iconView.snp.remakeConstraints { (make) in
                        make.left.equalTo(46)
                        make.top.equalTo(-8)
                        make.width.equalTo(44)
                        make.height.equalTo(44)
                    }
                    self.userIcon.snp.remakeConstraints { (make) in
                        make.left.equalTo(10)
                        make.top.equalTo(10)
                        make.width.equalTo(24)
                        make.height.equalTo(24)
                    }
                    self.cropImageCircle(self.userIcon, 12)
                }
                if let user = comment.user{
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
                }
                self.timeLabel.text = self.getDateString(date: comment.commentDate)
                self.likeCountLabel.text = self.getNumberString(number: comment.likeCount)
                if comment.isLike == 1 {
                    self.likeBtn.setImage(UIImage(named: "like_high"), for: .normal)
                    self.likeBtn.setImage(UIImage(named: "like_high"), for: .highlighted)
                }else {
                    if self.style == .Default {
                        self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                        self.likeBtn.setImage(UIImage(named: "like_gray"), for: .highlighted)
                    }else {
                        self.likeBtn.setImage(UIImage(named: "like_white"), for: .normal)
                        self.likeBtn.setImage(UIImage(named: "like_white"), for: .highlighted)
                    }
                }
                let contentStr = self.getContentString(content: comment.content)
                let contentAttrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor : self.contentColor]
                if let beUser = comment.beRepliedUser {
                    let replyAttrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor : self.replyColor]
                    let beUserName = self.getNicknameString(user: beUser)
                    let replyUserAttrsString = NSMutableAttributedString(string: beUserName, attributes: replyAttrs)
                    let replyLabelAttrsString = NSMutableAttributedString(string: YCLanguageHelper.getString(key: "ReplyLabel"), attributes: contentAttrs)
                    let replyContent = ": " + contentStr
                    let contentAttrsString = NSMutableAttributedString(string:replyContent, attributes:contentAttrs)
                    replyLabelAttrsString.append(replyUserAttrsString)
                    replyLabelAttrsString.append(contentAttrsString)
                    self.contentLabel.attributedText = replyLabelAttrsString
                }else {
                    let contentAttrsString = NSMutableAttributedString(string:contentStr, attributes:contentAttrs)
                    self.contentLabel.attributedText = contentAttrsString
                }
            }else {
                self.userNameLabel.isHidden = true
                self.userIcon.isHidden = true
                self.timeLabel.isHidden = true
                self.likeBtn.isHidden = true
                self.likeCountLabel.isHidden = true
                self.iconView.snp.remakeConstraints { (make) in
                    make.left.equalTo(0)
                    make.top.equalTo(-22)
                    make.width.equalTo(44)
                    make.height.equalTo(44)
                }
                self.contentLabel.textAlignment = .center
                let contentAttrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : self.contentColor]
                let contentAttrsString = NSMutableAttributedString(string:YCLanguageHelper.getString(key: "LoadMoreLabel"), attributes:contentAttrs)
                self.contentLabel.attributedText = contentAttrsString
            }
        }
    }
}

extension YCCommentListViewCell {
    
    @objc func viewTapHandler() {
        if let delegate = self.delegate {
            delegate.cellContentTap(self)
        }
    }
    
    @objc func iconTapHandler() {
        if let delegate = self.delegate {
            delegate.cellUserTap(self)
        }
    }
    
    @objc func likeButtonClick() {
        if let delegate = self.delegate {
            delegate.cellLikeButtonClick(self)
        }
    }
    
    func changeCommentLikeStatus(comment: YCCommentModel) {
        if let commentModel = self.commentModel, comment.commentID == commentModel.commentID {
            commentModel.isLike = comment.isLike
            commentModel.likeCount = comment.likeCount
            if comment.isLike == 1 {
                self.likeBtn.setImage(UIImage(named: "like_high"), for: .normal)
                self.likeBtn.setImage(UIImage(named: "like_high"), for: .highlighted)
            }else {
                if self.style == .Default {
                    self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                    self.likeBtn.setImage(UIImage(named: "like_gray"), for: .highlighted)
                }else {
                    self.likeBtn.setImage(UIImage(named: "like_white"), for: .normal)
                    self.likeBtn.setImage(UIImage(named: "like_white"), for: .highlighted)
                }
            }
            self.likeCountLabel.text = self.getNumberString(number: commentModel.likeCount)
        }
    }
}


protocol YCCommentListViewCellDelegate {
    func cellUserTap(_ cell:YCCommentListViewCell?)
    func cellContentTap(_ cell:YCCommentListViewCell?)
    func cellLikeButtonClick(_ cell:YCCommentListViewCell?)
}
