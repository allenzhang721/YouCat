//
//  VideoUIView.swift
//  YouCat
//
//  Created by ting on 2019/7/31.
//  Copyright © 2019 Curios. All rights reserved.
//

import Foundation
import UIKit
import AVKit


class YCVideoUIView: UIView {
    
    var loadedBlock: VideoLoadedBlock?
    var progressBlock: VideoProgressBlock?
    var playCompleteBlock: VideoPlayCompleteBlock?
    
    var videoPlayLayer: AVPlayerLayer?
    var videoView: UIView?
    var placeholder: UIImage?
    
    var videoPlayerItem: AVPlayerItem?
    var videoPlayer: AVPlayer? //AVQueuePlayer?
    var resource: YCVideoResource?
    
    var isReadyToPlay: Bool = false
    var autoPlay: Bool = false
    var isloop: Bool = false
    var isMuted: Bool = false
    
    var isPlaying: Bool = false;
    var isPause: Bool = false;
    
    var currentSecond: Double = 0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    func initView() {
        self.videoView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        self.addSubview(self.videoView!)
        self.videoPlayLayer = AVPlayerLayer()
        self.videoPlayLayer!.videoGravity = .resizeAspectFill
        self.videoPlayLayer!.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.videoView!.layer.insertSublayer(self.videoPlayLayer!, at: 0)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.05) {
            self.adjustFrame()
        }
    }
    
    func adjustFrame() {
        if let videoView = self.videoView {
            videoView.frame = self.bounds
        }
        if let videoPlayLayer = self.videoPlayLayer {
            videoPlayLayer.frame = self.bounds
        }
    }
    
    func setVideo(with resource: YCVideoResource?,
                  placeholder: UIImage? = nil,
                  options: YCVideoOptions? = nil,
                  loadedBlock: VideoLoadedBlock? = nil,
                  playCompleteBlock: VideoPlayCompleteBlock? = nil,
                  progressBlock: VideoProgressBlock? = nil) {
        
        guard let resource = resource else {
            self.placeholder = placeholder
            loadedBlock?(false, nil, nil)
            return
        }
        print("set \(self)")
        if self.videoPlayerItem != nil {
            self.clean()
        }
        self.resource = resource
        let options = options ?? YCVideoEmptyOptions
        if options.check(.keepPlaceholder) {
            self.placeholder = placeholder
        }
        if options.check(.aotuPlay) {
            self.autoPlay = true
        }
        if options.check(.loop) {
            self.isloop = true
        }
        if options.check(.muted) {
            self.isMuted = true
        }
        self.stopVideo()
        self.loadedBlock = loadedBlock
        self.playCompleteBlock = playCompleteBlock
        self.progressBlock = progressBlock
        self.videoPlayerItem = AVPlayerItem(url: resource.videoURL)
        self.isReadyToPlay = false
        self.videoPlayerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        self.videoPlayerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(self.videoDidPlayToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.videoPlayerItem)
        if let player = self.videoPlayer {
            player.replaceCurrentItem(with: self.videoPlayerItem)
        }else {
            self.videoPlayer = AVPlayer(playerItem: self.videoPlayerItem) //AVQueuePlayer(items: [playerItem])
        }
        if self.videoPlayerItem?.status == .readyToPlay {
            self.videoReadyToPlay()
        }
    }
    
    @objc func videoDidPlayToEnd(_ notify: Notification) {
        if let playerItem = notify.object as? AVPlayerItem {
            if let item = self.videoPlayerItem, item == playerItem {
                if !self.isloop {
                    self.isPlaying = false
                    if let playComplete = self.playCompleteBlock {
                        playComplete(nil, self.resource?.videoURL)
                    }
                }else {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                        if let videoPlayer = self.videoPlayer{
                            videoPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                            self.currentSecond = 0
                            videoPlayer.play()
                        }
                    }
                }
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        if keyPath == "loadedTimeRanges"{
            if !self.isReadyToPlay {
                self.isReadyToPlay = true
                if let loadedBlock = self.loadedBlock {
                    loadedBlock(true, nil, self.resource?.videoURL)
                }
            }
        }
        if keyPath == "status"{
            if playerItem.status == .readyToPlay{
                self.videoReadyToPlay()
            }else{
                if let loadedBlock = self.loadedBlock {
                    loadedBlock(false, nil, self.resource?.videoURL)
                }
            }
        }
    }
    
    func videoReadyToPlay(){
        self.adjustFrame()
        if self.autoPlay {
            self.playVideo()
        }
    }
    
    func playVideo() {
        if !self.isPlaying {
            self.isPlaying = true
            if self.isPause {
                if let videoPlayer = self.videoPlayer{
                    videoPlayer.play()
                    if let second = videoPlayer.currentItem?.currentTime().seconds {
                        self.currentSecond = second
                    }
                }
            }else {
                if let videoPlayer = self.videoPlayer, let playLayer = self.videoPlayLayer{
                    if playLayer.player != videoPlayer{
                        playLayer.player = videoPlayer
                    }
                    videoPlayer.isMuted = self.isMuted
                    videoPlayer.play()
                }
            }
        }
    }
    
    
    func pauseVideo() {
        if self.isPlaying {
            if let videoPlayer = self.videoPlayer{
                videoPlayer.pause()
                if let second = videoPlayer.currentItem?.currentTime().seconds {
                    self.currentSecond = second
                }
            }
            self.isPlaying = false
            self.isPause = true
        }
    }
    
    func stopVideo() {
        if self.isPlaying || self.isPause{
            if let videoPlayer = self.videoPlayer{
                videoPlayer.pause()
                videoPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                self.currentSecond = 0
            }
        }
        self.isPlaying = false
        self.isPause = false
    }
    
    func clean() {
        
        if let videoPlayer = self.videoPlayer{
            videoPlayer.pause()
            videoPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
            self.currentSecond = 0
        }
        self.videoPlayer = nil
        
        if let playerItem = self.videoPlayerItem {
            playerItem.cancelPendingSeeks()
            playerItem.asset.cancelLoading()
            playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
            playerItem.removeObserver(self, forKeyPath: "status")
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        }
        self.videoPlayerItem = nil
        
        if let videoPlayLayer = self.videoPlayLayer {
            videoPlayLayer.removeFromSuperlayer()
        }
        if let videoView = self.videoView {
            videoView.removeFromSuperview()
        }
        self.videoPlayLayer = nil
        self.videoView = nil
        self.resource = nil
        
        
        self.isReadyToPlay = false
        self.isloop = false
        self.autoPlay = false
        self.isMuted = false
        self.isPause = false
        self.isPlaying = false
        
        print("uiview clean \(self)")
    }
}


public struct YCVideoResource {
    /// The key used in cache.
    public let cacheKey: String
    
    /// The target image URL.
    public let videoURL: URL
    
    /**
     Create a resource.
     
     - parameter downloadURL: The target image URL.
     - parameter cacheKey:    The cache key. If `nil`, Kingfisher will use the `absoluteString` of `downloadURL` as the key.
     
     - returns: A resource.
     */
    public init(_ videoURL: URL, cacheKey: String? = nil) {
        self.videoURL = videoURL
        self.cacheKey = cacheKey ?? videoURL.absoluteString
    }
}


struct YCVideoOptionItem : OptionSet {
    
    var rawValue: Int8
    
    static let aotuPlay = YCVideoOptionItem(rawValue: 1 << 0)
    
    static let loop = YCVideoOptionItem(rawValue: 2 << 1)
    
    static let keepPlaceholder = YCVideoOptionItem(rawValue: 3 << 2)
    
    static let muted = YCVideoOptionItem(rawValue: 4 << 3)
}

typealias YCVideoOptions = [YCVideoOptionItem]
let YCVideoEmptyOptions = [YCVideoOptionItem]()


extension YCVideoOptions {
    
    func check(_ item: YCVideoOptionItem) -> Bool {
        return self.contains(item)
    }
    
}


typealias VideoProgressBlock = ((_ playTime: Double, _ totolTime: Double, _ videoURL: URL?) -> Void)
typealias VideoPlayCompleteBlock = ((_ error: NSError?, _ videoURL: URL?) -> Void)
typealias VideoLoadedBlock = ((_ readyToPlay: Bool, _ error: NSError?, _ videoURL: URL?) -> Void)

