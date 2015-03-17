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
    var background = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)) as UIVisualEffectView
    var weight:Int!
    let picker = UIPickerView()
    var pickerData = [Int]()
    var lbsLabel = UILabel()
    let border = UIView()
    
    var delegate: weightKeyboardDelegate?
    
    override init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .Custom
        picker.delegate = self
        picker.dataSource = self
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for var index = 45; index <= 500; index += 5 {
            pickerData.append(index)
        }
        
        picker.selectRow((weight - 45) / 5, inComponent: 0, animated: false)
        
        view.addSubview(background)
        background.addSubview(picker)
        
        lbsLabel.textColor = textColor
        lbsLabel.text = "lbs"
        lbsLabel.font = UIFont.systemFontOfSize(20)
        background.addSubview(lbsLabel)
        
        setWeightPerSideLabel()
    }
    
    override func viewDidLayoutSubviews() {
        background.frame = CGRectMake(0, view.frame.height - picker.frame.height, view.frame.size.width, view.frame.size.height)
        picker.frame = CGRectMake(0, 0, view.frame.size.width, 180)
        lbsLabel.frame = CGRectMake(view.frame.width / 2 + 28, 76, view.frame.width / 2 + 50, 30)
    }
    
    override func viewWillDisappear(animated: Bool) {
        delegate?.setWeight?(weight)
    }
    
//    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
//        var pickerViewLabel = UILabel()
//        pickerViewLabel = UILabel(frame: CGRectMake(0, 0, picker.rowSizeForComponent(component).width, picker.rowSizeForComponent(component).height))
//        pickerViewLabel.textAlignment = NSTextAlignment.Center
//        pickerViewLabel.text = pickerData[row].description
//        pickerViewLabel.font = UIFont(name: "SanFranciscoText-Medium", size: 18)
//        return pickerViewLabel
//    }
    
//    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        return NSAttributedString(string: pickerData[row].description, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
//    }
    
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
    }

}
