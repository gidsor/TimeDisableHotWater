//
//  AppDelegate.swift
//  TimeDisableHotWater
//
//  Created by Vadim Denisov on 03.09.2020.
//  Copyright © 2020 Vadim Denisov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let scheduleViewController = ScheduleViewController()
        window?.rootViewController = UINavigationController(rootViewController: scheduleViewController)
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
    
}

