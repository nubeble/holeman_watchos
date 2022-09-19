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

class ExtensionDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        // This will run in foreground mode.
        print("applicationDidFinishLaunching")
        
        /*
         // UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
         UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
         
         if success {
         print("Permission granted.")
         
         DispatchQueue.main.async {
         WKApplication.shared().registerForRemoteNotifications()
         }
         
         } else if let error = error {
         print(error.localizedDescription)
         }
         
         }
         */
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
        print("didRegisterForRemoteNotifications", "device token", deviceTokenAsString)
    }
    
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError", error)
    }
    
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (WKBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification", userInfo)
        
        if let ck = userInfo["ck"] as? NSDictionary {
            if let qry = ck["qry"] as? NSDictionary {
                if let rid = qry["rid"] as? String {
                    // print("rid", rid)
                    
                    let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
                    let recordID = CKRecord.ID.init(recordName: rid)
                    db.fetch(withRecordID: recordID) { record, error in
                        if let record = record, error == nil {
                            // print("record", record)
                            
                            // values={ holeNumber=18, id=27, elevation=1608.613647460938, location=<+39.73915482,-104.98470306> +/- 0.00m (speed 0.00 mps / course 0.00) @ 2001/01/01 9:00:00 AM Korean Standard Time, timestamp=1604930511235 }
                            
                            let id = record["id"] as! Int64
                            let holeNumber = record["holeNumber"] as! Int64
                            // let location = record["location"] as! CLLocation
                            // let elevation = record["elevation"] as! Double
                            let locations = record["locations"] as! [CLLocation]
                            let elevations = record["elevations"] as! [Double]
                            let timestamp = record["timestamp"] as! Int64
                            let battery = record["battery"] as! Int64
                            
                            /*
                             print("id", id)
                             print("holeNumber", holeNumber)
                             // print("location", location)
                             print("latitude", location.coordinate.latitude)
                             print("longitude", location.coordinate.longitude)
                             print("elevation", elevation)
                             print("battery", battery)
                             print("timestamp", timestamp)
                             */
                            
                            DispatchQueue.main.async {
                                /*
                                 let sensor = SensorModel(id: id, holeNumber: holeNumber, elevation: elevation, location: location, battery: battery, timestamp: timestamp)
                                 NotificationCenter.default.post(name: .sensorUpdated, object: sensor)
                                 */
                                let pin = Pin(id: id, holeNumber: holeNumber, elevations: elevations, locations: locations, battery: battery, timestamp: timestamp)
                                NotificationCenter.default.post(name: .pinUpdated, object: pin)
                            }
                        }
                    }
                }
            }
        }
        
        completionHandler(.newData)
    }
}
