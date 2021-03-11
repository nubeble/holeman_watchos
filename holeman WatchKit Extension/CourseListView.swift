//
//  CourseListView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/13.
//

import SwiftUI
import StoreKit

struct CourseListView: View {
    @State var mode: Int = 0
    
    @State var textMessage: String = ""
    @State var findNearbyCourseCounter = 0
    
    // @ObservedObject var locationManager = LocationManager()
    @State var placemark: CLPlacemark?
    @State var countryCode: String?
    
    @State var courses: [CourseModel] = []
    
    @State var selectedCourseIndex: Int = 0
    
    @StateObject var storeManager: StoreManager = StoreManager()
    
    var body: some View {
        if self.mode == 0 {
            
            // loading indicator
            ZStack {
                ProgressView()
                    .scaleEffect(1.2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                
                VStack {
                    Spacer()
                    
                    Text(self.textMessage).font(.system(size: 16)).foregroundColor(Color.gray).fontWeight(.medium)
                        .transition(.opacity)
                        .id(self.textMessage)
                }
            }.onAppear(perform: onCreate)
            
        } else if self.mode == 1 {
            
            GeometryReader { geometry in
                ScrollView() {
                    // VStack {
                    ScrollViewReader { value in
                        LazyVStack {
                            Text("Select Course").font(.system(size: 20, weight: .semibold))
                            Text("골프장을 선택하세요.").font(.system(size: 14, weight: .light)).padding(.bottom, 10)
                            
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
                                    
                                    // ToDo: internal test
                                    /*
                                     withAnimation {
                                     self.mode = 2
                                     }
                                     */
                                    
                                    // payment
                                    withAnimation {
                                        self.mode = 50
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
                                        // Text(str1).font(.system(size: 18))
                                        Text(str1).font(.system(size: 16))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        // Text(str2).font(.system(size: 16))
                                        Text(str2).font(.system(size: 14))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }.id($0)
                            } // end of ForEach
                            
                            Button(action: {
                                withAnimation {
                                    self.mode = 10
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
                            .padding(.bottom, -20) // check default padding
                            
                        }.onAppear {
                            // scroll
                            // value.scrollTo(2)
                        }
                    }
                    // }
                } // end of ScrollView
            }
            
        } else if self.mode == 2 { // move to next (HoleSearchView)
            
            let c = self.courses[self.selectedCourseIndex]
            HoleSearchView(course: c)
            
        } else if self.mode == 50 {
            
            ZStack {
                VStack {
                    Text("Selected Course").font(.system(size: 18, weight: .medium)).foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)
                        .padding(.top, 8)
                    
                    VStack {
                        if let name = self.courses[self.selectedCourseIndex].name {
                            let start1 = name.firstIndex(of: "(")
                            let end1 = name.firstIndex(of: ")")
                            
                            let i1 = name.index(start1!, offsetBy: -1)
                            
                            let range1 = name.startIndex..<i1
                            let str1 = name[range1]
                            
                            let i2 = name.index(start1!, offsetBy: 1)
                            
                            let range2 = i2..<end1!
                            let str2 = name[range2]
                            
                            
                            Text(str1).font(.system(size: 18))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(str2).font(.system(size: 16))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        if let address = self.courses[self.selectedCourseIndex].address {
                            let start1 = address.firstIndex(of: "(")
                            let end1 = address.firstIndex(of: ")")
                            
                            let i1 = address.index(start1!, offsetBy: -1)
                            
                            let range1 = address.startIndex..<i1
                            let str1 = address[range1]
                            
                            let i2 = address.index(start1!, offsetBy: 1)
                            
                            let range2 = i2..<end1!
                            let str2 = address[range2]
                            
                            // local language only
                            Text(str1).font(.system(size: 14)).foregroundColor(Color.gray)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 1)
                        }
                    }
                    .padding(.all, 10)
                    .background(Color(red: 32 / 255, green: 32 / 255, blue: 32 / 255))
                    .cornerRadius(8)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    HStack(spacing: 40) {
                        // button 1
                        Button(action: {
                            withAnimation {
                                // self.mode = 1 // show list
                                self.mode = 10 // go back
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 49 / 255, green: 49 / 255, blue: 49 / 255))
                                    .frame(width: 54, height: 54)
                                
                                Image(systemName: "xmark")
                                    .font(Font.system(size: 28, weight: .heavy))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, 10)
                        
                        // button 2
                        Button(action: {
                            self.storeManager.getProducts(productIDs: Static.productIDs)
                            
                            withAnimation {
                                self.mode = 51
                            }
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
                    }
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            
        } else if self.mode == 21 {
            
            // ToDo: show billing UI
            List(self.storeManager.myProducts, id: \.self) { product in
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(product.localizedTitle) // 1
                            .font(.headline)
                        Text(product.localizedDescription) // 2
                            .font(.caption2)
                    }
                    
                    Spacer()
                    
                    if UserDefaults.standard.bool(forKey: product.productIdentifier) { // 3
                        Text ("Purchased")
                            .foregroundColor(.green)
                    } else {
                        Button(action: {
                            // ToDo: Purchase particular ILO product
                        }) {
                            Text("Buy for \(product.price) $") // 4
                        }
                        .foregroundColor(.blue)
                    }
                }
                
            }
            
        } else if self.mode == 51 {
            
            // if self.storeManager.myProducts.count > 0 {
            if Util.contains(self.storeManager.myProducts, "com.nubeble.holeman.iap.course") == true {
                GeometryReader { geometry in
                    ScrollView() {
                        VStack {
                            Text("Payment").font(.system(size: 20, weight: .semibold))
                            Text("바우쳐를 구매해주세요.").font(.system(size: 14, weight: .light)).padding(.bottom, 10)
                            
                            
                            Text("Holeman Voucher")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(Color(red: 137 / 255, green: 209 / 255, blue: 254 / 255))
                                // .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.center)
                                .padding(.top, -6)
                            
                            Text(Util.getCourseName(self.courses[self.selectedCourseIndex].name) + " 18홀의 정확한 거리 측정 서비스를 1,000원에 이용하세요.")
                                .font(.system(size: 16))
                                .fontWeight(.light)
                                // .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 8)
                            
                            
                            Button(action: {
                                // ToDo: iap, purchase
                                SKPaymentQueue.default().add(self.storeManager) // ToDo: remove
                                
                                let product = Util.getProduct(self.storeManager.myProducts, "com.nubeble.holeman.iap.course")
                                self.storeManager.purchaseProduct(product: product!)
                                
                                withAnimation {
                                    self.mode = 52
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    
                                    Text("￦1,000 / 18 holes").foregroundColor(.black)
                                    //.font(.system(size: 15))
                                    // .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                .frame(height: 50)
                                .background(Color(red: 137 / 255, green: 209 / 255, blue: 254 / 255))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            
                            Button(action: {
                                // go back
                                withAnimation {
                                    self.mode = 10
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
                            .padding(.bottom, -20) // check default padding
                        }
                    }
                }
            } else {
                // loading indicator
                ProgressView()
                    .scaleEffect(1.2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
            }
            
        } else if self.mode == 52 {
            
            if self.storeManager.transactionState == nil || self.storeManager.transactionState == .purchasing {
                // loading indicator
                ProgressView()
                    .scaleEffect(1.2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
            } else if self.storeManager.transactionState == .failed {
                // back to payment
                self.mode = 50
            } else if self.storeManager.transactionState == .purchased {
                // move next in 3 secs
                
                // ToDo: check mark animation
                VStack {
                    Image(systemName: "checkmark")
                        .font(Font.system(size: 40, weight: .heavy))
                }.onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.mode = 2
                        }
                    }
                }
            } else { // restored
                // N/A
            }
            
        } else if self.mode == 10 { // go back
            
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
                    // print("Timer stopped")
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
                findNearbyCourse(location)
            }
        })
    }
    
    func findNearbyCourse(_ location: CLLocation) {
        findAllCourses() { result in
            if result == false {
                // no course nearby. try again in 3 secs
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    if self.findNearbyCourseCounter == 10 {
                        withAnimation(.linear(duration: 0.5)) {
                            self.textMessage = "잠시 후 다시 시도해주세요."
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            // back to CourseView
                            withAnimation {
                                self.mode = 10
                            }
                        }
                        
                        return
                    }
                    
                    // show wait message
                    withAnimation(.linear(duration: 0.5)) {
                        self.textMessage = Util.getWaitMessageForCourse(self.findNearbyCourseCounter)
                    }
                    self.findNearbyCourseCounter += 1
                    
                    findNearbyCourse(location)
                }
            }
        }
    }
    
    func findAllCourses(onComplete: @escaping (_ result: Bool) -> Void) {
        CloudManager.fetchAllCourses(String(self.countryCode!)) { records in
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
                            return
                        }
                    }
                    
                    c.id = id
                    c.location = location
                    c.name = name
                    
                    self.courses.append(c)
                    // --
                }
                
                if count == 0 {
                    print(#function, "no course nearby. try again in 3 seconds")
                    onComplete(false)
                } else {
                    // show list
                    withAnimation {
                        self.mode = 1
                    }
                    
                    onComplete(true)
                }
            } else {
                // N/A
            }
        }
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
} // end of View

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView()
    }
}
