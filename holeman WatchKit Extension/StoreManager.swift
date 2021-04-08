//
//  StoreManager.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/02/22.
//

import Foundation
import StoreKit

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    override init() {
        super.init()
        
        print(#function)
        
        SKPaymentQueue.default().add(self)
    }
    
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
                print(#function, "Product: \(product.productIdentifier), \(product.localizedTitle), \(product.price.floatValue)")
                
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
            // print(#function, product.productIdentifier)
            
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("Can't make payment")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            /*
             if transaction.payment.productIdentifier != "com.nubeble.holeman.iap.course" {
             continue
             }
             */
            
            
            switch transaction.transactionState {
            case .purchasing:
                print(#function, "purchasing")
                
                DispatchQueue.main.async {
                    self.transactionState = .purchasing
                }
                
            case .purchased:
                // UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier) // ToDo: iap, save to UserDefaults
                
                print(#function, "purchased: \(String(describing: transaction.payment.productIdentifier))",
                      String(describing: transaction.transactionIdentifier), String(describing: transaction.transactionDate),
                      // transaction.downloads[0].state,
                      transaction.downloads.count
                )
                
                queue.finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                
                
                // ToDo: 2021-04-07 download first
                // queue.start(transaction.downloads)
                // SKPaymentQueue.default().start(transaction.downloads)
                
                
                DispatchQueue.main.async {
                    self.transactionState = .purchased
                }
                
            case .restored:
                // UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier) // ToDo: iap, save to UserDefaults
                
                print(#function, "restored: \(String(describing: transaction.payment.productIdentifier))",
                      String(describing: transaction.transactionIdentifier), String(describing: transaction.transactionDate)
                )
                
                // queue.finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                
                DispatchQueue.main.async {
                    self.transactionState = .restored
                }
                
            // case .failed, .deferred:
            case .failed:
                print(#function, "failed: \(String(describing: transaction.error))")
                
                // queue.finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                
                DispatchQueue.main.async {
                    self.transactionState = .failed
                }
                
            case .deferred:
                print(#function, "deferred: \(String(describing: transaction.error))")
                
            default:
                print(#function, "default: \(String(describing: transaction.error))")
                
                // queue.finishTransaction(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print(#function, "Transaction removed", transactions)
        
        for transaction in transactions {
            print(#function, transaction.transactionIdentifier, transaction.transactionDate)
            
            /*
             switch transaction.transactionState {
             case .purchasing: print("0")
             case .purchased: print("1")
             case .failed: print("2")
             case .restored: print("3")
             case .deferred: print("4")
             }
             */
            
            // SKPaymentQueue.default().finishTransaction(transaction)
        }
        
    }
    
    // ToDo
    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        print(#function, "downloaded", downloads)
        
        /*
         // ToDo: 2021-04-07 finishTransaction here
         for download in downloads {
         SKPaymentQueue.default().finishTransaction(download.transaction)
         }
         */
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print(#function, "Transaction failed", error)
        
        DispatchQueue.main.async {
            self.transactionState = .failed
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
}
