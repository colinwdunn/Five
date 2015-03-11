//
//  ExerciseCellRow.swift
//  Five
//
//  Created by Colin Dunn on 3/7/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit

class ExerciseCellRow: UIView {
    
    let nameLabel = UILabel()
    let weightLabel = UILabel()
    let font = UIFont.systemFontOfSize(16)
    var name:Int! {
        didSet {
            nameLabel.text = exerciseName(rawValue: name)?.description()
        }
    }
    
    var weight:Int! {
        didSet {
            weightLabel.text = weight.description
        }
    }
    
    var reps:[Int]!

    override init() {
        super.init(frame: CGRect())
        nameLabel.font = font
        weightLabel.font = font
        nameLabel.textColor = lightTextColor
        weightLabel.textColor = lightTextColor
        addSubview(nameLabel)
        addSubview(weightLabel)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.frame = CGRectMake(0, 0, frame.width / 2, 30)
        weightLabel.frame = CGRectMake(frame.width / 2, 0, frame.width / 2, 30)
        
        for (i, rep) in enumerate(reps) {
            let sparkRow = UIView()
            sparkRow.frame = CGRectMake(frame.width - 60, 4 * CGFloat(i), 5 * CGFloat(rep), 3)
            sparkRow.backgroundColor = tintColor
            sparkRow.alpha = CGFloat(rep) * 0.2
            addSubview(sparkRow)
        }
        
        println("Reps: \(reps)")
    }

}
