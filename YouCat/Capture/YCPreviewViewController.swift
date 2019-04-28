//
//  YCPreviewViewController.swift
//  CuriosImagePicker
//
//  Created by Emiaostein on 2019/4/3.
//  Copyright © 2019 xueersi. All rights reserved.
//

import UIKit
import AVFoundation

class YCPreviewViewController: UIViewController {
    
    let asset: AVAsset
    
    init(asset: AVAsset) {
        self.asset = asset
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
    
    @objc func doneClick(sender: UIButton) {
        NotificationCenter.default.post(name: YCImagePickerViewControllerShouldExportVideoNotification, object: nil)
    }
    
    @objc func cancelClick(sender: UIButton) {
        NotificationCenter.default.post(name: YCImagePickerViewControllerShouldUpdateVideoNotification, object: nil)
        navigationController?.popToRootViewController(animated: false)
    }
    
    private func setup() {
        view.backgroundColor = .blue
        
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
        
        let cancelContainerView = UIView(frame: CGRect.zero)
        cancelContainerView.backgroundColor = .clear
        cancelContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelContainerView)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                cancelContainerView.widthAnchor.constraint(equalToConstant: 44),
                cancelContainerView.heightAnchor.constraint(equalToConstant: 44),
                cancelContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                cancelContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                ])
        } else {
            // Fallback on earlier versions
        }
        
        let editContainerView = UIView(frame: CGRect.zero)
        editContainerView.backgroundColor = .clear
        editContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(editContainerView)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                editContainerView.widthAnchor.constraint(equalTo: view.widthAnchor),
                editContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -88),
                editContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                editContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
                ])
        } else {
            // Fallback on earlier versions
        }
        
        let editshadow = UIImageView(image: UIImage(named: "shadow"))
        editshadow.contentMode = .scaleToFill
        editshadow.translatesAutoresizingMaskIntoConstraints = false
        editContainerView.addSubview(editshadow)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                editshadow.topAnchor.constraint(equalTo: editContainerView.topAnchor),
                editshadow.bottomAnchor.constraint(equalTo: editContainerView.bottomAnchor),
                editshadow.leadingAnchor.constraint(equalTo: editContainerView.leadingAnchor),
                editshadow.trailingAnchor.constraint(equalTo: editContainerView.trailingAnchor)
                ])
        } else {
            // Fallback on earlier versions
        }
        
        let doneButton = UIButton(frame: CGRect.zero)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.backgroundColor = UIColor(red: 19.0/255.0, green: 153.0/255.0, blue: 223.0/255.0, alpha: 1)
        doneButton.layer.cornerRadius = 12
        doneButton.setAttributedTitle(NSAttributedString(string: "就这样", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white ,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .heavy)]), for: .normal)
        doneButton.addTarget(self, action: #selector(doneClick(sender:)), for: .touchUpInside)
        editContainerView.addSubview(doneButton)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                doneButton.widthAnchor.constraint(equalToConstant: 73),
                doneButton.heightAnchor.constraint(equalToConstant: 54),
                doneButton.centerXAnchor.constraint(equalTo: editContainerView.centerXAnchor),
                doneButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -88 / 2)
                ])
        } else {
            // Fallback on earlier versions
        }
        
        let cancelButton = UIButton(frame: CGRect.zero)
        cancelButton.setImage(UIImage(named: "back"), for: .normal)
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
        
        DispatchQueue.main.async {[weak self] in
            guard let sf = self else {return}
            let asset = sf.asset
            let item = AVPlayerItem(asset: asset)
            let player = AVQueuePlayer(playerItem: item)
            let avideoLayer = AVPlayerLayer(player: player)
            avideoLayer.videoGravity = .resizeAspectFill
            avideoLayer.frame = previewView.bounds
            previewView.layer.addSublayer(avideoLayer)
            player.play()
            
            self?.looper = AVPlayerLooper(player: player, templateItem: item)
        }
    }
    var looper: AVPlayerLooper?

}
