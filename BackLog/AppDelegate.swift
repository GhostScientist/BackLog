//
//  AppDelegate.swift
//  BackLog
//
//  Created by Dakota Kim on 3/4/18.
//  Copyright © 2018 theghost. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        do {
            _ = try Realm()
        } catch {
            print("error initializing realm, \(error)")
        }
        return true
    }
}

