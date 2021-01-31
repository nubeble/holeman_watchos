//
//  SensorModel.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/30.
//

import Foundation
import CoreLocation.CLLocation

struct SensorModel {
    var id: Int64
    var holeNumber: Int64
    var elevation: Double
    var location: CLLocation
    var battery: Int64
    var timestamp: Int64
}
