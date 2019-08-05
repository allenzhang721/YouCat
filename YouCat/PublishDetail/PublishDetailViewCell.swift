//
//  PublishDetailViewCell.swift
//  YouCat
//
//  Created by ting on 2018/10/29.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
import Kingfisher

class YCPublishDetailViewCell: UICollectionViewCell, YCImageProtocol, YCNumberStringProtocol, YCContentStringProtocol {
    
    var userView: UIView!
    var userIcon: UIImageView!
    var followButton: YCFollowButton!
    
    var contentLabel: UILabel!
    
    var bottomOperateView: UIView!
    var likeImg: UIImageView!
    var likeCountLabel: UILabel!
    var commentCountLabel: UILabel!
    
    var contentPageController: UIPageControl!
    var contentScrollView: UIScrollView!
    let contentGap = 10
    var contentViews: [YCBaseView] = []
    var isDisplaying: Bool = false
    var isFocus: Bool = false
    
    var isDoubleTap: Bool = false
    
    var isTapStatus: Bool = false
    
    var tapTime: DispatchSourceTimer?
    
    
    var publishModel: YCPublishModel? {
        didSet{
            if let old = oldValue {
                if old.publishID != publishModel?.publishID {
                    self.displayRelease()
                    self.didSetPublishModel();
                }
            }else {
                self.didSetPublishModel();
            }
        }
    }
    
    var mediaModel: YCMediaViewModel?
    
    var contentIndex = 0
    var delegate:YCPublishDetailViewCellDelegate?
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    func initView(){
        
        self.isUserInteractionEnabled = true
        let viewSigleTap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapHandler))
        self.addGestureRecognizer(viewSigleTap)
        let viewDoubleTap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapHandler))
        viewDoubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(viewDoubleTap)
        
        self.contentScrollView = UIScrollView()
        self.addSubview(self.contentScrollView)
        self.contentScrollView.snp.makeConstraints { (make) in
            make.left.equalTo(0-self.contentGap)
            make.top.equalTo(0)
            make.right.equalTo(self.contentGap).priority(999)
            make.bottom.equalTo(0).priority(999)
        }
        self.contentScrollView.bounces = false
        self.contentScrollView.isPagingEnabled = true
        self.contentScrollView.showsHorizontalScrollIndicator = false
        self.contentScrollView.showsVerticalScrollIndicator = false
        self.contentScrollView.scrollsToTop = false
        self.contentScrollView.delegate = self

        self.contentPageController = UIPageControl()
        self.addSubview(self.contentPageController)
        self.contentPageController.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalTo(0-YCScreen.fullScreenArea.bottom)
        }
        self.contentPageController.isUserInteractionEnabled = false
        
        self.userView = UIView()
        self.addSubview(self.userView)
        self.userView.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.bottom.equalTo(self.contentPageController.snp.top).offset(0)
            make.width.equalTo(66)
            make.height.equalTo(66)
        }
        
        let iconBg = UIView()
        iconBg.backgroundColor = YCStyleColor.white
        self.userView.addSubview(iconBg)
        iconBg.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.bottom.equalTo(-12)
            make.width.equalTo(66)
            make.height.equalTo(66)
        }
        self.cropImageCircle(iconBg, 33)
        
        self.userIcon = UIImageView()
        iconBg.addSubview(self.userIcon)
        self.userIcon.snp.makeConstraints { (make) in
            make.left.equalTo(1)
            make.top.equalTo(1)
            make.width.equalTo(64)
            make.height.equalTo(64)
        }
        self.cropImageCircle(self.userIcon, 32)
        self.userIcon.image = UIImage(named: "default_icon")
        
        let iconTap = UITapGestureRecognizer(target: self, action: #selector(self.iconTapHandler))
        iconBg.isUserInteractionEnabled = true
        iconBg.addGestureRecognizer(iconTap)
        
        
        self.followButton = YCFollowButton(fontSize: 12, radius: 12)
        self.userView.addSubview(self.followButton)
        self.followButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(0)
            make.centerX.equalTo(iconBg).offset(0)
            make.width.equalTo(50)
            make.height.equalTo(24)
        }
        let followButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.followButtonTapHandler))
        self.followButton.addGestureRecognizer(followButtonTap)
        
        self.contentLabel = UILabel();
        self.contentLabel.numberOfLines = 0
        self.addSubview(self.contentLabel)
        self.contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-100)
            make.bottom.equalTo(self.contentPageController.snp.top).offset(0)
        }
        self.contentLabel.textColor = YCStyleColor.white
        self.contentLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.contentLabel.text = ""
        self.contentLabel.shadowColor = YCStyleColor.black
        self.contentLabel.shadowOffset = CGSize(width: 0, height: 0)
        self.contentLabel.layer.shadowOpacity = 0.1
        self.contentLabel.layer.shadowRadius = 2
        
        self.bottomOperateView = UIView()
        self.addSubview(self.bottomOperateView)
        self.bottomOperateView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(YCScreen.fullScreenArea.bottom)
        }
        
        let lineView = UIView()
        self.bottomOperateView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.left.equalTo(0)
            make.height.equalTo(0.5)
            make.top.equalTo(0)
        }
        lineView.backgroundColor = YCStyleColor.grayWhiteAlpha
        
        let shareView = UIView()
        self.bottomOperateView.addSubview(shareView)
        shareView.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(YCScreen.fullScreenArea.bottom)
            make.width.equalTo(54)
        }
        let shareTap = UITapGestureRecognizer(target: self, action: #selector(self.shareButtonClick))
        shareView.isUserInteractionEnabled = true
        shareView.addGestureRecognizer(shareTap)
        
        let shareLabel = UILabel();
        shareView.addSubview(shareLabel)
        shareLabel.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.width.equalTo(10)
            make.height.equalTo(44)
            make.top.equalTo(2)
        }
        shareLabel.textColor = YCStyleColor.white
        shareLabel.font = UIFont.systemFont(ofSize: 12)
        shareLabel.text = ""//YCLanguageHelper.getString(key: "ShareButtonLabel")
        shareLabel.textAlignment = .center
        
        let shareBtn = UIImageView(image: UIImage(named: "share_white"))
        shareView.addSubview(shareBtn)
        shareBtn.snp.makeConstraints { (make) in
            make.right.equalTo(shareLabel.snp.left).offset(0)
            make.centerY.equalTo(shareLabel).offset(0)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        let likeView = UIView()
        self.bottomOperateView.addSubview(likeView)
        likeView.snp.makeConstraints { (make) in
            make.right.equalTo(shareBtn.snp.left).offset(0)
            make.top.equalTo(0)
            make.height.equalTo(YCScreen.fullScreenArea.bottom)
            make.width.equalTo(60)
        }
        likeView.tag = 1
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(self.likeButtonClick))
        likeView.isUserInteractionEnabled = true
        likeView.addGestureRecognizer(likeTap)
        
        self.likeImg = UIImageView(image: UIImage(named: "like_white"))
        likeView.addSubview(self.likeImg)
        self.likeImg.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.centerY.equalTo(shareBtn).offset(0)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        self.likeCountLabel = UILabel();
        likeView.addSubview(self.likeCountLabel)
        self.likeCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.likeImg.snp.right).offset(-5)
            make.centerY.equalTo(shareBtn).offset(0)
        }
        self.likeCountLabel.textColor = YCStyleColor.white
        self.likeCountLabel.font = UIFont.boldSystemFont(ofSize: 12)
        self.likeCountLabel.text = "0"
        self.likeCountLabel.textAlignment = .left
        
        
        let commentCountView = UIView()
        self.bottomOperateView.addSubview(commentCountView)
        commentCountView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.right.equalTo(likeView.snp.left).offset(0)
            make.height.equalTo(YCScreen.fullScreenArea.bottom)
            make.width.equalTo(60)
        }
        commentCountView.tag = 2
        let commentCountTap = UITapGestureRecognizer(target: self, action: #selector(self.commentButtonClick))
        commentCountView.isUserInteractionEnabled = true
        commentCountView.addGestureRecognizer(commentCountTap)
       
        let commentImg = UIImageView(image: UIImage(named: "comment_white"))
        commentCountView.addSubview(commentImg)
        commentImg.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.centerY.equalTo(shareBtn).offset(0)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        self.commentCountLabel = UILabel();
        commentCountView.addSubview(self.commentCountLabel)
        self.commentCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(commentImg.snp.right).offset(-5)
            make.centerY.equalTo(shareBtn).offset(0)
        }
        self.commentCountLabel.textColor = YCStyleColor.white
        self.commentCountLabel.font = UIFont.boldSystemFont(ofSize: 12)
        self.commentCountLabel.text = "0"
        self.commentCountLabel.textAlignment = .left
        
        let commentView = UIView()
        self.bottomOperateView.addSubview(commentView)
        commentView.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.right.equalTo(commentCountView.snp.left)
            make.top.equalTo(0)
            make.height.equalTo(YCScreen.fullScreenArea.bottom)
        }
        commentView.layer.borderColor = UIColor.clear.cgColor//YCStyleColor.blackAlpha.cgColor
        commentView.layer.borderWidth = 1
        commentView.layer.cornerRadius = 16;
        commentView.backgroundColor = UIColor.clear//YCStyleColor.grayWhiteAlpha
        let commentTap = UITapGestureRecognizer(target: self, action: #selector(self.commentTapHandler))
        commentView.isUserInteractionEnabled = true
        commentView.addGestureRecognizer(commentTap)
        
        let commentSignImg = UIImageView(image: UIImage(named: "comment_sign_gray"))
        commentView.addSubview(commentSignImg)
        commentSignImg.snp.makeConstraints { (make) in
            make.height.equalTo(32)
            make.width.equalTo(32)
            make.left.equalTo(0)
            make.centerY.equalTo(shareBtn).offset(0)
        }
        
        let commentLabel = UILabel();
        commentView.addSubview(commentLabel)
        commentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(15)
            make.centerY.equalTo(shareBtn).offset(0)
        }
        commentLabel.textColor = YCStyleColor.grayWhite
        commentLabel.font = UIFont.systemFont(ofSize: 16)
        commentLabel.text = YCLanguageHelper.getString(key: "EnterCommentLabel")
        self.backgroundColor = YCStyleColor.black
    }
    
    func willDisplayView(contentIndex: Int) {
        if contentIndex != -1 {
            self.contentIndex = contentIndex
        }
        self.prepareContent()
    }
    
    func displayView() {
        print("displayView")
        if let _ = self.publishModel {
            if !self.isDisplaying {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2, execute: {
                    if self.isDisplaying {
                        self.loadContent()
                    }
                })
            }else {
                for view in self.contentViews {
                    view.displayView()
                }
            }
            self.isDisplaying = true
        }
    }
    
    func disPlayViewEnd() {
        print("disPlayViewEnd")
        for view in self.contentViews {
            view.stop()
        }
        self.isDisplaying = false
    }
    
    func displayPause() {
        print("displayPause")
        if self.isDisplaying {
            for view in self.contentViews {
                view.pause()
            }
        }
        self.isDisplaying = false
    }
    
    func displayRelease() {
        print("displayRelease")
        for view in self.contentViews {
            view.clean()
            view.removeFromSuperview()
        }
        self.mediaModel = nil
        self.contentViews.removeAll()
        self.contentIndex = 0
        self.isDisplaying = false
        self.isFocus = false
        self.isTapStatus = false
        self.userView.alpha = 1
        self.contentLabel.alpha = 1
        self.bottomOperateView.alpha = 1
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
                        self.userIcon.kf.setImage(with: ImageResource(downloadURL: imgURL), placeholder: UIImage(named: "default_icon"), options: nil, progressBlock: nil, completionHandler: nil)
                    }else {
                        self.userIcon.image = UIImage(named: "default_icon")
                    }
                }else {
                    self.userIcon.image = UIImage(named: "default_icon")
                }
                if user.relation == 0 {
                    self.followButton.isHidden = false
                    self.followButton.alpha = 1
                    self.followButton.setUnFollowStatus()
                }else {
                    self.followButton.isHidden = true
                }
            }
            self.contentLabel.text = self.getContentString(content: publish.content)
            self.likeCountLabel.text = self.getNumberString(number: publish.likeCount)
            self.commentCountLabel.text = self.getNumberString(number: publish.commentCount)
            self.resetCountLabel()
            if publish.isLike == 1 {
                self.likeImg.image = UIImage(named: "like_high")
            }else {
                self.likeImg.image = UIImage(named: "like_white")
            }
            for view in self.contentViews {
                view.clean()
                view.removeFromSuperview()
            }
            self.contentViews.removeAll()
            self.contentIndex = 0
        }
    }
    
    func resetCountLabel() {
        self.likeCountLabel.sizeToFit()
        let w1 = self.likeCountLabel.frame.width
        if w1 > 20 {
            self.viewWithTag(1)?.snp.updateConstraints({ (make) in
                make.width.equalTo(44+w1-5)
            })
        }
        self.commentCountLabel.sizeToFit()
        let w2 = self.commentCountLabel.frame.width
        if w2 > 20 {
            self.viewWithTag(2)?.snp.updateConstraints({ (make) in
                make.width.equalTo(44+w2-5)
            })
        }
    }
    
    func prepareContent() {
        if let publish = self.publishModel {
            if self.contentViews.count == 0 {
                let medias = publish.medias;
                if medias.count == 0 {
                    return
                }
                self.contentScrollView.isScrollEnabled = false
                let bound = self.frame
                var model: YCBaseModel
                if self.contentIndex != 0, self.contentIndex < medias.count {
                    model = medias[self.contentIndex]
                }else {
                    model = medias[0]
                    self.contentIndex = 0
                }
                let contentW = bound.width+CGFloat(self.contentGap*2)
                let contentH = bound.height //- self.bottomH
                let contentRect = CGRect(x: 0, y: 0, width: contentW, height: contentH).insetBy(dx: CGFloat(self.contentGap), dy: 0)
                self.addPublishContent(model: model, frame: contentRect, index: self.contentIndex)
                self.contentScrollView.contentSize = CGSize(width: contentW, height: bound.height)
                let offset = CGPoint(x: 0, y: 0)
                self.contentScrollView.setContentOffset(offset, animated: false)
                self.contentPageController.numberOfPages = medias.count
                self.contentPageController.currentPage = self.contentIndex
                if medias.count == 1 {
                    self.contentPageController.isHidden = true
                }else {
                    self.contentPageController.isHidden = false
                }
            }
        }
    }
    
    func loadContent(){
        if let publish = self.publishModel {
            let medias = publish.medias;
            let mediasCount = medias.count
            let bound = self.frame
            let contentW = bound.width+CGFloat(self.contentGap*2)
            let contentH = bound.height //- self.bottomH
            for (index,model) in medias.enumerated() {
                let contentRect = CGRect(x: contentW*CGFloat(index), y: 0, width: contentW, height: contentH).insetBy(dx: CGFloat(self.contentGap), dy: 0)
                var isHave = false
                for view in self.contentViews {
                    if view.contentIndex == index {
                        view.frame = contentRect
                        isHave = true
                    }
                }
                if !isHave {
                    self.addPublishContent(model: model, frame: contentRect, index: index)
                }
            }
            if mediasCount == 1 {
                self.contentScrollView.isScrollEnabled = false
                self.contentPageController.isHidden = true
            }else {
                self.contentScrollView.isScrollEnabled = true
                self.contentPageController.isHidden = false
            }
            self.contentScrollView.contentSize = CGSize(width: contentW * CGFloat(mediasCount),
                                                        height: bounds.height)
            let offset = CGPoint(x: contentW * CGFloat(self.contentIndex), y: 0)
            self.contentScrollView.setContentOffset(offset, animated: false)
            for view in self.contentViews {
                view.loadMedia(self.mediaModel)
                view.displayView()
                if view.contentIndex == self.contentIndex {
                    view.play()
                }else {
                    view.stop()
                }
            }
            self.contentPageController.numberOfPages = mediasCount
            self.contentPageController.currentPage = self.contentIndex
        }
    }
    
    func addPublishContent(model: YCBaseModel, frame: CGRect, index: Int){
        if let publish = self.publishModel {
            if publish.contentType == 1 {
                if let imageModel = model as? YCImageModel {
                    if imageModel.imageType == "gif" {
                        let aniView = YCAnimationView(frame: frame)
                        aniView.delegate = self
                        self.contentScrollView.addSubview(aniView)
                        self.contentViews.append(aniView)
                        aniView.loadImage(imageModel)
                        aniView.contentIndex = index
                    }else {
                        let imgView = YCImageView(frame: frame)
                        imgView.delegate = self
                        self.contentScrollView.addSubview(imgView)
                        self.contentViews.append(imgView)
                        imgView.loadImage(imageModel)
                        imgView.contentIndex = index
                    }
                }
            }else if publish.contentType == 2 {
                if let videoModel = model as? YCVideoModel {
                    let videoView = YCVideoView(frame: frame)
                    videoView.delegate = self
                    self.contentScrollView.addSubview(videoView)
                    self.contentViews.append(videoView)
                    videoView.loadVideo(videoModel)
                    videoView.contentIndex = index
                }
            }
        }
    }
}

extension YCPublishDetailViewCell: UIScrollViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if(scrollView == self.contentScrollView){
            self.isFocus = true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        if(scrollView == self.contentScrollView){
            self.isFocus = true
            self.setCurrentContent()
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if(scrollView == self.contentScrollView){
            self.isFocus = true
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if(scrollView == self.contentScrollView){
            self.setCurrentContent()
        }
    }
    
    func setCurrentContent(){
        var offset = self.contentScrollView.contentOffset
        let bound = self.frame
        let contentW = bound.width+CGFloat(self.contentGap*2)
        self.contentIndex = Int(offset.x / contentW)
        self.contentPageController.currentPage = self.contentIndex
        offset = CGPoint(x: contentW * CGFloat(self.contentIndex), y: 0)
        self.contentScrollView.setContentOffset(offset, animated: false)
        for view in self.contentViews {
            if view.contentIndex == self.contentIndex {
                view.play()
            }else {
                view.stop()
            }
        }
    }
}

extension YCPublishDetailViewCell: YCViewDelegate {
    func viewDidPlayToEnd(view: YCBaseView) {
        let contentIndex = view.contentIndex
        if let publish = self.publishModel {
            if self.isFocus || self.isDoubleTap{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1, execute: {
                    for view in self.contentViews {
                        if view.contentIndex == self.contentIndex {
                            view.play()
                        }else {
                            view.stop()
                        }
                    }
                })
            }else {
                let medias = publish.medias
                let mediasCount = medias.count
                let nextIndex = contentIndex + 1
                if nextIndex < mediasCount {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1, execute: {
                        if self.isDisplaying {
                            let bound = self.frame
                            let contentW = bound.width+CGFloat(self.contentGap*2)
                            let offset = CGPoint(x: contentW * CGFloat(nextIndex), y: 0)
                            self.contentScrollView.setContentOffset(offset, animated: true)
                        }
                    })
                }else {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1, execute: {
                        if self.isDisplaying {
                            DispatchQueue.main.async {
                                self.isDisplaying = false
                                if let delegate = self.delegate {
                                    delegate.cellDidPlayToEnd(cell: self)
                                }
                            }
                        }
                    })
                }
            }
        }
    }
}

extension YCPublishDetailViewCell {
    
    func changePublishLikeStatus(publish: YCPublishModel) {
        if let publishModel = self.publishModel, publish.publishID == publishModel.publishID {
            publishModel.isLike = publish.isLike
            publishModel.likeCount = publish.likeCount
            if publishModel.isLike == 1 {
                self.likeImg.image = UIImage(named: "like_high")
            }else {
                self.likeImg.image = UIImage(named: "like_white")
            }
            self.likeCountLabel.text = self.getNumberString(number: publishModel.likeCount)
            self.resetCountLabel()
        }
    }
    
    func changePublishCommentStatus(publish: YCPublishModel) {
        if let publishModel = self.publishModel {
            publishModel.commentCount = publish.commentCount
            self.commentCountLabel.text = self.getNumberString(number: publishModel.commentCount)
            self.resetCountLabel()
        }
    }
    
    @objc func followButtonTapHandler() {
        if let delegate = self.delegate {
            self.isFocus = true
            delegate.cellFollowButtonTap(self) {
                UIView.animate(withDuration: 0.5, animations: {
                    
                })
                UIView.animate(withDuration: 0.5, animations: {
                    self.followButton.alpha = 0
                }, completion: { (_) in
                    self.followButton.isHidden = true
                    self.followButton.alpha = 1
                })
            }
        }
    }
    
    @objc func shareButtonClick() {
        if let delegate = self.delegate {
            self.isFocus = true
            delegate.cellShareButtonClick(self)
        }
    }
    
    @objc func likeButtonClick() {
        if let delegate = self.delegate {
            self.isFocus = true
            delegate.cellLikeButtonClick(self)
        }
    }
    
    @objc func commentTapHandler() {
        if let delegate = self.delegate {
            self.isFocus = true
            delegate.cellCommentTap(self)
        }
    }
    
    @objc func commentButtonClick() {
        if let delegate = self.delegate {
            self.isFocus = true
            delegate.cellCommentButtonClick(self)
        }
    }
    
    @objc func iconTapHandler(sender:UITapGestureRecognizer) {
        if let delegate = self.delegate {
            self.isFocus = true
            delegate.cellUserIconTap(cell: self)
        }
    }
    
    @objc func viewTapHandler(sender:UITapGestureRecognizer) {
        if !self.isDoubleTap {
            if sender.numberOfTapsRequired == 1 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3, execute: {
                    if !self.isDoubleTap {
                        self.viewSigleTapHandler(sender: sender)
                    }
                })
            }else if sender.numberOfTapsRequired == 2 {
                self.isDoubleTap = true
                self.resetTapHandler()
                self.viewDoubleTapHandler(sender: sender)
            }
        }else {
            self.isDoubleTap = true
            self.resetTapHandler()
            self.viewDoubleTapHandler(sender: sender)
        }
    }
    
    func resetTapHandler() {
        if self.tapTime != nil {
            self.tapTime!.cancel()
            self.tapTime = nil
        }
        self.tapTime = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        self.tapTime?.schedule(deadline: .now()+1)
        self.tapTime!.setEventHandler {
            self.isDoubleTap = false
            self.tapTime!.cancel()
            self.tapTime = nil
        }
        self.tapTime!.resume()
    }
    
    func viewDoubleTapHandler(sender:UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.cellContentDoubleTap(self, sender: sender)
        }
    }
    
    func viewSigleTapHandler(sender:UITapGestureRecognizer) {
        if let publish = self.publishModel {
            if publish.contentType == 1 {
                if self.isTapStatus {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.userView.alpha = 1
                        self.contentLabel.alpha = 1
                        self.bottomOperateView.alpha = 1
                    })
                    self.isTapStatus = false
                }else {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.userView.alpha = 0
                        self.contentLabel.alpha = 0
                        self.bottomOperateView.alpha = 0
                    })
                    self.isTapStatus = true
                }
                
            }else if publish.contentType == 2 {
                if self.isTapStatus {
                    for view in self.contentViews {
                        if view.contentIndex == self.contentIndex {
                            view.play()
                        }else {
                            view.stop()
                        }
                    }
                    self.isTapStatus = false
                }else {
                    for view in self.contentViews {
                        view.pause()
                    }
                    self.isTapStatus = true
                }
            }
        }
    }
    
    func getCurrentView() -> YCBaseView? {
        var index = 0
        if self.contentIndex != 0, self.contentIndex < self.contentViews.count {
            index = self.contentIndex
        }
        for view in self.contentViews {
            if view.contentIndex == index {
                return view
            }
        }
        return nil
    }
}


protocol YCPublishDetailViewCellDelegate {
    func cellUserIconTap(cell: YCPublishDetailViewCell?)
    func cellDidPlayToEnd(cell: YCPublishDetailViewCell?)
    func cellCommentTap(_ cell: YCPublishDetailViewCell?)
    func cellContentDoubleTap(_ cell: YCPublishDetailViewCell?, sender:UITapGestureRecognizer)
    func cellFollowButtonTap(_ cell:YCPublishDetailViewCell?, followBlock: (()->Void)?)
    func cellShareButtonClick(_ cell:YCPublishDetailViewCell?)
    func cellLikeButtonClick(_ cell:YCPublishDetailViewCell?)
    func cellCommentButtonClick(_ cell:YCPublishDetailViewCell?)
}
