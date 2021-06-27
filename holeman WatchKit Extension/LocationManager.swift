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
        
        // self.locationManager.activityType = .fitness
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        
        self.locationManager.requestWhenInUseAuthorization() // ToDo: check notification
        
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
        
        // ToDo: detect permission change (location)
        /*
         if status == .authorizedWhenInUse || status == .authorizedAlways {
         
         } else {
         
         }
         */
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if self.filterLocation(location) {
            // print(#function, location)
            
            self.lastLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = -1 * newHeading.magneticHeading
        
        // print(#function, self.heading)
    }
    
    func filterLocation(_ location: CLLocation) -> Bool {
        let age = -location.timestamp.timeIntervalSinceNow
        if age > 10 { // if the elapsed time is more than 10 seconds
            return false
        }
        
        if location.horizontalAccuracy < 0 { // A negative value indicates that the location’s latitude and longitude are invalid
            return false
        }
        
        if location.horizontalAccuracy > 30 { // ToDo: 30 meters
            return false
        }
        
        return true
    }
}
