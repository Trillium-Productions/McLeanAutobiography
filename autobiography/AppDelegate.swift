//
//  AppDelegate.swift
//  autobiography
//
//  Created by William Rosenbloom on 4/2/16.
//  Copyright © 2016 William Rosenbloom. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let GENERAL_TIMEOUT: NSTimeInterval = 60
    let CONFIRM_TIMEOUT: NSTimeInterval = 20
    
    var navigator: UINavigationController!
    var customWindow: CustomWindow?
    var window: UIWindow? {
        get {
            customWindow = customWindow ?? CustomWindow(appdelegate: self)
            return customWindow
        }
        set { }
    }
    var timer: NSTimer?
    
    func startIdleTimer() {
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(GENERAL_TIMEOUT, target: self, selector: "onTimeout", userInfo: nil, repeats: false)
    }
    
    func onTimeout() {
        // TODO: confirm the user isn't there
        navigator.popToRootViewControllerAnimated(false)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        timer?.invalidate()
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

