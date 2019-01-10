//
//  Group.swift
//  GroupHere
//
//  Created by Henrique Valcanaia on 5/7/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

import UIKit
import Parse

class Group: PFObject, PFSubclassing {
    
    @NSManaged var activity: Activity
    @NSManaged var name: String
    
    static func parseClassName() -> String {
        return "Group"
    }
    
}
