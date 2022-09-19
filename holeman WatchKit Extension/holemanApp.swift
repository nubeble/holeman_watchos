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
    @WKApplicationDelegateAdaptor(ExtensionDelegate.self) var delegate
    
    @StateObject var storeManager = StoreManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                // ContentView()
                // ContentView().environmentObject(Course())
                
                SplashView()
                // SplashView().environmentObject(self.storeManager)
            }
            .environmentObject(self.storeManager)
        }
    }
}
