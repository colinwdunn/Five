//
//  TimerView.swift
//  Timer
//
//  Created by Colin Dunn on 3/15/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit

protocol timerViewDelegate {
    func timerStateChanged(state: Bool)
}

class TimerView: UIView {
    var delegate: timerViewDelegate?
    var color:UIColor = UIColor.blackColor() {
        didSet {
            timerLabel.textColor = color
        }
    }
    var foregroundLayer: CAShapeLayer!
    var backgroundLayer: CAShapeLayer!
    var foregroundPath: UIBezierPath!
    var backgroundPath: UIBezierPath!
    var size:CGFloat = 40
    var stroke:CGFloat = 4.0
    var font = UIFont(name: "HelveticaNeue-Light", size: 24)
    let startAngle = CGFloat(-M_PI_2)
    let endAngle = CGFloat((M_PI * 2.0) - M_PI_2)
    
    let timerLabel = UILabel()
    var timer:NSTimer = NSTimer()
    var timerIsRunning:Bool = false {
        didSet {
            if let delegate = self.delegate {
                delegate.timerStateChanged(timerIsRunning)
            }
        }
    }
    var time:Int! {
        didSet {
            countDown = time
            updateTime()
            timer.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTime", userInfo: nil, repeats: true)
            animateCircle(NSTimeInterval(time))
            timerIsRunning = true
        }
    }
    var countDown:Int!
    
    override init() {
        super.init()
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        timerLabel.font = font
        timerLabel.textAlignment = NSTextAlignment.Center
        timerLabel.textColor = color
        addSubview(timerLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timerLabel.frame = CGRectMake(0, 0, frame.width, frame.height)
        foregroundPath = UIBezierPath(arcCenter: CGPoint(x: frame.width / 2, y: frame.height / 2), radius: size, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        backgroundPath = UIBezierPath(arcCenter: CGPoint(x: frame.width / 2, y: frame.height / 2), radius: size, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        drawCircles()
    }
    
    func drawCircles() {
        foregroundLayer = CAShapeLayer()
        foregroundLayer.path = foregroundPath.CGPath
        foregroundLayer.fillColor = UIColor.clearColor().CGColor
        foregroundLayer.strokeColor = color.CGColor
        foregroundLayer.lineWidth = stroke;
        foregroundLayer.strokeEnd = 0.0
        
        backgroundLayer = CAShapeLayer()
        backgroundLayer.path = foregroundPath.CGPath
        backgroundLayer.fillColor = UIColor.clearColor().CGColor
        backgroundLayer.strokeColor = color.CGColor
        backgroundLayer.opacity = 0.1
        backgroundLayer.lineWidth = stroke;
        backgroundLayer.strokeEnd = 1.0;
        
        layer.addSublayer(foregroundLayer)
        layer.addSublayer(backgroundLayer)
    }
    
    func animateCircle(duration: NSTimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        foregroundLayer.strokeEnd = 1.0
        foregroundLayer.addAnimation(animation, forKey: "animateCircle")
    }

    func updateTime() {
        if countDown < 0 {
            timer.invalidate()
            timerIsRunning = false
        } else {
            timerLabel.text = countDown.description
            countDown = countDown - 1
        }
    }
}
