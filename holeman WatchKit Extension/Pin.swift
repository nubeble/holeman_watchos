//
//  Pin.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2022/04/23.
//

import Foundation
import CoreLocation.CLLocation

struct Pin {
    var id: Int64
    var holeNumber: Int64
    var elevations: [Double]
    var locations: [CLLocation]
    var battery: Int64
    var timestamp: Int64
}
