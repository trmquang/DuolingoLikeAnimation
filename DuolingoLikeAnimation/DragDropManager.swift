//
//  DragDropManager.swift
//  DuolingoLikeAnimation
//
//  Created by Quang Minh Trinh on 9/22/16.
//  Copyright © 2016 INSPI. All rights reserved.
//

import UIKit

@objc protocol Draggable {
    func canDragAtPoint(point : CGPoint) -> Bool
    func representationImageAtPoint(point : CGPoint) -> UIView?
    func dataItemAtPoint(point : CGPoint) -> AnyObject?
    func dragDataItem(item : AnyObject) -> Void
    @objc optional func startDraggingAtPoint(point : CGPoint) -> Void
    @objc optional func stopDragging() -> Void
    func stopDraggingWithAnimation(representImage: UIView, canvas: UIView, collectionView: UIView) -> Void
}


@objc protocol Droppable {
    func canDropAtRect(rect : CGRect) -> Bool
    func willMoveItem(item : AnyObject, inRect rect : CGRect) -> Void
    func didMoveItem(item : AnyObject, inRect rect : CGRect) -> Void
    func didMoveOutItem(item : AnyObject) -> Void
    func dropDataItem(item : AnyObject, atRect : CGRect, representImage: UIView, canvas: UIView, collectionView: UIView) -> Void
}
class DragAndDropManager: NSObject {
    
    var canvas : UIView = UIView()
    var sourceView : UIView = UIView()
    var destinationView: UIView = UIView()
    var panGestureRecogniser = UIPanGestureRecognizer()
    var tapGestureRecogniser = UITapGestureRecognizer()
    
    struct Bundle {
        var offset : CGPoint = CGPoint.zero
        var sourceDraggableView : UIView
        var overDroppableView : UIView?
        var representationImageView : UIView
        var dataItem : AnyObject
        var isSource: Bool
    }
    var bundle : Bundle?
    init(canvas : UIView, sourceView: UIView, destinationView: UIView) {
        
        super.init()
        
        self.canvas = canvas
        self.sourceView = sourceView
        self.destinationView = destinationView
        self.panGestureRecogniser.delegate = self
        self.panGestureRecogniser.addTarget(self, action: #selector(DragAndDropManager.itemPan(_:)))
        self.tapGestureRecogniser.delegate = self
        self.tapGestureRecogniser.addTarget(self, action: #selector(DragAndDropManager.itemTap(_:)))
        self.canvas.addGestureRecognizer(self.panGestureRecogniser)
        self.canvas.addGestureRecognizer(self.tapGestureRecogniser)
    }
    func itemTap(recogniser : UITapGestureRecognizer) -> Void {
        if let bundl = self.bundle where bundl.isSource == true {
            let pointOnCanvas = recogniser.locationInView(recogniser.view)
            let sourceDraggable : DuolingoCollectionView = bundl.sourceDraggableView as! DuolingoCollectionView
            let pointOnSourceDraggable = recogniser.locationInView(bundl.sourceDraggableView)
            self.canvas.addSubview(bundl.representationImageView)
            sourceDraggable.startDraggingAtPoint(pointOnSourceDraggable)
            
            var repImgFrame = bundl.representationImageView.frame
            repImgFrame.origin = CGPoint(x: pointOnCanvas.x - bundl.offset.x, y: pointOnCanvas.y - bundl.offset.y);
            bundl.representationImageView.frame = repImgFrame
            self.bundle?.overDroppableView = destinationView
            if self.bundle!.sourceDraggableView != self.bundle!.overDroppableView { // if we are actually dropping over a new view.
                
                //                    print("\(bundl.overDroppableView?.tag)")
                
                if let droppable = self.bundle!.overDroppableView as? DuolingoCollectionView {
                    
                    sourceDraggable.dragDataItem(bundl.dataItem)
                    
                    let rect = self.canvas.convertRect(bundl.representationImageView.frame, toView: self.bundle!.overDroppableView)
                    droppable.willMoveItem(bundl.dataItem, inRect: rect)
                    droppable.didMoveItem(bundl.dataItem, inRect: rect)
                    droppable.dropDataItem(bundl.dataItem, atRect: rect, representImage: bundl.representationImageView, canvas: self.canvas, collectionView: droppable)
                    droppable.reloadData()
                }
            }
            
//            bundl.representationImageView.removeFromSuperview()
            sourceDraggable.stopDragging()
        }
        
    }
    func itemPan(recogniser : UIPanGestureRecognizer) -> Void {
        
        if let bundl = self.bundle {
            let pointOnCanvas = recogniser.locationInView(recogniser.view)
            let sourceDraggable : Draggable = bundl.sourceDraggableView as! Draggable
            let pointOnSourceDraggable = recogniser.locationInView(bundl.sourceDraggableView)
            switch recogniser.state {
                
                
            case .Began :
                if sourceDraggable.canDragAtPoint(pointOnSourceDraggable) == true {
                    self.canvas.addSubview(bundl.representationImageView)
                    sourceDraggable.startDraggingAtPoint?(pointOnSourceDraggable)
                }
               
                
            case .Changed :
                
                // Update the frame of the representation image
                var repImgFrame = bundl.representationImageView.frame
                repImgFrame.origin = CGPoint(x: pointOnCanvas.x - bundl.offset.x, y: pointOnCanvas.y - bundl.offset.y);
                bundl.representationImageView.frame = repImgFrame
                
                var mainOverView : UIView?
                
                if bundl.isSource == false {
                    mainOverView = self.selectMainOverView(bundl)
                    if mainOverView == self.destinationView {
                        print("destination View")
                        
                    }
                    else if mainOverView == self.sourceView {
                        print ("source View")
                    }
                    if let droppable = mainOverView as? Droppable {
                        let rect = self.canvas.convertRect(bundl.representationImageView.frame, toView: mainOverView)
                        if droppable.canDropAtRect(rect) {
                            
                            if mainOverView != bundl.overDroppableView { // if it is the first time we are entering
                                
                                (bundl.overDroppableView as! Droppable).didMoveOutItem(bundl.dataItem)
                                droppable.willMoveItem(bundl.dataItem, inRect: rect)
                                
                            }
                            
                            // set the view the dragged element is over
                            self.bundle!.overDroppableView = mainOverView
                            
                            droppable.didMoveItem(bundl.dataItem, inRect: rect)
                            
                        }
                        
                        
                    }
                }
                else {
                    mainOverView = self.destinationView
                    if let droppable = mainOverView as? Droppable {
                        let rect = self.canvas.convertRect(bundl.representationImageView.frame, toView: mainOverView)
                        if droppable.canDropAtRect(rect) {
                            if mainOverView != bundl.overDroppableView { // if it is the first time we are entering
                                
                                (bundl.overDroppableView as! Droppable).didMoveOutItem(bundl.dataItem)
                                droppable.willMoveItem(bundl.dataItem, inRect: rect)
                                
                            }
//                            (bundl.overDroppableView as! Droppable).didMoveOutItem(bundl.dataItem)
//                            droppable.willMoveItem(bundl.dataItem, inRect: rect)
                            
                            // set the view the dragged element is over
                            self.bundle!.overDroppableView = self.destinationView
                            
                            droppable.didMoveItem(bundl.dataItem, inRect: rect)
                            
                        }
                        
                        
                    }

                }
                
                
                
            case .Ended :
                
                if bundl.sourceDraggableView != bundl.overDroppableView { // if we are actually dropping over a new view.
                    
//                    print("\(bundl.overDroppableView?.tag)")
                    
                    if let droppable = bundl.overDroppableView as? Droppable {
                        
                        sourceDraggable.dragDataItem(bundl.dataItem)
                        
                        let rect = self.canvas.convertRect(bundl.representationImageView.frame, toView: bundl.overDroppableView)
                        
                        droppable.dropDataItem(bundl.dataItem, atRect: rect, representImage: bundl.representationImageView, canvas: self.canvas, collectionView: droppable as! DuolingoCollectionView)
                        
                    }
                     sourceDraggable.stopDragging?()
                }
                
                
//                bundl.representationImageView.removeFromSuperview()
                else {
                    sourceDraggable.stopDraggingWithAnimation(bundl.representationImageView, canvas: self.canvas, collectionView: sourceDraggable as! DuolingoCollectionView)
                }
               
            
            case .Cancelled:
                print("Cancelled")
            default:
                break
                
            }
            
            
        } // if let bundl = self.bundle ...
        
        
        
    }
    // MARK: Helper Methods
    func convertRectToCanvas(rect : CGRect, fromView view : UIView) -> CGRect {
        
        var r : CGRect = rect
        
        var v = view
        
        while v != self.canvas {
            
            if let sv = v.superview {
                
                r.origin.x += sv.frame.origin.x
                r.origin.y += sv.frame.origin.y
                
                v = sv
                
                continue
            }
            break
        }
        
        return r
    }
    
    func selectMainOverView(bundl: Bundle) -> UIView{
        var overlappingArea : CGFloat = 0.0
        
        var viewFrameOnCanvas = self.convertRectToCanvas(destinationView.frame, fromView: destinationView)
        var intersectionNew = bundl.representationImageView.frame.intersect(viewFrameOnCanvas).size
        if (intersectionNew.width * intersectionNew.height) > overlappingArea {
            
            overlappingArea = intersectionNew.width * intersectionNew.height
            
            return destinationView
        }
        else {
            overlappingArea = 0.0
            viewFrameOnCanvas = self.convertRectToCanvas(sourceView.frame, fromView: destinationView)
            intersectionNew = bundl.representationImageView.frame.intersect(viewFrameOnCanvas).size
            if (intersectionNew.width * intersectionNew.height) > overlappingArea {
                
                overlappingArea = intersectionNew.width * intersectionNew.height
                
                return sourceView
            }
        }
        return self.canvas
    }
}

extension DragAndDropManager: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        var view = self.sourceView
        if createBundleByView(view, touch: touch) == true {
            return true
        }
        view = self.destinationView
        if createBundleByView(view, touch: touch) == true {
            return true
        }
        return false
    }
    func createBundleByView(view: UIView, touch: UITouch ) -> Bool {
        let draggableView = view as! Draggable
        let touchPointInView = touch.locationInView(view)
        if draggableView.canDragAtPoint(touchPointInView) {
            if let representation = draggableView.representationImageAtPoint(touchPointInView) {
                representation.frame = self.canvas.convertRect(representation.frame, fromView: view)
                representation.alpha = 1
                
                let pointOnCanvas = touch.locationInView(self.canvas)
                print(representation.frame)
                let offset = CGPoint(x: pointOnCanvas.x - representation.frame.origin.x, y: pointOnCanvas.y - representation.frame.origin.y)
                if let dataItem : AnyObject = draggableView.dataItemAtPoint(touchPointInView) {
                    if view == self.sourceView {
                        self.bundle = Bundle(
                            offset: offset,
                            sourceDraggableView: view,
                            overDroppableView : view is Droppable ? view : nil,
                            representationImageView: representation,
                            dataItem : dataItem,
                            isSource: true
                        )
                    }
                    else {
                        self.bundle = Bundle(
                            offset: offset,
                            sourceDraggableView: view,
                            overDroppableView : view is Droppable ? view : nil,
                            representationImageView: representation,
                            dataItem : dataItem,
                            isSource: false
                        )
                    }
                    
                    return true
                }
            }
        }
        
        
        return false
    }
}
