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
    
    var headerView: UIView!
    var userIcon: UIImageView!
    var followButton: YCFollowButton!
    var operatorButton: UIButton!
    
    var contentLabel: UILabel!
    
    var commentView: UIView!
    var shareBtn: UIButton!
    var shareLabel: UILabel!
    var likeBtn: UIButton!
    var likeCountLabel: UILabel!
    var commentBtn: UIButton!
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
        
        let buttonBottom = YCScreen.safeArea.bottom == 0 ? 10:(YCScreen.safeArea.bottom-5)
        self.contentScrollView = UIScrollView()
        self.addSubview(self.contentScrollView)
        self.contentScrollView.snp.makeConstraints { (make) in
            make.left.equalTo(0-self.contentGap)
            make.top.equalTo(0)
            make.right.equalTo(self.contentGap).priority(999)
            make.bottom.equalTo(0).priority(999)
        }
        self.contentScrollView.isPagingEnabled = true
        self.contentScrollView.showsHorizontalScrollIndicator = false
        self.contentScrollView.showsVerticalScrollIndicator = false
        self.contentScrollView.scrollsToTop = false
        self.contentScrollView.delegate = self
        
        
        self.headerView = UIView(frame: CGRect(x: 0, y: YCScreen.safeArea.top, width: self.frame.width, height: 50))
        self.addSubview(self.headerView)
        
        self.userIcon = UIImageView()
        self.headerView.addSubview(self.userIcon)
        self.userIcon.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(2)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.cropImageCircle(self.userIcon, 22)
        self.userIcon.image = UIImage(named: "default_icon")
        
        let iconTap = UITapGestureRecognizer(target: self, action: #selector(self.iconTapHandler))
        self.userIcon.isUserInteractionEnabled = true
        self.userIcon.addGestureRecognizer(iconTap)
        
        let iconBg = UIView()
        iconBg.backgroundColor = YCStyleColor.white
        self.headerView.insertSubview(iconBg, belowSubview: self.userIcon)
        iconBg.snp.makeConstraints { (make) in
            make.center.equalTo(self.userIcon).offset(0)
            make.width.equalTo(46)
            make.height.equalTo(46)
        }
        self.cropImageCircle(iconBg, 23)
        
        self.followButton = YCFollowButton(fontSize: 12, radius: 12)
        self.headerView.addSubview(self.followButton)
        self.followButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.userIcon.snp.right).offset(10)
            make.centerY.equalTo(self.userIcon).offset(2)
            make.width.equalTo(60)
            make.height.equalTo(24)
        }
        let followButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.followButtonTapHandler))
        self.followButton.addGestureRecognizer(followButtonTap)
    
        self.operatorButton = UIButton()
        self.headerView.addSubview(self.operatorButton)
        self.operatorButton.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-54)
            make.centerY.equalTo(self.userIcon).offset(0)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.operatorButton.setImage(UIImage(named: "operate_white"), for: .normal)
        self.operatorButton.setImage(UIImage(named: "operate_white"), for: .highlighted)
        self.operatorButton.addTarget(self, action: #selector(self.operateButtonClick), for: .touchUpInside)
        
        self.shareLabel = UILabel();
        self.addSubview(self.shareLabel)
        self.shareLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.width.equalTo(44)
            make.bottom.equalTo(0-buttonBottom)
        }
        self.shareLabel.textColor = YCStyleColor.white
        self.shareLabel.font = UIFont.systemFont(ofSize: 12)
        self.shareLabel.text = YCLanguageHelper.getString(key: "ShareButtonLabel")
        self.shareLabel.textAlignment = .center
        
        self.shareBtn = UIButton();
        self.addSubview(self.shareBtn)
        self.shareBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.bottom.equalTo(self.shareLabel.snp.top).offset(10)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.shareBtn.setImage(UIImage(named: "share_white"), for: .normal)
        self.shareBtn.setImage(UIImage(named: "share_white"), for: .highlighted)
        self.shareBtn.addTarget(self, action: #selector(self.shareButtonClick), for: .touchUpInside)
        
        self.contentPageController = UIPageControl()
        self.addSubview(self.contentPageController)
        self.contentPageController.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalTo(self.shareBtn.snp.top).offset(20)
        }
        self.contentPageController.isUserInteractionEnabled = false
        
        self.contentLabel = UILabel();
        self.contentLabel.numberOfLines = 0
        self.addSubview(self.contentLabel)
        self.contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalTo(self.contentPageController.snp.top).offset(10)
        }
        self.contentLabel.textColor = YCStyleColor.white
        self.contentLabel.font = UIFont.systemFont(ofSize: 14)
        self.contentLabel.text = ""
        self.contentLabel.shadowColor = YCStyleColor.black
        self.contentLabel.shadowOffset = CGSize(width: 0, height: 0.5)
        self.contentLabel.layer.shadowOpacity = 0.1
        self.contentLabel.layer.shadowRadius = 4
        
        self.likeBtn = UIButton();
        self.addSubview(self.likeBtn)
        self.likeBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.shareBtn.snp.left).offset(0)
            make.top.equalTo(self.shareBtn).offset(0)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        self.likeBtn.setImage(UIImage(named: "like_white"), for: .normal)
        self.likeBtn.setImage(UIImage(named: "like_white"), for: .highlighted)
        self.likeBtn.addTarget(self, action: #selector(self.likeButtonClick), for: .touchUpInside)
        
        self.likeCountLabel = UILabel();
        self.addSubview(self.likeCountLabel)
        self.likeCountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.likeBtn).offset(0)
            make.left.equalTo(self.likeBtn).offset(0)
            make.top.equalTo(self.likeBtn.snp.bottom).offset(-10)
        }
        self.likeCountLabel.textColor = YCStyleColor.white
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
        self.commentBtn.setImage(UIImage(named: "comment_white"), for: .normal)
        self.commentBtn.setImage(UIImage(named: "comment_white"), for: .highlighted)
        self.commentBtn.addTarget(self, action: #selector(self.commentButtonClick), for: .touchUpInside)
        
        self.commentCountLabel = UILabel();
        self.addSubview(self.commentCountLabel)
        self.commentCountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.commentBtn).offset(0)
            make.left.equalTo(self.commentBtn).offset(0)
            make.top.equalTo(self.commentBtn.snp.bottom).offset(-10)
        }
        self.commentCountLabel.textColor = YCStyleColor.white
        self.commentCountLabel.font = UIFont.systemFont(ofSize: 12)
        self.commentCountLabel.text = "0"
        self.commentCountLabel.textAlignment = .center
        
        self.commentView = UIView()
        self.addSubview(self.commentView)
        self.commentView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(self.commentBtn.snp.left)
            make.top.equalTo(self.commentBtn).offset(13)
            make.height.equalTo(35)
        }
        self.commentView.layer.borderColor = YCStyleColor.blackAlpha.cgColor
        self.commentView.layer.borderWidth = 1
        self.commentView.layer.cornerRadius = 16;
        self.commentView.backgroundColor = YCStyleColor.grayWhiteAlpha
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
        self.headerView.alpha = 1
        self.contentLabel.alpha = 1
        self.commentView.alpha = 1
        self.commentBtn.alpha = 1
        self.commentCountLabel.alpha = 1
        self.likeBtn.alpha = 1
        self.likeCountLabel.alpha = 1
        self.shareBtn.alpha = 1
        self.shareLabel.alpha = 1
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
            if publish.isLike == 1 {
                self.likeBtn.setImage(UIImage(named: "like_high"), for: .normal)
                self.likeBtn.setImage(UIImage(named: "like_high"), for: .highlighted)
            }else {
                self.likeBtn.setImage(UIImage(named: "like_white"), for: .normal)
                self.likeBtn.setImage(UIImage(named: "like_white"), for: .highlighted)
            }
            for view in self.contentViews {
                view.clean()
                view.removeFromSuperview()
            }
            self.contentViews.removeAll()
            self.contentIndex = 0
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
                let bottomH = YCScreen.safeArea.bottom == 0 ? 54:YCScreen.safeArea.bottom+44
                let contentH = bound.height - bottomH
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
            let bottomH = YCScreen.safeArea.bottom == 0 ? 54:YCScreen.safeArea.bottom+44
            let contentH = bound.height - bottomH
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
                self.likeBtn.setImage(UIImage(named: "like_high"), for: .normal)
                self.likeBtn.setImage(UIImage(named: "like_high"), for: .highlighted)
            }else {
                self.likeBtn.setImage(UIImage(named: "like_white"), for: .normal)
                self.likeBtn.setImage(UIImage(named: "like_white"), for: .highlighted)
            }
            self.likeCountLabel.text = self.getNumberString(number: publishModel.likeCount)
        }
    }
    
    func changePublishCommentStatus(publish: YCPublishModel) {
        if let publishModel = self.publishModel {
            publishModel.commentCount = publish.commentCount
            self.commentCountLabel.text = self.getNumberString(number: publishModel.commentCount)
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
    
    @objc func operateButtonClick(){
        if let delegate = self.delegate {
            self.isFocus = true
            delegate.cellOperateButtonClick(self)
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
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: {
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
                        self.headerView.alpha = 1
                        self.contentLabel.alpha = 1
                        self.commentView.alpha = 1
                        self.commentBtn.alpha = 1
                        self.commentCountLabel.alpha = 1
                        self.likeBtn.alpha = 1
                        self.likeCountLabel.alpha = 1
                        self.shareBtn.alpha = 1
                        self.shareLabel.alpha = 1
                    })
                    self.isTapStatus = false
                }else {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.headerView.alpha = 0
                        self.contentLabel.alpha = 0
                        self.commentView.alpha = 0
                        self.commentBtn.alpha = 0
                        self.commentCountLabel.alpha = 0
                        self.likeBtn.alpha = 0
                        self.likeCountLabel.alpha = 0
                        self.shareBtn.alpha = 0
                        self.shareLabel.alpha = 0
                    })
                    self.isTapStatus = true
                }
                
            }else if publish.contentType == 2 {
                if self.isTapStatus {
                    for view in self.contentViews {
                        view.pause()
                    }
                    self.isTapStatus = false
                }else {
                    for view in self.contentViews {
                        if view.contentIndex == self.contentIndex {
                            view.play()
                        }else {
                            view.stop()
                        }
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
    func cellOperateButtonClick(_ cell:YCPublishDetailViewCell?)
}
