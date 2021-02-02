//
//  CompassHeading.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/11/15.
//

import Foundation
import CoreLocation
import Combine

class CompassHeading: NSObject, ObservableObject, CLLocationManagerDelegate {
    // var objectWillChange = PassthroughSubject<Void, Never>()
    
    private let locationManager: CLLocationManager
    /*
    var degrees: Double = .zero {
        didSet {
            objectWillChange.send()
        }
    }
     */
    
    /*
    var degrees: Double = 0 {
        didSet {
            objectWillChange.send()
        }
    }
 */
    @Published var degree: Double?
    
    /*
    var degrees: Double? {
        willSet {
            // degree = newValue!
            if let n = newValue {
                degree = n
            }
            objectWillChange.send()
        }
    }
    */
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.headingAvailable() {
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // self.degrees = -1 * newHeading.magneticHeading
        self.degree = -1 * newHeading.magneticHeading
    }
}
