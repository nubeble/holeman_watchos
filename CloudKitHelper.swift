//
//  CloudKitHelper.swift
//  SwiftUICloudKitDemo
//
//  Created by Alex Nagy on 23/09/2019.
//  Copyright © 2019 Alex Nagy. All rights reserved.
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

struct CloudKitHelper {
    
    // record type
    struct RecordType {
        static let Items = "Items"
    }
    
    // MARK: - errors
    enum CloudKitHelperError: Error {
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
                CloudKitHelper.deleteAllSubscriptions(subscriptions) { (count) in
                    // ToDo:

                    print("deleteAllSubscriptions count", count)

                    print("save subscription...")
                    CloudKitHelper.saveSubscription()
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

    static func deleteAllSubscriptions(subscriptions: [CKSubscription], handler: @escaping ((Int) -> Void)) {
        for subscription in subscriptions {
            print("subscription", subscription)

            /*
                print("subscriptionType", subscription.subscriptionType)
                if let querySub = subscription as? CKQuerySubscription {
                let recordType = querySub.recordType! as String
                print("recordType", recordType)
                
                if (recordType == "Sensor") {
                print("already have subscription.")
                existance = true
                break
                }
                }
                */
            
            // delete all subscriptions
            print("delete subscription...")

            var index: Int = 0
            
            // ToDo: sync call
            db.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: { string, error in
                index++

                if error != nil {
                    // deletion of subscription failed, handle error here
                    // return
                }

                if (index == subscriptions.count) {
                    // handler(result)
                    handler(index)
                }
            })

        } // end of for
    }
    
    static func saveSubscription() { // ToDo: parameter: id
        // create subscription
        // predicate: You can customize this to only get notified when particular records are changed.
        
        // let sub = CKQuerySubscription(recordType: "Sensor", predicate: NSPredicate(value: true), options: [ .firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion ])
        
        let id: Int64 = 27
        let predicate = NSPredicate(format: "id == %d", id)
        let sub = CKQuerySubscription(recordType: "Sensor", predicate: predicate, options: [ .firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion ])
        
        // specify what kind of notification we want to receive
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true // silent push notifications
        notification.alertBody = nil
        
        sub.notificationInfo = notification
        
        // save this subscription to iCloud
        // ToDo: If you want to have just a single subscription it may be a good idea to save (into UserDefaults maybe) that subscription is created so you can avoid creating it next time.
        let db = CKContainer(identifier: "iCloud.com.nubeble.holeman.watchkitapp.watchkitextension").publicCloudDatabase
        db.save(sub) { (subscription, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let _ = subscription {
                print("success on saving subscription.")
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
                    completion(.failure(CloudKitHelperError.recordFailure))
                    return
                }
                
                // means success
                let id = record.recordID
                guard let text = record["text"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
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
                //                    completion(.failure(CloudKitHelperError.cursorFailure))
                //                    return
                //                }
                //                print("Cursor: \(String(describing: cursor))")
            }
            
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
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
     completion(.failure(CloudKitHelperError.recordIDFailure))
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
     completion(.failure(CloudKitHelperError.recordFailure))
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
     completion(.failure(CloudKitHelperError.recordFailure))
     return
     }
     let recordID = record.recordID
     guard let text = record["text"] as? String else {
     completion(.failure(CloudKitHelperError.castFailure))
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
