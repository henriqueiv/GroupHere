//
//  ClientViewController.swift
//  GroupHere
//
//  Created by Marcus Vinicius Kuquert on 11/05/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation
import Parse

class ClientViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var btnSwitchSpotting: UIButton!
    @IBOutlet weak var lblBeaconReport: UILabel!
    @IBOutlet weak var lblBeaconDetails: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var beaconRegion: CLBeaconRegion!
    var locationManager: CLLocationManager!
    var isSearchingForBeacons = false
    var lastFoundBeacon: CLBeacon! = CLBeacon()
    var nearbyActivitiesArray: NSMutableArray = []
    var lastProximity: CLProximity! = CLProximity.Unknown
    let uuid = NSUUID(UUIDString: "F34A1A1F-500F-48FB-AFAA-9584D641D7B1")
    let identifier = "br.com.henriquevalcanaia.GroupHere"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        lblBeaconDetails.hidden = true
        btnSwitchSpotting.layer.cornerRadius = 30.0
        
        tableView.delegate = self
        tableView.dataSource = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: identifier)
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
    }
    
    // MARK: IBAction method implementation
    @IBAction func switchSpotting(sender: AnyObject) {
        if !isSearchingForBeacons {
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoringForRegion(beaconRegion)
            locationManager.startUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Stop Spotting", forState: UIControlState.Normal)
            lblBeaconReport.text = "Spotting beacons..."
        }
        else {
            locationManager.stopMonitoringForRegion(beaconRegion)
            locationManager.stopRangingBeaconsInRegion(beaconRegion)
            locationManager.stopUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Start Spotting", forState: UIControlState.Normal)
            lblBeaconReport.text = "Not running"
            lblBeaconDetails.hidden = true
        }
        
        isSearchingForBeacons = !isSearchingForBeacons
    }
    
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        locationManager.requestStateForRegion(region)
    }
    
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        if state == CLRegionState.Inside {
            locationManager.startRangingBeaconsInRegion(beaconRegion)
        }
        else {
            locationManager.stopRangingBeaconsInRegion(beaconRegion)
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        lblBeaconReport.text = "Beacon in range"
        lblBeaconDetails.hidden = false
    }
    
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        lblBeaconReport.text = "No beacons in range"
        lblBeaconDetails.hidden = true
        
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        let foundBeacons = beacons
        if foundBeacons.count > 0 {
            let activity = Activity()
            let query = Activity.query()
            query?.includeKey("host")
            query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let array = objects{
                    for object in array{
                        if let activity = object as? Activity{
                            for beacon in foundBeacons{
                                if ((beacon as! CLBeacon).minor.integerValue == activity.minor){
                                    if(!self.nearbyActivitiesArray.containsObject(activity)){
                                        self.nearbyActivitiesArray.addObject(activity)
                                    }
                                }else{
                                    self.nearbyActivitiesArray.removeObject(activity)
                                }
                            }
                        }
                    }
                }
                self.tableView.reloadData()
            })
        }
    }
    
    //    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
    //        self.nearbyActivitiesArray.removeAllObjects()
    //        self.tableView.reloadData()
    //    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
        print(error)
    }
    
    
    //MARK - TAbleView DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyActivitiesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "activityCell")
        
        if let activity = nearbyActivitiesArray[indexPath.row] as? Activity{
            cell.textLabel?.text = activity.name
            let name: String = activity.host["name"]! as! String
            cell.detailTextLabel?.text = "Minor: \(activity.minor) Major: \(activity.major) Host: \(name)"
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if (nearbyActivitiesArray.count > 0){
            if let activity = nearbyActivitiesArray[indexPath.row] as? Activity{
                let query = Activity.query()!
                query.whereKey("host", equalTo: activity.host)
                query.whereKey("minor", equalTo: activity.minor)
                query.includeKey("users")
                query.getFirstObjectInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
                    if let act = object as? Activity{
                        var mutableArray: NSMutableArray = []
                        if (act.users.count > 0){
                            mutableArray = NSMutableArray(array: act.users)
                        }
                        if(!mutableArray.containsObject(PFUser.currentUser()!)){
                            mutableArray.addObject(PFUser.currentUser()!)
                            act.users = mutableArray
                            act.saveInBackground()
                        }
                    }
                })
                
                
                
                
                //                query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?,error: NSError?) -> Void in
                
                //                    let mutableArray = NSMutableArray(array: objects! as NSArray)
                
                //                    for object in objects!{
                //                        if let act = object as? Activity{
                //
                //                        }
                //                    }
                
                //                    if(!mutableArray.containsObject(PFUser.currentUser()!)){
                //                        mutableArray.addObject(PFUser.currentUser()!)
                //                    }
                //                })
                
            }
        }
    }
    
    
    
}

