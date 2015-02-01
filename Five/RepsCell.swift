//
//  RepsCell.swift
//  Five
//
//  Created by Colin Dunn on 1/31/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit

class RepsCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = tintColor
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
