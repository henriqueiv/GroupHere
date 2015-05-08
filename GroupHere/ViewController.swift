//
//  ViewController.swift
//  GroupHere
//
//  Created by Henrique Valcanaia on 5/7/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//
//HEY teste de push
import UIKit

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

}

