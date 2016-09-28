//
//  DuolingoCollectionView.swift
//  DuolingoLikeAnimation
//
//  Created by Quang Minh Trinh on 9/22/16.
//  Copyright © 2016 INSPI. All rights reserved.
//

import UIKit
import Foundation

@objc protocol DuolingoCollectionViewDataSource : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, indexPathForDataItem dataItem: AnyObject) -> NSIndexPath?
    func collectionView(collectionView: UICollectionView, dataItemForIndexPath indexPath: NSIndexPath) -> AnyObject
    
    func collectionView(collectionView: UICollectionView, moveDataItemFromIndexPath from: NSIndexPath, toIndexPath to : NSIndexPath) -> Void
    func collectionView(collectionView: UICollectionView, insertDataItem dataItem : AnyObject, atIndexPath indexPath: NSIndexPath) -> Void
    func collectionView(collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath: NSIndexPath) -> Void
    
}

class DuolingoCollectionView: UICollectionView, Draggable, Droppable {
    var draggingPathOfCellBeingDragged : NSIndexPath?
    var animating: Bool = false
    var paging : Bool = false
    var isHorizontal : Bool {
        return (self.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection == UICollectionViewScrollDirection.Horizontal
    }
    var currentInRect : CGRect?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
    }

    func canDragAtPoint(point : CGPoint) -> Bool {
        
        guard let _ = self.dataSource as? DuolingoCollectionViewDataSource else {
            return false
        }
        
        return self.indexPathForItemAtPoint(point) != nil && draggingPathOfCellBeingDragged == nil
    }
    
    func representationImageAtPoint(point : CGPoint) -> UIView? {
        
        var imageView : UIView?
        
        if let indexPath = self.indexPathForItemAtPoint(point) {
            
            if let cell = self.cellForItemAtIndexPath(indexPath) {
                UIGraphicsBeginImageContextWithOptions(cell.bounds.size, cell.opaque, 0)
                cell.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                let img = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                imageView = UIImageView(image: img)
                
                imageView?.frame = cell.frame
            }
        }
        
        return imageView
    }
    
    func dataItemAtPoint(point : CGPoint) -> AnyObject? {
        
        var dataItem : AnyObject?
        
        if let indexPath = self.indexPathForItemAtPoint(point) {
            
            if let dragDropDS : DuolingoCollectionViewDataSource = self.dataSource as? DuolingoCollectionViewDataSource {
                
                dataItem = dragDropDS.collectionView(self, dataItemForIndexPath: indexPath)
                
            }
            
        }
        return dataItem
    }
    
    func startDraggingAtPoint(point : CGPoint) -> Void {
        print ("start draggin")
        self.draggingPathOfCellBeingDragged = self.indexPathForItemAtPoint(point)
        
        self.reloadData()
        
    }
    
    func stopDragging() -> Void {
        print ("stop dragging")
        if let idx = self.draggingPathOfCellBeingDragged {
            if let cell = self.cellForItemAtIndexPath(idx) {
                cell.hidden = false
            }
        }
        
        self.draggingPathOfCellBeingDragged = nil
        
        self.reloadData()
        
    }
    
    func dragDataItem(item : AnyObject) -> Void {
        print ("drag data item")
        if let dragDropDataSource = self.dataSource as? DuolingoCollectionViewDataSource {
            
            if let existingIndexPath = dragDropDataSource.collectionView(self, indexPathForDataItem: item) {
                
                dragDropDataSource.collectionView(self, deleteDataItemAtIndexPath: existingIndexPath)
                
                self.animating = true
//                self.deleteItemsAtIndexPaths([existingIndexPath])
                self.animating = false
                self.reloadData()
//                self.performBatchUpdates({ () -> Void in
//                    
//                    
//                    
//                    }, completion: { complete -> Void in
//                        
//                        
//                        
//                        
//                        
//                        
//                })
                
                
            }
            
        }
        
    }

    func canDropAtRect(rect : CGRect) -> Bool {
        print("can drop at rect")
        return (self.indexPathForCellOverlappingRect(rect) != nil)
    }
    
    func indexPathForCellOverlappingRect( rect : CGRect) -> NSIndexPath? {
        print("index path for cell overlapping rect")
        var overlappingArea : CGFloat = 0.0
        var cellCandidate : UICollectionViewCell?
        
        
        let visibleCells = self.visibleCells
        if visibleCells().count == 0 {
            return NSIndexPath.init(forRow: 0, inSection: 0)
        }
        
        if  isHorizontal && rect.origin.x > self.contentSize.width ||
            !isHorizontal && rect.origin.y > self.contentSize.height {
            
            return NSIndexPath.init(forRow: visibleCells().count - 1, inSection: 0)
        }
        
        
        for visible in visibleCells() {
            
            
            let intersection = visible.frame.intersect(rect)
            print("Intersection: \(intersection)")
            if (intersection.width * intersection.height) > overlappingArea {
                overlappingArea = intersection.width * intersection.height
                
                cellCandidate = visible
            }
            
        }
        
        if let cellRetrieved = cellCandidate {
            
            return self.indexPathForCell(cellRetrieved)
        }
       
        return nil
    }
    
    
    
    func willMoveItem(item : AnyObject, inRect rect : CGRect) -> Void {
        print ("will move item")
        let dragDropDataSource = self.dataSource as! DuolingoCollectionViewDataSource // its guaranteed to have a data source
        
        if let _ = dragDropDataSource.collectionView(self, indexPathForDataItem: item) { // if data item exists
            return
        }
        
        if let indexPath = self.indexPathForCellOverlappingRect(rect) {
            
            dragDropDataSource.collectionView(self, insertDataItem: item, atIndexPath: indexPath)
            
            self.draggingPathOfCellBeingDragged = indexPath
            
            self.animating = true
            
            self.performBatchUpdates({ () -> Void in
                
                self.insertItemsAtIndexPaths([indexPath])
                
                }, completion: { complete -> Void in
                    
                    self.animating = false
                    
                    // if in the meantime we have let go
                    if self.draggingPathOfCellBeingDragged == nil {
                        
                        self.reloadData()
                    }
                    
                    
            })
            
            
        }
        
        currentInRect = rect
        
    }
    
    
    
    
    
    func checkForEdgesAndScroll(rect : CGRect) -> Void {
        print ("check for edge")
        if paging == true {
            return
        }
        
        let currentRect : CGRect = CGRect(x: self.contentOffset.x, y: self.contentOffset.y, width: self.bounds.size.width, height: self.bounds.size.height)
        var rectForNextScroll : CGRect = currentRect
        
        if isHorizontal {
            
            let leftBoundary = CGRect(x: 0, y: 0.0, width: 30.0, height: self.frame.size.height)
            let rightBoundary = CGRect(x: self.frame.size.width, y: 0.0, width: 30.0, height: self.frame.size.height)
            
            if rect.intersects(leftBoundary) == true {
                rectForNextScroll.origin.x -= self.bounds.size.width * 0.5
                if rectForNextScroll.origin.x < 0 {
                    rectForNextScroll.origin.x = 0
                }
            }
            else if rect.intersects(rightBoundary) == true {
                rectForNextScroll.origin.x += self.bounds.size.width * 0.5
                if rectForNextScroll.origin.x > self.contentSize.width - self.bounds.size.width {
                    rectForNextScroll.origin.x = self.contentSize.width - self.bounds.size.width
                }
            }
            
        } else { // is vertical
            
            let topBoundary = CGRect(x: 0.0, y: -30.0, width: self.frame.size.width, height: 30.0)
            let bottomBoundary = CGRect(x: 0.0, y: self.frame.size.height, width: self.frame.size.width, height: 30.0)
            
            if rect.intersects(topBoundary) == true {
                
            }
            else if rect.intersects(bottomBoundary) == true {
                
            }
        }
        
        // check to see if a change in rectForNextScroll has been made
        if currentRect != rectForNextScroll {
            self.paging = true
            self.scrollRectToVisible(rectForNextScroll, animated: true)
            
            let delayTime = Double(DISPATCH_TIME_NOW) + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            delay(delayTime, closure: {
                self.paging = false
            })
        
            
        }
        
    }
    
    func didMoveItem(item : AnyObject, inRect rect : CGRect) -> Void {
        
        let dragDropDS = self.dataSource as! DuolingoCollectionViewDataSource // guaranteed to have a ds
        
        if  let existingIndexPath = dragDropDS.collectionView(self, indexPathForDataItem: item),
            let indexPath = self.indexPathForCellOverlappingRect(rect) {
            
            if (indexPath as NSIndexPath).item != (existingIndexPath as NSIndexPath).item {
                
                dragDropDS.collectionView(self, moveDataItemFromIndexPath: existingIndexPath, toIndexPath: indexPath)
                
                self.animating = true
                
                self.performBatchUpdates({ () -> Void in
                    self.moveItemAtIndexPath(existingIndexPath, toIndexPath: indexPath)
                    
                    }, completion: { (finished) -> Void in
                        
                        self.animating = false
                        
                        self.reloadData()
                        
                })
                
                self.draggingPathOfCellBeingDragged = indexPath
                
            }
        }
        
        // Check Paging
        
        var normalizedRect = rect
        normalizedRect.origin.x -= self.contentOffset.x
        normalizedRect.origin.y -= self.contentOffset.y
        
        currentInRect = normalizedRect
        
        
        self.checkForEdgesAndScroll(normalizedRect)
        
        
    }
    
    func didMoveOutItem(item : AnyObject) -> Void {
        print ("did move out")
        guard let dragDropDataSource = self.dataSource as? DuolingoCollectionViewDataSource,
            let existngIndexPath = dragDropDataSource.collectionView(self, indexPathForDataItem: item) else {
                
                return
        }
        
        dragDropDataSource.collectionView(self, deleteDataItemAtIndexPath: existngIndexPath)
        
        self.animating = true
        
        self.performBatchUpdates({ () -> Void in
            
            
            self.deleteItemsAtIndexPaths([existngIndexPath])
            }, completion: { (finished) -> Void in
                
                self.animating = false;
                
                self.reloadData()
        })
        
        
        if let idx = self.draggingPathOfCellBeingDragged {
            if let cell = self.cellForItemAtIndexPath(idx) {
                cell.hidden = false
            }
        }
        
        self.draggingPathOfCellBeingDragged = nil
        
        currentInRect = nil
    }
    
    
    func dropDataItem(item : AnyObject, atRect : CGRect, representImage: UIView, canvas: UIView, collectionView: UIView) -> Void {
        print("drop data item")
        // show hidden cell
        if  let index = draggingPathOfCellBeingDragged,
            let cell = self.cellForItemAtIndexPath(index) where cell.hidden == true {
            let rect = cell.frame
            let newRect = collectionView.convertRect(rect, toView: canvas)
            UIView.animateWithDuration(0.1, animations: { (complete) in
                representImage.frame.origin = newRect.origin
                }, completion: { (complete) in
                cell.alpha = 1.0
                cell.hidden = false
                representImage.removeFromSuperview()
                self.currentInRect = nil
                    
                self.draggingPathOfCellBeingDragged = nil
                self.reloadData()
            })
            
            
            
            
        }
        
        
        
        
        
    }
    func stopDraggingWithAnimation(representImage: UIView, canvas: UIView, collectionView: UIView) {
        print ("stop dragging")
        if let idx = self.draggingPathOfCellBeingDragged {
            if let cell = self.cellForItemAtIndexPath(idx) {
                let rect = cell.frame
                let newRect = collectionView.convertRect(rect, toView: canvas)
                UIView.animateWithDuration(0.1, animations: { (complete) in
                    representImage.frame.origin = newRect.origin
                    }, completion: { (complete) in
                        cell.alpha = 1.0
                        cell.hidden = false
                        representImage.removeFromSuperview()
                        
                        self.draggingPathOfCellBeingDragged = nil
                        self.reloadData()
                })
            }
        }
        
    }
    
}
func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
