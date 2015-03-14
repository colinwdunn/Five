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
    
    var reps:[Int]! {
        didSet {
            for (index, view) in enumerate(reps) {
                if reps[index] > 0 {
                    sparkViews[index].frame.size.width = 4 * CGFloat(reps[index])
                    sparkViews[index].alpha = CGFloat(reps[index]) * 0.2
                    sparkViews[index].backgroundColor = tintColor
                }
            }
        }
    }
    
    var sparkViews = [UIView]()

    override init() {
        super.init(frame: CGRect())
        nameLabel.font = font
        weightLabel.font = font
        nameLabel.textColor = lightTextColor
        weightLabel.textColor = lightTextColor
        addSubview(nameLabel)
        addSubview(weightLabel)
        
        for i in 1...5 {
            let sparkView = UIView()
            sparkView.frame = CGRectMake(0, CGFloat(i) * 4, 20, 3)
            sparkView.backgroundColor = lightTextColor
            sparkView.alpha = 0.2
            sparkViews.append(sparkView)
            addSubview(sparkView)
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.frame = CGRectMake(0, 0, frame.width / 2, 30)
        weightLabel.frame = CGRectMake(frame.width / 2, 0, frame.width / 2, 30)
        
        for view in sparkViews {
            view.frame.origin.x = frame.width - 60
        }
    }

}
