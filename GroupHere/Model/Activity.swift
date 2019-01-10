//
//  Activity.swift
//  GroupHere
//
//  Created by Henrique Valcanaia on 5/7/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

import UIKit
import Parse

class Activity: PFObject, PFSubclassing {
    
    @NSManaged var name: String
    @NSManaged var location: PFGeoPoint
    @NSManaged var host: PFUser
    @NSManaged var minor: NSNumber
    @NSManaged var major: NSNumber
    @NSManaged var users: NSArray
    
    static func parseClassName() -> String {
        return "Activity";
    }
}
