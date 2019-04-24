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
    
    let maxClipDuration = TimeInterval(10)
    private(set) var videoUrl: URL!
    private(set) var videoAsset: AVAsset!
    private(set) var videoDuration: TimeInterval! // must > 10s
    private var secondWidth: CGFloat!
    private var snapshotImgs: [Int:UIImage] = [:]
    
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var panelContainer: UIView!
    @IBOutlet weak var snapshotView: UICollectionView! // video thumbnails
    @IBOutlet weak var lPanel: UIView!
    @IBOutlet weak var lMask: UIView!
    @IBOutlet weak var rPanel: UIView!
    @IBOutlet weak var rMask: UIView!
    @IBOutlet weak var uBorder: UIView!
    @IBOutlet weak var dBorder: UIView!
    @IBOutlet weak var indicator: UIView!
    private var videoPlayerLayer: AVPlayerLayer?
    private var doneHandler: ((UIViewController, URL)->())?
    private var cancelledHandler: ((UIViewController)->())?
    
    class func viewController(videoUrl: URL, done:((UIViewController, URL)->())? = nil, cancelled:((UIViewController)->())? = nil) -> YCClipViewController {
        let vc = UIStoryboard(name: "YCClip", bundle: nil).instantiateInitialViewController() as! YCClipViewController
        vc.videoUrl = videoUrl
        vc.videoAsset = AVAsset(url: videoUrl)
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
        
        let player = AVPlayer(playerItem: AVPlayerItem(asset: videoAsset))
        let avideoLayer = AVPlayerLayer(player: player)
        avideoLayer.videoGravity = .resizeAspect
        avideoLayer.frame = videoContainer.bounds
        videoContainer.layer.addSublayer(avideoLayer)
        videoPlayerLayer = avideoLayer
        
        generateSnapshots()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        videoPlayerLayer?.player?.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(videoContainer.bounds)
        videoPlayerLayer?.frame = videoContainer.bounds
    }
    
    private func setupNavigation() {
        navigationController?.setToolbarHidden(false, animated: false)
        navigationController?.toolbar.barStyle = .blackTranslucent
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
        exportVideo(url: videoUrl, range: r) {[weak self] (url) in
            guard let sf = self else {return}
            DispatchQueue.main.async {
                sf.doneHandler?(sf, url)
            }
        }
    }
    
    private func exportVideo(url: URL, range: CMTimeRange, completed:@escaping (URL)->()) {
        // https://stackoverflow.com/questions/31092455/avassetexportsession-export-fails-non-deterministically-with-error-operation-s/31146867
        let asset = AVAsset(url: url)
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
            }

        case .ended, .cancelled, .failed:
            calculateAndPlay()
        }
    }
    
    fileprivate func generateSnapshots() {
        let generator = AVAssetImageGenerator(asset: videoAsset)
        generator.requestedTimeToleranceAfter = .zero
        generator.requestedTimeToleranceBefore = .zero
        let times = (0..<Int(videoDuration)).map{return NSValue(time: CMTime(seconds: Double($0), preferredTimescale: 100))}
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
    
    fileprivate func calculateTimeRange() -> CMTimeRange {
        let minP = lPanel.convert(lPanel.bounds.origin, to: snapshotView)
        let maxP = rPanel.convert(rPanel.bounds.origin, to: snapshotView)
        let location = minP.x + lPanel.bounds.width
        let length = maxP.x - minP.x - lPanel.bounds.width
        let total = snapshotView.contentSize.width
        let loc = Double(location / total)
        let len = Double(length / total)
        let start = CMTime(seconds: videoDuration * loc, preferredTimescale: 100)
        let end = CMTime(seconds: videoDuration * (loc + len), preferredTimescale: 100)
        let range = CMTimeRange(start: start, end: end)
        return range
    }
    
    fileprivate func calculateRange() -> (location: Float, length: Float) {
        let minP = lPanel.convert(lPanel.bounds.origin, to: snapshotView)
        let maxP = rPanel.convert(rPanel.bounds.origin, to: snapshotView)
        let location = minP.x + lPanel.bounds.width
        let length = maxP.x - minP.x - lPanel.bounds.width
        let total = snapshotView.contentSize.width
        return (Float(location / total), Float(length / total))
    }
    
    /// Dragging or scrolling to seek the current video frame.
    ///
    /// - Parameter reverse: If reverse = YES, will seek the end video frame; elsewise seek the start video frame.
    /// - Returns: The selected range of time.
    @discardableResult
    fileprivate func calculateAndSeek(reverse: Bool) -> (start: CMTime, end: CMTime) {
        let r = calculateRange()
        let time = CMTime(seconds: videoDuration * (reverse ?  Double(r.location + r.length) : Double(r.location)), preferredTimescale: 100)
        let start = CMTime(seconds: videoDuration * Double(r.location), preferredTimescale: 100)
        let end = CMTime(seconds: videoDuration * Double(r.location + r.length), preferredTimescale: 100)
        videoPlayerLayer?.player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        return (start, end)
    }
    
    var playerTimeObserver: Any?
    /// Drag or scroll did end and play the selected range of video.
    fileprivate func calculateAndPlay() {
        let times = calculateAndSeek(reverse: false)
        if let observer = playerTimeObserver {videoPlayerLayer?.player?.removeTimeObserver(observer)}
        playerTimeObserver = videoPlayerLayer?.player?.addBoundaryTimeObserver(forTimes: [NSValue(time: times.end)], queue: DispatchQueue.main, using: {[weak self] in
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
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        calculateAndSeek(reverse: false)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        calculateAndPlay()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            calculateAndPlay()
        }
    }
}
