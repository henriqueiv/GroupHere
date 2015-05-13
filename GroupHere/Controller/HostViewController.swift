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

class HostViewController: UIViewController, CBPeripheralManagerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblBTStatus: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var stepperLabel: UILabel!
    
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
        self.activity.minor = 0
//        self.populateTableView()
    }
    
    func populateTableView(){
        SVProgressHUD.showWithStatus("Searching activities", maskType: .Gradient)
        let query = Activity.query()
        
        if self.activity.minor != 0{
            query?.whereKey("host", equalTo: PFUser.currentUser()!)
            query?.whereKey("minor", equalTo: self.activity.minor)
            query?.includeKey("users")
            query?.getFirstObjectInBackgroundWithBlock({ (object: PFObject?,error: NSError?) -> Void in
                self.activity = object as! Activity
//                println(self.activity.users)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                })
            })
        }else{
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            SVProgressHUD.dismiss()
            SVProgressHUD.showErrorWithStatus("You should create an activity before look for members", maskType: .Gradient)
        }
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
                            self.populateTableView()
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
        
        let shuffled = newShuffledArray(self.activity.users)
        var j = 0
        let groups = NSMutableArray.new()
        let users = NSMutableArray.new()
        
        for i in 0 ..< self.activity.users.count{
            let u = shuffled[i] as! PFUser
            users.addObject(u.username!)
            j++
            if (j == Int(stepper.value) || (i == self.activity.users.count-1)){
                groups.addObject(u)
                
                let alert = UIAlertView(title: "Grupo \(j)", message: "\(users)", delegate: self, cancelButtonTitle: "Ok")
                alert.show()
//                println("Gropus dentro do for: \(groups)")
                users.removeAllObjects()
                j = 0
            }
        }
//        groups.addObject(users.copy())
//        println("Grupo:\(groups)")
    }
    
    func newShuffledArray(array:NSArray) -> NSArray {
        var mutableArray = array.mutableCopy() as! NSMutableArray
        var count = mutableArray.count
        if count>1 {
            for var i=count-1;i>0;--i{
                mutableArray.exchangeObjectAtIndex(i, withObjectAtIndex: Int(arc4random_uniform(UInt32(i+1))))
            }
        }
        return mutableArray as NSArray
    }
    
    @IBAction func dismisKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func stepperValueChange(sender: UIStepper) {
        let value = Int(self.stepper.value)
        stepperLabel.text = "\(value)"
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

