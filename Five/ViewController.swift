//
//  ViewController.swift
//  Five
//
//  Created by Colin Dunn on 1/29/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit
import CloudKit

var records = [CKRecord]()
let db = CKContainer.defaultContainer().privateCloudDatabase

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    let kCellIdentifier = "Cell"
    var exercisesForDay:[[[CKRecord]]] = [[[CKRecord]]]() {
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
        exercisesByDay = self.buildIndex(records)
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
                records = results as [CKRecord]
                self.exercisesByDay = self.buildIndex(records)
//                self.tableView.reloadData()
                println("Days (\(self.exercisesForDay.count)): \(self.exercisesForDay)")
            }
        }
    }
    
    func addItem() {
        var lastTypeIsZero = false
        
        if !records.isEmpty {
            if records[0].objectForKey("Type") as Int == 0 {
                lastTypeIsZero = true
            }
        }
        
        var startTime = NSDate()
        
        for i in 1...3 {
            let record = CKRecord(recordType: "Exercise")
            record.setObject(startTime, forKey: "startTime")
            record.setObject(0, forKey: "Name")
            record.setObject(45 * i, forKey: "Weight")
            record.setObject(0, forKey: "Reps")
            
            if lastTypeIsZero {
                record.setObject(1, forKey: "Type")
                println("Created type 1")
            } else {
                record.setObject(0, forKey: "Type")
                println("Creatd type 0")
            }
            
            db.saveRecord(record) { (record, error) -> Void in
                if error != nil {
                    println(error.localizedDescription)
                }
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    records.append(record)
                    self.buildIndex(records)
                    
                    let indexPath = NSIndexPath(forRow: self.exercisesForDay.count - 1, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            }
        }
        
<<<<<<< HEAD
<<<<<<< HEAD
        if !exercisesForDay.isEmpty {
            let detailViewController = DetailViewController()
            detailViewController.exercisesForDay = exercisesByDay[0]
            self.navigationController?.pushViewController(detailViewController, animated: true)
        }
=======
        let detailViewController = DetailViewController()
        detailViewController.exercisesForDay = days[0]
        self.navigationController?.pushViewController(detailViewController, animated: true)
>>>>>>> parent of 20365e5... Moved type/name logic to view controller
=======
        let detailViewController = DetailViewController()
        detailViewController.exercisesForDay = days[0]
        self.navigationController?.pushViewController(detailViewController, animated: true)
>>>>>>> parent of 20365e5... Moved type/name logic to view controller
    }
    
    func removeItem(item: CKRecord) {
        db.deleteRecordWithID(item.recordID) { (record, error) -> Void in
            if error != nil {
                println(error.localizedDescription)
            }
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if let index = find(records, item) {
                    
                    for i in 1...3 {
                        records.removeAtIndex(index)
                        let indexPath = NSIndexPath(forRow: index, inSection: 0)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    }
                }
            }
        }
    }
    
    func buildIndex(records: [CKRecord]) -> [[[CKRecord]]] {
        var dates = [NSDate]()
        var result = [[[CKRecord]]]()
        
        for record in records {
            var date = record.objectForKey("startTime") as NSDate
            
            if !contains(dates, date) {
                dates.append(date)
            }
        }
        
        for date in dates {
            var recordForDate = [CKRecord]()
            
            for (index, exercise) in enumerate(records) {
                let created = exercise.objectForKey("startTime") as NSDate
                
                    for (index, name) in enumerate(dates)
                
                if date == created {
                    let record = records[index] as CKRecord
                    recordForDate.append(record)
                }
            }
            result.append(recordForDate)
        }
        
        for record in dates {
            
        }
        
        return result
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercisesForDay.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as DayCell
        let data = exercisesForDay[indexPath.row]
        
        let date = data[0].creationDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        let dateString = dateFormatter.stringFromDate(date)
        cell.date.text = dateString
        
        cell.exerciseOne.text = exerciseName(rawValue: data[0].objectForKey("Name") as Int)?.description()
        cell.exerciseTwo.text = exerciseName(rawValue: data[1].objectForKey("Name") as Int)?.description()
        cell.exerciseThree.text = exerciseName(rawValue: data[2].objectForKey("Name") as Int)?.description()
        
        cell.weightOne.text = (data[0].objectForKey("Weight") as Int).description
        cell.weightTwo.text = (data[1].objectForKey("Weight") as Int).description
        cell.weightThree.text = (data[2].objectForKey("Weight") as Int).description
        
        return cell
    }
}


extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailViewController = DetailViewController()
        detailViewController.exercisesForDay = exercisesByDay[indexPath.row]
        navigationController?.pushViewController(detailViewController, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let item = records[indexPath.row]
        self.removeItem(item)
    }
}
