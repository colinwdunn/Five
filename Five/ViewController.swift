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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    let kCellIdentifier = "Cell"
    
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
        
        tableView.registerClass(TableCell.self, forCellReuseIdentifier: kCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addItem"), animated: true)
        
        loadItems()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
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
                exercises = results as [CKRecord]
                self.tableView.reloadData()
                println("Exercises: \(exercises)")
            }
        }
    }
    
    func addItem() {
        var records = [CKRecord]()
        
        var lastTypeIsZero = false
        if exercises.isEmpty {
        } else {
            if exercises[0].objectForKey("Type") as Int == 0 {
                lastTypeIsZero = true
            }
        }
        
        for i in 1...3 {
            let record = CKRecord(recordType: "Exercise")
            record.setObject(45, forKey: "Weight")
            
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
                    records.insert(record, atIndex: 0)
                    exercises.insert(record, atIndex: 0)
                    let indexPath = NSIndexPath(forRow: exercises.count - 1, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            }
        }
        
        if exercises.isEmpty {
            println("Exercises is empty")
        } else {
            let detailViewController = DetailViewController()
            detailViewController.record = exercises[0]
            println("Records: \(records)")
            detailViewController.records = records
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
                    exercises.removeAtIndex(index)
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as TableCell
        let data = exercises[indexPath.row]
        
        let date = data.creationDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d h:m:s a"
        let dateString = dateFormatter.stringFromDate(date)
        
        cell.title.text = dateString
        
        let weight:Int = data.objectForKey("Weight") as Int
        cell.subTitle.text = weight.description
        
        return cell
    }
}


extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailViewController = DetailViewController()
        detailViewController.record = exercises[indexPath.row]
        navigationController?.pushViewController(detailViewController, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let item = exercises[indexPath.row]
        self.removeItem(item)
    }
}
