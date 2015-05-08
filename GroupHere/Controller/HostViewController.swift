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

class HostViewController: UIViewController, CBPeripheralManagerDelegate {
    
    var peripheralManager: CBPeripheralManager?
    var beaconRegion = CLBeaconRegion()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func transmit(sender: UIButton) {
        let act = Activity.new()
        var uuid = NSUUID()
        let identifier = "activity.identifier"
        act.UUID = uuid.UUIDString
        act.save()
        
        self.beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: identifier)
//        self.beaconRegion = CLBeaconRegion(proximityUUID: "", major: 2, minor: 1, identifier: "")
        peripheralManager = CBPeripheralManager(delegate: self, queue: dispatch_get_main_queue())
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