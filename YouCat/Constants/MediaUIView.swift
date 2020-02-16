//
//  MediaUIView.swift
//  YouCat
//
//  Created by ting on 2018/9/27.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
import Kingfisher
import AVKit
import MobileCoreServices

class YCMediaViewModel {
    var publishID: String!
    var videoPlayer: AVPlayer?
    var videoPlayerItem: AVPlayerItem?
    var videoStatusChange: ((String?, AVPlayerItem) -> Void)?
    var videoPlayComplete: ((AVPlayerItem) -> Void)?
    var unUsed: Bool = true
    
    init(publishID: String){
        self.publishID = publishID
    }
    
    init(publishID: String, videoPlayer: AVPlayer?, videoPlayerItem: AVPlayerItem?, videoStatusChange: ((String?, AVPlayerItem) -> Void)?, videoPlayComplete: ((AVPlayerItem) -> Void)?){
        self.publishID = publishID
        self.videoPlayer = videoPlayer
        self.videoPlayerItem = videoPlayerItem
        self.videoStatusChange = videoStatusChange
        self.videoPlayComplete = videoPlayComplete
    }
}

class YCBaseView: UIView {
    
    var contentIndex = 0
    var isPlaying = false;
    var isPause = false;
    var isloadComplete = false;
    var isLoading = false
    
    var delegate: YCViewDelegate?
    
    let colorMap=[
        1:YCStyleColor.cyan,
        2:YCStyleColor.gayBlue,
        3:YCStyleColor.nattierblue,
        4:YCStyleColor.turquoise,
        5:YCStyleColor.pink,
        6:YCStyleColor.lightPink,
        7:YCStyleColor.lightPurple,
        8:YCStyleColor.grayWhite,
        9:YCStyleColor.whiteYellow,
        0:YCStyleColor.whiteGray
    ]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func defaultImg() -> UIImage {
        let randomNumberTwo:Int = Int(arc4random_uniform(10))
        let color = self.colorMap[randomNumberTwo]
        let place = creatImageWithColor(color: color!)
        return place
    }
    
    func creatImageWithColor(color:UIColor) -> UIImage{
        let rect = CGRect(x:0,y:0,width:1,height:1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func defaultStyle(){
        
    }
    
    func loadMedia(_ mediaModel: YCMediaViewModel?) {
        
    }
    
    func willDisplayView() {
        
    }
    
    func endDisplayView() {
        
    }
    
    func displayView() {
        
    }
    
    func play() {
        
    }
    
    func pause() {
        
    }
    
    func stop() {
        
    }
    
    func clean () {
        self.isloadComplete = false
        self.isPlaying = false
        self.isPause = false
        self.isLoading = false
        self.contentIndex = 0
        self.delegate = nil
    }
    
    func getSnap() -> UIImage? {
        return nil
    }
    
    func getMediaData(_ width:Float = 1280, _ height:Float = 960, completionBlock: @escaping (Data?) -> Void) {
        
    }
}

protocol YCViewDelegate {
    func viewDidPlayToEnd(view: YCBaseView)
}

class YCMediaScrollView :UIScrollView {
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.panGestureRecognizer.delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

extension YCMediaScrollView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gest = gestureRecognizer as? UIPanGestureRecognizer {
            let transP = gest.translation(in: self)
            let frameH = self.frame.height
            let contentSizeH = self.contentSize.height
            let offY = self.contentOffset.y
//            print("gestureRecognizer \(transP)  aa \(frameH) bb \(contentSizeH) cc \(offY)")
            if (offY+frameH) > (contentSizeH - 1 ) {
                if transP.y < 0 {
                    self.isScrollEnabled = false
                    return true
                }else {
                    self.isScrollEnabled = true
                    return false
                }
            }else if offY < 1 {
                if transP.y > 0 {
                    self.isScrollEnabled = false
                    return true
                }else {
                    self.isScrollEnabled = true
                    return false
                }
            }else {
                self.isScrollEnabled = true
                return false
            }
        }
        return false
    }
}

class YCImageView: YCBaseView {
    
    var imageModel: YCImageModel?;
    
    var img: UIImageView?
    var imgScrollView: YCMediaScrollView?
    
    var loading: YCMediaLoadingView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func displayView() {
        self.imgScrollView?.isScrollEnabled = true
    }
    
    override func play() {
        self.imgScrollView?.isScrollEnabled = true
    }
    
    func initSnapView(){
        if self.img == nil {
            self.img = UIImageView();
            self.addSubview(self.img!)
            self.img?.snp.makeConstraints { (make) in
                make.left.equalTo(0)
                make.top.equalTo(0)
                make.width.equalTo(self)
                make.height.equalTo(self)
            }
            self.img?.contentMode = .scaleAspectFill
            self.img?.layer.masksToBounds = true
            self.backgroundColor = YCStyleColor.gray
        }
    }
    
    func initImageView() {
        let bounds = self.bounds
        if let imgModel = self.imageModel, self.img == nil {
            let imgW = imgModel.imageWidth
            let imgH = imgModel.imageHeight
            let imageH = CGFloat(imgH / imgW) * bounds.width
            let viewH = bounds.height - YCScreen.fullScreenArea.bottom
            if imageH > (viewH - YCScreen.safeArea.top) {
                self.imgScrollView = YCMediaScrollView()
                self.addSubview(self.imgScrollView!)
                if #available(iOS 11.0, *) {
                    self.imgScrollView?.snp.makeConstraints({ (make) in
                        make.left.equalTo(0)
                        make.top.equalTo(0)
                        make.width.equalTo(self)
                        make.height.equalTo(viewH)
                    })
                    let contentH = YCScreen.safeArea.top + imageH
                    self.imgScrollView?.contentInsetAdjustmentBehavior = .never
                    self.imgScrollView?.contentSize = CGSize(width: bounds.width, height: contentH)
                    let imgRect = CGRect(x: 0, y: YCScreen.safeArea.top, width: bounds.width, height: imageH)
                    self.img = UIImageView(frame: imgRect)
                } else {
                    self.imgScrollView?.snp.makeConstraints({ (make) in
                        make.left.equalTo(0)
                        make.top.equalTo(YCScreen.safeArea.top)
                        make.width.equalTo(self)
                        make.height.equalTo(viewH-YCScreen.safeArea.top)
                    })
                    self.imgScrollView?.contentSize = CGSize(width: bounds.width, height: imageH)
                    let imgRect = CGRect(x: 0, y: 0, width: bounds.width, height: imageH)
                    self.img = UIImageView(frame: imgRect)
                }
                self.imgScrollView?.addSubview(self.img!)
                self.img!.contentMode = .scaleAspectFill
                self.img!.layer.masksToBounds = true
            }else {
                var imgTop:CGFloat = (viewH - imageH)/2
                if imgTop < YCScreen.safeArea.top {
                    imgTop = YCScreen.safeArea.top
                }
                self.img = UIImageView()
                self.addSubview(self.img!)
                self.img?.snp.makeConstraints({ (make) in
                    make.left.equalTo(0)
                    make.top.equalTo(imgTop)
                    make.width.equalTo(self)
                    make.height.equalTo(imageH)
                })
                self.img?.contentMode = .scaleAspectFill
                self.img?.layer.masksToBounds = true
            }
        }
        self.backgroundColor = YCStyleColor.black
    }
    
    func loadSnapImage(_ imageModel: YCImageModel, snapShot: Bool){
        self.imageModel = imageModel
        if let image = self.imageModel {
            self.initSnapView()
            var imgPath = ""
            if snapShot {
                imgPath = image.imagePath + "?imageView2/2/w/480"
            }else {
                imgPath = image.imagePath
            }
            if let img = self.img, let url = URL(string: imgPath) {
                img.kf.setImage(with: ImageResource(downloadURL: url), placeholder: self.defaultImg(), options: nil, progressBlock: nil, completionHandler: nil)
            }
        }
    }
    
    func loadImage(_ imageModel: YCImageModel){
        self.imageModel = imageModel
//        let bound = YCScreen.bounds
        if let imageModel = self.imageModel {
            self.initImageView()
//            let imageW = Int(bound.width)
            let snapPath = imageModel.imagePath + "?imageView2/2/w/480"
            if let img = self.img, let url = URL(string: snapPath){
                img.kf.setImage(with: ImageResource(downloadURL: url), placeholder: self.defaultImg(), options: nil, progressBlock: nil, completionHandler: nil)
            }
        }
    }
    
    override func loadMedia(_ mediaModel: YCMediaViewModel?) {
        super.loadMedia(mediaModel)
        if let imageModel = self.imageModel, !self.isLoading, !self.isloadComplete {
            let imgPath = imageModel.imagePath
            if let img = self.img, let url = URL(string: imgPath) {
                self.isLoading = true
                let bounds = self.bounds
                let viewH = bounds.height - YCScreen.fullScreenArea.bottom
                self.loading = YCMediaLoadingView(frame: CGRect(x: 0, y: viewH, width: bounds.width, height: 1))
                self.addSubview(self.loading!)
                if let loading = self.loading {
                    loading.startAnimating()
                }
                img.kf.setImage(with: ImageResource(downloadURL: url), placeholder: nil, options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: { (image, error, type, url) in
                    if let loading = self.loading {
                        loading.stopAnimating()
                        loading.removeFromSuperview()
                    }
                    self.loading = nil
                    self.isloadComplete = true
                    self.isLoading = false
                })
            }
        }
    }
    
    override func defaultStyle(){
        if let img = self.img {
            img.image = self.defaultImg()
        }
    }
    
    override func clean () {
        super.clean()
        if let scrollView = self.imgScrollView {
            scrollView.removeFromSuperview()
        }
        if let img = self.img {
            img.removeFromSuperview()
        }
        self.img = nil
        self.imgScrollView = nil
        if let loading = self.loading {
            loading.stopAnimating()
            loading.removeFromSuperview()
        }
        self.loading = nil
    }
    
    override func getSnap() -> UIImage? {
        if let img = self.img, let image = img.image {
            let newImg = compressIconImage(image, maxW: 100)
            return newImg
        }
        return nil
    }
    
    override func getMediaData(_ width:Float = 1280, _ height:Float = 960, completionBlock: @escaping (Data?) -> Void) {
        if let img = self.img, let image = img.image {
            let queue = DispatchQueue(label: "mediaData")
            queue.async {
                let newImage = compressMaxImage(image, maxW: width, maxH: height)
                let imgData = newImage.jpegData(compressionQuality: 0.8)
                DispatchQueue.main.async {
                    completionBlock(imgData)
                }
            }
        }else {
            completionBlock(nil)
        }
    }
}

class YCAnimationView: YCBaseView {
    
    var imageModel: YCImageModel?;
    var img: AnimatedImageView?
    var loading: YCMediaLoadingView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initSnapView(){
        if self.img == nil {
            self.img = AnimatedImageView();
            self.img?.autoPlayAnimatedImage = false
            self.img?.repeatCount = .once
            self.addSubview(self.img!)
            self.img?.snp.makeConstraints { (make) in
                make.left.equalTo(0)
                make.top.equalTo(0)
                make.width.equalTo(self)
                make.height.equalTo(self)
            }
            self.img?.contentMode = .scaleAspectFill
            self.img?.layer.masksToBounds = true
            self.backgroundColor = YCStyleColor.gray
        }
    }
    
    func initImageView() {
        let bounds = self.frame
        if let imgModel = self.imageModel, self.img == nil {
            let imgW = imgModel.imageWidth
            let imgH = imgModel.imageHeight
            var imageH = CGFloat(imgH / imgW) * bounds.width
            let viewH = bounds.height - YCScreen.fullScreenArea.bottom
            var imgTop:CGFloat = 0
            if imageH > viewH {
                imgTop = 0
                imageH = viewH
            }else {
                imgTop = (viewH - imageH)/2
            }
            self.img = AnimatedImageView()
            self.addSubview(self.img!)
            self.img?.snp.makeConstraints({ (make) in
                make.left.equalTo(0)
                make.top.equalTo(imgTop)
                make.width.equalTo(self).offset(0)
                make.height.equalTo(imageH)
            })
            self.img?.autoPlayAnimatedImage = false
            self.img?.runLoopMode = .common
            self.img?.repeatCount = .once
            self.img?.delegate = self
            self.img?.contentMode = .scaleAspectFill
            self.img?.layer.masksToBounds = true
        }
        self.backgroundColor = YCStyleColor.black
    }
    
    func loadSnapImage(_ imageModel: YCImageModel, snapShot: Bool){
        self.imageModel = imageModel
        if let imageModel = self.imageModel, imageModel.imageType == "gif"{
            self.initSnapView()
            var imgPath = ""
            if snapShot {
                imgPath = imageModel.snapShotPath
                let gifIcon = UIImageView();
                self.addSubview(gifIcon)
                gifIcon.snp.makeConstraints { (make) in
                    make.right.equalTo(0)
                    make.bottom.equalTo(0)
                    make.width.equalTo(35)
                    make.height.equalTo(26)
                }
                gifIcon.image = UIImage(named: "gif_icon")
            }else {
                imgPath = imageModel.imagePath
            }
            if let img = self.img, let url = URL(string: imgPath) {
                img.kf.setImage(with: ImageResource(downloadURL: url), placeholder: self.defaultImg(), options: nil, progressBlock: nil, completionHandler: nil)
            }
        }
    }
    
    func loadImage(_ imageModel: YCImageModel){
        self.imageModel = imageModel
        if let imageModel = self.imageModel, imageModel.imageType == "gif"{
            self.initImageView()
            let snapPath = imageModel.snapShotPath
            if let img = self.img, let url = URL(string: snapPath) {
                img.kf.setImage(with: ImageResource(downloadURL: url), placeholder: self.defaultImg(), options: nil, progressBlock: nil, completionHandler: { (image, error, type, url) in
                    
                })
            }
        }
    }
    
    override func loadMedia(_ mediaModel: YCMediaViewModel?) {
        super.loadMedia(mediaModel)
        if let imageModel = self.imageModel, imageModel.imageType == "gif", !self.isLoading, !self.isloadComplete{
            let imgPath = imageModel.imagePath
            if let _ = self.img, let url = URL(string: imgPath) {
                self.isLoading = true
                let bounds = self.bounds
                let viewH = bounds.height - YCScreen.fullScreenArea.bottom
                self.loading = YCMediaLoadingView(frame: CGRect(x: 0, y: viewH, width: bounds.width, height: 1))
                self.addSubview(self.loading!)
                self.loading!.startAnimating()
                self.img!.kf.setImage(with: ImageResource(downloadURL: url), placeholder: nil, options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: { (image, error, type, url) in
                    if let loading = self.loading {
                        loading.stopAnimating()
                        loading.removeFromSuperview()
                    }
                    self.loading = nil
                    
                    self.isloadComplete = true
                    self.isLoading = false
                    if self.isPlaying {
                        self.img!.startAnimating()
                    }
                })
            }
        }
    }
    
    override func play() {
        super.play()
        if let img = self.img, !self.isPlaying {
            if self.isloadComplete {
                img.repeatCount = .infinite
                img.startAnimating()
                img.repeatCount = .once
            }
            self.isPlaying = true
            self.isPause = false
        }
    }
    
    override func pause() {
        super.pause()
        if let img = self.img, self.isPlaying {
            img.stopAnimating()
            self.isPlaying = false
            self.isPause = true
        }
    }
    
    override func stop() {
        super.stop()
        if let img = self.img {
            img.stopAnimating()
            self.isPlaying = false
            self.isPause = false
        }
    }
    
    override func defaultStyle(){
        if let img = self.img {
            img.image = self.defaultImg()
        }
    }
    
    override func clean () {
        super.clean()
        if let img = self.img {
            img.removeFromSuperview()
        }
        self.img = nil
        if let loading = self.loading {
            loading.stopAnimating()
            loading.removeFromSuperview()
        }
        self.loading = nil
    }
    
    override func getSnap() -> UIImage? {
        if let img = self.img, let image = img.image {
            let newImg = compressIconImage(image, maxW: 100)
            return newImg
        }
        return nil
    }
    
    override func getMediaData(_ width:Float = 1280, _ height:Float = 960, completionBlock: @escaping (Data?) -> Void) {
        if let img = self.img, self.isloadComplete{
            img.ycFrameSize = CGSize(width: CGFloat(width), height:  CGFloat(height))
            if let imgModel = self.imageModel{
                let queue = DispatchQueue(label: "mediaData")
                queue.async {
                    let frames = img.ycAllAnimationFrames
                    if frames.count == 0 {
                        DispatchQueue.main.async {
                            completionBlock(nil)
                        }
                    }else {
                        let destination: CGImageDestination
                        let document: [String] = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
                        let documentStr = document[0]
                        let fileManager = FileManager.default
                        let tempDirectory = NSString(string: documentStr).appendingPathComponent("gif")
                        do {
                            try fileManager.createDirectory(atPath: tempDirectory, withIntermediateDirectories: true, attributes: nil)
                        } catch {
                            completionBlock(nil)
                            return
                        }
                        let gifName = imgModel.imageID+".gif"
                        let path = NSString(string: tempDirectory).appendingPathComponent(gifName)
                        let url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, path as CFString, .cfurlposixPathStyle, false)
                        destination = CGImageDestinationCreateWithURL(url!, kUTTypeGIF, frames.count, nil)!
                        
                        let gifProperties = [
                            kCGImagePropertyGIFDictionary as String : [
                                kCGImagePropertyGIFLoopCount as String : 0
                            ]
                        ]
                        for (_, frame) in frames.enumerated() {
                            if let img = frame.image {
                                let delay = frame.duration
                                let frameProperties: [String: Any] = [
                                    kCGImagePropertyGIFDictionary as String : [
                                        kCGImagePropertyGIFDelayTime as String :delay
                                    ]
                                ]
                                CGImageDestinationAddImage(destination, img.cgImage!, frameProperties as CFDictionary)
                            }
                        }
                        CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
                        CGImageDestinationFinalize(destination)
                        
                        let fileUrl = URL(fileURLWithPath: path)
                        let data = try? Data(contentsOf: fileUrl)
                        DispatchQueue.main.async {
                            completionBlock(data)
                        }
                    }
                }
            }
        }else {
            completionBlock(nil)
        }
    }
}

extension YCAnimationView: AnimatedImageViewDelegate{
    func animatedImageViewDidFinishAnimating(_ imageView: AnimatedImageView){
        self.isPlaying = false
        if let delegate = self.delegate {
            delegate.viewDidPlayToEnd(view: self)
        }
    }
}

class YCVideoView: YCBaseView {
    
    var videoModel: YCVideoModel?;
    
    var cover: UIImageView?
    var playButton: UIImageView?
    
    var videoView: UIView?
    var videoViewWidth: CGFloat = 0
    var videoViewHeight: CGFloat = 0
    var mediaModel: YCMediaViewModel?
    var videoPlayLayer: AVPlayerLayer?
    var videoProgressView: UIView?
    var progressToken: Any?
    
    var videoUIView: YCVideoUIView?

    var readyPlay = false
    
    var isSnap = false
    var isDisplayView = false
    
    var currentSecond: Double = 0
    
    var loading: YCMediaLoadingView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initSnapView(){
        self.isSnap = true
        if self.cover == nil {
//            self.videoView = UIView()
//            self.addSubview(self.videoView!)
//            self.videoView?.snp.makeConstraints { (make) in
//                make.left.equalTo(0)
//                make.top.equalTo(0)
//                make.width.equalTo(self)
//                make.height.equalTo(self)
//            }
            self.videoUIView = YCVideoUIView()
            self.addSubview(self.videoUIView!)
            self.videoUIView?.snp.makeConstraints { (make) in
                make.left.equalTo(0)
                make.top.equalTo(0)
                make.width.equalTo(self)
                make.height.equalTo(self)
            }
            
            self.cover = UIImageView();
            self.addSubview(self.cover!)
            self.cover?.snp.makeConstraints { (make) in
                make.left.equalTo(0)
                make.top.equalTo(0)
                make.width.equalTo(self)
                make.height.equalTo(self)
            }
            self.cover?.contentMode = .scaleAspectFill
            self.cover?.layer.masksToBounds = true
            
            self.playButton = UIImageView();
            self.addSubview(playButton!)
            self.playButton!.snp.makeConstraints { (make) in
                make.right.equalTo(-5)
                make.top.equalTo(5)
                make.width.equalTo(20)
                make.height.equalTo(20)
            }
            self.playButton?.image = UIImage(named: "play_button_black")
        }
    }
    
    func initView() {
        self.isSnap = false
        let bounds = self.frame
        let topH = YCScreen.safeArea.top + 44
        let viewH = bounds.height - YCScreen.fullScreenArea.bottom
        let viewW = bounds.width
        if let videoModel = self.videoModel, self.videoView == nil {
            let vW = videoModel.videoWidth
            let vH = videoModel.videoHeight
            self.videoViewWidth = viewW
            self.videoViewHeight = viewH
            var videoTop:CGFloat = 0
            var videoLeft:CGFloat = 0
            if CGFloat(vH/vW) > (viewH-topH)/viewW {
                let vRate = CGFloat(vW / vH)
                let viewRate =  CGFloat(viewW / viewH)
                if vRate > viewRate {
                    self.videoViewWidth = CGFloat(vW / vH) * viewH
                    videoTop = 0
                    videoLeft = (viewW - self.videoViewWidth)/2
                }else {
                    self.videoViewHeight = CGFloat(vH / vW) * viewW
                    videoLeft = 0
                    videoTop = (viewH - self.videoViewHeight)/2
                }
            }else {
                self.videoViewHeight = CGFloat(vH / vW) * viewW
                videoTop = YCScreen.safeArea.top + (viewH - YCScreen.safeArea.top - self.videoViewHeight)/2
                videoLeft = 0
            }
            
            let maskView = UIView()
            self.addSubview(maskView)
            maskView.snp.makeConstraints { (make) in
                make.left.equalTo(0)
                make.top.equalTo(0)
                make.width.equalTo(viewW)
                make.height.equalTo(viewH)
            }
            maskView.clipsToBounds = true
            
            self.videoView = UIView()
            maskView.addSubview(self.videoView!)
            self.videoView?.snp.makeConstraints { (make) in
                make.left.equalTo(videoLeft)
                make.top.equalTo(videoTop)
                make.width.equalTo(self.videoViewWidth)
                make.height.equalTo(self.videoViewHeight)
            }
            self.cover = UIImageView();
            maskView.addSubview(self.cover!)
            self.cover!.snp.makeConstraints { (make) in
                make.left.equalTo(self.videoView!)
                make.top.equalTo(self.videoView!)
                make.width.equalTo(self.videoView!)
                make.height.equalTo(self.videoView!)
            }
            self.cover!.contentMode = .scaleAspectFill
            self.cover!.layer.masksToBounds = true
            
            self.playButton = UIImageView();
            self.addSubview(playButton!)
            self.playButton!.snp.makeConstraints { (make) in
                make.center.equalTo(self.cover!).offset(0)
                make.width.equalTo(64)
                make.height.equalTo(64)
            }
            self.playButton?.image = UIImage(named: "play_button_black")
            self.playButton?.isHidden = true
            
            self.loading = YCMediaLoadingView(frame: CGRect(x: 0, y: viewH, width: viewW, height: 1))
            self.addSubview(self.loading!)
            
            self.videoProgressView = UIView(frame: CGRect(x: 0, y: viewH, width: 0, height: 0.5))
            self.addSubview(self.videoProgressView!)
            self.videoProgressView?.backgroundColor = YCStyleColor.white
            self.videoProgressView?.isHidden = true
        }
    }
    
    override func willDisplayView() {
        if self.isSnap {
            self.isDisplayView = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                if self.isDisplayView, let videoUIView = self.videoUIView{
                    if videoUIView.isReadyToPlay{
                        if videoUIView.isPause {
                            videoUIView.playVideo()
                        }
                    }else if let video = self.videoModel, let dynamic = video.videoDynamic {
                        if let videoURL = URL(string: dynamic.dynamicPath){
                            videoUIView.setVideo(with: YCVideoResource(videoURL), placeholder: nil, options: [.aotuPlay, .loop, .muted], loadedBlock: { (ready, error, url) in
                                if ready, let cover = self.cover {
                                    UIView.animate(withDuration: 0.3, animations: {
                                        cover.alpha = 0
                                    }, completion: { (_) in
                                        cover.isHidden = true
                                        cover.alpha = 1
                                    })
                                }
                            }, playCompleteBlock: nil, progressBlock: nil)
                        }
                    }
                }
                self.isDisplayView = false
            }
        }
    }
    
    override func endDisplayView() {
        if self.isSnap {
            self.isDisplayView = false
            if let videoUIView = self.videoUIView {
                videoUIView.pauseVideo()
            }
        }
    }
    
    func loadSnapVideo(_ videoModel: YCVideoModel){
        self.videoModel = videoModel
        if let video = self.videoModel {
            self.initSnapView()
            if let cover = video.videoCover {
                let imgPath = cover.imagePath
                self.cover!.kf.setImage(with: ImageResource(downloadURL: URL(string: imgPath)!), placeholder: self.defaultImg(), options: nil, progressBlock: { (start, total) in
                }, completionHandler: { (image, error, type, url) in
                })
            }else {
                self.cover!.image = self.defaultImg()
            }
        }
    }
    
    func loadVideo(_ videoModel: YCVideoModel){
        self.videoModel = videoModel
        if let video = self.videoModel {
            self.initView()
            if let cover = video.videoCover, let url = URL(string: cover.imagePath) {
                self.cover!.kf.setImage(with: ImageResource(downloadURL: url), placeholder: self.defaultImg(), options: nil, progressBlock: { (start, total) in
                }, completionHandler: { (image, error, type, url) in
                })
            }else {
                self.cover!.image = self.defaultImg()
            }
        }
    }
    
    override func loadMedia(_ mediaModel: YCMediaViewModel?) {
        super.loadMedia(mediaModel)
        self.mediaModel = mediaModel
        if !self.isLoading, let media = self.mediaModel, let videoPlayer = media.videoPlayer, let videoPlayerItem = media.videoPlayerItem, self.videoPlayLayer == nil {
            self.isLoading = true
            self.videoPlayLayer = AVPlayerLayer(player: videoPlayer)
            self.videoPlayLayer?.videoGravity = .resizeAspectFill
            
            self.videoPlayLayer?.frame = CGRect(x: 0, y: 0, width: self.videoViewWidth, height: self.videoViewHeight)
            self.videoView?.layer.insertSublayer(self.videoPlayLayer!, at: 0)
            self.mediaModel?.videoStatusChange = self.videoStatusChange
            self.mediaModel?.videoPlayComplete = self.videoPlayComplete
            
            if let progress = self.videoProgressView {
                progress.frame.size.width = 0
            }
            let interval = CMTime(seconds: 0.1,
                                  preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            // Add time observer
            self.progressToken = self.mediaModel?.videoPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) {
                    [weak self] time in
                    // update player transport UI
                if let sf = self{
                    if let videoPlayerItem = sf.mediaModel?.videoPlayerItem {
                        let current = videoPlayerItem.currentTime().seconds
                        let duration = videoPlayerItem.duration.seconds
                        if let progress = sf.videoProgressView, !current.isNaN, !duration.isNaN, duration != 0 {
                            var value = CGFloat(current/duration) * YCScreen.bounds.width
                            if !value.isNaN {
                                if value < 0 {
                                    value = 0
                                }
                                progress.frame.size.width = value
                            }
                        }
                    }
                }
            }
            if videoPlayerItem.status == .readyToPlay{
                self.readyPlay = true
                self.videoReadyToPlay()
            }
        }
    }
    
//    @objc func videoDidPlayToEnd(_ notify: Notification) {
//        if let playerItem = notify.object as? AVPlayerItem {
//            self.videoPlayComplete(playerItem)
//        }
//    }
//    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        guard let playerItem = object as? AVPlayerItem else { return }
//        self.videoStatusChange(keyPath, playerItem)
//    }
    
    func videoPlayComplete(_ playerItem: AVPlayerItem) {
        self.isPlaying = false
        if let delegate = self.delegate {
            delegate.viewDidPlayToEnd(view: self)
        }
    }
    
    func videoStatusChange(_ keyPath: String?, _ playerItem: AVPlayerItem) {
        if keyPath == "loadedTimeRanges"{
            let current = playerItem.currentTime()
            if current.seconds > 0 {
                self.readyPlay = true
                if self.isPlaying{
                    if let cover = self.cover {
                        UIView.animate(withDuration: 0.3, animations: {
                            cover.alpha = 0
                        }) { (_) in
                            cover.isHidden = true
                            cover.alpha = 1
                        }
                    }
                    if self.currentSecond == current.seconds {
                        if let loading = self.loading {
                            loading.startAnimating()
                        }
                        if let progress = self.videoProgressView {
                            progress.isHidden = true
                        }
                    }else {
                        if let loading = self.loading {
                            loading.stopAnimating()
                        }
                        if let progress = self.videoProgressView {
                            progress.isHidden = false
                        }
                    }
                    self.currentSecond = current.seconds
                }
            }
        }else if keyPath == "status"{
            if playerItem.status == .readyToPlay{
                self.videoReadyToPlay()
            }else{
                print("load video error ")
            }
        }
    }
    
    func videoReadyToPlay(){
        self.isloadComplete = true
        self.currentSecond = 0
        if self.isPlaying {
            self.playHander()
        }
        self.isLoading = false
    }
    
    override func play() {
        super.play()
        if !self.isPlaying {
            self.playHander()
            self.isPlaying = true
            self.isPause = false
        }
    }
    
    override func pause() {
        super.pause()
        if self.isPlaying {
            self.pauseHander()
            self.isPlaying = false
            self.isPause = true
        }
    }
    
    override func stop() {
        super.stop()
        self.stopHander()
        self.isPlaying = false
        self.isPause = false
    }
    
    override func defaultStyle(){
        if let cover = self.cover {
            cover.image = self.defaultImg()
            cover.isHidden = false
        }
        if let playButton = self.playButton {
            playButton.isHidden = false
        }
    }
    
    override func clean () {
        if let cover = self.cover {
            cover.removeFromSuperview()
        }
        if let playButton = self.playButton {
            playButton.removeFromSuperview()
        }
        if let loading = self.loading {
            loading.stopAnimating()
            loading.removeFromSuperview()
        }
        if let player = self.mediaModel?.videoPlayer, self.isloadComplete{
            player.pause()
            player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
            if let token = self.progressToken, player.rate == 1.0 {
                self.mediaModel?.videoPlayer?.removeTimeObserver(token)
            }
        }
        if let _ = self.mediaModel {
            self.mediaModel?.videoPlayComplete = nil
            self.mediaModel?.videoStatusChange = nil
        }
        
        if let playLayer = self.videoPlayLayer {
            playLayer.removeFromSuperlayer()
        }
        if let videoView = self.videoView {
            videoView.removeFromSuperview()
        }
        if let progress = self.videoProgressView {
            progress.removeFromSuperview()
        }
        if let videoUIView = self.videoUIView {
            videoUIView.clean()
            videoUIView.removeFromSuperview()
        }
        self.progressToken = nil
        self.cover = nil
        self.videoPlayLayer = nil
        self.videoUIView = nil
        self.videoProgressView = nil
        self.mediaModel = nil
        
        self.videoView = nil
        self.loading = nil
        self.cover = nil
        self.playButton = nil
        self.readyPlay = false
        super.clean()
    }
    
    func playHander() {
        if let playButton = self.playButton {
            playButton.isHidden = true
        }
        if self.isloadComplete {
            if let videoPlayer = self.mediaModel?.videoPlayer{
                if !self.isPause {
                    videoPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                }
                videoPlayer.play()
                if let second = videoPlayer.currentItem?.currentTime().seconds {
                    self.currentSecond = second
                }
            }
            if self.readyPlay {
                if let loading = self.loading {
                    loading.stopAnimating()
                }
                if let progress = self.videoProgressView {
                    progress.isHidden = false
                }
                if let cover = self.cover {
                    UIView.animate(withDuration: 0.3, animations: {
                        cover.alpha = 0
                    }) { (_) in
                        cover.isHidden = true
                        cover.alpha = 1
                    }
                }
            }else {
                if let loading = self.loading {
                    loading.startAnimating()
                }
                if let progress = self.videoProgressView {
                    progress.isHidden = true
                }
                if let cover = self.cover {
                    cover.isHidden = false
                }
            }
        }else {
            if let loading = self.loading {
                loading.startAnimating()
            }
            if let progress = self.videoProgressView {
                progress.isHidden = true
            }
            if let cover = self.cover {
                cover.isHidden = false
            }
        }
    }
    
    func pauseHander() {
        if let playButton = self.playButton {
            playButton.isHidden = false
        }
        if self.isloadComplete {
            if let loading = self.loading {
                loading.stopAnimating()
            }
            if let videoPlayer = self.mediaModel?.videoPlayer{
                videoPlayer.pause()
                if let second = videoPlayer.currentItem?.currentTime().seconds {
                    self.currentSecond = second
                }
            }
        }else {
            if let cover = self.cover {
                cover.isHidden = false
            }
        }
    }
    
    func stopHander() {
        print("stopHandler")
        if let playButton = self.playButton {
            playButton.isHidden = true
        }
        if self.isloadComplete {
            if let loading = self.loading {
                loading.stopAnimating()
            }
            if let videoPlayer = self.mediaModel?.videoPlayer{
                videoPlayer.pause()
                videoPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                self.currentSecond = 0
            }
        }else {
            if let cover = self.cover {
                cover.isHidden = false
            }
        }
    }
    
    override func getSnap() -> UIImage? {
        if let cover = self.cover, let img = cover.image{
            let newImg = compressIconImage(img, maxW: 150)
            let playButton = UIImage(named: "play_button_black")
            let newSize = CGSize(width: newImg.size.width, height: newImg.size.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1)
            newImg.draw(at: CGPoint(x: 0, y: 0))
            playButton!.draw(in: CGRect(x: (newSize.width-88)/2, y: (newSize.height-88)/2, width: 88, height: 88))
            // 1.6.获取已经绘制好的
            let imageLong = UIGraphicsGetImageFromCurrentImageContext()
            // 1.7.结束绘制
            UIGraphicsEndImageContext()
            return imageLong
        }
        return nil
    }
    
}



