//
//  AppDelegate.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/17.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

import Haneke

class TestClass: DataConvertible, DataRepresentable {
    
    typealias Result = TestClass

    var number = 1
    var name = "Steven"
    
    static func convertFromData(data:NSData) -> Result?
    {
        return TestClass()
        
    }

    func asData() -> NSData!
    {
        let x = "xxxx"
        let mirror = Mirror(reflecting: x)
        print(mirror)
        
        return nil
    }
}

struct TestStruct {
    var num = 1
    var name = "Steven"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().disableInViewControllerClass(TUSessionViewController)
        IQKeyboardManager.sharedManager().disableToolbarInViewControllerClass(TUSessionViewController)
        
//        let cache = Cache<TestClass>(name: "github")
//
//        let cache = Shared.dataCache
        
//        let x = TestClass()
//        let mirror = Mirror(reflecting: x)
//        print(mirror)
        
//        let v = ["x", "x1", "x2"]
//        let dic = ["s": "b", "a": 9, "b": v]
//        let data = try? NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions.PrettyPrinted)
//        print(data)
//        
//        // data to array
//        // let data = NSData()
//        let dicOrArray = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
//        if let obj = dicOrArray as? NSDictionary {
//            print(obj)
//        }
//        
//        print(dicOrArray)
        
//        TUCache.shared.sessionItems[0]
        
//        let c = SSModel.ss_propertyItems(TestClass())
//        print(c)
//        
//        let s = SSModel.ss_propertyItems(TestStruct())
//        print(s)
//        
//        let b = SSModel.ss_propertyItems(TUSession())
//        print(b)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

