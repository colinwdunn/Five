//
//  DetailViewController.swift
//  Five
//
//  Created by Colin Dunn on 1/29/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit
import CloudKit

class DetailViewController: UIViewController, weightKeyboardDelegate {
    
    let weightButton = UIButton()
    let increase = UIButton()
    let decrease = UIButton()
    
    var currentWeight:Int!
    var record:CKRecord!
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        weightButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        weightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        weightButton.addTarget(self, action: "presentWeightKeyboard", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(weightButton)
        
        currentWeight = record.objectForKey("Weight") as Int
        recordWeight(currentWeight)
        
        increase.setTitle("+5", forState: .Normal)
        increase.setTitleColor(tintColor, forState: .Normal)
        increase.addTarget(self, action: "changeWeight:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(increase)
        
        decrease.setTitle("-5", forState: .Normal)
        decrease.setTitleColor(tintColor, forState: .Normal)
        
        decrease.addTarget(self, action: "changeWeight:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(decrease)
    }
    
    override func viewDidLayoutSubviews() {
        weightButton.frame = CGRectMake(15, 100, 100, 30)
        increase.frame = CGRectMake(15, 200, 100, 30)
        decrease.frame = CGRectMake(115, 200, 100, 30)
    }
    
    func presentWeightKeyboard() {
        let weightKeyboard = WeightKeyboardViewController()
        weightKeyboard.weight = currentWeight
        weightKeyboard.delegate = self
        self.presentViewController(weightKeyboard, animated: true) { () -> Void in
        }
    }
    
    func recordWeight(weight: Int) {
        weightButton.setTitle("\(weight.description) / \(Float(weightPerSide(weight)).formatted)", forState: .Normal)
        
        if currentWeight != weight {
            currentWeight = weight
            record.setObject(weight, forKey: "Weight")
            modify()
        }
        
        println(weight)
    }
    
    func weightPerSide(weight: Int) -> Float {
        var weightPerSide = (Float(weight) - 45) / 2
        
        return weightPerSide
    }
    
    func changeWeight(sender: UIButton) {
        if sender.titleLabel == increase.titleLabel {
            self.currentWeight = self.currentWeight + 5
        } else {
            self.currentWeight = self.currentWeight - 5
        }
        
        recordWeight(currentWeight)
    }

    
    func modify() {
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = { saved, deleted, error in
            if error != nil {
                println("\(error?.localizedDescription)")
            }
        }
        db.addOperation(operation)
    }

}

extension Float {
    var formatted:String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.stringFromNumber(self)!
    }
}
