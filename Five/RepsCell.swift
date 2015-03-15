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
    var bar = UIView()
    let bg = UIView()
    var selectedSegments:Int! {
        didSet {
            UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
                self.bar.frame.size.width = (self.contentView.frame.width / 5) * CGFloat(self.selectedSegments)
                self.bar.alpha = CGFloat(self.selectedSegments) * 0.2
            }, completion: nil)
            
            
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.clearColor()
        
        bar.frame = CGRectZero
        bar.backgroundColor = colorWithAlpha(tintColor, 0.8)
        contentView.addSubview(bar)
        
        segmentedControl = UISegmentedControl(items: segments)
        segmentedControl.tintColor = UIColor.clearColor()
        segmentedControl.addTarget(self, action: "segmentChanged:", forControlEvents: .ValueChanged)
        contentView.addSubview(segmentedControl)
    }
    
    func segmentChanged(sender: UISegmentedControl) {
        selectedSegments = sender.selectedSegmentIndex + 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        segmentedControl.frame = CGRectMake(0, 0, contentView.frame.width, contentView.frame.height - padding)
        bar.frame.size.width = contentView.frame.width / 5 * CGFloat(selectedSegments)
        bar.frame.size.height = contentView.frame.height - padding
        
        bg.frame = CGRectMake(0, 0, contentView.frame.width, contentView.frame.height - padding)
        bg.backgroundColor = tintColor
        bg.alpha = 0.1
        contentView.addSubview(bg)
        
//        for i in 1...4 {
//            let gridLine = UIView()
//            gridLine.frame = CGRectMake(CGFloat(i) * contentView.frame.width / 5 - 0.5, 0, 0.5, contentView.frame.height - padding)
//            gridLine.backgroundColor = bgColor
//            contentView.addSubview(gridLine)
//        }
//        
//        contentView.bringSubviewToFront(bar)
        contentView.bringSubviewToFront(segmentedControl)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}