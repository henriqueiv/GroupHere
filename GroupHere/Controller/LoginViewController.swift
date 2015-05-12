//
//  LoginViewController.swift
//  GroupHere
//
//  Created by Henrique Valcanaia on 5/9/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD

let kKeyUserDefaultsDeviceToken = "deviceToken"

class LoginViewController: UIViewController {
    
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (PFUser.currentUser() != nil){
            self.gotoApp()
            NSLog("Usuario logaod: %@", PFUser.currentUser()!)
        }else{
            NSLog("Nenhum usuario logado")
        }
    }
    @IBAction func login(sender: AnyObject) {
        SVProgressHUD.showWithStatus("Logando", maskType: .Gradient)
        PFUser.logInWithUsernameInBackground(self.tfUsername.text, password:self.tfPassword.text) {
            (user: PFUser?, error: NSError?) -> Void in
            SVProgressHUD.dismiss()
            if user != nil {
                SVProgressHUD.showSuccessWithStatus("Logado com sucesso", maskType: .Gradient)
                self.gotoApp()
            } else {
                SVProgressHUD.showErrorWithStatus(error?.description, maskType: .Gradient)
            }
        }
    }
    
    func gotoApp(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func updateUserDeviceToken(){
        if let deviceToken = NSUserDefaults.standardUserDefaults().stringForKey(kKeyUserDefaultsDeviceToken){
            PFUser.currentUser()?.setValue(deviceToken, forKey: "deviceToken")
            PFUser.currentUser()?.saveInBackground()
        }
    }
    
    @IBAction func touchDownView(sender: AnyObject) {
        self.view.endEditing(true)
    }
}
