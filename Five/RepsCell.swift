//
//  RepsCell.swift
//  Five
//
//  Created by Colin Dunn on 2/8/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit

class RepsCell: UITableViewCell {
    
    var segmentedControl: UISegmentedControl!
    let segments = ["1", "2", "3", "4", "5"]
    var padding:CGFloat = 10

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.clearColor()
        
        segmentedControl = UISegmentedControl(items: segments)
//        segmentedControl.tintColor = UIColor.clearColor()
        segmentedControl.backgroundColor = colorWithAlpha(lightTextColor, 0.25)
        contentView.addSubview(segmentedControl)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        segmentedControl.frame = CGRectMake(0, 0, contentView.frame.width, contentView.frame.height - padding)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}