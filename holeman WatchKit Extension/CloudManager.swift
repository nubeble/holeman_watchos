//
//  CloudManager.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/13.
//

import Foundation
import CloudKit
import SwiftUI

// MARK: - notes
// good to read: https://www.hackingwithswift.com/read/33/overview
//
// important setup in CloudKit Dashboard:
//
// https://www.hackingwithswift.com/read/33/4/writing-to-icloud-with-cloudkit-ckrecord-and-ckasset
// https://www.hackingwithswift.com/read/33/5/a-hands-on-guide-to-the-cloudkit-dashboard
//
// On your device (or in the simulator) you should make sure you are logged into iCloud and have iCloud Drive enabled.

struct CloudManager {
    
    // record type
    struct RecordType {
        static let Items = "Items"
    }
    
    // MARK: - errors
    enum CloudManagerError: Error {
        case recordFailure
        case recordIDFailure
        case castFailure
        case cursorFailure
    }
    
    static func subscribe() {
        let db = CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase
        
        // db.fetchAllSubscriptions(completionHandler: T##([CKSubscription]?, Error?) -> Void)
        db.fetchAllSubscriptions(completionHandler: { subscriptions, error in
            if error != nil {
                // failed to fetch all subscriptions, handle error here
                // end the function early
                return
            }
            
            if let subscriptions = subscriptions {
                if subscriptions.count == 0 {
                    print("no subscription exists.")
                    print("save subscription...")
                    // CloudManager.saveSubscription(27)
                }
                
                CloudManager.deleteAllSubscriptions(subscriptions: subscriptions) { (count) in
                    print("deleteAllSubscriptions count", count)
                    
                    print("save subscription...")
                    // CloudManager.saveSubscription(27)
                }
            }
        })
        
        /*
         let query = CKQuery(recordType: "Sensor", predicate: NSPredicate(value: true))
         
         
         
         db.perform(query, inZoneWithID: nil) {
         records, error in
         if error != nil {
         print("twang this is broken \(error)")
         } else {
         if records!.count > 0 {
         
         subID = String(NSUUID().UUIDString)
         let predicateY = NSPredicate(value: true)
         
         let subscription = CKSubscription(recordType: "Collections", predicate: predicateY, subscriptionID: subID, options: [.FiresOnRecordUpdate, .FiresOnRecordDeletion])
         
         subscription.notificationInfo = CKNotificationInfo()
         
         publicDB.saveSubscription(subscription) {
         subscription, error in
         if error != nil {
         print("ping sub failed, almost certainly cause it is already there \(theLink) \(error)")
         } else {
         print("bing subscription saved! \(subID) ")
         }
         }
         
         } else {
         print("no records found")
         }
         }
         }
         */
    }
    
    static func deleteAllSubscriptions(subscriptions: [CKSubscription], onComplete: @escaping ((Int) -> Void)) {
        let db = CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase
        
        var index: Int = 0
        
        for subscription in subscriptions {
            
            
            print("subscription", subscription)
            
            /*
             print("subscriptionType", subscription.subscriptionType)
             if let querySub = subscription as? CKQuerySubscription {
             let recordType = querySub.recordType! as String
             print("recordType", recordType)
             
             if recordType == "Sensor" {
             print("already have subscription.")
             existance = true
             break
             }
             }
             */
            
            // delete all subscriptions
            print("delete subscription...")
            
            db.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: { id, error in
                index += 1
                
                if error != nil {
                    // deletion of subscription failed, handle error here
                    // return
                }
                
                if index == subscriptions.count {
                    // handler(result)
                    onComplete(index)
                }
            })
            
        } // end of for
    }
    
    // static func saveSubscription(_ type: String, _ id: Int64) { // id: course id
    
    static func saveSubscription(_ type: String, _ id: Int64, onComplete: @escaping ((String) -> Void)) {
        
        // create subscription
        // predicate: You can customize this to only get notified when particular records are changed.
        
        // let sub = CKQuerySubscription(recordType: "Sensor", predicate: NSPredicate(value: true), options: [ .firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion ])
        
        // let id: Int64 = 27
        let predicate = NSPredicate(format: "id == %d", id)
        let sub = CKQuerySubscription(recordType: type, predicate: predicate, options: [ .firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion ])
        
        // specify what kind of notification we want to receive
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true // silent push notifications
        notification.alertBody = nil
        
        sub.notificationInfo = notification
        
        // save this subscription to iCloud
        // If you want to have just a single subscription it may be a good idea to save (into UserDefaults maybe) that subscription is created so you can avoid creating it next time.
        let db = CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase
        db.save(sub) { (subscription, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let subscription = subscription {
                print("success on saving subscription.")
                
                onComplete(subscription.subscriptionID)
            }
        }
    }
    
    // MARK: - save to CloudKit
    static func save(item: ListElement, completion: @escaping (Result<ListElement, Error>) -> ()) {
        
        // create item record (CKRecord)
        let itemRecord = CKRecord(recordType: RecordType.Items)
        itemRecord["text"] = item.text as CKRecordValue
        
        // public db, default zone
        
        // CKContainer(identifier: "iCloud.com.nubeble.holeman")
        // CKContainer.default()
        CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase.save(itemRecord) { (record, err) in // completion handler
            DispatchQueue.main.async {
                
                if let err = err {
                    completion(.failure(err))
                    return
                }
                
                guard let record = record else {
                    completion(.failure(CloudManagerError.recordFailure))
                    return
                }
                
                // means success
                let id = record.recordID
                guard let text = record["text"] as? String else {
                    completion(.failure(CloudManagerError.castFailure))
                    return
                }
                
                let element = ListElement(recordID: id, text: text)
                completion(.success(element))
                
            }
        }
    }
    
    static func fetch(completion: @escaping (Result<ListElement, Error>) -> ()) {
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: RecordType.Items, predicate: pred)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["text"]
        operation.resultsLimit = 50
        
        operation.recordFetchedBlock = { record in
            DispatchQueue.main.async {
                let recordID = record.recordID
                guard let text = record["text"] as? String else { return }
                let listElement = ListElement(recordID: recordID, text: text)
                completion(.success(listElement))
            }
        }
        
        operation.queryCompletionBlock = { (/*cursor*/ _, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
                //                guard let cursor = cursor else {
                //                    completion(.failure(CloudManagerError.cursorFailure))
                //                    return
                //                }
                //                print("Cursor: \(String(describing: cursor))")
            }
            
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    static func fetchNearbyLocations(_ countryCode: String, _ location: CLLocation, onComplete: @escaping (_ records:[CKRecord]?) -> Void) {
        print(#function)
        // convert radius in meters to kilometers
        
        // let radiusInMeters: CLLocationDistance = 1
        // let radiusInKilometers = 1 // ToDo: static (1 km)
        let radiusInKilometers = 50 // ToDo: internal test (50 km)
        
        // let p = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < %@", location, NSNumber(value: radiusInKilometers))
        let p = NSPredicate(format: "countryCode = %@ AND distanceToLocation:fromLocation:(location, %@) < %@", countryCode, location, NSNumber(value: radiusInKilometers))
        let query = CKQuery(recordType: "Course", predicate: p)
        // query.sortDescriptors = [CKLocationSortDescriptor(key: "location", relativeLocation: location)]
        /*
         let operation = CKQueryOperation(query: query)
         operation.resultsLimit = 50
         CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase.add(operation)
         */
        
        // CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
        CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase.perform(query, inZoneWith: CKRecordZone.default().zoneID) { (records, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Locations: \(error)")
                }
            } else {
                // print(records)
                onComplete(records)
            }
        }
    }
    
    static func fetchAllCourses(_ countryCode: String, onComplete: @escaping (_ records:[CKRecord]?) -> Void) {
        let p = NSPredicate(format: "countryCode = %@", countryCode)
        let query = CKQuery(recordType: "Course", predicate: p)
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase.perform(query, inZoneWith: CKRecordZone.default().zoneID) { (records, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Locations: \(error)")
                }
            } else {
                // print(records)
                onComplete(records)
            }
        }
    }
    
    static func getHoles(_ groupId: Int64, onComplete: @escaping (_ records:[CKRecord]?) -> Void) {
        let p = NSPredicate(format: "id = %d", groupId)
        let query = CKQuery(recordType: "Hole", predicate: p)
        // query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase.perform(query, inZoneWith: CKRecordZone.default().zoneID) { (records, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Locations: \(error)")
                }
            } else {
                // print(records)
                onComplete(records)
            }
        }
    }
    
    static func getSensor(_ groupId: Int64, _ holeNumber: Int64, onComplete: @escaping (_ record: CKRecord?) -> Void) {
        let rid = "sensor-" + String(groupId) + "-" + String(holeNumber)
        let recordID = CKRecord.ID.init(recordName: rid)
        
        
        CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Locations: \(error)")
                }
            } else {
                // print(record)
                onComplete(record)
            }
        }
    }
    
    static func getSensors(_ groupId: Int64, onComplete: @escaping (_ records:[CKRecord]?) -> Void) {
        let p = NSPredicate(format: "id = %d", groupId)
        let query = CKQuery(recordType: "Sensor", predicate: p)
        // query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase.perform(query, inZoneWith: CKRecordZone.default().zoneID) { (records, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Locations: \(error)")
                }
            } else {
                // print(records)
                onComplete(records)
            }
        }
    }
    
    /*
     static func subscribeToSensors(_ groupId: Int64) {
     let db = CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase
     
     // check existance
     db.fetchAllSubscriptions(completionHandler: { subscriptions, error in
     if error != nil {
     // failed to fetch all subscriptions, handle error here
     // end the function early
     return
     }
     
     if let subscriptions = subscriptions {
     if subscriptions.count == 0 {
     CloudManager.saveSubscription("Sensor", groupId)
     } else {
     CloudManager.deleteAllSubscriptions(subscriptions: subscriptions) { count in
     print("deleteAllSubscriptions count", count)
     
     print("save subscription...")
     CloudManager.saveSubscription("Sensor", groupId)
     }
     }
     }
     })
     }
     */
    
    static func subscribeToSensors(_ groupId: Int64) {
        // check UserDefaults
        let subId = UserDefaults.standard.string(forKey: "SUBSCRIPTION_SENSORS_SUB_ID")
        if subId != nil {
            // print("subscription ID", subId)
            let courseId = UserDefaults.standard.integer(forKey: "SUBSCRIPTION_SENSORS_COURSE_ID")
            print("course id", courseId)
            if courseId == Int(groupId) {
                // skip saving
                return
            } else {
                // 1. delete db
                let db = CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase
                db.delete(withSubscriptionID: subId!, completionHandler: { id, error in
                    // N/A
                })
                
                // 2. save db
                CloudManager.saveSubscription("Sensor", groupId) { id in
                    // 3. update ud (subId & courseId)
                    UserDefaults.standard.set(id, forKey: "SUBSCRIPTION_SENSORS_SUB_ID")
                    UserDefaults.standard.set(groupId, forKey: "SUBSCRIPTION_SENSORS_COURSE_ID") // course id
                }
            }
        } else {
            // 2. save db
            CloudManager.saveSubscription("Sensor", groupId) { id in
                // 3. update ud (subId & courseId)
                UserDefaults.standard.set(id, forKey: "SUBSCRIPTION_SENSORS_SUB_ID")
                UserDefaults.standard.set(groupId, forKey: "SUBSCRIPTION_SENSORS_COURSE_ID") // course id
            }
        }
    }
    
    static func saveUser(_ id: String, _ name: String, _ email: String) {
        /*
         let record = CKRecord(recordType: "User", recordID: CKRecord.ID.init(recordName: id))
         record["id"] = id as String
         record["name"] = name as String
         record["email"] = email as String
         let valid: Int64 = 100 // 100: valid, 200: invalid (logout)
         record["valid"] = valid as Int64
         
         let db = CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase
         db.save(record) { (record, error) in
         if let error = error {
         print(#function, error)
         return
         }
         
         if let _ = record {
         print(#function, "success on saving user.")
         }
         }
         */
        
        // fetch
        let recordID = CKRecord.ID.init(recordName: id)
        
        let db = CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase
        db.fetch(withRecordID: recordID) { (record, error) in
            if let error = error {
                // print(#function, error)
                print("User Record not found")
                
                let record = CKRecord(recordType: "User", recordID: CKRecord.ID.init(recordName: id))
                record["id"] = id as String
                record["name"] = name as String
                record["email"] = email as String
                let valid: Int64 = 100 // 100: valid, 200: invalid (logout)
                record["valid"] = valid as Int64
                
                // let db = CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase
                db.save(record) { (record, error) in
                    if let error = error {
                        print(#function, error)
                        return
                    }
                    
                    if let _ = record {
                        // print(#function, "success on saving user.")
                        print("User Record saved")
                    }
                }
                
                return
            }
            
            if let record = record {
                // print(#function, "success on updating user.")
                print("User Record found")
                
                // record["id"] = id as String
                record["name"] = name as String
                record["email"] = email as String
                let valid: Int64 = 100 // 100: valid, 200: invalid (logout)
                record["valid"] = valid as Int64
                
                // save
                db.save(record) { (record, error) in
                    if let error = error {
                        print(#function, error)
                        return
                    }
                    
                    if let _ = record {
                        // print(#function, "success on saving user.")
                        print("User Record updated")
                    }
                }
            }
        }
    }
    
    static func removeUser(_ id: String, onComplete: @escaping ((Int) -> Void)) { // update: fetch + save
        // fetch
        let recordID = CKRecord.ID.init(recordName: id)
        
        let db = CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase
        db.fetch(withRecordID: recordID) { (record, error) in
            if let error = error {
                print(#function, error)
                // return
                onComplete(0)
            }
            
            if let record = record {
                // print(#function, "success on updating user.")
                
                let valid: Int64 = 200 // 100: valid, 200: invalid (logout)
                record["valid"] = valid as Int64
                
                // save
                db.save(record) { (record, error) in
                    if let error = error {
                        print(#function, error)
                        // return
                        onComplete(0)
                    }
                    
                    if let _ = record {
                        print(#function, "success on saving user.")
                        onComplete(1)
                    }
                }
            }
        }
    }
    
    
    
    /*
     // MARK: - delete from CloudKit
     static func delete(recordID: CKRecord.ID, completion: @escaping (Result<CKRecord.ID, Error>) -> ()) {
     CKContainer.default().publicCloudDatabase.delete(withRecordID: recordID) { (recordID, err) in
     DispatchQueue.main.async {
     if let err = err {
     completion(.failure(err))
     return
     }
     guard let recordID = recordID else {
     completion(.failure(CloudManagerError.recordIDFailure))
     return
     }
     completion(.success(recordID))
     }
     }
     }
     
     // MARK: - modify in CloudKit
     static func modify(item: ListElement, completion: @escaping (Result<ListElement, Error>) -> ()) {
     guard let recordID = item.recordID else { return }
     CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { record, err in
     if let err = err {
     DispatchQueue.main.async {
     completion(.failure(err))
     }
     return
     }
     guard let record = record else {
     DispatchQueue.main.async {
     completion(.failure(CloudManagerError.recordFailure))
     }
     return
     }
     record["text"] = item.text as CKRecordValue
     
     CKContainer.default().publicCloudDatabase.save(record) { (record, err) in
     DispatchQueue.main.async {
     if let err = err {
     completion(.failure(err))
     return
     }
     guard let record = record else {
     completion(.failure(CloudManager.recordFailure))
     return
     }
     let recordID = record.recordID
     guard let text = record["text"] as? String else {
     completion(.failure(CloudManager.castFailure))
     return
     }
     let listElement = ListElement(recordID: recordID, text: text)
     completion(.success(listElement))
     }
     }
     }
     }
     */
}
