//
//  TableCell.swift
//  Five
//
//  Created by Colin Dunn on 1/29/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit

class TableCell: UITableViewCell {
    
    let title = UILabel()
    let subTitle = UILabel()
    let separator = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        subTitle.textAlignment = NSTextAlignment.Right
        contentView.addSubview(subTitle)
        
        contentView.addSubview(title)
        
        separator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        contentView.addSubview(separator)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        title.frame = CGRectMake(15, 0, contentView.frame.width - 30, contentView.frame.height)
        subTitle.frame = CGRectMake(15, 0, contentView.frame.width - 30, contentView.frame.height)
        separator.frame = CGRectMake(0, contentView.frame.height - 1, contentView.frame.width, 1)
    }
}
