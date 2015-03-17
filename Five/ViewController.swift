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
    var data:[[CKRecord]] = [[CKRecord]]()
    
    override init() {
        super.init(nibName: nil, bundle: nil)
        tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView.backgroundColor = UIColor.clearColor()
        view.backgroundColor = bgColor
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
                self.data = self.buildIndex(exercises)
                self.tableView.reloadData()
            }
        }
    }
    
    func addItem() {
        var lastTypeIsZero = false
        
        if !data.isEmpty {
            if data[0][0].objectForKey("Type") as! Int == 0 {
                lastTypeIsZero = true   
            }
        }
        
        var startTime = NSDate()
        let typeZeroNames = [exerciseName.Squat.rawValue, exerciseName.BenchPress.rawValue, exerciseName.Row.rawValue]
        let typeOneNames = [exerciseName.Squat.rawValue, exerciseName.OverheadPress.rawValue, exerciseName.Deadlift.rawValue]
        var day = [CKRecord]()
        
        for i in 1...3 {
            let record = CKRecord(recordType: "Exercise")
            record.setObject(startTime, forKey: "startTime")
            record.setObject([0,0,0,0,0], forKey: "Reps")
            
            if lastTypeIsZero {
                record.setObject(1, forKey: "Type")
                record.setObject(typeOneNames[i - 1], forKey: "Name")
            } else {
                record.setObject(0, forKey: "Type")
                record.setObject(typeZeroNames[i - 1], forKey: "Name")
            }
            
            let exercisesForName = exercises.filter { ($0.objectForKey("Name") as! Int) == record.objectForKey("Name") as! Int }
            if !exercisesForName.isEmpty {
                let previousWeight = exercisesForName[0].objectForKey("Weight") as! Int
                record.setObject(previousWeight, forKey: "Weight")
            } else {
                record.setObject(45, forKey: "Weight")
            }
            
            exercises.insert(record, atIndex: 0)
            day.append(record)
            
            db.saveRecord(record) { (record, error) -> Void in
                if error != nil {
                    println(error.localizedDescription)
                }
            }
        }
        
        data.insert(day, atIndex: 0)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
        
        let detailViewController = DetailViewController()
        detailViewController.data = data[0]
        
        navigationController?.pushViewController(detailViewController, animated: true)
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
        
        data.removeAtIndex(indexPath.row)
        tableView.cellForRowAtIndexPath(indexPath)?.setEditing(false, animated: false)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func buildIndex(records: [CKRecord]) -> [[CKRecord]] {
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
    
    func previousWeightForName(record: CKRecord) -> Int? {
        let exercisesForName = exercises.filter { ($0.objectForKey("Name") as! Int) == record.objectForKey("Name") as? Int }
        
        if let referenceIndex = find(exercisesForName, record) {
            if referenceIndex + 1 < exercisesForName.count {
                return exercisesForName[referenceIndex + 1].objectForKey("Weight") as? Int
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! DayCell
        cell.backgroundColor = UIColor.clearColor()
        
        let highlightView = UIView()
        highlightView.backgroundColor = highlightColor
        cell.selectedBackgroundView = highlightView
        
        let date = data[indexPath.row][0].objectForKey("startTime") as! NSDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        cell.date.text = dateFormatter.stringFromDate(date)
        
        for (index, row) in enumerate(cell.rows) {
            row.name = data[indexPath.row][index].objectForKey("Name") as! Int
            row.weight = data[indexPath.row][index].objectForKey("Weight") as! Int
            row.reps = data[indexPath.row][index].objectForKey("Reps") as! Array
            
            if let previousWeight = previousWeightForName(data[indexPath.row][index]) {
                if row.weight > previousWeight {
                    row.indicatorValue = 1
                } else if row.weight < previousWeight {
                    row.indicatorValue = -1
                } else if row.weight == previousWeight {
                    row.indicatorValue = 0
                }
            }
        }

        return cell
    }
}


extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailViewController = DetailViewController()
        detailViewController.data = data[indexPath.row]
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let items = data[indexPath.row]
        self.removeItems(items, indexPath: indexPath)
    }
}
