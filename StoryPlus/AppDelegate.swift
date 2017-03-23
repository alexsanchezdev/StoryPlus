//
//  AppDelegate.swift
//  StoryPlus
//
//  Created by Alex Sanchez on 16/3/17.
//  Copyright © 2017 Alex Sanchez. All rights reserved.
//

import UIKit
import Firebase
import StoreKit
import CoreGraphics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        //window?.backgroundColor = UIColor.rgb(r: 250, g: 250, b: 250, a: 1)
        window?.makeKeyAndVisible()
        window?.rootViewController = MainController()
        
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor.rgb(r: 255, g: 45, b: 85, a: 1)
        navigationBarAppearance.barTintColor = UIColor.rgb(r: 250, g: 250, b: 250, a: 1)
        navigationBarAppearance.isTranslucent = false
        
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544~1458002511")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        clearTemporaryDirectory()
    }
    
    func clearTemporaryDirectory(){
        let manager = FileManager.default
        
        if let tmp = try? manager.contentsOfDirectory(at: manager.temporaryDirectory, includingPropertiesForKeys: nil, options: []) {
            do {
                for file in tmp {
                    try manager.removeItem(at: file)
                }
            } catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
        }
        
        clearDocumentDirectory()
        
    }
    
    func clearDocumentDirectory(){
        
        let manager = FileManager.default
        
        if let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let url = documentDirectory.appendingPathComponent("videos")
            
            do {
                try manager.removeItem(at: url)
                let tmp = try manager.contentsOfDirectory(at: manager.temporaryDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                for file in tmp {
                    try manager.removeItem(at: file)
                }
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
            
        }
        
    }


}

