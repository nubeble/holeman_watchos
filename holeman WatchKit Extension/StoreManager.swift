//
//  StoreManager.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/02/22.
//

import Foundation
import StoreKit

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    //FETCH PRODUCTS
    var request: SKProductsRequest? // store the request as a property
    
    @Published var myProducts = [SKProduct]()
    
    func getProducts(productIDs: [String]) {
        print(#function, "Start requesting products...")
        
        self.request?.cancel()
        
        self.request = SKProductsRequest(productIdentifiers: Set(productIDs))
        self.request!.delegate = self
        self.request!.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(#function, "Received response")
        
        if !response.products.isEmpty {
            for product in response.products {
                print(#function, "Product: \(product.productIdentifier) \(product.localizedTitle) \(product.price.floatValue)")
                
                DispatchQueue.main.async {
                    self.myProducts.append(product)
                }
            }
            
            for invalidIdentifier in response.invalidProductIdentifiers {
                print("Invalid identifiers: \(invalidIdentifier)")
            }
        } else {
            print(#function, "response.products is empty")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(#function, "Request failed: \(error)")
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print(#function, "Request finished")
    }
    
    //HANDLE TRANSACTIONS
    @Published var transactionState: SKPaymentTransactionState?
    
    // 1.
    func purchaseProduct(_ product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("Can't make payment")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.payment.productIdentifier != "com.nubeble.holeman.iap.course" {
                continue
            }
            
            switch transaction.transactionState {
            case .purchasing:
                DispatchQueue.main.async {
                    self.transactionState = .purchasing
                }
                
            case .purchased:
                // UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier) // ToDo: iap, save to UserDefaults
                
                print(#function, "purchased: \(String(describing: transaction.payment.productIdentifier))")
                
                queue.finishTransaction(transaction)
                
                DispatchQueue.main.async {
                    self.transactionState = .purchased
                }
                
            case .restored:
                // UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier) // ToDo: iap, save to UserDefaults
                
                print(#function, "restored: \(String(describing: transaction.payment.productIdentifier))")
                
                queue.finishTransaction(transaction)
                
                DispatchQueue.main.async {
                    self.transactionState = .restored
                }
                
            case .failed, .deferred:
                print(#function, "error: \(String(describing: transaction.error))")
                
                queue.finishTransaction(transaction)
                
                DispatchQueue.main.async {
                    self.transactionState = .failed
                }
                
            default:
                print(#function, "default: \(String(describing: transaction.error))")
                
                queue.finishTransaction(transaction)
            }
        }
    }
    
    // 2.
    func restoreProducts() {
        print("Restoring products...")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("paymentQueueRestoreCompletedTransactionsFinished")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print(#function, error)
        
        DispatchQueue.main.async {
            self.transactionState = .failed
        }
    }
}
