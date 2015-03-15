//
//  DetailViewController.swift
//  Five
//
//  Created by Colin Dunn on 1/29/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit
import CloudKit

class DetailViewController: UIViewController, weightKeyboardDelegate, UITableViewDelegate, UITableViewDataSource {
    let animator = MenuAnimator()
    var data = [[CKRecord]]()
    var tabNames = [String]()
    var segmentedControl:UISegmentedControl!
    let separator = UIView()
    var weight:Int! {
        didSet {
            setWeight(weight)
        }
    }
    let weightButton = UIButton()
    let weightPerSideLabel = UILabel()
    
    var increaseWeight:RoundedButton!
    var decreaseWeight:RoundedButton!
    
    let kCellIdentifier = "RepsCell"
    
    var tableView: UITableView!
    
    var startTime: NSDate!
    var type: Int!
    var reps: Int!
    var name: Int!
    
    override init() {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = animator
        modalPresentationStyle = .Custom
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTabNames()
        createSegmentedControl()
        
        let date = data[0][0].objectForKey("startTime") as! NSDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        
        navigationItem.title = dateFormatter.stringFromDate(date)
        
        view.backgroundColor = bgColor
        
        tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView.registerClass(RepsCell.self, forCellReuseIdentifier: kCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.rowHeight = 60
        tableView.allowsSelection = false
        tableView.scrollEnabled = false
        tableView.backgroundColor = UIColor.clearColor()
        
        view.addSubview(tableView)
        
//        for i in 0...5 {
//            let x = CGFloat(i) * (view.frame.width - 41)/5 + 20
//            let gridLine = UIView(frame: CGRectMake(x, 80, 0.5, 310))
//            gridLine.backgroundColor = backgroundColor
//            view.addSubview(gridLine)
//        }
        
        weightButton.setTitleColor(tintColor, forState: .Normal)
        weightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        weightButton.setTitleColor(colorWithAlpha(tintColor, 0.5), forState: .Highlighted)
        weightButton.addTarget(self, action: "presentWeightKeyboard", forControlEvents: .TouchUpInside)
        view.addSubview(weightButton)
        weightPerSideLabel.textColor = lightTextColor
        view.addSubview(weightPerSideLabel)
        
        separator.backgroundColor = colorWithAlpha(lightTextColor, 0.25)
        view.addSubview(separator)
        
        increaseWeight = RoundedButton(color: tintColor, title: "")
        increaseWeight.addTarget(self, action: "changeWeight:", forControlEvents: .TouchUpInside)
        view.addSubview(increaseWeight)
        
        decreaseWeight = RoundedButton(color: accentColor, title: "")
        decreaseWeight.addTarget(self, action: "changeWeight:", forControlEvents: .TouchUpInside)
        view.addSubview(decreaseWeight)
        
        weight = data[segmentedControl.selectedSegmentIndex][0].objectForKey("Weight") as! Int
    }
    
    override func viewDidLayoutSubviews() {
        weightButton.frame = CGRectMake(20, view.frame.height - segmentedControl.frame.height - 70, view.frame.width, 20)
        weightPerSideLabel.frame = CGRectMake(20, weightButton.frame.origin.y + 25, view.frame.width, 20)
        increaseWeight.frame = CGRectMake(view.frame.width - 64, view.frame.height - segmentedControl.frame.height - 64, 44, 44)
        decreaseWeight.frame = CGRectMake(view.frame.width - 118, view.frame.height - segmentedControl.frame.height - 64, 44, 44)
        segmentedControl.frame = CGRectMake(0, view.frame.height - 60, view.frame.width, 60)
        separator.frame = CGRectMake(20, view.frame.height - segmentedControl.frame.height - 1, view.frame.width - 40, 1)
        tableView.frame = CGRectMake(20, 90, view.frame.width - 40, tableView.rowHeight * 6)
    }
    
    func createSegmentedControl() {
        segmentedControl = UISegmentedControl(items: tabNames)
        segmentedControl.tintColor = UIColor.clearColor()
        
        let fontAttributes = NSDictionary(object: UIFont.systemFontOfSize(16), forKey: NSFontAttributeName)
        let colorAttributes = NSDictionary(object: lightTextColor, forKey: NSForegroundColorAttributeName)
        let font = UIFont.systemFontOfSize(16)
        let normal = NSDictionary(objects: [font, lightTextColor], forKeys: [NSFontAttributeName, NSForegroundColorAttributeName])
        let highlighted = NSDictionary(objects: [font, colorWithAlpha(lightTextColor, 0.5)], forKeys: [NSFontAttributeName, NSForegroundColorAttributeName])
        let selected = NSDictionary(objects: [font, tintColor], forKeys: [NSFontAttributeName, NSForegroundColorAttributeName])
        
        segmentedControl.setTitleTextAttributes(normal as? [NSObject : AnyObject], forState: .Normal)
        segmentedControl.setTitleTextAttributes(highlighted as? [NSObject : AnyObject], forState: .Highlighted)
        segmentedControl.setTitleTextAttributes(selected as? [NSObject : AnyObject], forState: .Selected)
        segmentedControl.addTarget(self, action: "tabTouched:", forControlEvents: .ValueChanged)
        segmentedControl.selectedSegmentIndex = 0
        
        view.addSubview(segmentedControl)
    }
    
    func presentWeightKeyboard() {
        let weightKeyboard = WeightKeyboardViewController()
        weightKeyboard.weight = weight
        weightKeyboard.delegate = self
        self.presentViewController(weightKeyboard, animated: true) { () -> Void in
        }
    }
    
    func setWeight(newWeight: Int) {
        let currentWeight = data[segmentedControl.selectedSegmentIndex][0].objectForKey("Weight") as! Int
        
        if weight != newWeight {
            weight = newWeight
        }
        
        if newWeight != currentWeight {
            for (index, records) in enumerate(data[segmentedControl.selectedSegmentIndex]) {
                data[segmentedControl.selectedSegmentIndex][index].setObject(newWeight, forKey: "Weight")
                modifyItem(index)
            }
        }
        
        weightButton.setTitle("\(newWeight.description) lbs", forState: .Normal)
        let string = Float(weightPerSide(newWeight)).formatted
        
        if weightPerSide(weight) != 0 {
            weightPerSideLabel.text = String("\(string) lbs per side")
        } else {
            weightPerSideLabel.text = String("No added weight")
        }
    }
    
    func changeWeight(sender: UIButton) {
        var changedWeight:Int!
        if sender.titleLabel == increaseWeight.titleLabel {
            changedWeight = self.weight + 5
        } else {
            changedWeight = self.weight - 5
        }
        
        weight = changedWeight
    }
    
    func weightPerSide(weight: Int) -> Float {
        var weightPerSide = (Float(weight) - 45) / 2
        return weightPerSide
    }
    
    func setTabNames() {
        for i in 0...2 {
            let record = data[i][0]
            let int = record.objectForKey("Name") as! Int
            let string = exerciseName(rawValue: int)?.description()
            tabNames.append(string!)
        }
    }
    
    func tabTouched(sender: UISegmentedControl) {
        weight = data[segmentedControl.selectedSegmentIndex][0].objectForKey("Weight") as! Int
        tableView.reloadData()
    }
    
    func repsSegmentChanged(sender: UISegmentedControl) {
        let sets = data[segmentedControl.selectedSegmentIndex].count
        let set = data[segmentedControl.selectedSegmentIndex][sender.tag].objectForKey("Set") as! Int
        let modifiedRecord = data[segmentedControl.selectedSegmentIndex][sender.tag]
        modifiedRecord.setObject(sender.selectedSegmentIndex + 1, forKey: "Reps")
        modifyItem(sender.tag)
    }
    
    func modifyItem(index: Int) {
        let date = data[segmentedControl.selectedSegmentIndex][index].objectForKey("creationDate") as! NSDate
        let record = exercises.filter { ($0.objectForKey("creationDate") as! NSDate == date) }
        
        if index < data[segmentedControl.selectedSegmentIndex].count - 1 {
            let nextCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index + 1, inSection: 0)) as! RepsCell
            nextCell.segmentedControl.enabled = true
        }
        
        let operation = CKModifyRecordsOperation(recordsToSave: record, recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = { saved, deleted, error in
            if error != nil {
                println(error.localizedDescription)
            }
        }
        db.addOperation(operation)
    }
}

extension DetailViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[segmentedControl.selectedSegmentIndex].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! RepsCell
        cell.backgroundColor = UIColor.clearColor()
        cell.segmentedControl.addTarget(self, action: "repsSegmentChanged:", forControlEvents: .ValueChanged)
        cell.segmentedControl.tag = indexPath.row
        let cellReps = data[segmentedControl.selectedSegmentIndex][indexPath.row].objectForKey("Reps") as! Int
        cell.segmentedControl.selectedSegmentIndex = cellReps - 1
        cell.selectedSegments = cellReps
        
        if indexPath.row != 0 {
            if cell.segmentedControl.selectedSegmentIndex == -1 {
                let previousCellReps = data[segmentedControl.selectedSegmentIndex][indexPath.row - 1].objectForKey("Reps") as! Int
                if previousCellReps == 0 {
                    cell.segmentedControl.enabled = false
                }
            }
        }
        
        return cell
    }
}