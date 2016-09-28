//
//  ViewController.swift
//  DuolingoLikeAnimation
//
//  Created by Quang Minh Trinh on 9/13/16.
//  Copyright © 2016 INSPI. All rights reserved.
//

import UIKit
import KTCenterFlowLayout

class ViewController: UIViewController {

    @IBOutlet weak var wordListCollectionView: UICollectionView!
    
    @IBOutlet weak var arrangedWordListCollectionView: UICollectionView!
    var data : [[DataItem]] = [[], [DataItem.init(indexes: "confirmation", colour: UIColor.greenColor()), DataItem.init(indexes: "vendetta", colour: UIColor.redColor()), DataItem.init(indexes: "yeah", colour: UIColor.greenColor()), DataItem.init(indexes: "yes", colour: UIColor.greenColor()), DataItem.init(indexes: "nicely done", colour: UIColor.greenColor()),DataItem.init(indexes: "index", colour: UIColor.greenColor()), DataItem.init(indexes: "color", colour: UIColor.greenColor()), DataItem.init(indexes: "feeling", colour: UIColor.greenColor()), DataItem.init(indexes: "exploding", colour: UIColor.greenColor()), DataItem.init(indexes: "kitten", colour: UIColor.greenColor())], []]
    var dragAndDropManager: DragAndDropManager!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        let colours : [UIColor] = [
//            UIColor(red: 53.0/255.0, green: 102.0/255.0, blue: 149.0/255.0, alpha: 1.0),
//            UIColor(red: 177.0/255.0, green: 88.0/255.0, blue: 39.0/255.0, alpha: 1.0),
//            UIColor(red: 138.0/255.0, green: 149.0/255.0, blue: 86.0/255.0, alpha: 1.0)
//        ]
        
        wordListCollectionView.delegate = self
        wordListCollectionView.dataSource = self
        arrangedWordListCollectionView.delegate = self
        arrangedWordListCollectionView.dataSource = self
        wordListCollectionView.clipsToBounds = false
        arrangedWordListCollectionView.clipsToBounds = false
        self.dragAndDropManager = DragAndDropManager.init(canvas: self.view, sourceView: wordListCollectionView, destinationView: arrangedWordListCollectionView)
        wordListCollectionView.layer.borderColor = UIColor.blackColor().CGColor
        wordListCollectionView.layer.borderWidth = 1
        arrangedWordListCollectionView.layer.borderColor = UIColor.blackColor().CGColor
        arrangedWordListCollectionView.layer.borderWidth = 1
        if let layout = wordListCollectionView.collectionViewLayout as? UICollectionViewLeftAlignedLayout {
            layout.delegate = self
        }
        if let layout = arrangedWordListCollectionView.collectionViewLayout as? UICollectionViewLeftAlignedLayout {
            layout.delegate = self
        }
//        let layout = KTCenterFlowLayout()
//        layout.minimumInteritemSpacing = 1
//        layout.minimumLineSpacing = 1
//        let wordFlowLayout = self.wordListCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        wordFlowLayout.estimatedItemSize = CGSize(width: 80, height: 24)
//        let arrangedFlowLayout = self.arrangedWordListCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        arrangedFlowLayout.estimatedItemSize = CGSize(width: 80, height: 24)
        
//        let layout = UICollectionViewLeftAlignedLayout()
//        wordListCollectionView.collectionViewLayout = layout
//        arrangedWordListCollectionView.collectionViewLayout = layout
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[collectionView.tag].count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! WordListCollectionViewCell
        cell.dataItem = data[collectionView.tag][indexPath.row]
        cell.reloadData()
        cell.wordLbl.userInteractionEnabled = true
        cell.clipsToBounds = false
        cell.hidden = false
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.cornerRadius = 5
        if let dCollectionView = collectionView as? DuolingoCollectionView {
             
            if let draggingPathOfCellBeingDragged = dCollectionView.draggingPathOfCellBeingDragged {
                
                if draggingPathOfCellBeingDragged.item == indexPath.item {
                    
                    cell.hidden = true
                    
                }
            }
        }
        return cell
    }
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        let  randomWidth = (arc4random() % 120) + 60;
//        return CGSizeMake(CGFloat(randomWidth), 24);
//        
//    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let dataItem = data[collectionView.tag][indexPath.item]
        let label = UILabel.init()
        label.text = dataItem.indexes
        label.sizeToFit()
        return CGSize(width: label.frame.width + 8, height: 29);
    }
    
}

extension ViewController: DuolingoCollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, dataItemForIndexPath indexPath: NSIndexPath) -> AnyObject {
        return data[collectionView.tag][indexPath.item]
    }
    func collectionView(collectionView: UICollectionView, insertDataItem dataItem : AnyObject, atIndexPath indexPath: NSIndexPath) -> Void {
        
        if let di = dataItem as? DataItem {
            data[collectionView.tag].insert(di, atIndex: indexPath.item)
        }
        
        
    }
    func collectionView(collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath : NSIndexPath) -> Void {
        data[collectionView.tag].removeAtIndex(indexPath.item)
    }
    
    func collectionView(collectionView: UICollectionView, moveDataItemFromIndexPath from: NSIndexPath, toIndexPath to : NSIndexPath) -> Void {
        
        let fromDataItem: DataItem = data[collectionView.tag][from.item]
        data[collectionView.tag].removeAtIndex(from.item)
        data[collectionView.tag].insert(fromDataItem, atIndex: to.item)
        
    }
    
    func collectionView(collectionView: UICollectionView, indexPathForDataItem dataItem: AnyObject) -> NSIndexPath? {
        
        if let candidate : DataItem = dataItem as? DataItem {
            
            for item : DataItem in data[collectionView.tag] {
                if candidate  == item {
                    
                    let position = data[collectionView.tag].indexOf(item)! // ! if we are inside the condition we are guaranteed a position
                    let indexPath = NSIndexPath(forItem: position, inSection: 0)
                    return indexPath
                }
            }
        }
        
        return nil
        
    }
}

extension ViewController: UICollectionViewLeftAlignedLayoutDelegate {
    // 1. Returns the photo height
    func collectionView(collectionView:UICollectionView, widthForItemAtIndexPath indexPath:NSIndexPath) -> CGFloat {
        let dataItem = data[collectionView.tag][indexPath.item]
        let label = UILabel.init()
        label.text = dataItem.indexes
        label.sizeToFit()
        return label.frame.size.width + 8
    }
    
    // 2. Returns the annotation size based on the text
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 29
    }
}
