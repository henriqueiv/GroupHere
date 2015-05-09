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

class LoginViewController: UIViewController {

    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    @IBAction func login(sender: AnyObject) {
        if !SVProgressHUD.isVisible(){
            SVProgressHUD.showWithStatus("Logando", maskType: .Gradient)
        }
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
        
    }

}
