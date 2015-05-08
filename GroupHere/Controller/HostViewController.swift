//
//  HostViewController.swift
//  GroupHere
//
//  Created by Marcus Vinicius Kuquert on 07/05/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//



//Codigo para o transmisso de iBeacon
import UIKit
import CoreLocation
import CoreBluetooth

class HostViewController: UIViewController, UITableViewDataSource, CBPeripheralManagerDelegate, CLLocationManagerDelegate {
    
    var peripheralManager: CBPeripheralManager?
    let locationManager = CLLocationManager()
    
    var beaconRegion = CLBeaconRegion()
    var beaconsFound: [CLBeacon] = [CLBeacon]()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    @IBAction func transmit(sender: UIButton) {
        let act = Activity.new()
        var uuid = NSUUID()
        let identifier = "activity.identifier"
        act.UUID = uuid.UUIDString
        act.saveInBackgroundWithBlock { (sucess, error) -> Void in
            if sucess{
                println("Deu tudo certo em salvar o UUID")
                self.beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: identifier)
                self.peripheralManager = CBPeripheralManager(delegate: self, queue: dispatch_get_main_queue())
            }
        }
    }

    @IBAction func monitor(sender: UIButton) {
        let identifier = "activity.identifier"
        let act = Activity.query()
        act?.orderByDescending("createdAt")
        act?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
            println(object)
            
            if let obj = object as? Activity{
                println(obj.UUID)
                self.beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: obj.UUID), identifier: identifier)
            }
        })
        locationManager.startMonitoringForRegion(beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        locationManager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        locationManager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        
        if (beacons.count > 0) {
            beaconsFound = beacons as! [CLBeacon]
            tableView.reloadData()
        }
        
    }
    
    
    //MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconsFound.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "BeaconCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UITableViewCell
        
        let majorLabel = cell.viewWithTag(1) as! UILabel
        let minorLabel = cell.viewWithTag(2) as! UILabel
        let distanceLabel = cell.viewWithTag(3) as! UILabel
        
        let beacon = beaconsFound[indexPath.row]
        majorLabel.text = String(format: "%ld", arguments: [beacon.major.integerValue])
        minorLabel.text = String(format: "%ld", arguments: [beacon.minor.integerValue])
        
        var proximity: String
        switch (beacon.proximity) {
        case .Far: proximity = "Far"
        case .Immediate: proximity = "Immediate"
        case .Near: proximity = "Near"
        case .Unknown: proximity = "Unknown"
        }
        
        distanceLabel.text = proximity
        
        return cell
    }
    
    
    //MARK: CBPeripheralDelegate
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        switch (peripheral.state) {
        case .PoweredOn:
            var peripheralData = self.beaconRegion.peripheralDataWithMeasuredPower(-59)
            peripheralManager!.startAdvertising((peripheralData as NSDictionary as! [NSObject:AnyObject]))
        default:
            break
        }
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
        println("Peripheral started with error: \(error?.localizedDescription)")
    }

}