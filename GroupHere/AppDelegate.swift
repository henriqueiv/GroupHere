//
//  AppDelegate.swift
//  GroupHere
//
//  Created by Henrique Valcanaia on 5/7/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let kParseApplicationID = "lqRqCuysIlPT580tKDJTnLjoYPQSNFbo728h1nlB"
    let kParseClienteKey = "BcJWH8nwOB9SPD317AKdZ8NUO4z8hfbpnkkIDrPP"
    
    var homeViewController: ViewController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.configParse(launchOptions)
        println(application)
        self.configNotifications(application)
        return true
    }
    
    func configParse(launchOptions: [NSObject: AnyObject]?){
        Parse.enableLocalDatastore()
        self.registerSubclasses()
        Parse.setApplicationId(kParseApplicationID, clientKey: kParseClienteKey)
        PFUser.enableRevocableSessionInBackground()
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
    }
    
    func registerSubclasses(){
        Activity.registerSubclass()
        Group.registerSubclass()
    }
    
    func configNotifications(application: UIApplication){
        let userNotificationTypes = (UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound)
        var settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        println("registrou")
        println(application)
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current installation and save it to Parse.
        var currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        println("salvanu")
        currentInstallation.save()
        println("salvou")
    }
    
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        PFPush.handlePush(userInfo)
//    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
    }
    
    
}

