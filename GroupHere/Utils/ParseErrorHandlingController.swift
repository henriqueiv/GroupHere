////
////  ParseErrorHandlingController.swift
////  GroupHere
////
////  Created by Henrique Valcanaia on 5/7/15.
////  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
////
//
//import UIKit
//import Parse
//
//class ParseErrorHandlingController : NSObject {
//    class func handleParseError(error: NSError) {
//        if error.domain != PFParseErrorDomain {
//            return
//        }
//        
//        switch (error.code) {
//        case kPFErrorInvalidSessionToken:
//            handleInvalidSessionTokenError()
//            
//        default:
//            NSLog("%@", error)
//            
//        }
//        
//        func handleInvalidSessionTokenError() {
//            NSLog("erro maluco la")
//            //--------------------------------------
//            // Option 1: Show a message asking the user to log out and log back in.
//            //--------------------------------------
//            // If the user needs to finish what they were doing, they have the opportunity to do so.
//            //
//            // let alertView = UIAlertView(
//            //   title: "Invalid Session",
//            //   message: "Session is no longer valid, please log out and log in again.",
//            //   delegate: nil,
//            //   cancelButtonTitle: "Not Now",
//            //   otherButtonTitles: "OK"
//            // )
//            // alertView.show()
//            
//            //--------------------------------------
//            // Option #2: Show login screen so user can re-authenticate.
//            //--------------------------------------
//            // You may want this if the logout button is inaccessible in the UI.
//            //
//            // let presentingViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
//            // let logInViewController = PFLogInViewController()
//            // presentingViewController?.presentViewController(logInViewController, animated: true, completion: nil)
//        }
//    }
//}