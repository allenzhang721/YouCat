//
//  CuriosImagePickerViewController.swift
//  CuriosImagePicker
//
//  Created by Emiaostein on 2019/3/31.
//  Copyright © 2019 xueersi. All rights reserved.
//

import UIKit
import AVFoundation

let YCImagePickerViewControllerShouldUpdateVideoNotification = Notification.Name("YCImagePickerViewControllerShouldUpdateVideoNotification")
let YCImagePickerViewControllerShouldExportVideoNotification = Notification.Name("YCImagePickerViewControllerShouldExportVideoNotification")
let YCImagePickerViewControllerShouldCancelNotification = Notification.Name("YCImagePickerViewControllerShouldCancelNotification")

protocol YCImagePickerViewControllerDelegate: class {
    func imagePickerController(_ picker: YCImagePickerViewController, didFinishPickingMediaWithInfo infos: [PickerInfo])
    func imagePickerControllerDidCancel(_ picker: YCImagePickerViewController)
}

enum YCMediaType {
    case video(maxDuration: TimeInterval, dynamicDuration: TimeInterval, snapshotSize: CGSize)
}

class DynamicFrame {
    let duration: TimeInterval
    let image: UIImage
    init(duration: TimeInterval, image: UIImage) {
        self.duration = duration
        self.image = image
    }
}

enum PickerInfo {
    case filePath(String)
    case dynamicFilePath(String)
    case snapShot(UIImage)
    case dynamicFrames([DynamicFrame])
    case mediaSize(CGSize)
    case mediaType(YCMediaType)
}

class YCImagePickerViewController: UINavigationController {
    
    public weak var pickerDelegate: YCImagePickerViewControllerDelegate?
    public var mediaType: YCMediaType = .video(maxDuration: 20, dynamicDuration: 2, snapshotSize: CGSize.zero)
//    private(set) var videoUrl: URL?
    private(set) var videoAsset: AVAsset?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    func setup() {
        NotificationCenter.default.addObserver(forName: YCImagePickerViewControllerShouldUpdateVideoNotification, object: nil, queue: .main) {[weak self] (noti) in
            if let asset = noti.object as? AVAsset {
//                print("video url = ", url)
                self?.videoAsset = asset
            } else {
                self?.videoAsset = nil
            }
        }
        
        NotificationCenter.default.addObserver(forName: YCImagePickerViewControllerShouldExportVideoNotification, object: nil, queue: .main) {[weak self] (noti) in
            guard let sf = self else {return}
            sf.export()
        }
        
        NotificationCenter.default.addObserver(forName: YCImagePickerViewControllerShouldCancelNotification, object: nil, queue: .main) {[weak self] (noti) in
            guard let sf = self else {return}
            sf.pickerDelegate?.imagePickerControllerDidCancel(sf)
        }
        
        setNavigationBarHidden(true, animated: false)
        let capture = YCCaptureViewController(mediaType: mediaType)
        self.setViewControllers([capture], animated: false)
    }
    
    private func export() {
        guard let asset = videoAsset else {return}
        let viewSize = view.bounds.size
        let queue = DispatchQueue(label: "com.export.queue")
        queue.async { [weak self] in
            guard let sf = self else {return}
            var videoUrl: URL?
            var dynamicUrl: URL?
            var dynamicFrames: [DynamicFrame]?
            var snapshot: UIImage?
            let group = DispatchGroup()
            switch sf.mediaType {
            case .video(_, let dynamicDuration, let snapshotSize):
                group.enter()
                sf.exportDynamicVideo(asset: asset,screenSize: viewSize, dynamicDuration: dynamicDuration) { (url) in
                    print("dynamic video url = \(url)")
                    dynamicUrl = url
                    group.leave()
                }
                
                group.enter()
                sf.exportVideo(asset: asset, screenSize: viewSize) { (url) in
                    print("exported video url = \(url)")
                    videoUrl = url
                    group.leave()
                }
                
                group.enter()
                sf.exportDynamicImages(asset: asset, dynamicDuration: dynamicDuration, snapshotSize: snapshotSize) { (frames) in
//                    print("exported video frames = \(url)")
                    dynamicFrames = frames
                    snapshot = frames.first?.image
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                
                var info: [PickerInfo] = []
                if let v = videoUrl {
                    info.append(.filePath(v.path))
                }
                
                if let v = dynamicUrl {
                    info.append(.dynamicFilePath(v.path))
                }
                
                if let d = dynamicFrames {
                    info.append(.dynamicFrames(d))
                }
                
                if let s = snapshot {
                    info.append(.snapShot(s))
                }
                
                sf.pickerDelegate?.imagePickerController(sf, didFinishPickingMediaWithInfo: info)
            }
        }
        
    }
    
    private func exportVideo(asset: AVAsset, screenSize: CGSize, completed:@escaping (URL)->()) {
        // https://stackoverflow.com/questions/31092455/avassetexportsession-export-fails-non-deterministically-with-error-operation-s/31146867
        
        guard let videoTrack = asset.tracks.first(where: { (track) -> Bool in track.mediaType == .video}) else {return}
        let audioTrack = asset.tracks.first(where: { (track) -> Bool in track.mediaType == .audio})
        
        // Must!
        let mixComposition = AVMutableComposition()
        guard let mixVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid)) else {return}
        
        
        do {
            try mixVideoTrack.insertTimeRange(videoTrack.timeRange, of: videoTrack, at: CMTime.zero)
            if let au = audioTrack { // You should olny add
                let mixAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
                try mixAudioTrack?.insertTimeRange(au.timeRange, of: au, at: CMTime.zero)
            }
            
        } catch {
            return
        }
        let n = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
        let naturalSize = CGSize(width: abs(n.width), height: abs(n.height))
        let scale = min(naturalSize.width / screenSize.width, naturalSize.height / screenSize.height)
        let cropSize = CGSize(width: screenSize.width * scale, height: screenSize.height * scale)
        let cropOrigin = CGPoint(x: (naturalSize.width - cropSize.width) / 2, y: (naturalSize.height - cropSize.height) / 2)
        let cropRect = CGRect(x: cropOrigin.x.rounded(), y: cropOrigin.y.rounded(), width: cropSize.width.rounded(), height: cropSize.height.rounded())
        
        let videoCompostion = AVMutableVideoComposition()
        videoCompostion.frameDuration = mixVideoTrack.minFrameDuration
        videoCompostion.renderSize = cropRect.size
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        let cropLayer = AVMutableVideoCompositionLayerInstruction(assetTrack: mixVideoTrack)
//        cropLayer.setTransform(CGAffineTransform(translationX: -cropRect.minX, y: -cropRect.minY), at: CMTime.zero)
        cropLayer.setTransform(videoTrack.preferredTransform.concatenating(CGAffineTransform(translationX: -cropRect.minX, y: -cropRect.minY)), at: CMTime.zero)
        
        instruction.layerInstructions = [cropLayer]
        videoCompostion.instructions = [instruction]
        
        let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
        let outUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(UUID().uuidString.components(separatedBy: "-").last!)").appendingPathExtension("mov")
        exporter?.outputURL = outUrl
        exporter?.outputFileType = AVFileType.mov
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = videoCompostion
        exporter?.exportAsynchronously {
            if let e = exporter {
                print("exporter status = \(e.status.rawValue), error = \(e.error.debugDescription), outUrl = \(outUrl)")
                completed(outUrl)
            }
        }
    }
    
    private func exportDynamicImages(asset: AVAsset, dynamicDuration: TimeInterval, snapshotSize: CGSize, completed:@escaping ([DynamicFrame])->()) {
        let queue = DispatchQueue(label: "com.youcat.dynamicImages")
        queue.async {
            let group = DispatchGroup()
            let dynamicInterval: TimeInterval = 1.0/15.0;
            let frames = Int(dynamicDuration / dynamicInterval);
            let times  = (0..<frames).map{CMTime(seconds: TimeInterval($0) * dynamicInterval, preferredTimescale: 100)}.map{NSValue(time: $0)}
            let generator = AVAssetImageGenerator(asset: asset)
            if !snapshotSize.equalTo(CGSize.zero) {
                generator.maximumSize = snapshotSize
            }
            generator.requestedTimeToleranceAfter = CMTime.zero
            generator.requestedTimeToleranceBefore = CMTime.zero
            generator.appliesPreferredTrackTransform = true
            var dynamicFrames: [DynamicFrame] = []
            let count = times.count
            (0..<count).forEach{_ in group.enter()}
            generator.generateCGImagesAsynchronously(forTimes: times) {(time0, cgimage, time1, result, nil) in
                if let image = cgimage {
                    let uImage = UIImage(cgImage: image)
                    dynamicFrames.append(DynamicFrame(duration: dynamicInterval, image: uImage))
                    group.leave()
                }
            }
            
            group.notify(queue: .main, execute: {
                completed(dynamicFrames)
            })
        }
        
    }
    
    private func exportDynamicVideo(asset: AVAsset, screenSize: CGSize, dynamicDuration: TimeInterval, completed:@escaping (URL)->()) {
        // https://stackoverflow.com/questions/31092455/avassetexportsession-export-fails-non-deterministically-with-error-operation-s/31146867
        guard let videoTrack = asset.tracks.first(where: { (track) -> Bool in track.mediaType == .video}) else {return}
        let audioTrack = asset.tracks.first(where: { (track) -> Bool in track.mediaType == .audio})
        
        // Must!
        let mixComposition = AVMutableComposition()
        guard let mixVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid)) else {return}
        
        
        do {
            try mixVideoTrack.insertTimeRange(videoTrack.timeRange, of: videoTrack, at: CMTime.zero)
            if let au = audioTrack { // You should olny add
                let mixAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
                try mixAudioTrack?.insertTimeRange(au.timeRange, of: au, at: CMTime.zero)
            }
            
        } catch {
            return
        }
        
        let n = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
        let naturalSize = CGSize(width: abs(n.width), height: abs(n.height))
        let scale = min(naturalSize.width / screenSize.width, naturalSize.height / screenSize.height)
        let cropSize = CGSize(width: screenSize.width * scale, height: screenSize.height * scale)
        let cropOrigin = CGPoint(x: (naturalSize.width - cropSize.width) / 2, y: (naturalSize.height - cropSize.height) / 2)
        let cropRect = CGRect(x: cropOrigin.x.rounded(), y: cropOrigin.y.rounded(), width: cropSize.width.rounded(), height: cropSize.height.rounded())
        
        let videoCompostion = AVMutableVideoComposition()
        videoCompostion.frameDuration = mixVideoTrack.minFrameDuration
        videoCompostion.renderSize = cropRect.size
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        
        let cropLayer = AVMutableVideoCompositionLayerInstruction(assetTrack: mixVideoTrack)
        cropLayer.setTransform(videoTrack.preferredTransform.concatenating(CGAffineTransform(translationX: -cropRect.minX, y: -cropRect.minY)), at: CMTime.zero)
        
        instruction.layerInstructions = [cropLayer]
        videoCompostion.instructions = [instruction]
        
        let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
        let outUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(UUID().uuidString.components(separatedBy: "-").last!)").appendingPathExtension("mov")
        exporter?.outputURL = outUrl
        exporter?.timeRange = CMTimeRange(start: CMTime.zero, duration: CMTime(seconds: dynamicDuration, preferredTimescale: 100))
        exporter?.outputFileType = AVFileType.mov
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = videoCompostion
        exporter?.exportAsynchronously {
            if let e = exporter {
                completed(outUrl)
                print("exporter status = \(e.status.rawValue), error = \(e.error.debugDescription), outUrl = \(outUrl)")
            }
        }
    }
}


