//
//  PurchaseViewController.swift
//  GroupHere
//
//  Created by Paulo Ricardo Ramos da Rosa on 5/8/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

import UIKit
import StoreKit


class PurchaseViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDescription: UITextView!
    @IBOutlet weak var buyButton: UIButton!
    
    var product: SKProduct?
    var productID = "create_activity01"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buyButton.enabled = false
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        getProductInfo()
        
    }
    
    func getProductInfo(){
        if SKPaymentQueue.canMakePayments(){
            let request = SKProductsRequest(productIdentifiers: NSSet(objects: self.productID) as Set<NSObject> as Set<NSObject>)
            request.delegate = self
            request.start()
        } else {
            productDescription.text = "You must enable In-App Purchase"
        }
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        var products = response.products
        if (products.count != 0){
            product = products[0] as? SKProduct
            buyButton.enabled = true
            productName.text = product!.localizedTitle
            productDescription.text = product!.localizedDescription
        } else {
            productName.text = "Not found"
        }
        
        products = response.invalidProductIdentifiers
        
        for product in products{
            print("Product not found: \(product)")
        }
    }
    
    @IBAction func buyProduct(sender: AnyObject){
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
        //println("comprando")
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState{
            case SKPaymentTransactionState.Purchased:
                //println("destravando")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                self.unlockFeature()
                
            case SKPaymentTransactionState.Failed:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            default:
                break
            }
        }
    }
    
    func unlockFeature(){
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //println("Comprei")
        self.performSegueWithIdentifier("payScreen", sender: self)
        //appdelegate.homeViewController!.enableLevel2()
        buyButton.enabled = false
        //productName.text = "Item has been purchased"
    }
}
