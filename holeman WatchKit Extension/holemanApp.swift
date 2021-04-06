//
//  holemanApp.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/10/13.
//

import SwiftUI
import StoreKit

@main
struct holemanApp: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate
    
    
    @StateObject var storeManager = StoreManager()
    
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                // ContentView()
                // ContentView().environmentObject(Course())
                
                SplashView()
            }
            .onAppear {
                // print("ContentView appeared!")
                // WKExtension.shared().registerForRemoteNotifications()
                
                // ToDo: test purchase
                /*
                 self.storeManager.getProducts(productIDs: Static.productIDs)
                 
                 DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                 let product = Util.getProduct(self.storeManager.myProducts, "com.nubeble.holeman.iap.course")
                 if product != nil {
                 SKPaymentQueue.default().add(self.storeManager)
                 
                 self.storeManager.purchaseProduct(product!)
                 }
                 }
                 */
                
                // ToDo: test
                /*
                 print("finish transactions")
                 SKPaymentQueue.default().add(self.storeManager)
                 
                 for transactionPending in SKPaymentQueue.default().transactions {
                 print(#function, transactionPending.transactionIdentifier)
                 SKPaymentQueue.default().finishTransaction(transactionPending)
                 }
                 */
            }.onDisappear {
            }
        }
    }
}
