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
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.configParse(launchOptions)
        //        let uuid = NSUUID().UUIDString
        
        println(Activity.parseClassName())
        
        
        return true
    }
    
    func configParse(launchOptions: [NSObject: AnyObject]?){
        Parse.enableLocalDatastore()
        Activity.registerSubclass()
        Parse.setApplicationId(kParseApplicationID, clientKey: kParseClienteKey)
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
    }
    
    
    
    
}

