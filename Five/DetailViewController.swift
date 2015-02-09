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
    
    var exercisesForDay = [CKRecord]()
    var exercisesForName = [[CKRecord]]()
    var tabNames = [String]()
    var segmentedControl:UISegmentedControl!
    let separator = UIView()
    var weight:Int!
    let weightButton = UIButton()
    let weightPerSideLabel = UILabel()
    
    var increaseWeight:RoundedButton!
    var decreaseWeight:RoundedButton!
    
    let kCellIdentifier = "RepsCell"
    
    var tableView: UITableView!
    
    var startTime: NSDate!
    var type: Int!
    var sets:Int = 1
    var reps: Int!
    var name: Int!
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = exercisesForDay[0].creationDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        
        navigationItem.title = dateFormatter.stringFromDate(date)
        
        view.backgroundColor = UIColor.whiteColor()
        
        tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView.registerClass(RepsCell.self, forCellReuseIdentifier: kCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.rowHeight = 60
        tableView.allowsSelection = false
        tableView.scrollEnabled = false
        
        view.addSubview(tableView)
        
        for i in 0...5 {
            let x = CGFloat(i) * (view.frame.width - 41)/5 + 20
            let gridLine = UIView(frame: CGRectMake(x, 80, 1, 310))
            gridLine.backgroundColor = colorWithAlpha(lightTextColor, 0.25)
            view.addSubview(gridLine)
        }
        
        weightButton.setTitleColor(tintColor, forState: .Normal)
        weightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        weightButton.setTitleColor(colorWithAlpha(tintColor, 0.5), forState: .Highlighted)
        weightButton.addTarget(self, action: "presentWeightKeyboard", forControlEvents: .TouchUpInside)
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
        
        segmentedControl.setTitleTextAttributes(normal, forState: .Normal)
        segmentedControl.setTitleTextAttributes(highlighted, forState: .Highlighted)
        segmentedControl.setTitleTextAttributes(selected, forState: .Selected)
        segmentedControl.addTarget(self, action: "tabTouched:", forControlEvents: .ValueChanged)

        view.addSubview(segmentedControl)
        
        separator.backgroundColor = colorWithAlpha(lightTextColor, 0.25)
        view.addSubview(separator)
        
        increaseWeight = RoundedButton(color: tintColor, title: "+5")
        increaseWeight.addTarget(self, action: "changeWeight:", forControlEvents: .TouchUpInside)
        view.addSubview(increaseWeight)
        
        decreaseWeight = RoundedButton(color: accentColor, title: "-5")
        decreaseWeight.addTarget(self, action: "changeWeight:", forControlEvents: .TouchUpInside)
        view.addSubview(decreaseWeight)
        
        println("Exercises: \(exercisesForDay)")
    }
    
    override func viewWillAppear(animated: Bool) {
        exercisesForName = buildIndex(exercisesForDay)
        //        println("Exercises for Day \(exercisesForDay.count): \(exercisesForDay)")
        weight = exercisesForDay[segmentedControl.selectedSegmentIndex].objectForKey("Weight") as Int
        type = exercisesForDay[segmentedControl.selectedSegmentIndex].objectForKey("Type") as Int
        updateSelectedValues()
        
        if type == 0 {
            exercisesForDay[0].setObject(exerciseName.Squat.rawValue, forKey: "Name")
            exercisesForDay[1].setObject(exerciseName.BenchPress.rawValue, forKey: "Name")
            exercisesForDay[2].setObject(exerciseName.Row.rawValue, forKey: "Name")
        } else {
            exercisesForDay[0].setObject(exerciseName.Squat.rawValue, forKey: "Name")
            exercisesForDay[1].setObject(exerciseName.OverheadPress.rawValue, forKey: "Name")
            exercisesForDay[2].setObject(exerciseName.Deadlift.rawValue, forKey: "Name")
        }
        
        modify()
        setWeight(weight)
    }
    
    override func viewDidLayoutSubviews() {
        weightButton.frame = CGRectMake(20, view.frame.height - segmentedControl.frame.height - 70, view.frame.width, 20)
        weightPerSideLabel.frame = CGRectMake(20, weightButton.frame.origin.y + 25, view.frame.width, 20)
        increaseWeight.frame = CGRectMake(view.frame.width - 64, view.frame.height - segmentedControl.frame.height - 64, 44, 44)
        decreaseWeight.frame = CGRectMake(view.frame.width - 118, view.frame.height - segmentedControl.frame.height - 64, 44, 44)
        segmentedControl.frame = CGRectMake(0, view.frame.height - 60, view.frame.width, 60)
        separator.frame = CGRectMake(20, view.frame.height - segmentedControl.frame.height - 1, view.frame.width - 40, 1)
        tableView.frame = CGRectMake(20, 25, view.frame.width - 40, tableView.rowHeight * 6)
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
            exercisesForDay[segmentedControl.selectedSegmentIndex].setObject(weight, forKey: "Weight")
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
            let name = exerciseName(rawValue: exercisesForDay[i].objectForKey("Name") as Int)?.description()
            tabNames.append(name!)
        }
    }
    
    func tabTouched(sender: UISegmentedControl) {
        println("Tab \(sender.selectedSegmentIndex) touched")
        weight = exercisesForDay[segmentedControl.selectedSegmentIndex].objectForKey("Weight") as Int
        setWeight(weight)
        updateSelectedValues()
    }
    
    func modify() {
        for i in 0...2 {
            let operation = CKModifyRecordsOperation(recordsToSave: [exercisesForDay[i]], recordIDsToDelete: nil)
            operation.modifyRecordsCompletionBlock = { saved, deleted, error in
                if error != nil {
                    println("Modify Error: \(error?.localizedDescription)")
                }
            }
            db.addOperation(operation)
        }
    }
    
    func repsSegmentChanged(sender: UISegmentedControl) {
        println("Row: \(sender.tag), Index: \(sender.selectedSegmentIndex)")
        println("Sets \(sets)")
        println("Current exercise: \(exercisesForName[segmentedControl.selectedSegmentIndex])")
        
        let selectedExerciseGroup = exercisesForName[segmentedControl.selectedSegmentIndex]
        let modifiedExercise = selectedExerciseGroup[sender.tag]
        modifiedExercise.setObject(sender.selectedSegmentIndex + 1, forKey: "Reps")
        
        modify()
        addItem()
        
        if sets < 5 && sender.tag == sets - 1 {
            sets += 1
            let indexPath = NSIndexPath(forRow: self.sets - 1, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        updateSelectedValues()
    }
    
    func updateSelectedValues() {
        println("Exercise for Name \(exercisesForName.count): \(exercisesForName)")
        let selected = exercisesForName[segmentedControl.selectedSegmentIndex]
        startTime = selected[0].objectForKey("startTime") as NSDate
        name = selected[0].objectForKey("Name") as Int
        weight = selected[0].objectForKey("Weight") as Int
        type = selected[0].objectForKey("Type") as Int
        
        println("Selected: \(exerciseName(rawValue: name)?.description()), \(weight) lbs")
    }
    
    func addItem() {
        let record = CKRecord(recordType: "Exercise")
        record.setObject(startTime, forKey: "startTime")
        record.setObject(name, forKey: "Name")
        record.setObject(weight, forKey: "Weight")
        record.setObject(type, forKey: "Type")
        
        db.saveRecord(record) { (record, error) -> Void in
            if error != nil {
                println(error.localizedDescription)
            }
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.exercisesForName[self.segmentedControl.selectedSegmentIndex].append(record)
            }
        }
    }
    
    func buildIndex(records: [CKRecord]) -> [[CKRecord]] {
        var names = [Int]()
        var result = [[CKRecord]]()
        
        for record in records {
            var name = record.objectForKey("Name") as Int
            
            if !contains(names, name) {
                names.append(name)
            }
            
            println("Types (\(names.count)): \(names)")
        }
        
        for name in names {
            var recordForName = [CKRecord]()
            
            for (index, exercise) in enumerate(exercisesForDay) {
                let existingName = exercise.objectForKey("Name") as Int
                
                if name == existingName {
                    let record = exercisesForDay[index] as CKRecord
                    recordForName.append(record)
                }
            }
            result.append(recordForName)
            
            println("Result \(result.count): \(result)")
        }
        
        return result
    }
}

extension DetailViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as RepsCell
        cell.segmentedControl.addTarget(self, action: "repsSegmentChanged:", forControlEvents: .ValueChanged)
        cell.segmentedControl.tag = indexPath.row
        return cell
    }
}

extension DetailViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}