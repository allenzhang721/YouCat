//
//  PublishCollectionViewCell.swift
//  YouCat
//
//  Created by ting on 2018/10/22.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

enum YCPublishCollectionViewCellType: String{
    case POST = "post"
    case LIKE = "like"
    case THEME = "theme"
}

class YCPublishCollectionViewCell: UICollectionViewCell, YCImageProtocol, YCNumberStringProtocol, YCContentStringProtocol {
    
    var bgView: UIView!
    
    var publishView: UIView!
    var contentLabel: UILabel!
    var userIcon: UIImageView!
    var iconBg: UIView!
    
    var likeImg: UIImageView!
    var likeCountLabel: UILabel!
    
    var publishMoreImg: UIImageView!
    
    var contentViews: [YCBaseView] = []
    
    var type: YCPublishCollectionViewCellType = .POST
    
    var publishModel: YCPublishModel? {
        didSet{
            self.didSetPublishModel();
        }
    }
    
    var delegate: YCPublishCollectionViewCellDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
 
    func initView() {
        self.backgroundColor = YCStyleColor.white
        self.bgView = UIView()
        self.addSubview(self.bgView)
        self.bgView.snp.makeConstraints { (make) in
            make.left.equalTo(1)
            make.right.equalTo(-1).priority(999)
            make.top.equalTo(1)
            make.bottom.equalTo(-1).priority(999)
        }
        self.bgView.backgroundColor = YCStyleColor.white
        self.bgView.layer.cornerRadius = 8;
        self.bgView.clipsToBounds = true
        
        let shadowView = UIView()
        self.addSubview(shadowView)
        self.sendSubviewToBack(shadowView)
        shadowView.snp.makeConstraints { (make) in
            make.left.equalTo(self.bgView)
            make.right.equalTo(self.bgView)
            make.top.equalTo(self.bgView)
            make.bottom.equalTo(self.bgView)
        }
        shadowView.backgroundColor = YCStyleColor.white
        shadowView.layer.cornerRadius = 8;
        self.addShadow(shadowView, 8, 4)
        
        self.publishView = UIView()
        self.bgView.addSubview(self.publishView)
        self.publishView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.width.equalTo(self.bgView)
            make.height.equalTo(self.bgView.snp.width).multipliedBy(0)
        }
        self.addShadow(self.publishView, 0, 1)
        //self.publishView.backgroundColor = YCStyleColor.gay
        
        self.userIcon = UIImageView();
        self.addSubview(self.userIcon)
        self.userIcon.snp.makeConstraints { (make) in
            make.left.equalTo(self.bgView).offset(8)
            make.top.equalTo(self.publishView.snp.bottom).offset(-22)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.cropImageCircle(self.userIcon, 22)
        self.userIcon.image = UIImage(named: "default_icon")
        
        self.iconBg = UIView()
        self.iconBg.backgroundColor = YCStyleColor.white
        self.insertSubview(self.iconBg, belowSubview: self.userIcon)
        self.iconBg.snp.makeConstraints { (make) in
            make.center.equalTo(self.userIcon).offset(0)
            make.width.equalTo(46)
            make.height.equalTo(46)
        }
        self.cropImageCircle(self.iconBg, 23)
        
        self.contentLabel = UILabel();
        self.contentLabel.numberOfLines = 3
        self.addSubview(self.contentLabel)
        self.contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.bgView).offset(5)
            make.right.equalTo(self.bgView).offset(-5)
            make.top.equalTo(self.publishView.snp.bottom).offset(32)
        }
        self.contentLabel.textColor = YCStyleColor.blackGray
        self.contentLabel.font = UIFont.systemFont(ofSize: 16)
        self.contentLabel.text = ""
        
        self.likeCountLabel = UILabel();
        self.addSubview(self.likeCountLabel)
        self.likeCountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.bgView).offset(-10)
            make.top.equalTo(self.publishView.snp.bottom).offset(8)
        }
        self.likeCountLabel.numberOfLines = 1
        self.likeCountLabel.textColor = YCStyleColor.gray
        self.likeCountLabel.font = UIFont.systemFont(ofSize: 12)
        self.likeCountLabel.text = "0"
        self.likeCountLabel.textAlignment = .left
        
        self.likeImg = UIImageView()
        self.addSubview(self.likeImg)
        self.likeImg.snp.makeConstraints { (make) in
            make.right.equalTo(self.likeCountLabel.snp.left).offset(0)
            make.centerY.equalTo(self.likeCountLabel).offset(0)
            make.width.equalTo(33)
            make.height.equalTo(33)
        }
        self.likeImg.image = UIImage(named: "like_gray")
        
        self.publishMoreImg = UIImageView()
        self.addSubview(self.publishMoreImg)
        self.publishMoreImg.snp.makeConstraints { (make) in
            make.right.equalTo(self.bgView)
            make.top.equalTo(self.bgView)
            make.width.equalTo(35)
            make.height.equalTo(26)
        }
        self.publishMoreImg.image = UIImage(named: "publish_more_icon")
        self.publishMoreImg.isHidden = true
    }
    
    func didSetPublishModel(){
        self.setCellValue()
    }
    
    func setCellValue(){
        if let publish = self.publishModel {
            if let user = publish.user{
                if let icon = user.icon {
                    var imagePath = icon.imagePath
                    if imagePath != "" {
                        imagePath = imagePath + "?imageView2/2/w/132"
                    }
                    if let imgURL = URL(string: imagePath) {
                        self.userIcon.kf.setImage(with: ImageResource(downloadURL: imgURL), placeholder:  UIImage(named: "default_icon"), options: nil, progressBlock: nil, completionHandler: nil)
                    }else {
                        self.userIcon.image = UIImage(named: "default_icon")
                    }
                }else {
                    self.userIcon.image = UIImage(named: "default_icon")
                }
            }
            if self.type == .POST {
                self.userIcon.isHidden = true
                self.iconBg.isHidden = true
            }else {
                self.userIcon.isHidden = false
                self.iconBg.isHidden = false
            }
            for view in self.contentViews {
                view.removeFromSuperview()
            }
            self.contentViews.removeAll()
            let medias = publish.medias;
            let mediasCount = medias.count
            if mediasCount == 0 {
                self.publishView.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.bgView)
                    make.left.equalTo(self.bgView)
                    make.width.equalTo(self.bgView)
                    make.height.equalTo(0)
                }
            }else {
                if publish.contentType == 1 {   // 1  image
                    if mediasCount > 0 {
                        let imgModel = medias[0] as! YCImageModel
                        var imgView: YCBaseView
                        if imgModel.imageType == "gif" {
                            imgView = YCAnimationView()
                            (imgView as! YCAnimationView).loadSnapImage(imgModel, snapShot: true)
                        }else {
                            imgView = YCImageView()
                            (imgView as! YCImageView).loadSnapImage(imgModel, snapShot: true)
                        }
                        self.publishView.addSubview(imgView)
                        imgView.snp.makeConstraints({ (make) in
                            make.top.equalTo(0)
                            make.left.equalTo(0)
                            make.width.equalTo(self.publishView)
                            make.height.equalTo(self.publishView)
                        })
                        self.contentViews.append(imgView)
                        let imgW = imgModel.imageWidth
                        let imgH = imgModel.imageHeight
                        var rate: Float = 1.0
                        if imgW != 0 && imgH != 0 {
                            rate = imgH/imgW;
                        }
                        self.publishView.snp.remakeConstraints { (make) in
                            make.top.equalTo(self.bgView)
                            make.left.equalTo(self.bgView)
                            make.width.equalTo(self.bgView)
                            make.height.equalTo(self.bgView.snp.width).multipliedBy(rate)
                        }
                    }
                }else if(publish.contentType == 2){ // 2 video
                    if mediasCount > 0 {
                        let videoView = YCVideoView()
                        self.publishView.addSubview(videoView)
                        videoView.snp.makeConstraints({ (make) in
                            make.top.equalTo(0)
                            make.left.equalTo(0)
                            make.width.equalTo(self.publishView)
                            make.height.equalTo(self.publishView)
                        })
                        self.contentViews.append(videoView)
                        let videoModel = medias[0] as! YCVideoModel
                        let videoW = videoModel.videoWidth
                        let videoH = videoModel.videoHeight
                        var rate: Float = 1.0
                        if videoW != 0 && videoH != 0 {
                            rate = videoH/videoW;
                            
                        }
                        self.publishView.snp.remakeConstraints { (make) in
                            make.top.equalTo(self.bgView)
                            make.left.equalTo(self.bgView)
                            make.width.equalTo(self.bgView)
                            make.height.equalTo(self.bgView.snp.width).multipliedBy(rate)
                        }
                        videoView.loadSnapVideo(videoModel)
                    }
                }
                for (index,view) in self.contentViews.enumerated() {
                    view.contentIndex = index
                }
            }
            self.contentLabel.text = self.getContentString(content: publish.content)
            self.likeCountLabel.text = self.getNumberString(number: publish.likeCount)
            if publish.isLike == 1 {
                self.likeImg.image = UIImage(named: "like_high")
            }else {
                self.likeImg.image = UIImage(named: "like_gray")
            }
            if medias.count > 1 {
                self.publishMoreImg.isHidden = false
            }else {
                self.publishMoreImg.isHidden = true
            }
//            self.commentCountLabel.text = self.getNumberString(number: publish.commentCount)
        }
    }
    
}

protocol YCPublishCollectionViewCellDelegate: YCContentStringProtocol {
    func cellUserIconTap(_ cell:YCPublishCollectionViewCell?)
    func getPublishSize(publish: YCPublishModel, publishSize: [String : CGSize], frame: CGSize, sectionInset: UIEdgeInsets, minimumInteritemSpacing: Float, columnCount: Int) -> CGSize
}

extension YCPublishCollectionViewCellDelegate {
    
    func cellUserIconTap(_ cell:YCPublishCollectionViewCell?){
        
    }
    
    func getPublishSize(publish: YCPublishModel, publishSize: [String : CGSize], frame: CGSize, sectionInset: UIEdgeInsets, minimumInteritemSpacing: Float, columnCount: Int) -> CGSize {
        let publishID = publish.publishID
        if let size = publishSize[publishID]{
            return size
        }else {
            let contentWidth = Float(frame.width - sectionInset.left - sectionInset.right)
            let cellW = Float((contentWidth - Float(columnCount - 1)*minimumInteritemSpacing)/Float(columnCount))
            var cellH = cellW
            let medias = publish.medias
            let mediasCount = medias.count
            var mediaH:Float = 0.0
            if mediasCount == 0 {
                mediaH = 0.0
            }else {
                if publish.contentType == 1 {
                    if mediasCount > 0 {
                        let imgModel = medias[0] as! YCImageModel
                        let imgW = imgModel.imageWidth
                        let imgH = imgModel.imageHeight
                        var rate: Float = 1.0
                        if imgW != 0 && imgH != 0 {
                            rate = imgH/imgW;
                        }
                        mediaH = (cellW-2)*rate
                    }else {
                        mediaH = 0.0
                    }
                }else if(publish.contentType == 2){ // 2 video
                    if mediasCount > 0 {
                        let videoModel = medias[0] as! YCVideoModel
                        let videoW = videoModel.videoWidth
                        let videoH = videoModel.videoHeight
                        var rate: Float = 1.0
                        if videoW != 0 && videoH != 0 {
                            rate = videoH/videoW;
                        }
                        mediaH = (cellW-2)*rate
                    }else {
                        mediaH = 0.0
                    }
                }
            }
            let content = self.getContentString(content: publish.content)
            let label = UILabel(frame: CGRect(x: 9, y: 0, width: CGFloat(cellW-12), height: 22))
            label.numberOfLines = 3
            label.textColor = YCStyleColor.black
            label.font = UIFont.systemFont(ofSize: 16)
            label.text = content
            label.sizeToFit();
            let contentH = Float(label.frame.height)
            cellH = mediaH + contentH + 45
            let size = CGSize(width: CGFloat(cellW), height: CGFloat(cellH))
            return size
        }
    }
    
}
