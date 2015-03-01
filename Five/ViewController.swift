//
//  ViewController.swift
//  Five
//
//  Created by Colin Dunn on 1/29/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit
import CloudKit

var exercises = [CKRecord]()
let db = CKContainer.defaultContainer().privateCloudDatabase

enum exerciseName:Int {
    case Squat, BenchPress, Row, OverheadPress, Deadlift
    func description() -> String {
        switch self {
        case .Squat:
            return "Squat"
        case .BenchPress:
            return "Bench Press"
        case Row:
            return "Row"
        case .OverheadPress:
            return "Overhead Press"
        case .Deadlift:
            return "Deadlift"
        default:
            return String(self.rawValue)
        }
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    let kCellIdentifier = "Cell"
    var days:[[CKRecord]] = [[CKRecord]]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override init() {
        super.init(nibName: nil, bundle: nil)
        tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(DayCell.self, forCellReuseIdentifier: kCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 160
        view.addSubview(tableView)
        
        navigationItem.title = "Five"
        navigationController?.navigationBar.tintColor = tintColor
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addItem"), animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        days = self.buildIndex(exercises)
        loadItems()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.frame
    }
    
    func loadItems() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Exercise", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        db.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                println(error.localizedDescription)
            }
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                exercises = results as! [CKRecord]
                self.days = self.buildIndex(exercises)
//                self.tableView.reloadData()
//                println("Days (\(self.days.count)): \(self.days)")
                println(exercises)
            }
        }
    }
    
    func addItem() {
        var lastTypeIsZero = false
        
        if !exercises.isEmpty {
            if exercises[0].objectForKey("Type") as! Int == 0 {
                lastTypeIsZero = true
            }
        }
        
        var startTime = NSDate()
        
        let typeZeroNames = [exerciseName.Squat.rawValue, exerciseName.BenchPress.rawValue, exerciseName.Row.rawValue]
        let typeOneNames = [exerciseName.Squat.rawValue, exerciseName.OverheadPress.rawValue, exerciseName.Deadlift.rawValue]
        
        for i in 1...3 {
            let record = CKRecord(recordType: "Exercise")
            record.setObject(startTime, forKey: "startTime")
            record.setObject(45 * i, forKey: "Weight")
            record.setObject(0, forKey: "Reps")
            
            if lastTypeIsZero {
                record.setObject(1, forKey: "Type")
                record.setObject(typeOneNames[i - 1], forKey: "Name")
                println("Created type 1")
            } else {
                record.setObject(0, forKey: "Type")
                record.setObject(typeZeroNames[i - 1], forKey: "Name")
                println("Creatd type 0")
            }
            
            db.saveRecord(record) { (record, error) -> Void in
                if error != nil {
                    println(error.localizedDescription)
                }
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    exercises.append(record)
                    self.buildIndex(exercises)
                    
                    let indexPath = NSIndexPath(forRow: self.days.count - 1, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            }
        }
        
        if !days.isEmpty {
            let detailViewController = DetailViewController()
            detailViewController.exercisesForDay = days[0]
            self.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    func removeItem(item: CKRecord) {
        db.deleteRecordWithID(item.recordID) { (record, error) -> Void in
            if error != nil {
                println(error.localizedDescription)
            }
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if let index = find(exercises, item) {
                    
                    for i in 1...3 {
                        exercises.removeAtIndex(index)
                        let indexPath = NSIndexPath(forRow: index, inSection: 0)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    }
                }
            }
        }
    }
    
    func buildIndex(records: [CKRecord]) -> [[CKRecord]] {
        var dates = [NSDate]()
        var result = [[CKRecord]]()
        
        for record in records {
            var date = record.objectForKey("startTime") as! NSDate
            
            if !contains(dates, date) {
                dates.append(date)
            }
        }
        
        for date in dates {
            var recordForDate = [CKRecord]()
            
            for (index, exercise) in enumerate(exercises) {
                let created = exercise.objectForKey("startTime") as! NSDate
                
                if date == created {
                    let record = exercises[index] as CKRecord
                    recordForDate.append(record)
                }
            }
            result.append(recordForDate)
        }
        
        return result
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! DayCell
        let data = days[indexPath.row]
        
        let date = data[0].creationDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        let dateString = dateFormatter.stringFromDate(date)
        cell.date.text = "\(dateString) (\(data.count))"
        
        cell.exerciseOne.text = exerciseName(rawValue: data[0].objectForKey("Name") as! Int)?.description()
        cell.exerciseTwo.text = exerciseName(rawValue: data[1].objectForKey("Name") as! Int)?.description()
        cell.exerciseThree.text = exerciseName(rawValue: data[2].objectForKey("Name") as! Int)?.description()
        
        cell.weightOne.text = (data[0].objectForKey("Weight") as! Int).description
        cell.weightTwo.text = (data[1].objectForKey("Weight") as! Int).description
        cell.weightThree.text = (data[2].objectForKey("Weight") as! Int).description
        
        return cell
    }
}


extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailViewController = DetailViewController()
        detailViewController.exercisesForDay = days[indexPath.row]
        navigationController?.pushViewController(detailViewController, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
//    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let item = exercises[indexPath.row]
        self.removeItem(item)
    }
}
