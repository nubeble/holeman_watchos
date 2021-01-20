//
//  CourseSearchView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/13.
//

import SwiftUI
import CoreLocation
import CloudKit

struct CourseSearchView: View {
    @State var mode: Int = 0
    
    @State var text1: String = "정산컨트리클럽(JEONGSAN CC)"
    
    @ObservedObject var locationManager = LocationManager()
    
    @State var placemark: CLPlacemark?
    // @State var city: String?
    // @State var country: String?
    @State var countryCode: String?
    
    struct CourseData: Codable, Hashable {
        let name: String
        let range: [Int]
    }
    
    // @State var course: CourseModel = CourseModel(address: "", countryCode: "", courses: [], id: 0, location: CLLocation(latitude: 0.0, longitude: 0.0), name: "")
    @State var courses: [CourseModel] = []
    
    var body: some View {
        
        if (self.mode == 0) {
            
            // loading indicator
            ZStack {
                ProgressView()
                    .scaleEffect(1.5, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
            }.onAppear(perform: onCreate)
            
        } else if (self.mode == 1) {
            
            ZStack {
                Text(text1).font(.system(size: 20)).multilineTextAlignment(.center)
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    HStack(spacing: 40) {
                        // button 1
                        Button(action: {
                            // print("button click")
                            /*
                             withAnimation {
                             self.mode = 3
                             }
                             */
                            
                            // ToDo: test
                            withAnimation {
                                self.mode = 3
                            }
                            
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 54, height: 54)
                                
                                Image(systemName: "xmark")
                                    .font(Font.system(size: 28, weight: .heavy))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, 10)
                        // .opacity(button1Opacity)
                        
                        
                        // button 2
                        Button(action: {
                            print("button click")
                            /*
                             withAnimation {
                             self.mode = 3
                             }
                             */
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 54, height: 54)
                                
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(Font.system(size: 28, weight: .heavy))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, 10)
                        // .opacity(button1Opacity)
                    }
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            } // end of ZStack
            
        } else if (self.mode == 2) {
            
            ZStack {
                Text(text1).font(.system(size: 22)).multilineTextAlignment(.center)
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    HStack(spacing: 40) {
                        // button 1
                        Button(action: {
                            print("button click")
                            /*
                             withAnimation {
                             self.mode = 3
                             }
                             */
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 54, height: 54)
                                
                                Image(systemName: "xmark")
                                    .font(Font.system(size: 28, weight: .heavy))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, 10)
                        // .opacity(button1Opacity)
                        
                        
                        // button 3
                        
                        Button(action: {
                            print("button click")
                            /*
                             withAnimation {
                             self.mode = 3
                             }
                             */
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 54, height: 54)
                                
                                Image(systemName: "checkmark")
                                    .font(Font.system(size: 28, weight: .heavy))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, 10)
                        // .opacity(button1Opacity)
                    }
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            } // end of ZStack
            
        } // end of if (mode)
        else if (mode == 3) {
            HoleSearchView(courses: self.courses)
        }
        
    }
    
    private func onCreate() {
        // print(#function, "onCreate()")
        
        // get country code
        getCountryCodeTimer()
    }
    
    private func getCountryCodeTimer() {
        // --
        var runCount = 0
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            runCount += 1
            print(#function, "Timer fired #\(runCount)")
            
            if let location = locationManager.lastLocation {
                self.getCountryCode(location: location)
                
                print("Timer stopped")
                timer.invalidate()
            }
        }
        // --
    }
    
    private func getCountryCode(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            // always good to check if no error
            // also we have to unwrap the placemark because it's optional
            // I have done all in a single if but you check them separately
            if error == nil, let placemark = placemarks, !placemark.isEmpty {
                self.placemark = placemark.last
            }
            
            // a new function where you start to parse placemarks to get the information you need
            let result = self.parsePlacemarks(location: location)
            if (result == false) {
                // call timer again
                getCountryCodeTimer()
            } else {
                // find the nearest course
                // let l:CLLocation = CLLocation(latitude: 36.767056, longitude: 127.221505)
                // CloudKitManager.fetchNearbyLocations(String(self.countryCode!), l) { records in
                CloudKitManager.fetchNearbyLocations(String(self.countryCode!), location) { records in
                    // print(#function, records)
                    if let records = records {
                        var count = 0
                        for record in records {
                            count += 1
                            // print("course #\(count)", record)
                            
                            print("course #\(count)")
                            
                            let address = record["address"] as! String
                            // let countryCode = record["countryCode"] as! String
                            let courses = record["courses"] as! [String]
                            let id = record["id"] as! Int64
                            let location = record["location"] as! CLLocation
                            let name = record["name"] as! String
                            
                            // set data
                            // --
                            var c: CourseModel = CourseModel(address: "", countryCode: "", courses: [], id: 0, location: CLLocation(latitude: 0.0, longitude: 0.0), name: "")
                            
                            c.address = address
                            c.countryCode = countryCode!
                            
                            // courses
                            var i = 0
                            for course in courses {
                                // print("course[\(i)]", course)
                                i += 1
                                
                                // parse json
                                do {
                                    // let data = Data.init(base64Encoded: course)
                                    let data = Data(course.utf8)
                                    let decodedData = try JSONDecoder().decode(CourseData.self, from: data)
                                    // print(decodedData)
                                    
                                    // decodedData.name
                                    // decodedData.range[0], decodedData.range[1]
                                    
                                    let item = CourseItem(name: decodedData.name, range: [decodedData.range[0], decodedData.range[1]])
                                    c.courses.append(item)
                                } catch {
                                    print(error)
                                }
                            }
                            
                            c.id = id
                            c.location = location
                            c.name = name
                            
                            self.courses.append(c)
                            // --
                            
                            // print
                            // --
                            /*
                             print("address", address)
                             
                             var i = 0
                             for course in courses {
                             // print("course[\(i)]", course)
                             i += 1
                             
                             // parse json
                             do {
                             // let data = Data.init(base64Encoded: course)
                             let data = Data(course.utf8)
                             let decodedData = try JSONDecoder().decode(CourseData.self, from: data)
                             print(decodedData)
                             
                             // decodedData.name
                             // decodedData.range[0], decodedData.range[1]
                             } catch {
                             print(error)
                             }
                             }
                             
                             print("id", id)
                             print("latitude", location.coordinate.latitude)
                             print("longitude", location.coordinate.longitude)
                             print("name", name)
                             */
                            // --
                        }
                        
                        if (count == 0) {
                            // ToDo: no course nearby
                        } else {
                            // move to HoleSearchView
                            withAnimation {
                                self.mode = 3
                            }
                        }
                    } else {
                        // ToDo: error handling
                    }
                }
            }
        })
    }
    
    private func parsePlacemarks(location: CLLocation) -> Bool {
        // let location = self.lastLocation
        
        // here we check if location manager is not nil using a _ wild card
        //if let _ = location {
        // unwrap the placemark
        if let placemark = self.placemark {
            // wow now you can get the city name. remember that apple refers to city name as locality not city
            // again we have to unwrap the locality remember optionalllls also some times there is no text so we check that it should not be empty
            /*
             if let city = placemark.locality, !city.isEmpty {
             // here you have the city name
             // assign city name to our iVar
             self.city = city
             
             print(#function, city)
             }
             // the same story optionalllls also they are not empty
             if let country = placemark.country, !country.isEmpty {
             
             self.country = country
             
             print(#function, country)
             }
             */
            // get the country short name which is called isoCountryCode
            if let countryShortName = placemark.isoCountryCode, !countryShortName.isEmpty {
                
                self.countryCode = countryShortName
                
                print(#function, countryShortName)
                
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    } // end of parsePlacemarks()
    
    
}

struct CourseSearchView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSearchView()
    }
}
