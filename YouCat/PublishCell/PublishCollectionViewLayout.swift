//
//  PublishCollectionViewLayout.swift
//  YouCat
//
//  Created by ting on 2018/10/24.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit

public let YCCollectionViewWaterfallSectionHeader = "YCCollectionViewWaterfallSectionHeader"
public let YCCollectionViewWaterfallSectionFooter = "YCCollectionViewWaterfallSectionFooter"

@objc public protocol YCCollectionViewWaterfallLayoutDelegate: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
  
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
}

class YCCollectionViewWaterfallLayout: UICollectionViewLayout {
    
    public var columnCount: Int = 2{
        didSet {
            self.invalidateIfNotEqual(oldValue: oldValue as AnyObject, newValue: columnCount as AnyObject)
        }
    }
    
    public var minimumLineSpacing: Float = 10.0 {
        didSet {
            self.invalidateIfNotEqual(oldValue: oldValue as AnyObject, newValue: minimumLineSpacing as AnyObject)
        }
    }
    
    public var minimumInteritemSpacing: Float = 10.0 {
        didSet {
            self.invalidateIfNotEqual(oldValue: oldValue as AnyObject, newValue: minimumInteritemSpacing as AnyObject)
        }
    }
    
    public var headerReferenceSize: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            self.invalidateIfNotEqual(oldValue: oldValue as AnyObject, newValue: headerReferenceSize as AnyObject)
        }
    }
    
    public var footerReferenceSize: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            self.invalidateIfNotEqual(oldValue: oldValue as AnyObject, newValue: footerReferenceSize as AnyObject)
        }
    }
  
    public var sectionInset:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            invalidateIfNotEqual(oldValue: oldValue as AnyObject, newValue: sectionInset as AnyObject)
        }
    }
    
    private weak var delegate: YCCollectionViewWaterfallLayoutDelegate?  {
        get {
            return self.collectionView?.delegate as? YCCollectionViewWaterfallLayoutDelegate
        }
    }
    
    private var columnHeights = [Float]()
    private var sectionItemAttributes = [[UICollectionViewLayoutAttributes]]()
    private var allItemAttributes = [UICollectionViewLayoutAttributes]()
    private var headersAttributes = [Int: UICollectionViewLayoutAttributes]()
    private var footersAttributes = [Int: UICollectionViewLayoutAttributes]()
    private var unionRects = [CGRect]()
    
    override public func prepare() {
        super.prepare()
        
        let numberOfSections = self.collectionView?.numberOfSections
        if numberOfSections == 0 {
            debugPrint("NumberOfSections can't be zero")
            return
        }
        if self.columnCount == 0 {
            debugPrint("Column can't be zero")
            return
        }
        if self.delegate == nil {
            debugPrint("delegate must be YCCollectionViewWaterfallLayoutDelegate")
            return
        }
        
        if self.collectionView == nil {
            debugPrint("collectionView can't be null")
            return
        }
        
        self.columnHeights.removeAll()
        self.sectionItemAttributes.removeAll()
        self.allItemAttributes.removeAll()
        self.headersAttributes.removeAll()
        self.footersAttributes.removeAll()
        self.unionRects.removeAll()
        
        for _ in 0..<self.columnCount{
            self.columnHeights.append(0)
        }
        
        var top: Float = 0
        
        for section in 0..<numberOfSections! {
            var minimumInteritemSpacing: Float
            if let itemSpacing = self.delegate?.collectionView?(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAt: section) {
                minimumInteritemSpacing = Float(itemSpacing)
            }else {
                minimumInteritemSpacing = self.minimumInteritemSpacing
            }
            
            var minimumLineSpacing: Float
            if let itemSpacing = self.delegate?.collectionView?(self.collectionView!, layout: self, minimumLineSpacingForSectionAt: section) {
                minimumLineSpacing = Float(itemSpacing)
            }else {
                minimumLineSpacing = self.minimumLineSpacing
            }

            var sectionInset: UIEdgeInsets
            if let inset = self.delegate?.collectionView?(self.collectionView!, layout: self, insetForSectionAt: section) {
                sectionInset = inset
            }
            else {
                sectionInset = self.sectionInset
            }
            
            let collectionFrame = self.collectionView!.frame
            let contentWidth = Float(collectionFrame.width - sectionInset.left - sectionInset.right)
            let itemWidth = Float((contentWidth - Float(columnCount - 1)*minimumInteritemSpacing)/Float(self.columnCount))
            
            // header
            var headerReferenceSize: CGSize
            if let size = self.delegate?.collectionView?(self.collectionView!, layout: self, referenceSizeForHeaderInSection: section) {
                headerReferenceSize = size
            }else {
                headerReferenceSize = self.headerReferenceSize
            }
            if headerReferenceSize.height > 0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: YCCollectionViewWaterfallSectionHeader, with: IndexPath(item: 0, section: section))
                
                attributes.frame = CGRect(x: 0, y: CGFloat(top), width: headerReferenceSize.width, height: headerReferenceSize.height)
                self.headersAttributes[section] = attributes
                self.allItemAttributes.append(attributes)
                
                top += Float(headerReferenceSize.height)
            }
            
            top += Float(sectionInset.top)
            for idx in 0..<self.columnCount {
                self.columnHeights[idx] = top
            }
            
            //Section items
            let itemCount = self.collectionView!.numberOfItems(inSection: section)
            var itemAttributes = [UICollectionViewLayoutAttributes]()
            
            // Item will be put into shortest column.
            for idx in 0..<itemCount {
                let indexPath = IndexPath(item: idx, section: section)
                let columnIndex = self.shortestColumnIndex()
                let xOffset = Float(sectionInset.left) + (itemWidth + minimumInteritemSpacing)*Float(columnIndex)
                let yOffset = self.columnHeights[columnIndex]
                let itemSize = self.delegate?.collectionView(collectionView: self.collectionView!, layout: self, sizeForItemAtIndexPath: indexPath)
                var itemHeight: Float = 0.0
                if let size = itemSize {
                    itemHeight = Float(size.height) * itemWidth / Float(size.width)
                }
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: CGFloat(xOffset), y: CGFloat(yOffset), width: CGFloat(itemWidth), height: CGFloat(itemHeight))
                itemAttributes.append(attributes)
                self.allItemAttributes.append(attributes)
                columnHeights[columnIndex] = Float(yOffset + itemHeight + minimumLineSpacing)
            }
            self.sectionItemAttributes.append(itemAttributes)
            
            //Section footer
            let columnIndex = self.longestColumnIndex()
            top = self.columnHeights[columnIndex] - minimumLineSpacing + Float(sectionInset.bottom)
            
            var footerReferenceSize: CGSize
            if let size = self.delegate?.collectionView?(self.collectionView!, layout: self, referenceSizeForFooterInSection: section) {
                footerReferenceSize = size
            }else {
                footerReferenceSize = self.footerReferenceSize
            }
            
            if footerReferenceSize.height > 0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: YCCollectionViewWaterfallSectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0, y: CGFloat(top), width: footerReferenceSize.width, height:footerReferenceSize.height)
                footersAttributes[section] = attributes
                allItemAttributes.append(attributes)
                top += Float(footerReferenceSize.height)
            }
            
            for idx in 0..<self.columnCount {
                self.columnHeights[idx] = top
            }
        }
    }
    
    override open var collectionViewContentSize: CGSize {
        get{
            let numberOfSections = self.collectionView?.numberOfSections
            if numberOfSections == 0 {
                return CGSize(width: 0, height: 0)
            }
            
            var contentSize = self.collectionView?.bounds.size
            let columnIndex = self.longestColumnIndex()
            contentSize?.height = CGFloat(self.columnHeights[columnIndex])
            return contentSize!
        }
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section >= self.sectionItemAttributes.count {
            return nil
        }
        
        if indexPath.item >= self.sectionItemAttributes[indexPath.section].count {
            return nil
        }
        
        return self.sectionItemAttributes[indexPath.section][indexPath.item]
    }
    
    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attribute: UICollectionViewLayoutAttributes?
        
        if elementKind == YCCollectionViewWaterfallSectionHeader {
            if indexPath.section < self.headersAttributes.count {
                attribute = self.headersAttributes[indexPath.section]
            }
        }
        else if elementKind == YCCollectionViewWaterfallSectionFooter {
            if indexPath.section < self.footersAttributes.count {
                attribute = self.footersAttributes[indexPath.section]
            }
        }
        return attribute
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
        var attrs = [UICollectionViewLayoutAttributes]()
        for attr in self.allItemAttributes {
            if rect.intersects(attr.frame) {
                attrs.append(attr)
            }
        }
        return Array(attrs)
    }
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let oldBounds = self.collectionView?.bounds {
            if oldBounds.width != newBounds.width {
                return true
            }else {
                return false
            }
        }else {
            return false
        }
    }
    
    private func shortestColumnIndex() -> Int {
        var index: Int = 0
        var shortestHeight = MAXFLOAT
        
        for (idx, height) in self.columnHeights.enumerated() {
            if height < shortestHeight {
                shortestHeight = height
                index = idx
            }
        }
        return index
    }
    
    private func longestColumnIndex() -> Int {
        var index: Int = 0
        var longestHeight:Float = 0
        
        for (idx, height) in self.columnHeights.enumerated() {
            if height > longestHeight {
                longestHeight = height
                index = idx
            }
        }
        return index
    }
    
    
    private func invalidateIfNotEqual(oldValue: AnyObject, newValue: AnyObject) {
        if !oldValue.isEqual(newValue) {
            invalidateLayout()
        }
    }
}

