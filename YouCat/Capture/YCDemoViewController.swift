//
//  YCDemoViewController.swift
//  YouCat
//
//  Created by Emiaostein on 2019/4/5.
//  Copyright © 2019 Curios. All rights reserved.
//

import UIKit
import AVFoundation

class YCDemoViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var dynamicVideoView: UIView!
    @IBOutlet weak var snapshotView: UIImageView!
    var videoLayer: AVPlayerLayer?
    var dynamicVideoLayer: AVPlayerLayer?
    var videoLooper: AVPlayerLooper?
    var dynamicVideoLooper: AVPlayerLooper?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    func setup() {
        let avideoLayer = AVPlayerLayer()
        avideoLayer.videoGravity = .resizeAspect
        avideoLayer.frame = videoView.bounds
        videoView.layer.addSublayer(avideoLayer)
        videoLayer = avideoLayer
        
        let bvideoLayer = AVPlayerLayer()
        bvideoLayer.videoGravity = .resizeAspect
        bvideoLayer.frame = dynamicVideoView.bounds
        dynamicVideoView.layer.addSublayer(bvideoLayer)
        dynamicVideoLayer = bvideoLayer
        
        
    }
    
    @IBAction func imagePickerClick(_ sender: Any) {
        let picker = YCImagePickerViewController()
//        picker.mediaType = .video(maxDuration: 10, dynamicDuration: 3, snapshotSize: CGSize.zero)
        picker.pickerDelegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension YCDemoViewController: YCImagePickerViewControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: YCImagePickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: YCImagePickerViewController, didFinishPickingMediaWithInfo infos: [PickerInfo]) {
        
        for info in infos {
            switch info {
            case .filePath(let filePath):
                let asset = AVAsset(url: URL(fileURLWithPath: filePath))
                let item = AVPlayerItem(asset: asset)
                let queuePlayer = AVQueuePlayer(playerItem: item)
                let looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
                videoLayer?.player = queuePlayer
                queuePlayer.play()
                videoLooper = looper
                
            case .snapShot(_):
                ()
            case .dynamicFrames(let frames):
                imageView.animationImages = frames.map{$0.image}
                switch picker.mediaType {
                    case .video(_, let dynamicDuration, _):
                        imageView.animationDuration = dynamicDuration
                }
                imageView.startAnimating()
            case .mediaSize(_):
                ()
            case .mediaType(_):
                ()
            case .dynamicFilePath(let filePath):
                let asset = AVAsset(url: URL(fileURLWithPath: filePath))
                let item = AVPlayerItem(asset: asset)
                let queuePlayer = AVQueuePlayer(playerItem: item)
                let looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
                dynamicVideoLayer?.player = queuePlayer
                queuePlayer.play()
                dynamicVideoLooper = looper
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}
