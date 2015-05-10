//
//  LoginRegisterViewController.swift
//  GroupHere
//
//  Created by Henrique Valcanaia on 5/7/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var userPicture: UIImageView!
    
    let picker = UIImagePickerController()
    let myActionSheet = UIActionSheet()
    let kIndexTakePhotoButton = 0
    let kIndexChooseFromLibraryButton = 1
    let kIndexCancelButton = 2
    let kPFErrorUsernameTaken = 202
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        picker.delegate = self
        
        myActionSheet.addButtonWithTitle("Take photo")
        myActionSheet.addButtonWithTitle("Choose from library")
        myActionSheet.addButtonWithTitle("Cancel")
        myActionSheet.cancelButtonIndex = kIndexCancelButton
        myActionSheet.delegate = self
    }
    
    @IBAction func signUp(sender: AnyObject) {
        SVProgressHUD.showWithStatus("Signin up", maskType: .Gradient)
        let user = PFUser()
        user.username = tfUsername.text
        user.password = tfPassword.text
        user.setObject(tfName.text, forKey: "name")
        if let imageData = UIImagePNGRepresentation(self.userPicture.image){
            let pictureFile = PFFile(name: user.username! + "-picture.png", data: imageData)
            user.setObject(pictureFile, forKey: "picture")
        }
        
        user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if succeeded {
                //                self.performSegueWithIdentifier("gotoApp", sender: nil)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccessWithStatus("Usuário cadastrado com sucesso", maskType: .Gradient)
                    
                })
            }else{
                //                ParseErrorHandlingController.handleParseError(error!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                    if error!.code == self.kPFErrorUsernameTaken{
                        SVProgressHUD.showWithStatus("Usuário já cadastrado, realizando login...", maskType: .Gradient)
                        //                        self.login(user)
                    }else{
                        SVProgressHUD.showErrorWithStatus(error?.description, maskType: .Gradient)
                    }
                    println(error)
                })
            }
        }
    }
    
    @IBAction func touchDownView(sender: AnyObject) {
        //self.dismissKeyboard()
    }
    
    func gotoApp(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func setPicture(){
        myActionSheet.showInView(self.view)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        userPicture.contentMode = .ScaleAspectFill //3
        userPicture.image = chosenImage //4
        dismissViewControllerAnimated(true, completion: nil) //5
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func photoFromLibrary() {
        picker.allowsEditing = true //2
        picker.sourceType = .PhotoLibrary //3
        picker.modalPresentationStyle = .Popover
        presentViewController(picker, animated: true, completion: nil)//4
    }
    
    func takePhoto() {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.cameraCaptureMode = .Photo
            presentViewController(picker, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }
    
    func actionSheet(myActionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex {
        case kIndexTakePhotoButton:
            self.takePhoto();
            
        case kIndexChooseFromLibraryButton:
            self.photoFromLibrary()
            
        case kIndexCancelButton:
            #if DEBUG
                NSLog("Close");
            #endif
            
        default:
            #if DEBUG
                NSLog("Indice nao implementado")
            #endif
        }
    }

    
}
