//
//  AppDelegate.swift
//  Five
//
//  Created by Colin Dunn on 1/29/15.
//  Copyright (c) 2015 Colin Dunn. All rights reserved.
//

import UIKit

let tintColor = UIColor(red: 0/255, green: 126/255, blue: 229/255, alpha: 1)
let textColor = UIColor(red: 37/255, green: 40/255, blue: 43/255, alpha: 1)
let lightTextColor = UIColor(red: 123/255, green: 137/255, blue: 148/255, alpha: 1)

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

