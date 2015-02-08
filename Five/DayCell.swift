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
    
    let titleFont = UIFont(name: "HelveticaNeue-Medium", size: 16)
    let subtitleFont = UIFont.systemFontOfSize(16)
    
    let date = UILabel()
    let exerciseOne = UILabel()
    let exerciseTwo = UILabel()
    let exerciseThree = UILabel()
    let weightOne = UILabel()
    let weightTwo = UILabel()
    let weightThree = UILabel()
    
    let separator = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        date.text = "Date"
        date.font = titleFont
        
        exerciseOne.text = "Exercise One"
        exerciseTwo.text = "Exercise Two"
        exerciseThree.text = "Exercise Three"
        exerciseOne.font = subtitleFont
        exerciseTwo.font = subtitleFont
        exerciseThree.font = subtitleFont
        exerciseOne.textColor = lightTextColor
        exerciseTwo.textColor = lightTextColor
        exerciseThree.textColor = lightTextColor
        
        weightOne.text = "45"
        weightTwo.text = "45"
        weightThree.text = "45"
        weightOne.font = subtitleFont
        weightTwo.font = subtitleFont
        weightThree.font = subtitleFont
        weightOne.textColor = lightTextColor
        weightTwo.textColor = lightTextColor
        weightThree.textColor = lightTextColor
        
        separator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        
        contentView.addSubview(date)
        contentView.addSubview(exerciseOne)
        contentView.addSubview(exerciseTwo)
        contentView.addSubview(exerciseThree)
        contentView.addSubview(weightOne)
        contentView.addSubview(weightTwo)
        contentView.addSubview(weightThree)
        contentView.addSubview(separator)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        date.frame = CGRectMake(15, 10, contentView.frame.width - 30, 30)
        
        exerciseOne.frame = CGRectMake(15, 45, contentView.frame.width / 2, 30)
        exerciseTwo.frame = CGRectMake(15, 80, contentView.frame.width / 2, 30)
        exerciseThree.frame = CGRectMake(15, 115, contentView.frame.width / 2, 30)
        
        weightOne.frame = CGRectMake(contentView.frame.width / 2, 45, contentView.frame.width / 2, 30)
        weightTwo.frame = CGRectMake(contentView.frame.width / 2, 80, contentView.frame.width / 2, 30)
        weightThree.frame = CGRectMake(contentView.frame.width / 2, 115, contentView.frame.width / 2, 30)
        
        separator.frame = CGRectMake(0, contentView.frame.height - 2, contentView.frame.width, 1)
    }
}