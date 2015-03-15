//
//  AppDelegate.swift
//  Five
//
//  Created by Colin Dunn on 1/29/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit

let tintColor = UIColor(red: 81/255, green: 168/255, blue: 226/255, alpha: 1)
let accentColor = UIColor(red: 255/255, green: 92/255, blue: 51/255, alpha: 1)
let textColor = UIColor(red: 37/255, green: 40/255, blue: 43/255, alpha: 1)
let lightTextColor = UIColor(red: 123/255, green: 137/255, blue: 148/255, alpha: 1)
let bgColor = UIColor(red: 234/255, green: 236/255, blue: 241/255, alpha: 1)
let highlightColor = UIColor(red: 214/255, green: 218/255, blue: 227/255, alpha: 1)

func colorWithAlpha(color: UIColor, alpha: CGFloat) -> UIColor {
    let color = color
    var red:CGFloat!, blue:CGFloat!, green:CGFloat!
    let components = CGColorGetComponents(color.CGColor)
    red = components[0]
    green = components[1]
    blue = components[2]
    let colorWithAlpha = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    return colorWithAlpha
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        
        let navController = UINavigationController(rootViewController: ViewController())
        window?.rootViewController = navController
        
        window?.makeKeyAndVisible()
        return true
    }
}

extension Float {
    var formatted:String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.stringFromNumber(self)!
    }
}