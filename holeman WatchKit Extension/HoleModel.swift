//
//  HoleModel.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/26.
//

import Foundation

struct HoleModel {
    var id: Int64
    var unit: String
    var holes: [HoleItem]
}

struct HoleItem {
    var name: String // name(color)
    var value: Int // value
}
