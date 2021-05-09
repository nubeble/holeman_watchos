//
//  TeeingGroundData.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/02/07.
//

import Foundation

struct TeeingGroundsData: Codable, Hashable {
    let teeingGrounds: [TeeingGroundData]
    let par: Int
    let handicap: Int
    let title: String
    let name: String
    let tips: [String]
}

// teeingGroundInfo - holes: [TeeingGrounds] - teeingGrounds: [TeeingGround] - TeeingGround item
struct TeeingGroundData: Codable, Hashable {
    let name: String
    let color: String
    let distance: Int
}
