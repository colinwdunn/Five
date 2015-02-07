//
//  ExerciseViewController.swift
//  Five
//
//  Created by Colin Dunn on 2/1/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit
import CloudKit

class ExerciseViewController: UIViewController, weightKeyboardDelegate {
    
    let kCellIdentifier = "Cell"
    
    var collectionView:UICollectionView!
    var collectionData = [String]()
    
    let weightButton = UIButton()
    let increase = UIButton()
    let decrease = UIButton()
    
    var currentWeight:Int!
    var record:CKRecord!
    
    var exercises:[CKRecord]!
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 70, height: 70)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 1.0
        
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.registerClass(RepsCell.self, forCellWithReuseIdentifier: kCellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clearColor()
        //        self.view.addSubview(collectionView)
        
        collectionData = ["foo", "bar", "baz", "four", "five", "foo", "bar", "baz", "four", "five"]
        
        println("Exercises: \(exercises)")
    }
    
    override func viewDidLayoutSubviews() {
        weightButton.frame = CGRectMake(15, 80, 100, 30)
        increase.frame = CGRectMake(115, 80, 50, 30)
        decrease.frame = CGRectMake(165, 80, 50, 30)
        
        collectionView.frame = self.view.frame
        collectionView.frame.origin.y = 80
    }
    func presentWeightKeyboard() {
        let weightKeyboard = WeightKeyboardViewController()
        weightKeyboard.weight = currentWeight
        weightKeyboard.delegate = self
        self.presentViewController(weightKeyboard, animated: true) { () -> Void in
        }
    }
    
    func recordWeight(weight: Int) {
        weightButton.setTitle("(weight.description) / \(Float(weightPerSide(weight)).formatted)", forState: .Normal)
        
        if currentWeight != weight {
            currentWeight = weight
            record.setObject(weight, forKey: "Weight")
            modify()
        }
    }
    
    func weightPerSide(weight: Int) -> Float {
        var weightPerSide = (Float(weight) - 45) / 2
        
        return weightPerSide
    }
    
    func changeWeight(sender: UIButton) {
        var changedWeight:Int!
        if sender.titleLabel == increase.titleLabel {
            changedWeight = self.currentWeight + 5
        } else {
            changedWeight = self.currentWeight - 5
        }
        
        recordWeight(changedWeight)
    }
    
    
    func modify() {
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = { saved, deleted, error in
            if error != nil {
                println("\(error?.localizedDescription)")
            }
        }
        db.addOperation(operation)
        println("Record modified")
    }
    
}

extension ExerciseViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellIdentifier, forIndexPath: indexPath) as RepsCell
        let data = collectionData[indexPath.item]
        // Add any data to the cell
        return cell as UICollectionViewCell
    }
}

extension ExerciseViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let data = collectionData[indexPath.item]
        // Do something like push or present a new view controller
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
