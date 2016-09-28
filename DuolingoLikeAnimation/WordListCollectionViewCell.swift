//
//  WordListCollectionViewCell.swift
//  DuolingoLikeAnimation
//
//  Created by Quang Minh Trinh on 9/13/16.
//  Copyright © 2016 INSPI. All rights reserved.
//

import UIKit

class WordListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var wordLbl: UILabel!
    var dataItem: DataItem!
    func reloadData() {
        wordLbl.text = dataItem.indexes
        wordLbl.sizeToFit()
        backgroundColor = UIColor.grayColor()
        wordLbl.backgroundColor = UIColor.grayColor()
        wordLbl.textColor = UIColor.whiteColor()
        self.sizeToFit()
    }
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        self.sizeToFit()
    }
}
