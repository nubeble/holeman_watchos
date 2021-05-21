//
//  StoreManager.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/02/22.
//

import Foundation
import StoreKit

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    // #if DEBUG
    let verifyReceiptURL = "https://sandbox.itunes.apple.com/verifyReceipt"
    // #else
    // let verifyReceiptURL = "https://buy.itunes.apple.com/verifyReceipt"
    // #endif
    
    override init() {
        super.init()
        
        // print("StoreManager.init()")
        
        SKPaymentQueue.default().add(self)
    }
    
    func destroy() {
        print(#function)
        
        SKPaymentQueue.default().remove(self)
    }
    
    //FETCH PRODUCTS
    var request: SKProductsRequest? // store the request as a property
    
    @Published var myProducts = [SKProduct]()
    
    //HANDLE TRANSACTIONS
    @Published var transactionState: SKPaymentTransactionState?
    
    @Published var remainingTransactionsCount: Int?
    
    func initState() {
        print(#function)
        
        DispatchQueue.main.async {
            self.transactionState = nil
        }
    }
    
    func initProducts() {
        print(#function)
        
        DispatchQueue.main.async {
            self.myProducts.removeAll()
        }
    }
    
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
                
                print(#function, "Product downloadable", product.isDownloadable)
                
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
            // for transaction in SKPaymentQueue.default().transactions {
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
                
                /*
                 print(#function, "purchased: \(String(describing: transaction.payment.productIdentifier))",
                 String(describing: transaction.transactionIdentifier), String(describing: transaction.transactionDate),
                 transaction.downloads.count
                 )
                 */
                print(#function, "purchased")
                
                DispatchQueue.main.async {
                    self.transactionState = .purchased
                }
                
                queue.finishTransaction(transaction)
            // SKPaymentQueue.default().finishTransaction(transaction)
            
            // NotificationCenter.default.post(name: Notification.Name(rawValue: "InAppProductPurchasedNotification"), object: nil)
            
            // receiptValidation()
            
            case .restored:
                // UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier) // ToDo: iap, save to UserDefaults
                
                print(#function, "restored: \(String(describing: transaction.payment.productIdentifier))",
                      String(describing: transaction.transactionIdentifier), String(describing: transaction.transactionDate)
                )
                
                DispatchQueue.main.async {
                    self.transactionState = .restored
                }
                
                queue.finishTransaction(transaction)
            // SKPaymentQueue.default().finishTransaction(transaction)
            
            // case .failed, .deferred:
            case .failed:
                print(#function, "failed: \(String(describing: transaction.error))")
                
                queue.finishTransaction(transaction)
                // SKPaymentQueue.default().finishTransaction(transaction)
                
                DispatchQueue.main.async {
                    self.transactionState = .failed
                }
                
            case .deferred:
                print(#function, "deferred: \(String(describing: transaction.error))")
                
            default:
                print(#function, "default: \(String(describing: transaction.error))")
                
            // queue.finishTransaction(transaction)
            // SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print(#function, "Transaction removed")
        
        let count = queue.transactions.count
        print(#function, "removedTransactionsCount", count)
        
        DispatchQueue.main.async {
            self.remainingTransactionsCount = count
        }
        
        
        
        /*
         for transaction in transactions {
         print(#function, transaction.transactionIdentifier, transaction.transactionDate)
         
         switch transaction.transactionState {
         case .purchasing: print("0")
         case .purchased: print("1")
         case .failed: print("2")
         case .restored: print("3")
         case .deferred: print("4")
         }
         }
         */
        
        // print(#function, "Transactions in queue")
        /*
         for transaction in queue.transactions {
         print("Transactions in queue", transaction.transactionIdentifier, transaction.transactionDate)
         }
         
         if queue.transactions.count == 0 {
         print("remove observer")
         // SKPaymentQueue.default().remove(self)
         }
         */
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print(#function, "Transaction failed", error)
        
        /*
         DispatchQueue.main.async {
         self.transactionState = .failed
         }
         */
    }
    
    // 2.
    func restoreProducts() {
        print("Restoring products...")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("paymentQueueRestoreCompletedTransactionsFinished")
    }
    
    func receiptValidation() {
        let receiptFileURL = Bundle.main.appStoreReceiptURL
        let receiptData = try? Data(contentsOf: receiptFileURL!)
        let recieptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        // let jsonDict: [String: AnyObject] = ["receipt-data" : recieptString! as AnyObject, "password" : "dab3f8e770384d99ae7dda0096529a30" as AnyObject]
        let jsonDict: [String: AnyObject] = ["receipt-data" : recieptString! as AnyObject]
        
        do {
            let requestData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            let storeURL = URL(string: verifyReceiptURL)!
            var storeRequest = URLRequest(url: storeURL)
            storeRequest.httpMethod = "POST"
            storeRequest.httpBody = requestData
            
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: storeRequest, completionHandler: { [weak self] (data, response, error) in
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    print("response: ", jsonResponse)
                    
                    if let date = self?.getExpirationDateFromResponse(jsonResponse as! NSDictionary) {
                        print("date: ", date)
                    }
                } catch let parseError {
                    print("error: ", parseError)
                }
            })
            task.resume()
        } catch let parseError {
            print("error: ", parseError)
        }
    }
    
    func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> Date? {
        if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
            
            let lastReceipt = receiptInfo.lastObject as! NSDictionary
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            
            if let expiresDate = lastReceipt["expires_date"] as? String {
                return formatter.date(from: expiresDate)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
