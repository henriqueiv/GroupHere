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
import SVProgressHUD

class HostViewController: UIViewController, CBPeripheralManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblBTStatus: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stepper: UIStepper!
    
    let uuid = NSUUID(UUIDString: "F34A1A1F-500F-48FB-AFAA-9584D641D7B1")
    let identifier = "br.com.henriquevalcanaia.GroupHere"
    var bluetoothPeripheralManager: CBPeripheralManager!
    var dataDictionary = NSDictionary()
    var beaconRegion: CLBeaconRegion!
    var activity = Activity.new()
    var isBroadcasting = false
    let major = 10
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "populateTableView", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func populateTableView(){
        let query = Activity.query()
        query?.whereKey("host", equalTo: PFUser.currentUser()!)
        query?.whereKey("minor", equalTo: self.activity.minor)
        query?.includeKey("users")
        query?.getFirstObjectInBackgroundWithBlock({ (object: PFObject?,error: NSError?) -> Void in
            self.activity = object as! Activity
            println(self.activity.users)
        })
        tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func createActivityAndStartTransmiting(){
        if ((textField.text) != ""){
            //Query para incrementar o minor baseado na ultima activity do Parse
            SVProgressHUD.showWithStatus("Creating Ativity", maskType: .Gradient)
            let query = Activity.query()
            query?.orderByDescending("minor")
            query?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                var activ = object as? Activity
                //Se nao existir nenhuma activity no parse é criada uma
                if (activ == nil){
                    self.activity.minor = 0
                    activ = self.activity
                }
                self.activity.name = self.textField.text
                self.activity.host = PFUser.currentUser()!
                self.activity.minor = NSNumber(integer: activ!.minor.integerValue + 1)
                self.activity.major = self.major
                PFGeoPoint.geoPointForCurrentLocationInBackground({ (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
                    if let location = geoPoint{
                        self.activity.location = location
                    }
                    self.activity.saveInBackgroundWithBlock({ (sucess: Bool, error: NSError?) -> Void in
                        if(sucess){
                            println("Saved activit on Parese:")
                            println(self.activity)
                            self.beaconRegion = CLBeaconRegion(proximityUUID: self.uuid, major: self.activity.major.unsignedShortValue , minor: self.activity.minor.unsignedShortValue, identifier: self.identifier)
                            self.dataDictionary = self.beaconRegion.peripheralDataWithMeasuredPower(nil)
                            self.bluetoothPeripheralManager.startAdvertising(self.dataDictionary as [NSObject : AnyObject])
                            self.btnAction.setTitle("Stop", forState: UIControlState.Normal)
                            self.lblStatus.text = "Broadcasting..."
                            self.isBroadcasting = true
                            SVProgressHUD.showSuccessWithStatus("Activity created with success", maskType: .Gradient)
                        }else{
                            SVProgressHUD.showErrorWithStatus(error?.description, maskType: .Gradient)
                        }
                    })
                })
            })
        }else{
            let alert = UIAlertView(title: "You need the acitivity name", message: "Choose a name and try again", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    // MARK: IBAction method implementation
    @IBAction func populate(sender: AnyObject) {
        populateTableView()
    }
    
    @IBAction func generateGroups(sender: AnyObject) {
        var previousNumber: UInt32? // used in randomNumber()
        
        func randomNumber() -> UInt32 {
            var randomNumber = arc4random_uniform(10)
            while previousNumber == randomNumber {
                randomNumber = arc4random_uniform(10)
            }
            previousNumber = randomNumber
            return randomNumber
        }
    }
    
    @IBAction func dismisKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func switchBroadcastingState(sender: AnyObject) {
        if !isBroadcasting {
            if bluetoothPeripheralManager.state == CBPeripheralManagerState.PoweredOn {
                createActivityAndStartTransmiting()
            }
        }else {
            bluetoothPeripheralManager.stopAdvertising()
            
            btnAction.setTitle("Start", forState: UIControlState.Normal)
            lblStatus.text = "Stopped"
            
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activity.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "activityCell")
        if let user = self.activity.users[indexPath.row] as? PFUser{
            cell.textLabel?.text = user.username
            let name: String = user["name"]! as! String
            cell.detailTextLabel?.text = name
        }
        return cell
        
    }
}

