//
//  HostViewController.swift
//  GroupHere
//
//  Created by Marcus Vinicius Kuquert on 07/05/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation
import CoreBluetooth
import Parse

class HostViewController: UIViewController, CBPeripheralManagerDelegate {
    
    @IBOutlet weak var btnAction: UIButton!
    
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var lblBTStatus: UILabel!
    
    @IBOutlet weak var txtMajor: UITextField!
    
    @IBOutlet weak var txtMinor: UITextField!
    
    @IBOutlet weak var activityName: UITextField!
    
    let uuid = NSUUID(UUIDString: "F34A1A1F-500F-48FB-AFAA-9584D641D7B1")
    
    var beaconRegion: CLBeaconRegion!
    
    var bluetoothPeripheralManager: CBPeripheralManager!
    
    var isBroadcasting = false
    
    var dataDictionary = NSDictionary()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismisKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    // MARK: IBAction method implementation
    
    @IBAction func switchBroadcastingState(sender: AnyObject) {
        if !isBroadcasting {
            if bluetoothPeripheralManager.state == CBPeripheralManagerState.PoweredOn {
                var act = Activity.new()
                
                if ((activityName.text) != ""){
                    let query = Activity.query()
                    query?.orderByDescending("minor")
                    query?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                        println(object)
                        if let activ = object as? Activity{
                            act.name = self.activityName.text
                            act.host = PFUser.currentUser()!
                            act.minor = NSNumber(integer: activ.minor.integerValue + 1)
                            act.major = 10
                            act.saveInBackgroundWithBlock({ (sucess: Bool, error) -> Void in
                                if(sucess){
                                    println("Salvou tudo certo:")
                                    println(act)
                                    
                                    self.beaconRegion = CLBeaconRegion(proximityUUID: self.uuid, major: act.major.unsignedShortValue , minor: act.minor.unsignedShortValue, identifier: "com.appcoda.beacondemo")
                                    
                                    self.dataDictionary = self.beaconRegion.peripheralDataWithMeasuredPower(nil)
                                    self.bluetoothPeripheralManager.startAdvertising(self.dataDictionary as [NSObject : AnyObject])
                                    
                                    self.btnAction.setTitle("Stop", forState: UIControlState.Normal)
                                    self.lblStatus.text = "Broadcasting..."
                                    self.txtMajor.enabled = false
                                    self.txtMinor.enabled = false
                                    
                                    self.isBroadcasting = true
                                    
                                    
                                    
                                    
                                }
                            })
                        }
                    })
                }else{
                    let alert = UIAlertView(title: "You need a acitivity name", message: "Choose a name and try again", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
        }
        else {
            bluetoothPeripheralManager.stopAdvertising()
            
            btnAction.setTitle("Start", forState: UIControlState.Normal)
            lblStatus.text = "Stopped"
            
            txtMajor.enabled = true
            txtMinor.enabled = true
            
            isBroadcasting = false
        }
    }
    
    
    // MARK: CBPeripheralManagerDelegate method implementation
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        var statusMessage = ""
        
        switch peripheral.state {
        case CBPeripheralManagerState.PoweredOn:
            statusMessage = "Bluetooth Status: Turned On"
            
        case CBPeripheralManagerState.PoweredOff:
            if isBroadcasting {
                switchBroadcastingState(self)
            }
            statusMessage = "Bluetooth Status: Turned Off"
            
        case CBPeripheralManagerState.Resetting:
            statusMessage = "Bluetooth Status: Resetting"
            
        case CBPeripheralManagerState.Unauthorized:
            statusMessage = "Bluetooth Status: Not Authorized"
            
        case CBPeripheralManagerState.Unsupported:
            statusMessage = "Bluetooth Status: Not Supported"
            
        default:
            statusMessage = "Bluetooth Status: Unknown"
        }
        
        lblBTStatus.text = statusMessage
    }
    
}

