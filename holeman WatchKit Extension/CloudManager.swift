//
//  CloudManager.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/13.
//

import Foundation
import CloudKit
import SwiftUI

struct CloudManager {
    /*
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
     */
    
    static func subscribe() {
        let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
        
        // db.fetchAllSubscriptions(completionHandler: T##([CKSubscription]?, Error?) -> Void)
        db.fetchAllSubscriptions(completionHandler: { subscriptions, error in
            if error != nil {
                // failed to fetch all subscriptions, handle error here
                // end the function early
                return
            }
            
            if let subscriptions = subscriptions {
                if subscriptions.count == 0 {
                    print("no subscription exists. save subscription...")
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
    
    static func deleteAllSubscriptions(subscriptions: [CKSubscription], onCompletion: @escaping ((Int) -> Void)) {
        let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
        
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
            
            print("delete subscription...")
            
            db.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: { id, error in
                index += 1
                
                if error != nil {
                    // deletion of subscription failed, handle error here
                    // return
                }
                
                if index == subscriptions.count {
                    DispatchQueue.main.async {
                        onCompletion(index)
                    }
                }
            })
        } // for
    }
    
    static func saveSubscription(_ type: String, _ id: Int64, onCompletion: @escaping ((String) -> Void)) {
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
        let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
        db.save(sub) { (subscription, error) in
            if let error = error {
                print(error)
                
                return
            }
            
            if let subscription = subscription {
                print("success on saving subscription.")
                
                DispatchQueue.main.async {
                    onCompletion(subscription.subscriptionID)
                }
            }
        }
    }
    
    // MARK: - save to CloudKit
    /*
     static func save(item: ListElement, completion: @escaping (Result<ListElement, Error>) -> ()) {
     
     // create item record (CKRecord)
     let itemRecord = CKRecord(recordType: RecordType.Items)
     itemRecord["text"] = item.text as CKRecordValue
     
     // public db, default zone
     
     // CKContainer(identifier: "iCloud.com.nubeble.holeman")
     // CKContainer.default()
     CKContainer(identifier: Static.containerId).publicCloudDatabase.save(itemRecord) { (record, err) in // completion handler
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
     */
    /*
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
     */
    
    static func fetchNearbyLocations(_ countryCode: String, _ location: CLLocation, onCompletion: @escaping (_ records: [CKRecord]?) -> Void) {
        print(#function)
        
        let radiusInKilometers = 3 // 3 km
        
        // let p = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < %@", location, NSNumber(value: radiusInKilometers))
        let p = NSPredicate(format: "countryCode = %@ AND distanceToLocation:fromLocation:(location, %@) < %@", countryCode, location, NSNumber(value: radiusInKilometers))
        let query = CKQuery(recordType: "Course", predicate: p)
        // query.sortDescriptors = [CKLocationSortDescriptor(key: "location", relativeLocation: location)] // Consider: not working
        /*
         let operation = CKQueryOperation(query: query)
         operation.resultsLimit = 50
         CKContainer(identifier: Static.containerId).publicCloudDatabase.add(operation)
         */
        
        // CKContainer(identifier: Static.containerId).publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
        CKContainer(identifier: Static.containerId).publicCloudDatabase.perform(query, inZoneWith: CKRecordZone.default().zoneID) { (records, error) in
            if let error = error {
                print("Cloud Query Error: \(error)")
                
                return
            }
            
            if let records = records {
                print(#function, records)
                
                DispatchQueue.main.async {
                    onCompletion(records)
                }
            }
        }
    }
    
    /*
     static func fetchAllCourses(_ countryCode: String, onCompletion: @escaping (_ records: [CKRecord]?) -> Void) {
     let p = NSPredicate(format: "countryCode = %@", countryCode)
     let query = CKQuery(recordType: "Course", predicate: p)
     query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
     
     CKContainer(identifier: Static.containerId).publicCloudDatabase.perform(query, inZoneWith: CKRecordZone.default().zoneID) { (records, error) in
     if let error = error {
     print("Cloud Query Error - Fetch Locations: \(error)")
     
     return
     }
     
     if let records = records {
     // print("#function", records)
     
     DispatchQueue.main.async {
     onCompletion(records)
     }
     }
     }
     }
     */
    static func fetchAllCourses(_ countryCode: String, onCompletion: @escaping (_ records: [CKRecord]?) -> Void) {
        let p = NSPredicate(format: "countryCode = %@", countryCode)
        let query = CKQuery(recordType: "Course", predicate: p)
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
        
        var records = [CKRecord]()
        
        func recurrentOperations(cursor: CKQueryOperation.Cursor?) {
            let recurrentOperation = CKQueryOperation(cursor: cursor!)
            recurrentOperation.qualityOfService = .userInteractive
            recurrentOperation.resultsLimit = 18
            
            recurrentOperation.recordFetchedBlock = { (record:CKRecord!) -> Void in
                // print("-> cloudKitLoadRecords - recurrentOperations - fetch \(counter)")
                records.append(record)
            }
            
            recurrentOperation.queryCompletionBlock = { (cursor: CKQueryOperation.Cursor?, error: Error?) -> Void in
                if let error = error {
                    print(#function, "recurrentOperation error - \(String(describing: error))")
                    
                    return
                }
                
                if let cursor = cursor {
                    // print("recurrentOperations - records \(records.count) - cursor \(cursor.description)")
                    recurrentOperations(cursor: cursor)
                } else {
                    DispatchQueue.main.async {
                        onCompletion(records)
                    }
                }
                
            }
            
            db.add(recurrentOperation)
        }
        
        // initial operation
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive
        operation.resultsLimit = 18
        
        operation.recordFetchedBlock = { (record:CKRecord!) -> Void in
            // print("operation - fetch \(counter)")
            records.append(record)
        }
        
        operation.queryCompletionBlock = { (cursor: CKQueryOperation.Cursor?, error: Error?) -> Void in
            if let error = error {
                print(#function, "operation error - \(String(describing: error))")
                
                return
            }
            
            if let cursor = cursor {
                // print("operations - records \(records.count) - cursor \(cursor.description)")
                recurrentOperations(cursor: cursor)
            } else {
                DispatchQueue.main.async {
                    onCompletion(records)
                }
            }
        }
        
        db.add(operation)
    }
    
    // static func getHoles(_ groupId: Int64, onCompletion: @escaping (_ records:[CKRecord]?) -> Void) {
    static func getHoles(_ groupId: Int64, onCompletion: @escaping (_ record: CKRecord?) -> Void) {
        
        /*
         let p = NSPredicate(format: "id = %d", groupId)
         let query = CKQuery(recordType: "Hole", predicate: p)
         // query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
         
         CKContainer(identifier: Static.containerId).publicCloudDatabase.perform(query, inZoneWith: CKRecordZone.default().zoneID) { (records, error) in
         if let error = error {
         DispatchQueue.main.async {
         print("Cloud Query Error - Fetch Locations: \(error)")
         }
         } else {
         // print(records)
         DispatchQueue.main.async {
         onCompletion(records)
         }
         }
         }
         */
        // fetch by name: hole-27
        let rid = "hole-" + String(groupId)
        let recordID = CKRecord.ID.init(recordName: rid)
        
        CKContainer(identifier: Static.containerId).publicCloudDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let error = error {
                print("Cloud Query Error: \(error)")
                
                return
            }
            
            if let record = record {
                // print(#function, record)
                
                DispatchQueue.main.async {
                    onCompletion(record)
                }
            }
        }
    }
    
    /*
     static func getSensor(_ groupId: Int64, _ holeNumber: Int64, onCompletion: @escaping (_ record: CKRecord?) -> Void) {
     let rid = "sensor-" + String(groupId) + "-" + String(holeNumber)
     let recordID = CKRecord.ID.init(recordName: rid)
     
     CKContainer(identifier: Static.containerId).publicCloudDatabase.fetch(withRecordID: recordID) { (record, error) in
     if let error = error {
     print("Cloud Query Error: \(error)")
     
     return
     }
     
     if let record = record {
     // print("#function", record)
     
     DispatchQueue.main.async {
     onCompletion(record)
     }
     }
     }
     }
     */
    static func getPin(_ groupId: Int64, _ holeNumber: Int64, onCompletion: @escaping (_ record: CKRecord?) -> Void) {
        let rid = "pin-" + String(groupId) + "-" + String(holeNumber)
        let recordID = CKRecord.ID.init(recordName: rid)
        
        CKContainer(identifier: Static.containerId).publicCloudDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let error = error {
                print("Cloud Query Error: \(error)")
                
                return
            }
            
            if let record = record {
                // print("#function", record)
                
                DispatchQueue.main.async {
                    onCompletion(record)
                }
            }
        }
    }
    
    /*
     static func getSensors(_ groupId: Int64, onCompletion: @escaping (_ records:[CKRecord]?) -> Void) {
     let p = NSPredicate(format: "id = %d", groupId)
     let query = CKQuery(recordType: "Sensor", predicate: p)
     query.sortDescriptors = [NSSortDescriptor(key: "holeNumber", ascending: true)]
     
     CKContainer(identifier: Static.containerId).publicCloudDatabase.perform(query, inZoneWith: CKRecordZone.default().zoneID) { (records, error) in
     if let error = error {
     print("Cloud Query Error: \(error)")
     
     return
     }
     
     if let records = records {
     // print(#function, records) // sorted by holeNumber
     
     DispatchQueue.main.async {
     onCompletion(records)
     }
     }
     }
     }
     */
    
    static func getPins(_ groupId: Int64, onCompletion: @escaping (_ records:[CKRecord]?) -> Void) {
        let p = NSPredicate(format: "id = %d", groupId)
        let query = CKQuery(recordType: "Pin", predicate: p)
        query.sortDescriptors = [NSSortDescriptor(key: "holeNumber", ascending: true)]
        
        let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
        
        var records = [CKRecord]()
        
        func recurrentOperations(cursor: CKQueryOperation.Cursor?) {
            let recurrentOperation = CKQueryOperation(cursor: cursor!)
            recurrentOperation.qualityOfService = .userInteractive
            recurrentOperation.resultsLimit = 18
            
            recurrentOperation.recordFetchedBlock = { (record:CKRecord!) -> Void in
                // print("-> cloudKitLoadRecords - recurrentOperations - fetch \(counter)")
                records.append(record)
            }
            
            recurrentOperation.queryCompletionBlock = { (cursor: CKQueryOperation.Cursor?, error: Error?) -> Void in
                if let error = error {
                    print(#function, "recurrentOperation error - \(String(describing: error))")
                    
                    return
                }
                
                if let cursor = cursor {
                    // print("recurrentOperations - records \(records.count) - cursor \(cursor.description)")
                    recurrentOperations(cursor: cursor)
                } else {
                    DispatchQueue.main.async {
                        onCompletion(records)
                    }
                }
                
            }
            
            db.add(recurrentOperation)
        }
        
        // initial operation
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInteractive
        operation.resultsLimit = 18
        
        operation.recordFetchedBlock = { (record:CKRecord!) -> Void in
            // print("operation - fetch \(counter)")
            records.append(record)
        }
        
        operation.queryCompletionBlock = { (cursor: CKQueryOperation.Cursor?, error: Error?) -> Void in
            if let error = error {
                print(#function, "operation error - \(String(describing: error))")
                
                return
            }
            
            if let cursor = cursor {
                // print("operations - records \(records.count) - cursor \(cursor.description)")
                recurrentOperations(cursor: cursor)
            } else {
                DispatchQueue.main.async {
                    onCompletion(records)
                }
            }
        }
        
        db.add(operation)
    }
    
    
    
    
    
    
    
    /*
     static func subscribeToSensors(_ groupId: Int64) {
     let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
     
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
    
    static func subscribeToPins(_ groupId: Int64) {
        // check UserDefaults
        let subId = UserDefaults.standard.string(forKey: "SUBSCRIPTION_PINS_SUB_ID")
        if subId != nil {
            // print("subscription ID", subId)
            let courseId = UserDefaults.standard.integer(forKey: "SUBSCRIPTION_PINS_COURSE_ID")
            // print("course id", courseId)
            if courseId == Int(groupId) {
                // skip saving
                return
            } else {
                // 1. delete db
                let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
                db.delete(withSubscriptionID: subId!, completionHandler: { id, error in
                    // N/A
                })
                
                // 2. save db
                CloudManager.saveSubscription("Pin", groupId) { id in
                    // 3. update ud (subId & courseId)
                    UserDefaults.standard.set(id, forKey: "SUBSCRIPTION_PINS_SUB_ID")
                    UserDefaults.standard.set(groupId, forKey: "SUBSCRIPTION_PINS_COURSE_ID")
                }
            }
        } else {
            // 2. save db
            CloudManager.saveSubscription("Pin", groupId) { id in
                // 3. update ud (subId & courseId)
                UserDefaults.standard.set(id, forKey: "SUBSCRIPTION_PINS_SUB_ID")
                UserDefaults.standard.set(groupId, forKey: "SUBSCRIPTION_PINS_COURSE_ID")
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
         
         let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
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
        
        let recordID = CKRecord.ID.init(recordName: id)
        
        let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
        db.fetch(withRecordID: recordID) { (record, error) in
            if let _ = error {
                // print(#function, "User Record not found")
                
                // create user
                
                let record = CKRecord(recordType: "User", recordID: CKRecord.ID.init(recordName: id))
                record["id"] = id as String
                record["name"] = name as String
                record["email"] = email as String
                let valid: Int64 = 100 // 100: valid, 200: invalid (logout)
                record["valid"] = valid as Int64
                let freeTrialCount: Int64 = 0
                record["freeTrialCount"] = freeTrialCount as Int64
                let purchaseCount: Int64 = 0
                record["purchaseCount"] = purchaseCount as Int64
                
                // let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
                db.save(record) { (record, error) in
                    if let error = error {
                        print(#function, error)
                        
                        return
                    }
                    
                    if let _ = record {
                        print("User Record created")
                    }
                }
                
                // send welcome email
                if email != "noemail" {
                    CloudManager.sendWelcomeEmail(name, email)
                    
                    // CloudManager.openURL() // ToDo: test (open URL)
                }
                
                return
            }
            
            if let record = record {
                // print("User Record found")
                
                // update user
                
                // record["id"] = id as String
                if name != "noname" { record["name"] = name as String }
                if email != "noemail" { record["email"] = email as String }
                let valid: Int64 = 100 // 100: valid, 200: invalid (logout)
                record["valid"] = valid as Int64
                // let freeTrialCount: Int64 = 0
                // record["freeTrialCount"] = freeTrialCount as Int64
                // let purchaseCount: Int64 = 0
                // record["purchaseCount"] = purchaseCount as Int64
                
                // save
                db.save(record) { (record, error) in
                    if let error = error {
                        print(#function, error)
                        
                        return
                    }
                    
                    if let _ = record {
                        print("User Record updated")
                    }
                }
            }
        }
    }
    
    static func sendWelcomeEmail(_ name: String, _ email: String) {
        print(#function, name, email)
        
        let url = "https://asia-northeast1-holeman-4070a.cloudfunctions.net/welcome_email"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        // request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        let data: [String: String] = ["name": name, "email": email]
        let body = try! JSONSerialization.data(withJSONObject: data, options: [])
        request.httpBody = body
        
        // request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            // print(#function, response!)
            
            /*
             do {
             let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
             print(#function, json)
             
             let status = json["status"] as! String
             if status == "OK" {
             let results = json["results"] as! [[String:Any]]
             if let elevation = results[0]["elevation"] as? Double {
             self.userElevation = elevation
             
             MainView.elevationDiff = elevation - alt
             }
             }
             } catch {
             print(#function, "error")
             }
             */
        })
        
        task.resume()
    }
    
    static func openURL() {
        if let url = URL(string: "https://holeman.cc") {
            WKExtension.shared().openSystemURL(url)
        }
    }
    
    static func removeUser(_ id: String, onCompletion: @escaping ((Int) -> Void)) { // update: fetch + save
        // fetch
        let recordID = CKRecord.ID.init(recordName: id)
        
        let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
        db.fetch(withRecordID: recordID) { (record, error) in
            if let error = error {
                print(#function, error)
                
                return
            }
            
            if let record = record {
                // print(#function, "success on updating user.")
                
                let valid: Int64 = 200 // 100: valid, 200: invalid (logout)
                record["valid"] = valid as Int64
                
                // save
                db.save(record) { (record, error) in
                    if let error = error {
                        print(#function, error)
                        
                        return
                    }
                    
                    if let _ = record {
                        print(#function, "success on saving user.")
                        
                        DispatchQueue.main.async {
                            onCompletion(1)
                        }
                    }
                }
            }
        }
    }
    
    static func getUserName(_ userId: String, onCompletion: @escaping ((_ name: String) -> Void)) {
        let recordID = CKRecord.ID.init(recordName: userId)
        
        CKContainer(identifier: Static.containerId).publicCloudDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let _ = error {
                print(#function, "User Record not found")
                
                DispatchQueue.main.async {
                    onCompletion("")
                }
                
                return
            }
            
            if let record = record {
                guard let name = record["name"] as? String else {
                    print(#function, "name error")
                    
                    DispatchQueue.main.async {
                        onCompletion("")
                    }
                    
                    return
                }
                
                DispatchQueue.main.async {
                    onCompletion(name)
                }
            }
        }
    }
    
    /*
     static func setProductId(_ userId: String, _ productId: String) { // update user with purchased product id
     // fetch
     let recordID = CKRecord.ID.init(recordName: userId)
     
     let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
     db.fetch(withRecordID: recordID) { (record, error) in
     if let _ = error {
     print(#function, "User Record not found")
     
     return
     }
     
     if let record = record {
     // print("User Record found")
     
     if record["valid"] as! Int64 == 100 { // valid
     record["lastPurchasedProductId"] = productId as String
     
     // save
     db.save(record) { (record, error) in
     if let error = error {
     print(#function, error)
     
     return
     }
     
     if let _ = record {
     print("User Record updated with purchased product id")
     }
     }
     }
     }
     }
     }
     */
    /*
     static func getProductId(_ userId: String, onCompletion: @escaping ((_ productId: String) -> Void)) {
     let recordID = CKRecord.ID.init(recordName: userId)
     
     CKContainer(identifier: Static.containerId).publicCloudDatabase.fetch(withRecordID: recordID) { (record, error) in
     if let _ = error {
     print(#function, "User Record not found")
     
     return
     }
     
     if let record = record {
     guard let lastPurchasedProductId = record["lastPurchasedProductId"] as? String else {
     print(#function, "lastPurchasedProductId error")
     
     return
     }
     
     DispatchQueue.main.async {
     onCompletion(lastPurchasedProductId)
     }
     }
     }
     }
     */
    
    static func getFreeTrialCount(_ userId: String, onCompletion: @escaping ((_ freeTrialCount: Int64) -> Void)) {
        let recordID = CKRecord.ID.init(recordName: userId)
        
        CKContainer(identifier: Static.containerId).publicCloudDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let _ = error {
                print(#function, "User Record not found")
                
                return
            }
            
            if let record = record {
                guard let freeTrialCount = record["freeTrialCount"] as? Int64 else {
                    print(#function, "freeTrialCount error")
                    
                    return
                }
                
                DispatchQueue.main.async {
                    onCompletion(freeTrialCount)
                }
            }
        }
    }
    
    static func setFreeTrialCount(_ userId: String, _ count: Int64) {
        // fetch
        let recordID = CKRecord.ID.init(recordName: userId)
        
        let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
        db.fetch(withRecordID: recordID) { (record, error) in
            if let _ = error {
                print(#function, "User Record not found")
                
                return
            }
            
            if let record = record {
                // print("User Record found")
                
                if record["valid"] as! Int64 == 100 { // valid
                    record["freeTrialCount"] = count as Int64
                    
                    // save
                    db.save(record) { (record, error) in
                        if let error = error {
                            print(#function, error)
                            
                            return
                        }
                        
                        if let _ = record {
                            print("User Record updated with purchased product id")
                        }
                    }
                }
            }
        }
    }
    
    static func checkFreeTrialCount(_ userId: String, onCompletion: @escaping ((_ freeTrialCount: Int64) -> Void)) { // get & update
        print(#function, userId)
        
        let recordID = CKRecord.ID.init(recordName: userId)
        
        let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
        db.fetch(withRecordID: recordID) { (record, error) in
            if let _ = error {
                print(#function, "User Record not found")
                
                return
            }
            
            if let record = record {
                // print("User Record found")
                
                if record["valid"] as! Int64 == 100 { // valid
                    let freeTrialCount = record["freeTrialCount"] as! Int64
                    
                    if freeTrialCount < 10 {
                        // update DB
                        let count = freeTrialCount + 1
                        record["freeTrialCount"] = count as Int64
                        
                        db.save(record) { (record, error) in
                            if let error = error {
                                print(#function, error)
                                
                                return
                            }
                            
                            if let _ = record {
                                print("User Record updated")
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        onCompletion(freeTrialCount)
                    }
                } else {
                    DispatchQueue.main.async {
                        onCompletion(10) // never come here
                    }
                }
            }
        }
    }
    
    static func updatePurchaseCount(_ userId: String) { // increase purchaseCount
        let recordID = CKRecord.ID.init(recordName: userId)
        
        let db = CKContainer(identifier: Static.containerId).publicCloudDatabase
        db.fetch(withRecordID: recordID) { (record, error) in
            if let _ = error {
                print(#function, "User Record not found")
                
                return
            }
            
            if let record = record {
                // print("User Record found")
                
                if record["valid"] as! Int64 == 100 { // valid
                    let count = record["purchaseCount"] as! Int64 + 1
                    record["purchaseCount"] = count as Int64
                    
                    // save
                    db.save(record) { (record, error) in
                        if let error = error {
                            print(#function, error)
                            
                            return
                        }
                        
                        if let _ = record {
                            print("User Record updated with purchased product id")
                        }
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
