//
//  TeeingGroundInfoModel.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/25.
//

import Foundation

struct TeeingGroundInfoModel {
    var unit: String // "M", "Y"
    var holes: [TeeingGrounds]
}

struct TeeingGrounds {
    var teeingGrounds: [TeeingGround]
    var par: Int
    var handicap: Int
    var title: String
    var name: String
}

struct TeeingGround {
    var name: String
    var color: String
    var distance: Int
}
