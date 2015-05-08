//
//  homeViewController.swift
//  GroupHere
//
//  Created by Paulo Ricardo Ramos da Rosa on 5/8/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

import UIKit

class homeViewController: UIViewController {

    @IBOutlet weak var level2Button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
    }

    func enableLevel2(){
        level2Button.enabled = true
    }

}
