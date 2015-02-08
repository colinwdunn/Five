//
//  RoundedButton.swift
//  Five
//
//  Created by Colin Dunn on 2/8/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    
    init(color: UIColor, title: String) {
        super.init(frame: CGRect())
        setTitle(title, forState: .Normal)
        setTitleColor(UIColor.whiteColor(), forState: .Normal)
        setBackgroundImage(UIImage.imageWithColor(color), forState: UIControlState.Normal)
        setBackgroundImage(UIImage.imageWithColor(colorWithAlpha(color, 0.5)), forState: UIControlState.Highlighted)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
    }
    
}

extension UIImage {
    class func imageWithColor(color:UIColor?) -> UIImage! {
        
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0);
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext();
        
        if let color = color {
            color.setFill()
        }
        else {
            UIColor.whiteColor().setFill()
        }
        
        CGContextFillRect(context, rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
}