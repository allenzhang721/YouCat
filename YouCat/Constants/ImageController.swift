//
//  ImageController.swift
//  YouCat
//
//  Created by ting on 2018/9/26.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
import SnapKit


protocol YCImageProtocol{
    func cropImageCircle(_ imageView:UIView, _ radis:CGFloat)
    func cropImageRound(_ imageView:UIView, _ radis:CGFloat)
    func addShadow(_ imageView:UIView,  _ radis:CGFloat, _ height: CGFloat)
}

extension YCImageProtocol{
    
    func cropImageCircle(_ imageView:UIView, _ radis:CGFloat = 0){
        var cornerRadius = radis
        if cornerRadius == 0 {
            cornerRadius = imageView.frame.width;
        }
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = cornerRadius
        imageView.layer.masksToBounds = true
    }
    
    func cropImageRound(_ imageView:UIView, _ radis:CGFloat = 4){
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = radis
        imageView.clipsToBounds = true
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: imageView.bounds, cornerRadius: radis).cgPath
        imageView.layer.mask = shapeLayer
    }
    
    func addShadow(_ imageView:UIView, _ radis:CGFloat = 8.0, _ height: CGFloat = 2){
        imageView.layer.shadowOffset = CGSize(width: 0, height: height)
        imageView.layer.shadowColor = YCStyleColor.black.cgColor
        imageView.layer.shadowOpacity = 0.1
        imageView.layer.shadowRadius = radis
    }
}

func compressJPGImage(_ image:UIImage, maxWidth:Float = 1280.00, needScale:Bool = false) -> (UIImage?, Data?){
    let newImage = compressImage(image, maxW: maxWidth, needScale: needScale)
    let newData = UIImageJPEGRepresentation(newImage, 0.5)
    return (newImage, newData)
}

func compressPNGImage(_ image:UIImage, maxWidth:Float = 1280.00, needScale:Bool = false) -> (UIImage?, Data?){
    let newImage = compressImage(image, maxW: maxWidth, needScale: needScale)
    let newData = UIImagePNGRepresentation(newImage)
    return (newImage, newData)
}

func compressMaxImage(_ image: UIImage, maxW:Float = 1280.00, maxH:Float = 960.00) -> UIImage{
    let maxWidth = CGFloat(maxW)
    let maxHeight = CGFloat(maxH)
    let imageSize = image.size
    if imageSize.width > maxWidth || imageSize.height > maxHeight {
        let imageRate = imageSize.width / imageSize.height
        var rate:CGFloat
        if imageRate > 1 {
            rate = maxWidth / imageSize.width
        }else {
            rate = maxHeight / imageSize.height
        }
        let newSize = CGSize(width: rate*image.size.width, height: rate*image.size.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height), blendMode: .normal, alpha: 1.0)
        let newimage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newimage
    }else {
         return image
    }
}

func compressIconImage(_ image:UIImage, maxW:Float = 1280.00) -> UIImage{
    let maxWidth = CGFloat(maxW)
    let maxHeight = CGFloat(maxW)
    let imageSize = image.size
    let imageRate = imageSize.width / imageSize.height
    let maxRate = maxWidth / maxHeight
    var rate:CGFloat
    if maxRate > imageRate{
        rate = maxWidth / imageSize.width
    }else {
        rate = maxHeight / imageSize.height
    }
    let newSize = CGSize(width: rate*image.size.width, height: rate*image.size.height)
    let imgSize = CGSize(width: maxWidth, height: maxHeight)
    UIGraphicsBeginImageContextWithOptions(imgSize, false, 1)
    image.draw(in: CGRect(x: (imgSize.width - newSize.width)/2, y: (imgSize.height - newSize.height)/2, width: newSize.width, height: newSize.height), blendMode: .normal, alpha: 1.0)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
}

func compressImage(_ image:UIImage, maxW:Float = 1280.00, needScale:Bool = false) -> UIImage{
    let maxWidth = CGFloat(maxW)
    let maxHeight = CGFloat(maxW)
    let imageSize = image.size
    let imageScale = image.scale
    var imageW = imageSize.width
    var imageH = imageSize.height
    if needScale{
        imageW = imageW*imageScale
        imageH = imageH*imageScale
    }
    
    var rate:CGFloat = 1
    let imageRate = imageW / imageH
    let maxRate = maxWidth / maxHeight
    if imageW > maxWidth*6 || imageH > maxHeight*6{
        if maxRate > imageRate{
            rate = maxHeight*6 / imageH
        }else {
            rate = maxWidth*6 / imageW
        }
    }else {
        if maxRate > imageRate{
            rate = maxWidth / imageW
        }else {
            rate = maxHeight / imageH
        }
    }
    var newImage:UIImage!
    if rate < 1{
        let newSize = CGSize.init(width: rate*imageW, height: rate*imageH)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height), blendMode: .normal, alpha: 1.0)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }else {
        newImage = image
    }
    return newImage
}

