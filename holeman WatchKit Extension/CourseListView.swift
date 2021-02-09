//
//  CourseListView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/13.
//

import SwiftUI

struct CourseListView: View {
    @State var mode: Int = 0
    
    // @ObservedObject var locationManager = LocationManager()
    @State var placemark: CLPlacemark?
    @State var countryCode: String?
    
    @State var courses: [CourseModel] = []
    
    @State var selectedCourseIndex: Int = 0
    
    var body: some View {
        
        if self.mode == 0 {
            
            // loading indicator
            ZStack {
                ProgressView()
                    .scaleEffect(1.5, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
            }.onAppear(perform: onCreate)
            .onDisappear {
                // print(#function, "!!!")
            }
            
        } else if self.mode == 1 {
            
            GeometryReader { geometry in
                ScrollView() {
                    // VStack {
                    ScrollViewReader { value in
                        LazyVStack {
                            Text("Select Course").font(.system(size: 20, weight: .semibold))
                            Text("골프장을 선택하세요.").font(.system(size: 16, weight: .light)).padding(.bottom, 10)
                            
                            // Divider()
                            
                            ForEach(0 ..< self.courses.count) {
                                let index = $0
                                
                                let name = self.courses[index].name
                                
                                let start1 = name.firstIndex(of: "(")
                                let end1 = name.firstIndex(of: ")")
                                
                                let i1 = name.index(start1!, offsetBy: -1)
                                
                                let range1 = name.startIndex..<i1
                                let str1 = name[range1]
                                
                                let i2 = name.index(start1!, offsetBy: 1)
                                
                                let range2 = i2..<end1!
                                let str2 = name[range2]
                                
                                Button(action: {
                                    self.selectedCourseIndex = index
                                    // print("button click", name)
                                    
                                    // move to CourseSearchView
                                    withAnimation {
                                        self.mode = 2
                                    }
                                }) {
                                    /*
                                     Text(str1 + "\n" + str2).font(.system(size: 18))
                                     .fixedSize(horizontal: false, vertical: true)
                                     .lineLimit(2)
                                     // .multilineTextAlignment(.leading)
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     */
                                    VStack(spacing: 2) {
                                        Text(str1).font(.system(size: 18))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(str2).font(.system(size: 18 * 0.8))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }.id($0)
                            }
                            
                            Button(action: {
                                withAnimation {
                                    self.mode = 3
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 49 / 255, green: 49 / 255, blue: 49 / 255))
                                        .frame(width: 54, height: 54)
                                    
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(Color(red: 187 / 255, green: 187 / 255, blue: 187 / 255))
                                        .font(Font.system(size: 28, weight: .heavy))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, 6)
                            .padding(.bottom, -20) // ToDo: check default padding
                            
                        }.onAppear {
                            // scroll
                            // value.scrollTo(2)
                        }
                    }
                    // }
                } // end of ScrollView
            }
            
        } else if self.mode == 2 {
            
            let c = self.courses[self.selectedCourseIndex]
            HoleSearchView(course: c)
            
        } else if self.mode == 3 { // go back
            
            CourseView()
            
        }
        
        
        
    }
    
    func onCreate() {
        // print(#function, "onCreate()")
        
        // get country code
        getCountryCodeTimer()
    }
    
    func getCountryCodeTimer() {
        DispatchQueue.main.async {
            let locationManager = LocationManager()
            
            // --
            var runCount = 0
            
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                runCount += 1
                print(#function, "Timer fired #\(runCount)")
                
                if let location = locationManager.lastLocation {
                    print("Timer stopped")
                    timer.invalidate()
                    
                    self.getCountryCode(location: location)
                }
            }
            // --
        }
    }
    
    func getCountryCode(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            // always good to check if no error
            // also we have to unwrap the placemark because it's optional
            // I have done all in a single if but you check them separately
            if error == nil, let placemark = placemarks, !placemark.isEmpty {
                self.placemark = placemark.last
            }
            
            // a new function where you start to parse placemarks to get the information you need
            let result = self.parsePlacemarks(location: location)
            if result == false {
                // call timer again
                getCountryCodeTimer()
            } else {
                CloudKitManager.fetchAllCourses(String(self.countryCode!)) { records in
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
                        
                        if count == 0 {
                            // ToDo: no course nearby
                        } else {
                            // show list
                            withAnimation {
                                self.mode = 1
                            }
                        }
                    } else {
                        // ToDo: error handling
                    }
                }
            }
        })
    }
    
    func parsePlacemarks(location: CLLocation) -> Bool {
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

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView()
    }
}
