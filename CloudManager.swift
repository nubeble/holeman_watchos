//
//  CloudManager.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/10/26.
//

import Foundation
import CloudKit


enum FetchError {
    case fetchingError, noRecords, none
}

struct CloudManager {
    
    private let RecordType = "Course"
    
    func fetch(completion: @escaping ([CKRecord]?, FetchError) -> Void) {
        let publicDatabase = CKContainer(identifier: "iCloud.com.nubeble.holeman").publicCloudDatabase // public db
        
        
        // let query = CKQuery(recordType: RecordType, predicate: NSPredicate(value: true))
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: RecordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "country_code", ascending: false)] // ToDo: check
        
        publicDatabase.perform(query, inZoneWith: CKRecordZone.default().zoneID, completionHandler: { (records, error) -> Void in // default record zone
            
            self.processQueryResponseWith(records: records, error: error as NSError?, completion: { fetchedRecords, fetchError in
                completion(fetchedRecords, fetchError)
            })
            
        })
    }
    
    
    private func processQueryResponseWith(records: [CKRecord]?, error: NSError?, completion: @escaping ([CKRecord]?, FetchError) -> Void) {
        guard error == nil else {
            completion(nil, .fetchingError)
            return
        }
        
        guard let records = records, records.count > 0 else {
            completion(nil, .noRecords)
            return
        }
        
        completion(records, .none)
    }
    
}


