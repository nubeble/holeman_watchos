//
//  holemanApp.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/10/13.
//

import SwiftUI

@main
struct holemanApp: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                // ContentView()
                // ContentView().environmentObject(Course())
                
                SplashView()
                
            }.onAppear {
                print("ContentView appeared!")
                // WKExtension.shared().registerForRemoteNotifications()
            }.onDisappear {
                print("ContentView disappeared!")
            }
            
        }
    }
    
}
