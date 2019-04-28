//
//  YCCaptureViewController.swift
//  CuriosImagePicker
//
//  Created by Emiaostein on 2019/4/2.
//  Copyright © 2019 xueersi. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class YCCaptureViewController: UIViewController {
    
    private let mediaType: YCMediaType
    private let camera = CameraController()
    
    init(mediaType: YCMediaType) {
        self.mediaType = mediaType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
//        print("long press!")
        switch sender.state {
        case .began:
            captureDidBegan()
        case .ended:
            captureEnded()
        case .possible:
            ()
        case .changed:
            ()
        case .cancelled:
            ()
        case .failed:
            ()
        @unknown default:
            ()
        }
    }
    
    @objc func cancelClick(sender: UIButton) {
        cancelled()
    }
    
    @objc func libraryClick(sender: UIButton) {
        beganLibrary()
    }
    
    @objc func switchCamera(sender: UIButton) {
        do {
            try camera.switchCameras()
        } catch {}
    }
    
    var captureCount = 0
    private func captureDidBegan() {
        print(#function)
        
        ////Oval animation
        let ovalTransformAnim       = CAKeyframeAnimation(keyPath:"transform")
        ovalTransformAnim.values    = [NSValue(caTransform3D: CATransform3DIdentity),
                                       NSValue(caTransform3D: CATransform3DMakeScale(1.5, 1.5, 1))]
        ovalTransformAnim.keyTimes  = [0, 1]
        ovalTransformAnim.duration  = 0.2
        ovalTransformAnim.beginTime = 0
        ovalTransformAnim.timingFunctions = [CAMediaTimingFunction(name: .easeOut)]
        ovalTransformAnim.fillMode = .forwards
        ovalTransformAnim.isRemovedOnCompletion = false
        // 4
        captureShaperLayer?.add(ovalTransformAnim, forKey: "path")
        UIView.animate(withDuration: 0.2) {
            for tag in  [1001, 1002, 1003] {
                self.view.viewWithTag(tag)?.alpha = 0
            }
        }
        
        guard camera.isRecording == false else {return}
        camera.startVideoCapture {[weak self] (url) in
            let asset = AVAsset(url: url)
            self?.previewVideo(asset: asset)
        }
        
        
        switch mediaType {
        case .video(let maxDuration, _, _):
            let count = captureCount
            DispatchQueue.main.asyncAfter(deadline: .now() + maxDuration) {
                guard self.captureCount == count else {return}
                self.captureEnded()
            }
        }
    }
    
    private func captureEnded() {
        guard camera.isRecording == true else {return}
        captureCount += 1
        camera.stopVideoCapture()
    }
    
    private func cancelled() {
        NotificationCenter.default.post(name: YCImagePickerViewControllerShouldCancelNotification, object: nil)
    }
    
    private func beganLibrary() {
        switch mediaType {
        case .video(_, _, _):
//            let imagePicker = UIImagePickerController()
//            imagePicker.sourceType = .photoLibrary
//            imagePicker.mediaTypes = [String(kUTTypeMovie)]
//            imagePicker.videoQuality = .typeHigh
////            imagePicker.videoMaximumDuration = maxDuration
//            imagePicker.delegate = self
//            present(imagePicker, animated: true, completion: nil)
            
            let photos = YCPhotosViewController.viewController {[weak self] (vc, type) in
                switch type {
                case .done(let asset):
                    if (asset.duration.seconds <= 10) {
                        self?.previewVideo(asset: asset)
                    } else {
                        self?.clipVideo(asset: asset)
                        //                    clipVideo(url: videoUrl)
                    }
                    
                case .cancel:
                    ()
                }
                
                self?.dismiss(animated: true, completion: nil)
            }
            
            present(photos, animated: true, completion: nil)
            
        }
    }
    
    private func previewVideo(asset: AVAsset) {
        NotificationCenter.default.post(name: YCImagePickerViewControllerShouldUpdateVideoNotification, object: asset)
        let preview = YCPreviewViewController(asset: asset)
        navigationController?.pushViewController(preview, animated: false)
        
        captureShaperLayer?.removeAllAnimations()
        for tag in  [1001, 1002, 1003] {
            self.view.viewWithTag(tag)?.alpha = 1
        }
    }
    
    private func clipVideo(asset: AVAsset) {
        navigationController?.setToolbarHidden(false, animated: false)
        navigationController?.toolbar.barStyle = .blackTranslucent
        let clip = YCClipViewController.viewController(asset: asset, done: {[weak self] (vc, url) in
            vc.removeFromParent()
            self?.navigationController?.setToolbarHidden(true, animated: false)
            let asset = AVAsset(url: url)
            self?.previewVideo(asset: asset)
        }) {[weak self] (vc) in
            self?.navigationController?.setToolbarHidden(true, animated: false)
            self?.navigationController?.popViewController(animated: true)
        }
        
        navigationController?.pushViewController(clip, animated: true)
    }
    
    var captureShaperLayer: CAShapeLayer?
    private func setup() {
        view.backgroundColor = .white
        
        // Preview container view, using to put avplayer Layer
        let previewView = UIView(frame: CGRect.zero)
        previewView.backgroundColor = .lightGray
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                previewView.topAnchor.constraint(equalTo: view.topAnchor),
                previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                ])
        } else {
            // Fallback on earlier versions
        }
        
        
        // Capture container view, using to put capture button.
        let captureContainerView = UIView(frame: CGRect.zero)
        captureContainerView.backgroundColor = .clear
        captureContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureContainerView)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                captureContainerView.widthAnchor.constraint(equalToConstant: 88),
                captureContainerView.heightAnchor.constraint(equalToConstant: 88),
                captureContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                captureContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
                ])
        } else {
            // Fallback on earlier versions
        }
        
        // Library container view, using to put library button
        let libraryContainerView = UIView(frame: CGRect.zero)
        libraryContainerView.tag = 1001
        libraryContainerView.backgroundColor = .clear
        libraryContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(libraryContainerView)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                libraryContainerView.widthAnchor.constraint(equalToConstant: 44),
                libraryContainerView.heightAnchor.constraint(equalToConstant: 44),
                libraryContainerView.centerYAnchor.constraint(equalTo: captureContainerView.centerYAnchor),
                libraryContainerView.leadingAnchor.constraint(equalTo: captureContainerView.trailingAnchor, constant: 32),
                ])
        } else {
            // Fallback on earlier versions
        }
        
        // Cancel container view, using to put cancel button
        let cancelContainerView = UIView(frame: CGRect.zero)
        cancelContainerView.tag = 1002
        cancelContainerView.backgroundColor = .clear
        cancelContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelContainerView)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                cancelContainerView.widthAnchor.constraint(equalToConstant: 44),
                cancelContainerView.heightAnchor.constraint(equalToConstant: 44),
                cancelContainerView.centerYAnchor.constraint(equalTo: captureContainerView.centerYAnchor),
                cancelContainerView.rightAnchor.constraint(equalTo: captureContainerView.leftAnchor, constant: -32),
                ])
        } else {
            // Fallback on earlier versions
        }
        
        // Flip camera container view, using to put flip camera button
        let switchCameraContainerView = UIView(frame: CGRect.zero)
        switchCameraContainerView.tag = 1003
        switchCameraContainerView.backgroundColor = .clear
        switchCameraContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchCameraContainerView)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                switchCameraContainerView.widthAnchor.constraint(equalToConstant: 44),
                switchCameraContainerView.heightAnchor.constraint(equalToConstant: 44),
                switchCameraContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                switchCameraContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                ])
        } else {
            // Fallback on earlier versions
        }
        
        
        camera.prepare {[weak self] (error) in
            if let error = error {
                print(error)
            }
            try? self?.camera.displayPreview(on: previewView)
        }
        
        let captureBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        captureBlurView.translatesAutoresizingMaskIntoConstraints = false
        captureContainerView.addSubview(captureBlurView)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                captureBlurView.topAnchor.constraint(equalTo: captureContainerView.topAnchor, constant: -22),
                captureBlurView.bottomAnchor.constraint(equalTo: captureContainerView.bottomAnchor, constant: 22),
                captureBlurView.leadingAnchor.constraint(equalTo: captureContainerView.leadingAnchor, constant: -22),
                captureBlurView.trailingAnchor.constraint(equalTo: captureContainerView.trailingAnchor, constant: 22),
                ])
        } else {
            // Fallback on earlier versions
        }
        let oval = CAShapeLayer()
        oval.frame = CGRect(x: 22, y: 22, width: 88, height: 88)
        let ovalPath = UIBezierPath(ovalIn:CGRect(x: 0, y: 0, width: 88, height: 88))
        oval.path = ovalPath.cgPath
        captureBlurView.layer.mask = oval
        captureShaperLayer = oval
        
        
        let captureCircle = UIView(frame: CGRect.zero)
        captureCircle.backgroundColor = .white
        captureCircle.layer.cornerRadius = 35
        captureCircle.translatesAutoresizingMaskIntoConstraints = false
        captureContainerView.addSubview(captureCircle)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                captureCircle.widthAnchor.constraint(equalToConstant: 70),
                captureCircle.heightAnchor.constraint(equalToConstant: 70),
                captureCircle.centerXAnchor.constraint(equalTo: captureContainerView.centerXAnchor),
                captureCircle.centerYAnchor.constraint(equalTo: captureContainerView.centerYAnchor)
                ])
        } else {
            // Fallback on earlier versions
        }
        
        
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        captureContainerView.addGestureRecognizer(longPress)
        
        
        let cancelButton = UIButton(frame: CGRect.zero)
        cancelButton.setImage(UIImage(named: "arrow-down"), for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.backgroundColor = .clear
        cancelButton.addTarget(self, action: #selector(cancelClick(sender:)), for: .touchUpInside)
        cancelContainerView.addSubview(cancelButton)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                cancelButton.topAnchor.constraint(equalTo: cancelContainerView.topAnchor),
                cancelButton.bottomAnchor.constraint(equalTo: cancelContainerView.bottomAnchor),
                cancelButton.leadingAnchor.constraint(equalTo: cancelContainerView.leadingAnchor),
                cancelButton.trailingAnchor.constraint(equalTo: cancelContainerView.trailingAnchor),
                ])
        } else {
            // Fallback on earlier versions
        }
        
        let libraryButton = UIButton(frame: CGRect.zero)
        libraryButton.setImage(UIImage(named: "library"), for: .normal)
        libraryButton.translatesAutoresizingMaskIntoConstraints = false
        libraryButton.backgroundColor = .clear
        libraryButton.addTarget(self, action: #selector(libraryClick(sender:)), for: .touchUpInside)
        libraryContainerView.addSubview(libraryButton)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                libraryButton.topAnchor.constraint(equalTo: libraryContainerView.topAnchor),
                libraryButton.bottomAnchor.constraint(equalTo: libraryContainerView.bottomAnchor),
                libraryButton.leadingAnchor.constraint(equalTo: libraryContainerView.leadingAnchor),
                libraryButton.trailingAnchor.constraint(equalTo: libraryContainerView.trailingAnchor),
                ])
        } else {
            // Fallback on earlier versions
        }
        
        let switchCameraButton = UIButton(frame: CGRect.zero)
        switchCameraButton.setImage(UIImage(named: "camera-flip"), for: .normal)
        switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
        switchCameraButton.backgroundColor = .clear
        switchCameraButton.addTarget(self, action: #selector(switchCamera(sender:)), for: .touchUpInside)
        switchCameraContainerView.addSubview(switchCameraButton)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                switchCameraButton.topAnchor.constraint(equalTo: switchCameraContainerView.topAnchor),
                switchCameraButton.bottomAnchor.constraint(equalTo: switchCameraContainerView.bottomAnchor),
                switchCameraButton.leadingAnchor.constraint(equalTo: switchCameraContainerView.leadingAnchor),
                switchCameraButton.trailingAnchor.constraint(equalTo: switchCameraContainerView.trailingAnchor),
                ])
        } else {
            // Fallback on earlier versions
        }
    }
}

//extension YCCaptureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        switch mediaType {
//        case .video:
//            // file:///private/var/mobile/Containers/Data/Application/8FECFE12-2129-4A6A-B00A-13C3C482A331/tmp/50CB4711-ACAE-4B47-B465-2E921D76A134.MOV
//            if let videoUrl = info[.mediaURL] as? URL {
//                let asset = AVAsset(url: videoUrl)
//                if (asset.duration.seconds <= 10) {
//                    previewVideo(url: videoUrl)
//                } else {
////                    clipVideo(url: videoUrl)
//                }
//            }
//        }
//        dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//}
