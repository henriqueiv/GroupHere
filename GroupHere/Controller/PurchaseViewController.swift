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
    var productID = "<INSERT ID HERE>"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buyButton.enabled = false
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        getProductInfo()
        
    }
    
    func getProductInfo(){
        if SKPaymentQueue.canMakePayments(){
            let request = SKProductsRequest(productIdentifiers: NSSet(objects: self.productID) as Set<NSObject>)
            request.delegate = self
            request.start()
        } else {
            productDescription.text = "You must enable In-App Purchase"
        }
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        var products = response.products
        if (products.count != 0){
            product = products[0] as? SKProduct
            buyButton.enabled = true
            productName.text = product!.localizedDescription
        } else {
            productName.text = "Not found"
        }
        
        products = response.invalidProductIdentifiers
        
        for product in products{
            println("Product not found: \(product)")
        }
    }
    
    @IBAction func buyProduct(sender: AnyObject){
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        for transaction in transactions as![SKPaymentTransaction]{
            switch transaction.transactionState{
            case SKPaymentTransactionState.Purchased:
                self.unlockFeature()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            case SKPaymentTransactionState.Failed:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            default:
                break
            }
        }
    }
    
    func unlockFeature(){
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        appdelegate.homeViewController!.enableLevel2()
        buyButton.enabled = false
        productName.text = "Item has been purchased"
    }
}
