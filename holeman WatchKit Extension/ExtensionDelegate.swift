//
//  ExtensionDelegate.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/11/05.
//

// import Foundation
import WatchKit
import UserNotifications
import CloudKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    // func appl
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        // This will run in foreground mode.
        print("applicationDidFinishLaunching")
        
        
        // UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            
            if success {
                print("Permission granted.")
                
                DispatchQueue.main.async {
                    WKExtension.shared().registerForRemoteNotifications()
                }
                
            } else if let error = error {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        print("applicationWillResignActive")
    }
    
    /*
     func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
     // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
     
     //Note: several lines are omitted here
     
     
     // This will run in background mode.
     print("background run")
     }
     */
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        // print("didRegisterForRemoteNotifications", deviceToken)
        
        let deviceTokenAsString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("device token", deviceTokenAsString)
    }
    
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError", error)
    }
    
    
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (WKBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification", userInfo)
        
        if let ck = userInfo["ck"] as? NSDictionary {
            if let qry = ck["qry"] as? NSDictionary {
                if let rid = qry["rid"] as? String {
                    //Do stuff
                    
                    print("rid", rid)
                    
                    // ToDo: check recordType - Sensor
                    
                    let db = CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase
                    let recordID = CKRecord.ID.init(recordName: rid)
                    db.fetch(withRecordID: recordID) { record, error in
                        
                        if let record = record, error == nil {
                            
                            print("record", record)
                            
                            
                            // ToDo: update record
                            
                            // 1. parse data
                            
                            // values={ holeNumber=18, id=27, elevation=1608.613647460938, location=<+39.73915482,-104.98470306> +/- 0.00m (speed 0.00 mps / course 0.00) @ 2001/01/01 9:00:00 AM Korean Standard Time, timestamp=1604930511235 }
                            
                            let id = record["id"] as! Int64
                            let holeNumber = record["holeNumber"] as! Int64
                            let location = record["location"] as! CLLocation
                            let elevation = record["elevation"] as! Double
                            let timestamp = record["timestamp"] as! Int64
                            let battery = record["battery"] as! Int64
                            
                            print("id", id)
                            print("holeNumber", holeNumber)
                            // print("location", location)
                            print("latitude", location.coordinate.latitude)
                            print("longitude", location.coordinate.longitude)
                            print("elevation", elevation)
                            print("battery", battery)
                            print("timestamp", timestamp)
                        }
                        
                    }
                    
                }
                
                
                
                
            }
        }
        
        // CKNotification noti;
        
        
        
        
        /*
         
         let info : NSDictionary! = userInfo as! NSDictionary
         
         if info != nil
         {
         let aps = info["aps"] as? NSDictionary
         UserDefaults.standard.set(aps, forKey: "aps")
         }*/
        
        
        // ToDo: call fetchCompletionHandler
        // You should call the fetchCompletionHandler as soon as you're finished performing that operation, so the system can accurately estimate its power and data cost.
        
        // completionHandler(.failed)
        completionHandler(.newData)
    }
    
    
}
