//
//  RegistrationHelper.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/11/02.
//

import Foundation
import UserNotifications
import SwiftUI

class RegistrationHelper {
    static let shared = RegistrationHelper()

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            
            if success {
                print("Permission granted.")
                
                // self.getNotificationSettings()
                WKExtension.shared().registerForRemoteNotifications()
                
            } else if let error = error {
                print(error.localizedDescription)
            }
            
            /*
                [weak self] granted, error in

                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
            */
        }
    }

    /*
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            
            
            WKExtension.shared().registerForRemoteNotifications()
            
            /*
            DispatchQueue.main.async {
                // WKExtension.shared().registerForRemoteNotifications()
            }
            */
        }
    }
    */
    

}

