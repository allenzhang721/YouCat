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
    
    func loadMedia() {
        
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

class YCImageView: YCBaseView {
    
    var imageModel: YCImageModel?;
    
    var img: UIImageView?
    var imgScrollView: UIScrollView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        let bounds = self.frame
        if let imgModel = self.imageModel, self.img == nil {
            let imgW = imgModel.imageWidth
            let imgH = imgModel.imageHeight
            var imageH = CGFloat(imgH / imgW) * bounds.width
            let viewH = bounds.height
            var imgTop:CGFloat = 0
            var isAdd = false
            if imageH > (viewH - YCScreen.safeArea.top) {
                if imageH < viewH {
                    imgTop = YCScreen.safeArea.top
                    imageH = (viewH - YCScreen.safeArea.top)
                    isAdd = true
                }else {
                    self.imgScrollView = UIScrollView()
                    self.addSubview(self.imgScrollView!)
                    self.imgScrollView?.snp.makeConstraints({ (make) in
                        make.left.equalTo(0)
                        make.top.equalTo(0)
                        make.width.equalTo(self)
                        make.height.equalTo(self)
                    })
                    self.imgScrollView?.contentSize = CGSize(width: bounds.width, height: imageH)
                    let imgRect = CGRect(x: 0, y: 0, width: bounds.width, height: imageH)
                    self.img = UIImageView(frame: imgRect)
                    self.imgScrollView?.addSubview(self.img!)
                    self.img!.contentMode = .scaleAspectFill
                    self.img!.layer.masksToBounds = true
                }
            }else {
                imgTop = (viewH - imageH)/2
                isAdd = true
            }
            if isAdd {
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
//        let bound = YCScreen.bounds
        if let image = self.imageModel {
            self.initSnapView()
            var imgPath = ""
            if snapShot {
//                let imageW = Int(bound.width)
                imgPath = image.imagePath + "?imageView2/2/w/1280"
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
            let snapPath = imageModel.imagePath + "?imageView2/2/w/1280"
            if let img = self.img, let url = URL(string: snapPath){
                img.kf.setImage(with: ImageResource(downloadURL: url), placeholder: self.defaultImg(), options: nil, progressBlock: nil, completionHandler: nil)
            }
        }
    }
    
    override func loadMedia() {
        super.loadMedia()
        if let imageModel = self.imageModel, !self.isLoading, !self.isloadComplete {
            let imgPath = imageModel.imagePath
            if let img = self.img, let url = URL(string: imgPath) {
                self.isLoading = true
                var loadingView: UIActivityIndicatorView?
                loadingView = UIActivityIndicatorView(style: .whiteLarge)
                self.addSubview(loadingView!)
                loadingView!.snp.makeConstraints({ (make) in
                    make.center.equalTo(self).offset(0)
                })
                loadingView!.startAnimating()
                img.kf.setImage(with: ImageResource(downloadURL: url), placeholder: nil, options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: { (image, error, type, url) in
                    if loadingView != nil {
                        loadingView!.stopAnimating()
                        loadingView!.removeFromSuperview()
                    }
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
            let viewH = bounds.height
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
            self.img?.runLoopMode = RunLoop.Mode.common
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
    
    override func loadMedia() {
        super.loadMedia()
        if let imageModel = self.imageModel, imageModel.imageType == "gif", !self.isLoading, !self.isloadComplete{
            let imgPath = imageModel.imagePath
            if let _ = self.img, let url = URL(string: imgPath) {
                self.isLoading = true
                var loadingView: UIActivityIndicatorView?
                loadingView = UIActivityIndicatorView(style: .whiteLarge)
                self.addSubview(loadingView!)
                loadingView!.snp.makeConstraints({ (make) in
                    make.center.equalTo(self).offset(0)
                })
                loadingView!.startAnimating()
                self.img!.kf.setImage(with: ImageResource(downloadURL: url), placeholder: nil, options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: { (image, error, type, url) in
                    if loadingView != nil {
                        loadingView!.stopAnimating()
                        loadingView!.removeFromSuperview()
                    }
                    
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
            img.thumbWidth = CGFloat(width);
            img.thumbHeight = CGFloat(height);
            if let frames = img.animationFrames, let imgModel = self.imageModel{
                let queue = DispatchQueue(label: "mediaData")
                queue.async {
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
    var videoPlayItem: AVPlayerItem?
    var videoPlayer: AVPlayer?
    var videoPlayLayer: AVPlayerLayer?
    var loadingView: UIActivityIndicatorView?

    var readyPlay = false
    
    var isSnap = false
    
    var currentSecond: Double = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    deinit {
        if let playerItem = self.videoPlayItem {
            playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
            playerItem.removeObserver(self, forKeyPath: "status")
        }
        self.videoPlayItem = nil
    }
    
    func initSnapView(){
        self.isSnap = true
        if self.cover == nil {
            self.videoView = UIView()
            self.addSubview(self.videoView!)
            self.videoView?.snp.makeConstraints { (make) in
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
                make.center.equalTo(self.cover!).offset(0)
                make.width.equalTo(44)
                make.height.equalTo(44)
            }
            self.playButton?.image = UIImage(named: "play_button_black")
            
            self.loadingView = UIActivityIndicatorView()
            self.loadingView = UIActivityIndicatorView(style: .whiteLarge)
            self.addSubview(self.loadingView!)
            if let cover = self.cover {
                self.loadingView?.snp.makeConstraints { (make) in
                    make.center.equalTo(cover).offset(0)
                }
            }else {
                self.loadingView?.snp.makeConstraints { (make) in
                    make.center.equalTo(self).offset(0)
                }
            }
            self.loadingView?.hidesWhenStopped = true
        }
    }
    
    func initView() {
        self.isSnap = false
        let bounds = self.frame
        if let videoModel = self.videoModel, self.videoView == nil {
            let vW = videoModel.videoWidth
            let vH = videoModel.videoHeight
            var videoH = CGFloat(vH / vW) * bounds.width
            let viewH = bounds.height
            var videoTop:CGFloat = 0
            if videoH > viewH {
                videoTop = 0
                videoH = viewH
            }else {
                if videoH > (viewH - YCScreen.safeArea.top) {
                    videoTop = (viewH - videoH)/2
                }else {
                    videoTop = YCScreen.safeArea.top + (viewH - YCScreen.safeArea.top - videoH)/2
                }
            }
            self.videoView = UIView()
            self.addSubview(self.videoView!)
            self.videoView?.snp.makeConstraints { (make) in
                make.left.equalTo(0)
                make.top.equalTo(videoTop)
                make.width.equalTo(self)
                make.height.equalTo(videoH)
            }
            self.cover = UIImageView();
            self.addSubview(self.cover!)
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
                make.width.equalTo(44)
                make.height.equalTo(44)
            }
            self.playButton?.image = UIImage(named: "play_button_black")
            
            self.loadingView = UIActivityIndicatorView()
            self.loadingView = UIActivityIndicatorView(style: .whiteLarge)
            self.addSubview(self.loadingView!)
            if let cover = self.cover {
                self.loadingView?.snp.makeConstraints { (make) in
                    make.center.equalTo(cover).offset(0)
                }
            }else {
                self.loadingView?.snp.makeConstraints { (make) in
                    make.center.equalTo(self).offset(0)
                }
            }
            self.loadingView?.hidesWhenStopped = true
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
    
    override func loadMedia() {
        super.loadMedia()
        if let videoModel = self.videoModel{
            let bound = self.frame
            let vW = videoModel.videoWidth
            let vH = videoModel.videoHeight
            var videoH = CGFloat(vH / vW) * bound.width
            let viewH = bounds.height
            if videoH > viewH {
                videoH = viewH
            }
            if let videoURL = URL(string: videoModel.videoPath), self.videoPlayItem == nil, !self.isLoading {
                self.isLoading = true
                self.videoPlayItem = AVPlayerItem(url: videoURL)
                self.videoPlayItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
                self.videoPlayItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
                self.videoPlayer = AVPlayer(playerItem: self.videoPlayItem)
                self.videoPlayLayer = AVPlayerLayer(player: self.videoPlayer)
                self.videoPlayLayer?.videoGravity = .resizeAspectFill
                var layerTop:CGFloat = 0.0
                if self.isSnap {
                    layerTop = (bound.height - videoH)/2
                }
                self.videoPlayLayer?.frame = CGRect(x: 0, y: layerTop, width: bound.width, height: videoH)
                self.videoView?.layer.insertSublayer(self.videoPlayLayer!, at: 0)
                NotificationCenter.default.addObserver(self, selector:  #selector(self.videoDidPlayToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.videoPlayItem)
            }
        }
    }
    
    @objc func videoDidPlayToEnd(_ notify: Notification) {
        self.isPlaying = false
        if let delegate = self.delegate {
            delegate.viewDidPlayToEnd(view: self)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        if keyPath == "loadedTimeRanges"{
            let current = playerItem.currentTime()
            if current.seconds > 0 {
                self.readyPlay = true
                if self.isPlaying{
                    if let cover = self.cover {
                        cover.isHidden = true
                    }
                    if self.currentSecond == current.seconds {
                        if let loading = self.loadingView {
                            loading.startAnimating()
                        }
                    }else {
                        if let loading = self.loadingView {
                            loading.stopAnimating()
                        }
                    }
                    self.currentSecond = current.seconds
                }
            }
        }else if keyPath == "status"{
            if playerItem.status == .readyToPlay{
                self.isloadComplete = true
                self.currentSecond = 0
                if self.isPlaying {
                    self.playHander()
                }
                self.isLoading = false
            }else{
                print("load video error ")
            }
        }
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
        if let loading = self.loadingView {
            loading.removeFromSuperview()
        }
        if let playItem = self.videoPlayItem {
            playItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
            playItem.removeObserver(self, forKeyPath: "status")
        }
        if let player = self.videoPlayer, self.isloadComplete{
            player.pause()
            player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        }
        if let playLayer = self.videoPlayLayer {
            playLayer.removeFromSuperlayer()
        }
        if let videoView = self.videoView {
            videoView.removeFromSuperview()
        }
        self.videoPlayItem = nil
        self.videoPlayer = nil
        self.videoPlayLayer = nil
        
        self.videoView = nil
        self.loadingView = nil
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
            if let videoPlayer = self.videoPlayer{
                if !self.isPause {
                    videoPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                }
                videoPlayer.play()
                if let second = videoPlayer.currentItem?.currentTime().seconds {
                    self.currentSecond = second
                }
            }
            if self.readyPlay {
                if let loading = self.loadingView {
                    loading.stopAnimating()
                }
                if let cover = self.cover {
                    cover.isHidden = true
                }
            }else {
                if let loading = self.loadingView {
                    loading.startAnimating()
                }
                if let cover = self.cover {
                    cover.isHidden = false
                }
            }
        }else {
            if let loading = self.loadingView {
                loading.startAnimating()
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
            if let loading = self.loadingView {
                loading.stopAnimating()
            }
            if let videoPlayer = self.videoPlayer{
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
        if let playButton = self.playButton {
            playButton.isHidden = false
        }
        if self.isloadComplete {
            if let loading = self.loadingView {
                loading.stopAnimating()
            }
            if let videoPlayer = self.videoPlayer{
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
