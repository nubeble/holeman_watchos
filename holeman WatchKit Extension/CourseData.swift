//
//  CourseData.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/02/06.
//

import Foundation

// course - courses - course item
struct CourseData: Codable, Hashable {
    let name: String
    let range: [Int]
}
