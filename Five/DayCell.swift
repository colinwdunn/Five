//
//  DayCell.swift
//  Five
//
//  Created by Colin Dunn on 2/1/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit
import CloudKit

class DayCell: UITableViewCell {
    let date = UILabel()
    var rows = [ExerciseCellRow]()
    let separator = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        date.text = "Date"
        date.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        contentView.addSubview(date)
        
        for i in 0...2 {
            let row = ExerciseCellRow()
            rows.append(row)
            contentView.addSubview(row)
        }
        
        separator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        date.frame = CGRectMake(15, 10, contentView.frame.width - 30, 30)
        separator.frame = CGRectMake(0, contentView.frame.height - 2, contentView.frame.width, 1)
        
        for (index, row) in enumerate(rows) {
            row.frame = CGRectMake(15, 50 + 30 * CGFloat(index), contentView.frame.width, 45)
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        for row in rows {
            for sparkView in row.sparkViews {
                sparkView.backgroundColor = tintColor
            }
        }
    }
}