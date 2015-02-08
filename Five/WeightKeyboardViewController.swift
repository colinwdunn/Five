//
//  WeightKeyboardViewController.swift
//  Five
//
//  Created by Colin Dunn on 1/29/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit

@objc protocol weightKeyboardDelegate {
    optional func setWeight(value: Int)
    optional func weightPerSide(weight: Int) -> Float
}

class WeightKeyboardViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let background = UIView()
    let cancel = UIButton()
    let topTitle = UILabel()
    let done = UIButton()
    let divider = UIView()
    let weightPerSideLabel = UILabel()
    var weight:Int!
    let picker = UIPickerView()
    var pickerData = [Int]()
    
    var delegate: weightKeyboardDelegate?
    
    override init() {
        super.init(nibName: nil, bundle: nil)
        picker.delegate = self
        picker.dataSource = self
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for var index = 45; index <= 250; index += 5 {
            pickerData.append(index)
        }
        
        println("Weight \(weight)")
        picker.selectRow((weight - 45) / 5, inComponent: 0, animated: false)
        
        background.backgroundColor = UIColor.whiteColor()
        view.addSubview(background)
        
        cancel.frame = CGRectMake(15, 0, 100, 45)
        cancel.setTitle("Cancel", forState: .Normal)
        cancel.setTitleColor(tintColor, forState: .Normal)
        cancel.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        cancel.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        background.addSubview(cancel)
        
        topTitle.text = "Select Weight"
        topTitle.textColor = textColor
        topTitle.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        topTitle.textAlignment = NSTextAlignment.Center
        background.addSubview(topTitle)
        
        done.setTitle("Done", forState: .Normal)
        done.setTitleColor(tintColor, forState: .Normal)
        done.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        done.addTarget(self, action: "doneTap", forControlEvents: .TouchUpInside)
        background.addSubview(done)
        
        divider.backgroundColor = textColor
        divider.alpha = 0.2
        background.addSubview(divider)
        
        background.addSubview(picker)
        
        weightPerSideLabel.textColor = lightTextColor
        weightPerSideLabel.textAlignment = .Right
        background.addSubview(weightPerSideLabel)
        
        setWeightPerSideLabel()
    }
    
    override func viewDidLayoutSubviews() {
        background.frame = CGRectMake(0, view.frame.size.height - 225, view.frame.size.width, view.frame.size.height)
        topTitle.frame = CGRectMake((view.frame.size.width - 200) / 2, -1, 200, 45)
        done.frame = CGRectMake(view.frame.size.width - 115, 0, 100, 45)
        divider.frame = CGRectMake(0, 45, view.frame.size.width, 1)
        picker.frame = CGRectMake(0, 45, view.frame.size.width, 180)
        weightPerSideLabel.frame = CGRectMake(self.view.frame.size.width / 2 - 150, 120, 100, 30)
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    func doneTap() {
        delegate?.setWeight?(weight)
        dismiss()
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row].description
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setWeightPerSideLabel()
        weight = pickerData[picker.selectedRowInComponent(0)]
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func setWeightPerSideLabel() {
        let weight = (pickerData[picker.selectedRowInComponent(0)].description).toInt()
        var weightPerSide = delegate?.weightPerSide!(weight!).formatted
        weightPerSideLabel.text = weightPerSide
    }

}
