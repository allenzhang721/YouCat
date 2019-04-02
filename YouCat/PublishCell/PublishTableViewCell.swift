//
//  FeedCell.swift
//  YouCat
//
//  Created by ting on 2018/9/25.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class YCPublishTableViewCell: UITableViewCell, YCImageProtocol, YCNumberStringProtocol, YCContentStringProtocol {
    
    var bgView: UIView!
    var userIcon: UIImageView!
    var userNameLabel: UILabel!
    var operateBtn: UIButton!
    
    var publishView: UIView!
    
    var contentLabel: UILabel!
    var commentView: UIView!
    var shareBtn: UIButton!
    var shareLabel: UILabel!
    var likeBtn: UIButton!
    var likeCountLabel: UILabel!
    var commentBtn: UIButton!
    var commentCountLabel: UILabel!
    
    var contentViews: [YCBaseView] = []
    
    var publishModel: YCPublishModel? {
        didSet{
            if let old = oldValue {
                if old.publishID != publishModel?.publishID {
                    self.didSetPublishModel();
                }else {
                    self.setPublishLikeStatus()
                    self.setPublishCommentStatus()
                    self.setPublishContent()
                }
            }else {
                self.didSetPublishModel();
            }
        }
    }
    
    var delegate: YCPublishTableViewCellDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.initView()
    }
    
    func initView() {
        self.bgView = UIView();
        self.addSubview(self.bgView)
        self.bgView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10).priority(999)
            make.top.equalTo(5)
            make.bottom.equalTo(-15).priority(999)
        }
        self.bgView.backgroundColor = YCStyleColor.white
        self.bgView.layer.cornerRadius = 8;
        self.addShadow(self.bgView, 8, 4)
        
        let userView = UIView()
        self.addSubview(userView)
        userView.snp.makeConstraints { (make) in
            make.left.equalTo(self.bgView).offset(10)
            make.top.equalTo(self.bgView).offset(10)
            make.right.equalTo(self.bgView).offset(-60)
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
            make.height.equalTo(22)
        }
        self.userNameLabel.textColor = YCStyleColor.black
        self.userNameLabel.font = UIFont.systemFont(ofSize: 16)
        self.userNameLabel.text = ""
        
        let iconTap = UITapGestureRecognizer(target: self, action: #selector(self.iconTapHandler))
        userView.isUserInteractionEnabled = true
        userView.addGestureRecognizer(iconTap)
        
        self.operateBtn = UIButton();
        self.addSubview(self.operateBtn)
        self.operateBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.bgView).offset(-10)
            make.top.equalTo(self.bgView).offset(10)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.operateBtn.setImage(UIImage(named: "operate_gray"), for: .normal)
        self.operateBtn.setImage(UIImage(named: "operate_gray"), for: .highlighted)
        self.operateBtn.addTarget(self, action: #selector(self.operatorButtonClick), for: .touchUpInside)
        
        self.publishView = UIView()
        self.addSubview(self.publishView)
        self.publishView.snp.makeConstraints { (make) in
            make.top.equalTo(self.userIcon.snp.bottom).offset(10)
            make.left.equalTo(self.bgView)
            make.width.equalTo(self.bgView)
            make.height.equalTo(self.bgView.snp.width).multipliedBy(0)
        }
        //self.publishView.backgroundColor = YCStyleColor.gay
        
        self.contentLabel = UILabel();
        self.contentLabel.numberOfLines = 0
        self.addSubview(self.contentLabel)
        self.contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.bgView).offset(10)
            make.right.equalTo(self.bgView).offset(-10)
            make.top.equalTo(self.publishView.snp.bottom).offset(10)
            make.bottom.equalTo(-80)
        }
        self.contentLabel.textColor = YCStyleColor.black
        self.contentLabel.font = UIFont.systemFont(ofSize: 16)
        self.contentLabel.text = ""
        
        self.shareBtn = UIButton();
        self.addSubview(self.shareBtn)
        self.shareBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.bgView).offset(-10)
            make.top.equalTo(self.contentLabel.snp.bottom).offset(0)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.shareBtn.setImage(UIImage(named: "share_gray"), for: .normal)
        self.shareBtn.setImage(UIImage(named: "share_gray"), for: .highlighted)
        self.shareBtn.addTarget(self, action: #selector(self.shareButtonClick), for: .touchUpInside)
        
        self.shareLabel = UILabel();
        self.addSubview(self.shareLabel)
        self.shareLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.shareBtn).offset(0)
            make.left.equalTo(self.shareBtn).offset(0)
            make.top.equalTo(self.shareBtn.snp.bottom).offset(-5)
        }
        self.shareLabel.textColor = YCStyleColor.gray
        self.shareLabel.font = UIFont.systemFont(ofSize: 12)
        self.shareLabel.text = YCLanguageHelper.getString(key: "ShareButtonLabel")
        self.shareLabel.textAlignment = .center
        
        self.likeBtn = UIButton();
        self.addSubview(self.likeBtn)
        self.likeBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.shareBtn.snp.left).offset(0)
            make.top.equalTo(self.shareBtn).offset(0)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
        self.likeBtn.setImage(UIImage(named: "like_gray"), for: .highlighted)
        self.likeBtn.addTarget(self, action: #selector(self.likeButtonClick), for: .touchUpInside)
        
        self.likeCountLabel = UILabel();
        self.addSubview(self.likeCountLabel)
        self.likeCountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.likeBtn).offset(0)
            make.left.equalTo(self.likeBtn).offset(0)
            make.top.equalTo(self.likeBtn.snp.bottom).offset(-5)
        }
        self.likeCountLabel.textColor = YCStyleColor.gray
        self.likeCountLabel.font = UIFont.systemFont(ofSize: 12)
        self.likeCountLabel.text = "0"
        self.likeCountLabel.textAlignment = .center
        
        self.commentBtn = UIButton();
        self.addSubview(self.commentBtn)
        self.commentBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.likeBtn.snp.left).offset(0)
            make.top.equalTo(self.likeBtn).offset(0)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.commentBtn.setImage(UIImage(named: "comment_gray"), for: .normal)
        self.commentBtn.setImage(UIImage(named: "comment_gray"), for: .highlighted)
        self.commentBtn.addTarget(self, action: #selector(self.commentButtonClick), for: .touchUpInside)
        
        self.commentCountLabel = UILabel();
        self.addSubview(self.commentCountLabel)
        self.commentCountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.commentBtn).offset(0)
            make.left.equalTo(self.commentBtn).offset(0)
            make.top.equalTo(self.commentBtn.snp.bottom).offset(-5)
        }
        self.commentCountLabel.textColor = YCStyleColor.gray
        self.commentCountLabel.font = UIFont.systemFont(ofSize: 12)
        self.commentCountLabel.text = "0"
        self.commentCountLabel.textAlignment = .center
        
        self.commentView = UIView()
        self.addSubview(self.commentView)
        self.commentView.snp.makeConstraints { (make) in
            make.left.equalTo(self.bgView).offset(10)
            make.right.equalTo(self.commentBtn.snp.left).offset(-5)
            make.top.equalTo(self.commentBtn).offset(13)
            make.height.equalTo(35)
        }
        self.commentView.layer.borderColor = YCStyleColor.gray.cgColor
        self.commentView.layer.borderWidth = 1
        self.commentView.layer.cornerRadius = 16;
        
        let commentTap = UITapGestureRecognizer(target: self, action: #selector(self.commentTapHandler))
        self.commentView.isUserInteractionEnabled = true
        self.commentView.addGestureRecognizer(commentTap)
        
        let commentLabel = UILabel();
        self.commentView.addSubview(commentLabel)
        commentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(15)
            make.top.equalTo(6)
            make.height.equalTo(22)
        }
        commentLabel.textColor = YCStyleColor.gray
        commentLabel.font = UIFont.systemFont(ofSize: 16)
        commentLabel.text = YCLanguageHelper.getString(key: "EnterCommentLabel")
    }
    
    func didSetPublishModel(){
        self.setCellValue()
    }
    
    func setCellValue(){
        if let publish = self.publishModel {
            if let user = publish.user{
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
            for view in self.contentViews {
                view.clean()
                view.removeFromSuperview()
            }
            self.contentViews.removeAll()
            let medias = publish.medias;
            let mediasCount = medias.count
            if mediasCount == 0 {
                self.publishView.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.userIcon.snp.bottom).offset(10)
                    make.left.equalTo(self.bgView)
                    make.width.equalTo(self.bgView)
                    make.height.equalTo(0)
                }
            }else {
                if publish.contentType == 1 {   // 1  image
                    if mediasCount == 1 {
                        let imgModel = medias[0] as! YCImageModel
                        var imgView: YCBaseView;
                        if imgModel.imageType == "gif" {
                            imgView = YCAnimationView()
                            (imgView as! YCAnimationView).loadSnapImage(imgModel, snapShot: true)
                        }else {
                            imgView = YCImageView()
                            (imgView as! YCImageView).loadSnapImage(imgModel, snapShot: true)
                        }
                        imgView.contentIndex = 0
                        self.publishView.addSubview(imgView)
                        self.contentViews.append(imgView)
                        let imgW = imgModel.imageWidth
                        let imgH = imgModel.imageHeight
                        var rate: Float = 1.0
                        if imgW != 0 && imgH != 0 {
                            rate = imgH/imgW;
                            if rate > 4/3 {
                                rate = 4/3/rate
                                if rate < 3/4 {
                                    rate = 3/4
                                }
                                imgView.snp.makeConstraints({ (make) in
                                    make.top.equalTo(0)
                                    make.left.equalTo(0)
                                    make.width.equalTo(self.bgView.snp.width).multipliedBy(rate)
                                    make.height.equalTo(self.publishView)
                                })
                                rate = 4/3
                            }else {
                                imgView.snp.makeConstraints({ (make) in
                                    make.top.equalTo(0)
                                    make.left.equalTo(0)
                                    make.width.equalTo(self.publishView)
                                    make.height.equalTo(self.publishView)
                                })
                            }
                        }else {
                            imgView.snp.makeConstraints({ (make) in
                                make.top.equalTo(0)
                                make.left.equalTo(0)
                                make.width.equalTo(self.publishView)
                                make.height.equalTo(self.publishView)
                            })
                        }
                        self.publishView.snp.remakeConstraints { (make) in
                            make.top.equalTo(self.userIcon.snp.bottom).offset(10)
                            make.left.equalTo(self.bgView)
                            make.width.equalTo(self.bgView)
                            make.height.equalTo(self.bgView.snp.width).multipliedBy(rate)
                        }
                    }else if mediasCount < 5 {
                        //let cellW = (self.frame.width - 10) / 2
                        let row = CGFloat(Int((mediasCount-1) / 2))
                        var snpView: UIView = self.publishView
                        for (index,model) in medias.enumerated() {
                            if let imgModel = model as? YCImageModel {
                                var imgView: YCBaseView;
                                if imgModel.imageType == "gif" {
                                    imgView = YCAnimationView()
                                    (imgView as! YCAnimationView).loadSnapImage(imgModel, snapShot: true)
                                }else {
                                    imgView = YCImageView()
                                    (imgView as! YCImageView).loadSnapImage(imgModel, snapShot: true)
                                }
                                imgView.contentIndex = index
                                self.publishView.addSubview(imgView)
                                self.contentViews.append(imgView)
                                imgView.snp.makeConstraints({ (make) in
                                    make.width.equalTo(self.bgView.snp.width).offset(-5).multipliedBy(0.5)
                                    make.height.equalTo(self.bgView.snp.width).offset(-5).multipliedBy(0.5)
                                })
                                if index == 0 {
                                    imgView.snp.makeConstraints({ (make) in
                                        make.top.equalTo(0)
                                        make.left.equalTo(0)
                                    })
                                }else {
                                    let indexColumn = CGFloat(Int(index%2))
                                    if indexColumn != 0 {
                                        imgView.snp.makeConstraints({ (make) in
                                            make.top.equalTo(snpView.snp.top).offset(0)
                                            make.left.equalTo(snpView.snp.right).offset(10)
                                        })
                                    }else {
                                        imgView.snp.makeConstraints({ (make) in
                                            make.top.equalTo(snpView.snp.bottom).offset(10)
                                            make.left.equalTo(0)
                                        })
                                    }
                                }
                                snpView = imgView
                            }
                        }
                        let off = 0-(5-5*row)
                        let mul = (row+1)/2
                        self.publishView.snp.remakeConstraints({ (make) in
                            make.top.equalTo(self.userIcon.snp.bottom).offset(10)
                            make.left.equalTo(self.bgView)
                            make.width.equalTo(self.bgView)
                            make.height.equalTo(self.bgView.snp.width).offset(off).multipliedBy(mul)
                        })
                    }else {
                       // let cellW = (self.frame.width - 10) / 3
                        let row = CGFloat(Int((mediasCount-1) / 3))
                        var snpView: UIView = self.publishView
                        for (index,model) in medias.enumerated() {
                            if let imgModel = model as? YCImageModel {
                                var imgView: YCBaseView;
                                if imgModel.imageType == "gif" {
                                    imgView = YCAnimationView()
                                    (imgView as! YCAnimationView).loadSnapImage(imgModel, snapShot: true)
                                }else {
                                    imgView = YCImageView()
                                    (imgView as! YCImageView).loadSnapImage(imgModel, snapShot: true)
                                }
                                imgView.contentIndex = index
                                self.publishView.addSubview(imgView)
                                self.contentViews.append(imgView)
                                imgView.snp.makeConstraints({ (make) in
                                    make.width.equalTo(self.bgView.snp.width).offset(-3.333).multipliedBy(0.333)
                                    make.height.equalTo(self.bgView.snp.width).offset(-3.333).multipliedBy(0.333)
                                })
                                if index == 0 {
                                    imgView.snp.makeConstraints({ (make) in
                                        make.top.equalTo(0)
                                        make.left.equalTo(0)
                                    })
                                }else {
                                    let indexColumn = CGFloat(Int(index%3))
                                    if indexColumn != 0 {
                                        imgView.snp.makeConstraints({ (make) in
                                            make.top.equalTo(snpView.snp.top).offset(0)
                                            make.left.equalTo(snpView.snp.right).offset(5)
                                        })
                                    }else {
                                        imgView.snp.makeConstraints({ (make) in
                                            make.top.equalTo(snpView.snp.bottom).offset(5)
                                            make.left.equalTo(0)
                                        })
                                    }
                                }
                                snpView = imgView
                            }
                        }
                        let off = 0-(10-5*row)/3
                        let mul = (row+1)/3
                        self.publishView.snp.remakeConstraints({ (make) in
                            make.top.equalTo(self.userIcon.snp.bottom).offset(10)
                            make.left.equalTo(self.bgView)
                            make.width.equalTo(self.bgView)
                            make.height.equalTo(self.bgView.snp.width).offset(off).multipliedBy(mul)
                        })
                    }
                }else if(publish.contentType == 2){ // 2 video
                    if mediasCount == 1 {
                        let videoView = YCVideoView()
                        self.publishView.addSubview(videoView)
                        self.contentViews.append(videoView)
                        videoView.contentIndex = 0
                        let videoModel = medias[0] as! YCVideoModel
                        let videoW = videoModel.videoWidth
                        let videoH = videoModel.videoHeight
                        var rate: Float = 1.0
                        if videoW != 0 && videoH != 0 {
                            rate = videoH/videoW;
                            if rate > 1 {
                                rate = 1/rate
                                if rate < 3/4 {
                                    rate = 3/4
                                }
                                videoView.snp.makeConstraints({ (make) in
                                    make.top.equalTo(0)
                                    make.left.equalTo(0)
                                    make.width.equalTo(self.bgView.snp.width).multipliedBy(rate)
                                    make.height.equalTo(self.publishView)
                                })
                                rate = 1
                            }else {
                                videoView.snp.makeConstraints({ (make) in
                                    make.top.equalTo(0)
                                    make.left.equalTo(0)
                                    make.width.equalTo(self.publishView)
                                    make.height.equalTo(self.publishView)
                                })
                            }
                        }else {
                            videoView.snp.makeConstraints({ (make) in
                                make.top.equalTo(0)
                                make.left.equalTo(0)
                                make.width.equalTo(self.publishView)
                                make.height.equalTo(self.publishView)
                            })
                        }
                        self.publishView.snp.remakeConstraints { (make) in
                            make.top.equalTo(self.userIcon.snp.bottom).offset(10)
                            make.left.equalTo(self.bgView)
                            make.width.equalTo(self.bgView)
                            make.height.equalTo(self.bgView.snp.width).multipliedBy(rate)
                        }
                        videoView.loadSnapVideo(videoModel)
                    }
                }
            }
            for (index,view) in self.contentViews.enumerated() {
                view.contentIndex = index
                view.tag = index
                view.isUserInteractionEnabled = true
                let contentTap = UITapGestureRecognizer(target: self, action: #selector(self.contentTapHandler))
                view.addGestureRecognizer(contentTap)
            }
            
            self.setPublishLikeStatus()
            self.setPublishCommentStatus()
            self.setPublishContent()
        }
    }
}

extension YCPublishTableViewCell {
    
    func changePublishLikeStatus(publish: YCPublishModel) {
        if self.publishModel != nil, publish.publishID == self.publishModel!.publishID {
            self.publishModel!.isLike = publish.isLike
            self.publishModel!.likeCount = publish.likeCount
            self.setPublishLikeStatus()
        }
    }
    
    func setPublishLikeStatus() {
        if let publishModel = self.publishModel {
            if publishModel.isLike == 1 {
                self.likeBtn.setImage(UIImage(named: "like_high"), for: .normal)
                self.likeBtn.setImage(UIImage(named: "like_high"), for: .highlighted)
            }else {
                self.likeBtn.setImage(UIImage(named: "like_gray"), for: .normal)
                self.likeBtn.setImage(UIImage(named: "like_gray"), for: .highlighted)
            }
            self.likeCountLabel.text = self.getNumberString(number: publishModel.likeCount)
        }
    }
    
    func changePublishCommentStatus(publish: YCPublishModel) {
        if self.publishModel != nil, publish.publishID == self.publishModel!.publishID {
            self.publishModel!.commentCount = publish.commentCount
            self.setPublishCommentStatus()
        }
    }
    
    func setPublishCommentStatus() {
        if let publishModel = self.publishModel {
            self.commentCountLabel.text = self.getNumberString(number: publishModel.commentCount)
        }
    }
    
    func setPublishContent() {
        if let publishModel = self.publishModel {
            self.contentLabel.text = self.getContentString(content: publishModel.content)
        }
    }
    
    @objc func operatorButtonClick() {
        if let delegate = self.delegate {
            delegate.cellOperateButtonClick(self)
        }
    }
    
    @objc func shareButtonClick() {
        if let delegate = self.delegate {
            delegate.cellShareButtonClick(self)
        }
    }
    
    @objc func likeButtonClick() {
        if let delegate = self.delegate {
            delegate.cellLikeButtonClick(self)
        }
    }
    
    @objc func commentTapHandler() {
        if let delegate = self.delegate {
            delegate.cellCommentTap(self)
        }
    }
    
    @objc func commentButtonClick() {
        if let delegate = self.delegate {
            delegate.cellCommentButtonClick(self)
        }
    }
    
    @objc func iconTapHandler(sender:UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.cellUserIconTap(self)
        }
    }
    
    @objc func contentTapHandler(sender:UITapGestureRecognizer) {
        if let delegate = self.delegate, let index = sender.view?.tag {
           delegate.cellContentTap(self, contentIndex: index)
        }
    }
    
    func getContentView() -> YCBaseView? {
        for view in self.contentViews {
            if view.contentIndex == 0 {
                return view
            }
        }
        return nil
    }
}


protocol YCPublishTableViewCellDelegate {
    func cellUserIconTap(_ cell:YCPublishTableViewCell?)
    func cellContentTap(_ cell:YCPublishTableViewCell?, contentIndex: Int)
    func cellCommentTap(_ cell:YCPublishTableViewCell?)
    func cellShareButtonClick(_ cell:YCPublishTableViewCell?)
    func cellLikeButtonClick(_ cell:YCPublishTableViewCell?)
    func cellCommentButtonClick(_ cell:YCPublishTableViewCell?)
    func cellOperateButtonClick(_ cell:YCPublishTableViewCell?)
}


