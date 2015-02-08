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
    
    var exercises = [CKRecord]()
    var tabNames = [String]()
    var segmentedControl:UISegmentedControl!
    let separator = UIView()
    var weight:Int!
    let weightButton = UIButton()
    let weightPerSideLabel = UILabel()
    
    var increaseWeight:RoundedButton!
    var decreaseWeight:RoundedButton!
    
    let kCellIdentifier = "Cell"
    var collectionView:UICollectionView!
    var collectionData = [String]()
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = exercises[0].creationDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        
        navigationItem.title = dateFormatter.stringFromDate(date)
        
        view.backgroundColor = UIColor.whiteColor()
        
        let exerciseType = exercises[0].objectForKey("Type") as Int
        
        if exerciseType == 0 {
            exercises[0].setObject(exerciseName.Squat.rawValue, forKey: "Name")
            exercises[1].setObject(exerciseName.BenchPress.rawValue, forKey: "Name")
            exercises[2].setObject(exerciseName.Row.rawValue, forKey: "Name")
        } else {
            exercises[0].setObject(exerciseName.Squat.rawValue, forKey: "Name")
            exercises[1].setObject(exerciseName.OverheadPress.rawValue, forKey: "Name")
            exercises[2].setObject(exerciseName.Deadlift.rawValue, forKey: "Name")
        }
        
        modify()
        
        weightButton.setTitleColor(tintColor, forState: .Normal)
        weightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        weightButton.setTitleColor(colorWithAlpha(tintColor, 0.5), forState: .Highlighted)
        weightButton.addTarget(self, action: "presentWeightKeyboard", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(weightButton)
        weightPerSideLabel.textColor = lightTextColor
        view.addSubview(weightPerSideLabel)
        
        setTabNames()
        
        segmentedControl = UISegmentedControl(items: tabNames)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.clearColor()
        
        let fontAttributes = NSDictionary(object: UIFont.systemFontOfSize(16), forKey: NSFontAttributeName)
        let colorAttributes = NSDictionary(object: lightTextColor, forKey: NSForegroundColorAttributeName)
        let font = UIFont.systemFontOfSize(16)
        let normal = NSDictionary(objects: [font, lightTextColor], forKeys: [NSFontAttributeName, NSForegroundColorAttributeName])
        let highlighted = NSDictionary(objects: [font, colorWithAlpha(lightTextColor, 0.5)], forKeys: [NSFontAttributeName, NSForegroundColorAttributeName])
        let selected = NSDictionary(objects: [font, tintColor], forKeys: [NSFontAttributeName, NSForegroundColorAttributeName])
        
        segmentedControl.setTitleTextAttributes(normal, forState: UIControlState.Normal)
        segmentedControl.setTitleTextAttributes(highlighted, forState: UIControlState.Highlighted)
        segmentedControl.setTitleTextAttributes(selected, forState: UIControlState.Selected)
        segmentedControl.addTarget(self, action: "tabTouched:", forControlEvents: .ValueChanged)

        view.addSubview(segmentedControl)
        
        separator.backgroundColor = colorWithAlpha(lightTextColor, 0.25)
        view.addSubview(separator)
        
        increaseWeight = RoundedButton(color: tintColor, title: "+5")
        increaseWeight.addTarget(self, action: "changeWeight:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(increaseWeight)
        
        decreaseWeight = RoundedButton(color: accentColor, title: "-5")
        decreaseWeight.addTarget(self, action: "changeWeight:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(decreaseWeight)
        
        weight = exercises[segmentedControl.selectedSegmentIndex].objectForKey("Weight") as Int
        setWeight(weight)
        
        println("Exercises: \(exercises)")
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 106.0, height: 106.0)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 1.0
        
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.registerClass(CollectionCell.self, forCellWithReuseIdentifier: kCellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
        
        collectionData = ["foo", "bar", "baz"]
    }
    
    override func viewDidLayoutSubviews() {
        weightButton.frame = CGRectMake(20, view.frame.height - segmentedControl.frame.height - 70, view.frame.width, 20)
        weightPerSideLabel.frame = CGRectMake(20, weightButton.frame.origin.y + 25, view.frame.width, 20)
        increaseWeight.frame = CGRectMake(view.frame.width - 64, view.frame.height - segmentedControl.frame.height - 64, 44, 44)
        decreaseWeight.frame = CGRectMake(view.frame.width - 118, view.frame.height - segmentedControl.frame.height - 64, 44, 44)
        segmentedControl.frame = CGRectMake(0, view.frame.height - 60, view.frame.width, 60)
        separator.frame = CGRectMake(20, view.frame.height - segmentedControl.frame.height - 1, view.frame.width - 40, 1)
        collectionView.frame = self.view.frame
    }
    
    func presentWeightKeyboard() {
        let weightKeyboard = WeightKeyboardViewController()
        println("Weight: \(weight)")
        weightKeyboard.weight = weight
        weightKeyboard.delegate = self
        self.presentViewController(weightKeyboard, animated: true) { () -> Void in
        }
    }
    
    func setWeight(value: Int) {
        weightButton.setTitle(value.description, forState: .Normal)
        weightPerSideLabel.text = Float(weightPerSide(value)).formatted
        
        if weight != value {
            weight = value
            exercises[segmentedControl.selectedSegmentIndex].setObject(weight, forKey: "Weight")
            modify()
        }
    }
    
    func weightPerSide(weight: Int) -> Float {
        var weightPerSide = (Float(weight) - 45) / 2
        return weightPerSide
    }
    
    func changeWeight(sender: UIButton) {
        var changedWeight:Int!
        if sender.titleLabel == increaseWeight.titleLabel {
            changedWeight = self.weight + 5
        } else {
            changedWeight = self.weight - 5
        }
        
        setWeight(changedWeight)
    }
    
    func setTabNames() {
        for i in 0...2 {
            let name = exerciseName(rawValue: exercises[i].objectForKey("Name") as Int)?.description()
            tabNames.append(name!)
        }
    }
    
    func tabTouched(sender: UISegmentedControl) {
        println("Tab \(sender.selectedSegmentIndex) touched")
        weight = exercises[segmentedControl.selectedSegmentIndex].objectForKey("Weight") as Int
        setWeight(weight)
    }
    
    func modify() {
        for i in 0...2 {
            let operation = CKModifyRecordsOperation(recordsToSave: [exercises[i]], recordIDsToDelete: nil)
            operation.modifyRecordsCompletionBlock = { saved, deleted, error in
                if error != nil {
                    println("Modify Error: \(error?.localizedDescription)")
                }
            }
            db.addOperation(operation)
        }
    }
}

extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellIdentifier, forIndexPath: indexPath) as CollectionCell
        let data = collectionData[indexPath.item]
        // Add any data to the cell
        return cell as UICollectionViewCell
    }
}

extension CollectionViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let data = collectionData[indexPath.item]
        // Do something like push or present a new view controller
    }
}