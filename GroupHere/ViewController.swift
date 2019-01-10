
//
//  ViewController.swift
//  GroupHere
//
//  Created by Henrique Valcanaia on 5/7/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//
//HEY teste de push
import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var level2Button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appdelegate = UIApplication.sharedApplication().delegate
            as! AppDelegate
        
        appdelegate.homeViewController = self
    }
    
    func enableLevel2(){
        level2Button.enabled = true
    }

    @IBAction func logout(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
            if error != nil{
               println("Erro: \(error)")
            }else{
                self.gotoLogin()
            }
        }
    }
    
    func gotoLogin(){
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
}

