//
//  DataItem.swift
//  DuolingoLikeAnimation
//
//  Created by Quang Minh Trinh on 9/14/16.
//  Copyright © 2016 INSPI. All rights reserved.
//

import Foundation
import UIKit

class DataItem: Equatable{
    var indexes : String = ""
    var colour : UIColor = UIColor.clearColor()
    init(indexes : String, colour : UIColor) {
        self.indexes = indexes
        self.colour = colour
    }
}
func ==(lhs: DataItem, rhs: DataItem) -> Bool {
    return lhs.indexes == rhs.indexes && lhs.colour == rhs.colour
}
