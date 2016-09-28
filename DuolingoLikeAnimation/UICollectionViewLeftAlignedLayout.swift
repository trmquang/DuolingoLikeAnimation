//
//  UICollectionViewLeftAlignedLayout.swift
//  SwiftDemo
//
//  Created by fanpyi on 22/2/16.
//  Copyright © 2016 fanpyi. All rights reserved.
//  based on http://stackoverflow.com/questions/13017257/how-do-you-determine-spacing-between-cells-in-uicollectionview-flowlayout  https://github.com/mokagio/UICollectionViewLeftAlignedLayout

import UIKit
extension UICollectionViewLayoutAttributes {
    func leftAlignFrameWithSectionInset(sectionInset:UIEdgeInsets){
        var frame = self.frame
        frame.origin.x = sectionInset.left
        self.frame = frame
    }
}

class UICollectionViewLeftAlignedLayout: UICollectionViewFlowLayout {
    var delegate:UICollectionViewLeftAlignedLayoutDelegate!
    var cache = [UICollectionViewLayoutAttributes]()
    override func prepareLayout() {
        print("prepare layout")
    }
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var attributesCopy: [UICollectionViewLayoutAttributes] = []
        if let attributes = super.layoutAttributesForElementsInRect(rect) {
            attributes.forEach({ attributesCopy.append($0.copy() as! UICollectionViewLayoutAttributes) })
        }
        
        for attributes in attributesCopy {
            if attributes.representedElementKind == nil {
                let indexpath = attributes.indexPath
                if let attr = layoutAttributesForItemAtIndexPath(indexpath) {
                    attributes.frame = attr.frame
                }
            }
        }
        return attributesCopy
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if let currentItemAttributes = super.layoutAttributesForItemAtIndexPath(indexPath)?.copy() as? UICollectionViewLayoutAttributes {
            let sectionInset = self.evaluatedSectionInsetForItemAtIndex(indexPath.section)
            let isFirstItemInSection = indexPath.item == 0
            let layoutWidth = CGRectGetWidth(self.collectionView!.frame) - sectionInset.left - sectionInset.right
            
            if (isFirstItemInSection) {
                currentItemAttributes.leftAlignFrameWithSectionInset(sectionInset)
                var frame = currentItemAttributes.frame
//                frame.size.height = delegate.collectionView(collectionView!, heightForItemAtIndexPath: indexPath)
//                frame.size.width = delegate.collectionView(collectionView!, widthForItemAtIndexPath: indexPath)
                currentItemAttributes.frame = frame
                return currentItemAttributes
            }
            
            let previousIndexPath = NSIndexPath(forItem: indexPath.item - 1, inSection: indexPath.section)
            
            let previousFrame = layoutAttributesForItemAtIndexPath(previousIndexPath)?.frame ?? CGRectZero
            let previousFrameRightPoint = previousFrame.origin.x + previousFrame.width
            var currentFrame = currentItemAttributes.frame
//            currentFrame.size.height = delegate.collectionView(collectionView!, heightForItemAtIndexPath: indexPath)
//            currentFrame.size.width = delegate.collectionView(collectionView!, widthForItemAtIndexPath: indexPath)
            let strecthedCurrentFrame = CGRectMake(sectionInset.left,
                                                   currentFrame.origin.y,
                                                   layoutWidth,
                                                   currentFrame.size.height)
            // if the current frame, once left aligned to the left and stretched to the full collection view
            // widht intersects the previous frame then they are on the same line
            let isFirstItemInRow = !CGRectIntersectsRect(previousFrame, strecthedCurrentFrame)
            
            if (isFirstItemInRow) {
                // make sure the first item on a line is left aligned
                currentItemAttributes.leftAlignFrameWithSectionInset(sectionInset)
                var frame = currentItemAttributes.frame
//                frame.size.height = delegate.collectionView(collectionView!, heightForItemAtIndexPath: indexPath)
//                frame.size.width = delegate.collectionView(collectionView!, widthForItemAtIndexPath: indexPath)
                currentItemAttributes.frame = frame
                return currentItemAttributes
            }
            
            var frame = currentItemAttributes.frame
            frame.origin.x = previousFrameRightPoint + evaluatedMinimumInteritemSpacingForSectionAtIndex(indexPath.section)
//            frame.size.height = delegate.collectionView(collectionView!, heightForItemAtIndexPath: indexPath)
//            frame.size.width = delegate.collectionView(collectionView!, widthForItemAtIndexPath: indexPath)
            print ("layoutAttribute at index path: \(indexPath)")
            currentItemAttributes.frame = frame
            
            return currentItemAttributes
            
        }
        return nil
    }
//    override func invalidationContextForInteractivelyMovingItems(targetIndexPaths: [NSIndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [NSIndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
//        var context = super.invalidationContextForInteractivelyMovingItems(targetIndexPaths,
//                                                                           withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths,
//                                                                           previousPosition: previousPosition)
//
//        return context
//    }
    
    func evaluatedMinimumInteritemSpacingForSectionAtIndex(sectionIndex:Int) -> CGFloat {
        if let delegate = self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout {
            if delegate.respondsToSelector(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAtIndex:))) {
                return delegate.collectionView!(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAtIndex: sectionIndex)
                
            }
        }
        return self.minimumInteritemSpacing
        
    }
    
    func evaluatedSectionInsetForItemAtIndex(index: Int) ->UIEdgeInsets {
        if let delegate = self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout {
            if  delegate.respondsToSelector(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAtIndex:))) {
                return delegate.collectionView!(self.collectionView!, layout: self, insetForSectionAtIndex: index)
            }
        }
        return self.sectionInset
    }
    
}

protocol UICollectionViewLeftAlignedLayoutDelegate {
    // 1. Method to ask the delegate for the height of the image
    func collectionView(collectionView:UICollectionView, heightForItemAtIndexPath indexPath:NSIndexPath) -> CGFloat
    // 2. Method to ask the delegate for the height of the annotation text
    func collectionView(collectionView: UICollectionView, widthForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat
    
}

