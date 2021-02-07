//
//  LocationManager.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/11/15.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    // let objectWillChange = PassthroughSubject<Void, Never>()
    
    private let locationManager = CLLocationManager()
    
    /*
     @Published var locationStatus: CLAuthorizationStatus? {
     willSet {
     objectWillChange.send()
     }
     }
     */
    @Published var locationStatus: CLAuthorizationStatus?
    
    /*
     @Published var lastLocation: CLLocation? {
     willSet {
     objectWillChange.send()
     }
     }
     */
    @Published var lastLocation: CLLocation?
    
    @Published var heading: Double?
    
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.headingAvailable() {
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
        
        // print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        
        // print(#function, location)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = -1 * newHeading.magneticHeading
    }
}
