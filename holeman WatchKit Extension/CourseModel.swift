//
//  CourseModel.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/16.
//

import Foundation
import CoreLocation.CLLocation

struct CourseModel {
    var address: String
    var countryCode: String
    var courses: [CourseItem]
    var id: Int64
    var location: CLLocation
    var name: String
    var email: String
    var hlds: Int64
}

struct CourseItem {
    var name: String
    var range: [Int]
}
