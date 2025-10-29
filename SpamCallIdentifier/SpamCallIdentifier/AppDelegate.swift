//
//  AppDelegate.swift
//  SpamCallIdentifier
// 
//  Created by Digitral Pvt Ltd on 23/05/25.
//  Email: Digitral
//  Contact No: +91-
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController() // Replace with your VC
        window?.makeKeyAndVisible()
        return true
    }
}

