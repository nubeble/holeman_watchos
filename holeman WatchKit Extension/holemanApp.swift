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
    
    
    //@StateObject var storeManager = StoreManager()
    /*
     let productIDs = [
     "com.nubeble.holeman.iap.course",
     "com.nubeble.holeman.test1",
     "com.nubeble.holeman.test2"
     ]
     */
    
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
                
                /*
                 // SKPaymentQueue.default().add(storeManager)
                 // SKPaymentQueue.default().remove(storeManager)
                 
                 storeManager.getProducts(productIDs: productIDs)
                 */
                
                /*
                 storeManager.getProducts(productIDs: Static.productIDs)
                 
                 DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                 SKPaymentQueue.default().add(storeManager) // ToDo: remove
                 
                 let product = Util.getProduct(self.storeManager.myProducts, "com.nubeble.holeman.iap.course")
                 storeManager.purchaseProduct(product: product!)
                 }
                 */
            }.onDisappear {
            }
        }
    }
}
