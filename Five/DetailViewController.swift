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
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: NSCoder())
    }
    
    var data = [CKRecord]()
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
    var name: Int!
    
    let transitionManger = TransitionManger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTabNames()
        createSegmentedControl()
        
        let date = data[0].objectForKey("startTime") as! NSDate
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
        
        weight = data[segmentedControl.selectedSegmentIndex].objectForKey("Weight") as! Int
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
        weightKeyboard.modalPresentationStyle = .Custom
        weightKeyboard.transitioningDelegate = transitionManger
        transitionManger.presentingController = weightKeyboard
        navigationController?.presentViewController(weightKeyboard, animated: true, completion: nil)
    }
    
    func setWeight(newWeight: Int) {
        let currentWeight = data[segmentedControl.selectedSegmentIndex].objectForKey("Weight") as! Int
        
        if weight != newWeight {
            weight = newWeight
        }
        
        if newWeight != currentWeight {
            modifyItem()
            data[segmentedControl.selectedSegmentIndex].setObject(newWeight, forKey: "Weight")
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
            let record = data[i]
            let int = record.objectForKey("Name") as! Int
            let string = exerciseName(rawValue: int)?.description()
            tabNames.append(string!)
        }
    }
    
    func tabTouched(sender: UISegmentedControl) {
        weight = data[segmentedControl.selectedSegmentIndex].objectForKey("Weight") as! Int
        tableView.reloadData()
    }
    
    func repsSegmentChanged(sender: UISegmentedControl) {
        let modifiedRecord = data[segmentedControl.selectedSegmentIndex]
        var reps:[Int] = data[segmentedControl.selectedSegmentIndex].objectForKey("Reps") as! Array
        reps[sender.tag] = sender.selectedSegmentIndex + 1
        data[segmentedControl.selectedSegmentIndex].setObject(reps, forKey: "Reps")
        
        if sender.tag < reps.count - 1 {
            let nextCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag + 1, inSection: 0)) as! RepsCell
            nextCell.segmentedControl.enabled = true
        }
        
        modifyItem()
    }
    
    func modifyItem() {
        let operation = CKModifyRecordsOperation(recordsToSave: [data[segmentedControl.selectedSegmentIndex]], recordIDsToDelete: nil)
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
        let reps:[Int] = data[segmentedControl.selectedSegmentIndex].objectForKey("Reps") as! Array
        return reps.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! RepsCell
        cell.backgroundColor = UIColor.clearColor()
        cell.segmentedControl.addTarget(self, action: "repsSegmentChanged:", forControlEvents: .ValueChanged)
        cell.segmentedControl.tag = indexPath.row
        let reps:[Int] = data[segmentedControl.selectedSegmentIndex].objectForKey("Reps") as! Array
        let cellReps = reps[indexPath.row]
        cell.segmentedControl.selectedSegmentIndex = cellReps - 1
        cell.selectedSegments = cellReps
        
        if indexPath.row != 0 {
            if cell.segmentedControl.selectedSegmentIndex == -1 {
                let previousCellReps = reps[indexPath.row - 1]
                if previousCellReps == 0 {
                    cell.segmentedControl.enabled = false
                }
            }
        }
        
        return cell
    }
}