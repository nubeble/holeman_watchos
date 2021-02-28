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
    // var request: SKProductsRequest!
    
    @Published var myProducts = [SKProduct]()
    
    func getProducts(productIDs: [String]) {
        if SKPaymentQueue.canMakePayments() {
            print(#function, "Start requesting products ...")
            
            let request = SKProductsRequest(productIdentifiers: Set(productIDs))
            request.delegate = self
            request.start()
        } else {
            print(#function, "Can't make payments ...")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(#function, "Received response")
        
        if !response.products.isEmpty {
            for fetchedProduct in response.products {
                DispatchQueue.main.async {
                    self.myProducts.append(fetchedProduct)
                }
            }
            
            for invalidIdentifier in response.invalidProductIdentifiers {
                print("Invalid identifiers found: \(invalidIdentifier)")
            }
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
    func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment) // ToDo: remove
        } else {
            print("Can't make payment")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing
            case .purchased:
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                transactionState = .purchased
            case .restored:
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                transactionState = .restored
            case .failed, .deferred:
                print("Payment Queue Error: \(String(describing: transaction.error))")
                queue.finishTransaction(transaction)
                transactionState = .failed
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
    // 2.
    func restoreProducts() {
        print("Restoring products ...")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
