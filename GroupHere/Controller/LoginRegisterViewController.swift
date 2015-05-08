//
//  LoginRegisterViewController.swift
//  GroupHere
//
//  Created by Henrique Valcanaia on 5/7/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD

class LoginRegisterViewController: UIViewController {
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var userPicture: UIImageView!
    
    let kPFErrorUsernameTaken = 202
    
    @IBAction func signUp(sender: AnyObject) {
        SVProgressHUD.showWithStatus("Signin up", maskType: .Gradient)
        let user = PFUser()
        user.username = tfUsername.text
        user.password = tfPassword.text
        user.setObject(tfName.text, forKey: "name")
        if let imageData = UIImagePNGRepresentation(self.userPicture.image){
            let pictureFile = PFFile(name: user.username! + "-picture.png", data: imageData)
            user.setObject(pictureFile, forKey: "picture")
        }
        
        user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if succeeded {
                //                self.performSegueWithIdentifier("gotoApp", sender: nil)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccessWithStatus("Usuário cadastrado com sucesso", maskType: .Gradient)
                    
                })
            }else{
                //                ParseErrorHandlingController.handleParseError(error!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                    if error!.code == self.kPFErrorUsernameTaken{
                        SVProgressHUD.showWithStatus("Usuário já cadastrado, realizando login...", maskType: .Gradient)
                        self.login(user)
                    }else{
                        SVProgressHUD.showErrorWithStatus(error?.description, maskType: .Gradient)
                    }
                    println(error)
                })
            }
        }
    }
    
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
    
    @IBAction func touchDownView(sender: AnyObject) {
        //self.dismissKeyboard()
    }
    
    func gotoApp(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
}
