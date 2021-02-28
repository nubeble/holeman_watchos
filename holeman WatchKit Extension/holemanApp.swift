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
    
    let productIDs = [
        //Use your product IDs instead
        /*
         "com.BLCKBIRDS.TreasureStore.IAP.PowerSword",
         "com.BLCKBIRDS.TreasureStore.IAP.HealingPotion",
         "com.BLCKBIRDS.TreasureStore.IAP.PirateSkin"
         */
        "com.nubeble.holeman.iap.course",
        "com.nubeble.holeman.test1",
        "com.nubeble.holeman.test2",
        
        "com.nubeble.holeman.watchkitapp.iap.test1",
        "com.nubeble.holeman.watchkitapp.test",
        
        "com.nubeble.holeman.watchkitapp.watchkitextension.iap.test1",
        "com.nubeble.holeman.watchkitapp.watchkitextension.test2",
        "course",
        
        "com.nubeble.holeman.watchkitapp.watchkitextension.iap.test100",
        
        "com.nubeble.holeman.watchkitapp.iap.test10",
        
        "com.nubeble.test1"
    ]
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                // ContentView()
                // ContentView().environmentObject(Course())
                
                SplashView()
            }.onAppear {
                // print("ContentView appeared!")
                // WKExtension.shared().registerForRemoteNotifications()
                
                
                SKPaymentQueue.default().add(storeManager)
                
                // SKPaymentQueue.default().remove(storeManager)
                
                storeManager.getProducts(productIDs: productIDs)
            }.onDisappear {
                // print("ContentView disappeared!")
            }
            
        }
    }
}
