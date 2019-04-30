//
//  YCClipViewController.swift
//  CuriosImagePicker
//
//  Created by Emiaostein on 2019/4/22.
//  Copyright © 2019 xueersi. All rights reserved.
//

import UIKit
import AVFoundation

/// ┌─────────────────────────────┐
/// │ ┌─────────────────────────┐ │
/// │ │                         │ │
/// │ │                         │ │
/// │ │                         │ │
/// │ │                         │ │
/// │ │                         │ │
/// │ │     videoContainer      │ │
/// │ │                         │ │
/// │ │                         │ │
/// │ │                         │ │
/// │ │                         │ │
/// │ │                         │ │
/// │ │                         │ │
/// │ └─────────────────────────┘ │
/// │ ┌───┬─┬────────────┬─┬────┐ │
/// │ │  ┌┼─├────────────┤ │    │ │
/// │ │  ││ ├────────────┤ │  │ │ │
/// │ └──┼┴─┴──────┬─────┴─┴──┼─┘ │
/// │    └─┐       └───┐      │   │
/// └──────┼───────────┼──────┼───┘
///        │           │      │
///      Panel      border   mask

class YCClipViewController: UIViewController {
    
    private var maxClipDuration = TimeInterval(10)
    private(set) var videoAsset: AVAsset!
    private(set) var videoDuration: TimeInterval! // must > 10s
    private var secondWidth: CGFloat!
    private var snapshotImgs: [Int:UIImage] = [:]
    
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var panelContainer: UIView!
    @IBOutlet weak var durationContainer: UIVisualEffectView!
    
    @IBOutlet weak var snapshotView: UICollectionView! // video thumbnails
    @IBOutlet weak var lPanel: UIView!
    @IBOutlet weak var lMask: UIView!
    @IBOutlet weak var rPanel: UIView!
    @IBOutlet weak var rMask: UIView!
    @IBOutlet weak var uBorder: UIView!
    @IBOutlet weak var dBorder: UIView!
    @IBOutlet weak var indicator: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    
    private var videoPlayerLayer: AVPlayerLayer?
    private var doneHandler: ((UIViewController, URL)->())?
    private var cancelledHandler: ((UIViewController)->())?
    
    class func viewController(asset: AVAsset, maxDuration: TimeInterval, done:((UIViewController, URL)->())? = nil, cancelled:((UIViewController)->())? = nil) -> YCClipViewController {
        let vc = UIStoryboard(name: "YCClip", bundle: nil).instantiateInitialViewController() as! YCClipViewController
        vc.videoAsset = asset
        vc.maxClipDuration = maxDuration
        vc.videoDuration = round(vc.videoAsset.duration.seconds)
        vc.doneHandler = done
        vc.cancelledHandler = cancelled
        return vc
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigation()
        snapshotView.contentInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        
        indicator.layer.shadowColor = UIColor.black.cgColor
        indicator.layer.shadowRadius = 4
        
        let player = AVPlayer(playerItem: AVPlayerItem(asset: videoAsset))
        let avideoLayer = AVPlayerLayer(player: player)
        avideoLayer.videoGravity = .resizeAspect
        avideoLayer.frame = videoContainer.bounds
        videoContainer.layer.addSublayer(avideoLayer)
        videoPlayerLayer = avideoLayer
        
        
        DispatchQueue.main.async {[weak self] in
            self?.generateSnapshots()
            self?.calculateAndSeek(reverse: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        videoPlayerLayer?.player?.play()
        calculateAndPlay()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(videoContainer.bounds)
        videoPlayerLayer?.frame = videoContainer.bounds
    }
    
    private func setupNavigation() {
        setToolbarItems([
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancell)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done)),
            ], animated: false)
    }
    
    @objc func cancell() {
        cancelledHandler?(self)
    }
    
    @objc func done() {
        let r = calculateTimeRange()
        exportVideo(asset: videoAsset, range: r.range) {[weak self] (url) in
            guard let sf = self else {return}
            DispatchQueue.main.async {
                sf.doneHandler?(sf, url)
            }
        }
    }
    
    private func exportVideo(asset: AVAsset, range: CMTimeRange, completed:@escaping (URL)->()) {
        // https://stackoverflow.com/questions/31092455/avassetexportsession-export-fails-non-deterministically-with-error-operation-s/31146867
//        let asset = AVAsset(url: url)
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)
        let outUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(UUID().uuidString.components(separatedBy: "-").last!)").appendingPathExtension("mov")
        exporter?.outputURL = outUrl
        exporter?.outputFileType = AVFileType.mov
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.timeRange = range
        exporter?.exportAsynchronously {
            if let e = exporter {
                print("exporter status = \(e.status.rawValue), error = \(e.error.debugDescription), outUrl = \(outUrl)")
                completed(outUrl)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func indicator(hidden: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.indicator.alpha = hidden ? 0 : 1
            }
        } else {
            self.indicator.alpha = hidden ? 0 : 1
        }
    }
    
    var beganPanCenterOffset: CGFloat = 0
    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        guard let v = sender.view else {
            return
        }
        switch sender.state {
        case .possible:
            ()
        case .began:
            videoPlayerLayer?.player?.pause()
            beganPanCenterOffset = v.center.x - sender.location(in: panelContainer).x
            if (v != indicator) {
                indicator(hidden: true, animated: false)
            }
            
        case .changed:
            if v == lPanel {
                let minX = 16 + v.bounds.width / 2
                let maxX = rPanel.frame.minX - secondWidth - v.bounds.width / 2
                let nextX = sender.location(in: panelContainer).x + beganPanCenterOffset
                v.center.x = max(min(nextX, maxX), minX)
                updateUI()
                calculateAndSeek(reverse: false)
            } else if v == rPanel {
                let minX = lPanel.frame.maxX + secondWidth + v.bounds.width / 2
                let maxX = panelContainer.bounds.width - 16 - v.bounds.width / 2
                let nextX = sender.location(in: panelContainer).x + beganPanCenterOffset
                v.center.x = max(min(nextX, maxX), minX)
                updateUI()
                calculateAndSeek(reverse: true)
            } else if v == indicator {
                let minX = lPanel.frame.maxX
                let maxX = rPanel.frame.minX
                let nextX = sender.location(in: panelContainer).x + beganPanCenterOffset
                v.center.x = max(min(nextX, maxX), minX)
//                updateUI()
                calculateAndSeek(reverse: false, resetIndicator: false)
            }

        case .ended, .cancelled, .failed:
            if (v != indicator) {
                indicator(hidden: false, animated: true)
            }
            calculateAndPlay(resetIndicator: false)
        }
    }
    
    fileprivate func generateSnapshots() {
        let generator = AVAssetImageGenerator(asset: videoAsset)
        generator.requestedTimeToleranceAfter = .zero
        generator.requestedTimeToleranceBefore = .zero
        let times = (0..<Int(videoDuration)).map{return NSValue(time: CMTime(seconds: Double($0), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))}
        generator.generateCGImagesAsynchronously(forTimes: times) {[weak self] (requestedTime, image, actualTime, result, error) in
            if let img = image {
                let indx = Int(requestedTime.seconds)
                self?.snapshotImgs[indx] = UIImage(cgImage: img)
                DispatchQueue.main.async {
                    if let indexPaths = self?.snapshotView.indexPathsForVisibleItems, let i = indexPaths.first(where: {$0.item == indx}) {
                        self?.snapshotView.reloadItems(at: [i])
                    }
                }
            }
        }
    }
    
    fileprivate func updateUI() {
        uBorder.frame.size.width = rPanel.frame.minX - lPanel.frame.maxX
        uBorder.frame.origin.x = lPanel.frame.maxX
        dBorder.frame.size.width = rPanel.frame.minX - lPanel.frame.maxX
        dBorder.frame.origin.x = lPanel.frame.maxX
        lMask.frame.size.width = lPanel.frame.minX
        lMask.frame.origin.x = -(lPanel.frame.minX)
        rMask.frame.size.width = panelContainer.bounds.width - rPanel.frame.maxX
        rMask.frame.origin.x = 16
    }
    
    fileprivate func calculateTimeRange() -> (range: CMTimeRange, idc: CMTime) {
        let minP = lPanel.convert(lPanel.bounds.origin, to: snapshotView)
        let maxP = rPanel.convert(rPanel.bounds.origin, to: snapshotView)
        let indP = indicator.convert(indicator.bounds.origin, to: snapshotView)
        let location = minP.x + lPanel.bounds.width
        let length = maxP.x - minP.x - lPanel.bounds.width
        let idcLoc = indP.x + indicator.bounds.width / 2
        let total = snapshotView.contentSize.width
        let loc = Double(location / total)
        let len = Double(length / total)
        let idc = Double(idcLoc / total)
        let start = CMTime(seconds: videoDuration * loc, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let end = CMTime(seconds: videoDuration * (loc + len), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mid = CMTime(seconds: videoDuration * idc, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let range = CMTimeRange(start: start, end: end)
        return (range, mid)
    }
    
    fileprivate func calculateRange() -> (location: Float, length: Float, idc: Float) {
        let minP = lPanel.convert(lPanel.bounds.origin, to: snapshotView)
        let maxP = rPanel.convert(rPanel.bounds.origin, to: snapshotView)
        let indP = indicator.convert(indicator.bounds.origin, to: snapshotView)
        let location = minP.x + lPanel.bounds.width
        let length = maxP.x - minP.x - lPanel.bounds.width
        let idc = indP.x + indicator.bounds.width / 2
        let total = snapshotView.contentSize.width
        return (Float(location / total), Float(length / total), Float(idc / total))
    }
    
    /// Dragging or scrolling to seek the current video frame.
    ///
    /// - Parameter reverse: If reverse = YES, will seek the end video frame; elsewise seek the start video frame.
    /// - Returns: The selected range of time.
    @discardableResult
    fileprivate func calculateAndSeek(reverse: Bool, resetIndicator: Bool = true) -> (start: CMTime, end: CMTime, idc: CMTime) {
        if (resetIndicator) {
            indicator.center.x = lPanel.frame.maxX
        }
        let r = calculateRange()
        let start = CMTime(seconds: videoDuration * Double(r.location), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let end = CMTime(seconds: videoDuration * Double(r.location + r.length), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let idc = CMTime(seconds: videoDuration * Double(r.idc), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        videoPlayerLayer?.player?.seek(to: reverse ? end : idc, toleranceBefore: .zero, toleranceAfter: .zero)
        durationLabel.text = "\(Int(round(end.seconds - start.seconds))) 秒"
        return (start, end, idc)
    }
    
    var playerTimeObserver: Any?
    var indictorTimeObserver: Any?
    /// Drag or scroll did end and play the selected range of video.
    fileprivate func calculateAndPlay(resetIndicator: Bool = true) {
        let times = calculateAndSeek(reverse: false, resetIndicator: resetIndicator)
        
        if let observer = indictorTimeObserver {videoPlayerLayer?.player?.removeTimeObserver(observer)}
        indictorTimeObserver = videoPlayerLayer?.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main, using: { (time) in
            self.indicator.center.x += self.secondWidth / 100;
        })
        
        if let observer = playerTimeObserver {videoPlayerLayer?.player?.removeTimeObserver(observer)}
        playerTimeObserver = videoPlayerLayer?.player?.addBoundaryTimeObserver(forTimes: [NSValue(time: times.end)], queue: DispatchQueue.main, using: {[weak self] in
            if let idcObserver = self?.indictorTimeObserver {self?.videoPlayerLayer?.player?.removeTimeObserver(idcObserver); self?.indictorTimeObserver = nil}
            self?.calculateAndPlay()
        })

        videoPlayerLayer?.player?.play()
    }
}

extension YCClipViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(videoDuration)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SnapshotCell", for: indexPath)
        
        if let imgView = cell.viewWithTag(100) as? UIImageView, let img = snapshotImgs[indexPath.item] {
            imgView.image = img
        }
        
        return cell
    }
}

extension YCClipViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        secondWidth = secondWidth == nil ? (collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right) / CGFloat(maxClipDuration) : secondWidth
        return CGSize(width: secondWidth, height: collectionView.bounds.height)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        videoPlayerLayer?.player?.pause()
        indicator(hidden: true, animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        calculateAndSeek(reverse: false)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        indicator(hidden: false, animated: true)
        calculateAndPlay()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if (!decelerate) {
            indicator(hidden: false, animated: true)
            calculateAndPlay()
        }
    }
}
