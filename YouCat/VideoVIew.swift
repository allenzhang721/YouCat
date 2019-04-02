//
//  VideoVIew.swift
//  YouCat
//
//  Created by ting on 2018/11/14.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
import AVKit

class VideoView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    func initView(){
        self.backgroundColor = UIColor.blue
        
        let movieUrl = URL(string: "https://video.youcat.cn/9c03a9fac95611e889d710ddb1b7faba.mp4")!
        
        let playerItem:AVPlayerItem = AVPlayerItem(url: movieUrl)
        
        // 创建 AVPlayer 播放器
        let player:AVPlayer = AVPlayer(playerItem: playerItem)
        
        // 将 AVPlayer 添加到 AVPlayerLayer 上
        let playerLayer:AVPlayerLayer = AVPlayerLayer(player: player)
        
        // 设置播放页面大小
        
        //playerLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        // 设置画面缩放模式
        playerLayer.videoGravity = .resizeAspectFill
        
        // 在视图上添加播放器
        self.layer.addSublayer(playerLayer)
        
        // 开始播放
//        player.play()
    }
    
}
