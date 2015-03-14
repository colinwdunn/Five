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
    var days:[[CKRecord]] = [[CKRecord]]()
    
    override init() {
        super.init(nibName: nil, bundle: nil)
        tableView = UITableView(frame: CGRectZero, style: .Plain)

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
        loadItems()

        let selection = tableView.indexPathForSelectedRow()
        if (selection != nil) {
            tableView.deselectRowAtIndexPath(selection!, animated: true)
        }
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
                self.days = self.uniqueDays(exercises)
                self.tableView.reloadData()
            }
        }
    }
    
    func addItem() {
        var lastTypeIsZero = false
        
        if !days.isEmpty {
            if days[0][0].objectForKey("Type") as! Int == 0 {
                lastTypeIsZero = true   
            }
        }
        
        var startTime = NSDate()
        
        let typeZeroNames = [exerciseName.Squat.rawValue, exerciseName.BenchPress.rawValue, exerciseName.Row.rawValue]
        let typeOneNames = [exerciseName.Squat.rawValue, exerciseName.OverheadPress.rawValue, exerciseName.Deadlift.rawValue]
        var day = [CKRecord]()
        
        for i in 1...3 {
            for set in 1...5 {
                let record = CKRecord(recordType: "Exercise")
                record.setObject(startTime, forKey: "startTime")
                record.setObject(45, forKey: "Weight")
                record.setObject(0, forKey: "Reps")
                record.setObject(set, forKey: "Set")
                
                if lastTypeIsZero {
                    record.setObject(1, forKey: "Type")
                    record.setObject(typeOneNames[i - 1], forKey: "Name")
                } else {
                    record.setObject(0, forKey: "Type")
                    record.setObject(typeZeroNames[i - 1], forKey: "Name")
                }
                
                exercises.insert(record, atIndex: 0)
                day.append(record)
                
                db.saveRecord(record) { (record, error) -> Void in
                    if error != nil {
                        println(error.localizedDescription)
                    }
                }
            }
        }
        
        days.insert(day, atIndex: 0)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    func removeItems(items: [CKRecord], indexPath: NSIndexPath) {
        for item in items {
            db.deleteRecordWithID(item.recordID) { (record, error) -> Void in
                if error != nil {
                    println(error.localizedDescription)
                }
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    if let index = find(exercises, item) {
                        exercises.removeAtIndex(index)
                    }
                }
            }
        }
        
        days.removeAtIndex(indexPath.row)
        tableView.cellForRowAtIndexPath(indexPath)?.setEditing(false, animated: false)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        println(days)
    }
    
    func uniqueDays(records: [CKRecord]) -> [[CKRecord]] {
        var days = [NSDate: [CKRecord]]()
        
        for record in records {
            if (days[record.objectForKey("startTime") as! NSDate] == nil) {
                days[record.objectForKey("startTime") as! NSDate] = []
            }
            
            days[record.objectForKey("startTime") as! NSDate]!.append(record)
        }
        
        return sorted(days.keys) { (a: NSDate, b: NSDate) in
            a.compare(b) == .OrderedDescending
            }

            .map { sorted(days[$0]!) { $0.objectForKey("Name") as! Int! < $1.objectForKey("Name") as! Int! } }
    }
    
    func uniqueNames(records: [CKRecord]) -> [[CKRecord]] {
        var names = [Int]()
        var result = [[CKRecord]]()
        
        for record in records {
            var name = record.objectForKey("Name") as! Int
            
            if !contains(names, name) {
                names.append(name)
            }
        }
        
        for name in names {
            var recordForName = [CKRecord]()
            
            for (index, exercise) in enumerate(records) {
                let existingName = exercise.objectForKey("Name") as! Int
                
                if name == existingName {
                    let record = records[index] as CKRecord
                    recordForName.append(record)
                }
            }
            recordForName.sort { $0.objectForKey("Set") as! Int! < $1.objectForKey("Set") as! Int! }
            result.append(recordForName)
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
        let data = uniqueNames(days[indexPath.row])
        
        let date = data[0][0].objectForKey("startTime") as! NSDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        cell.date.text = dateFormatter.stringFromDate(date)
        
        for (index, row) in enumerate(cell.rows) {
            row.name = data[index][0].objectForKey("Name") as! Int
            row.weight = data[index][0].objectForKey("Weight") as! Int
            row.reps = []
            
            for record in data[index] {
                let rep = record.objectForKey("Reps") as! Int
                row.reps.append(rep)
            }
        }
        return cell
    }
}


extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var data = uniqueNames(days[indexPath.row])
        
        let detailViewController = DetailViewController()
        detailViewController.data = data
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let items = days[indexPath.row]
        self.removeItems(items, indexPath: indexPath)
    }
}
