//
//  MainView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/11/22.
//

import SwiftUI

extension Notification.Name {
    static let sensorUpdated = Notification.Name("SensorUpdated")
}

struct MainView: View {
    @State var mode: Int = 0
    
    // var save: Bool?
    
    let sensorUpdatedNotification = NotificationCenter.default.publisher(for: .sensorUpdated)
    
    @State var textHoleName: String = "별우(STAR) 9TH"
    @State var textPar: String = "PAR 4"
    @State var textHandicap: String = "HDCP 12"
    @State var textUnit: String = ""
    @State var textTeeDistance: String = "• 330"
    @State var colorTeeDistance: Color = Color.white
    // @State var textDistance: String = "384"
    // @State var textHeight: String = "-9"
    @State var textMessage: String = ""
    @State var progressValue: Float = 0.0
    
    @ObservedObject var locationManager = LocationManager()
    
    var distance: String {
        if let location = locationManager.lastLocation {
            if self.latitude == nil || self.longitude == nil { return "0" }
            
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let coordinate1 = CLLocation(latitude: latitude, longitude: longitude)
            
            let coordinate2 = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
            
            var distance = coordinate1.distance(from: coordinate2) // result is in meters
            
            // ToDo: internal test (distance)
            // print(distance)
            distance = distance - 289642 + 380 // 매탄동
            // distance = distance - 307348 + 380 // 우면동
            
            // var returnValue: Double = 0
            var returnValue: Int = 0
            if self.distanceUnit == 0 {
                // returnValue = round(distance * 10) / 10
                returnValue = Int(round(distance))
                
                if returnValue > 999 { returnValue = 999 }
            } else if self.distanceUnit == 1 {
                let tmp = distance * 1.09361
                // returnValue = round(tmp * 10) / 10
                returnValue = Int(round(tmp))
                
                if returnValue > 999 { returnValue = 999 }
            }
            
            return "\(returnValue)"
        } else {
            return "0"
        }
    }
    
    var height: String {
        if let location = locationManager.lastLocation {
            if MainView.elevationDiff == nil || self.elevation == nil { return "0" }
            
            let altitude = location.altitude
            
            let height = altitude + MainView.elevationDiff!
            let d = self.elevation! - height
            
            // var returnValue: Double = 0
            var returnValue: Int = 0
            if self.distanceUnit == 0 {
                // returnValue = round(d * 10) / 10
                returnValue = Int(round(d))
                
                if returnValue > 999 { returnValue = 999 }
            } else if self.distanceUnit == 1 {
                let tmp = d * 1.09361
                // returnValue = round(tmp * 10) / 10
                returnValue = Int(round(tmp))
                
                if returnValue > 999 { returnValue = 999 }
            }
            
            return "\(returnValue)"
        } else {
            return "0"
        }
    }
    
    var bearing: Double {
        if let location = locationManager.lastLocation {
            if let heading = locationManager.heading {
                // print(#function, heading)
                
                if self.latitude == nil || self.longitude == nil { return 0 }
                
                // calc bearing
                let bearing = Util.getBearing(self.latitude!, self.longitude!, location.coordinate.latitude, location.coordinate.longitude)
                
                var angle = heading + bearing
                // angle = (angle + 360) % 360
                
                let tmp = angle + 360
                angle = tmp.truncatingRemainder(dividingBy: 360)
                
                return angle
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    @State var timer1: Timer? = nil // get user elevation timer
    @State var timer2: Timer? = nil // hole pass check timer
    
    // static var getUserElevationTimerStarted = false
    static var lastGetUserElevationTime: UInt64?
    static var elevationDiff: Double?
    static var lastHoleNumber: Int?
    static var lastTeeingGroundIndex: Int?
    
    
    @State var course: CourseModel? = nil
    @State var teeingGroundInfo: TeeingGroundInfoModel? = nil
    @State var teeingGroundIndex: Int?
    @State var holeNumber: Int? // current hole number
    @State var distanceUnit: Int = -1 // 0: meter, 1: yard
    @State var sensors: [SensorModel] = []
    @State var latitude: Double?
    @State var longitude: Double?
    @State var elevation: Double? // hole elevation
    // 3.
    @State var userElevation: Double? // user elevation (mElevation) - meter
    
    struct Menu: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .padding(6)
                .background(configuration.isPressed ? Color.green : Color.green.opacity(0))
                .clipShape(Circle())
        }
    }
    
    struct HoleName: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .padding(2)
                .background(configuration.isPressed ? Color.green : Color.green.opacity(0))
                .cornerRadius(2)
        }
    }
    
    // @ObservedObject var compassHeading = CompassHeading()
    
    // ToDo: static (30 m)
    static let HOLE_PASS_DISTANCE: Double = 30 // meter
    @State var holePassFlag = 100 // 100: normal state, 200: 홀까지 남은 거리가 30미터 안으로 들어왔을 때, 300: 10초 머물렀을 때, 400: 다시 30미터 (+ 10미터) 밖으로 나갔을 때
    @State var holePassCount = 0
    // @State var holePassStartTime: DispatchTime? = nil
    
    // pass to TeeView & HoleView
    @State var names: [String]?
    @State var color: [Color]?
    @State var distances: [String]?
    
    // pass to HoleSearchView
    @State var from: Int?
    
    /*
     var btn: some View { Button(action: {
     // self.presentationMode.wrappedValue.dismiss()
     }) {
     HStack {
     Image("ic_back") // set image here
     .aspectRatio(contentMode: .fit)
     .foregroundColor(.white)
     Text("Go back")
     }
     }
     }
     */
    
    var body: some View {
        if self.mode == 0 {
            
            // message //
            ZStack {
                /*
                 Color.yellow
                 .opacity(0.1)
                 .edgesIgnoringSafeArea(.all)
                 */
                
                VStack {
                    if let name = self.course?.name {
                        let start1 = name.firstIndex(of: "(")
                        let end1 = name.firstIndex(of: ")")
                        
                        let i1 = name.index(start1!, offsetBy: -1)
                        
                        let range1 = name.startIndex..<i1
                        let str1 = name[range1]
                        
                        let i2 = name.index(start1!, offsetBy: 1)
                        
                        let range2 = i2..<end1!
                        let str2 = name[range2]
                        
                        Text(str1).font(.system(size: 16))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(str2).font(.system(size: 12)) // 영문 코스명은 12로 고정
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer().frame(maxHeight: .infinity)
                    }
                }
                
                VStack {
                    // textMessage 폰트 크기는 20이지만, holeName만 24로 키운다
                    Text(self.textMessage).font(.system(size: 24)).fontWeight(.medium).multilineTextAlignment(.center)
                    // .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    ProgressBar(progress: self.$progressValue)
                        .frame(width: 54, height: 54)
                        .padding(10.0)
                        .onAppear(perform: {
                            self.progressValue = 0.0
                            
                            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                                let randomValue = Float([0.012, 0.022, 0.034, 0.016, 0.11].randomElement()!)
                                self.progressValue += randomValue
                                
                                if self.progressValue >= 1 {
                                    timer.invalidate()
                                    // print(#function, "timer stopped.")
                                    
                                    // self.progressValue = 0.0
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation {
                                            self.mode = 1
                                        }
                                    }
                                }
                            }
                        })
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            .onAppear(perform: {
                let holeName = self.teeingGroundInfo?.holes[self.holeNumber! - 1].name ?? ""
                
                self.textMessage = holeName
            })
            
        } else if self.mode == 1 {
            
            // main //
            GeometryReader { geometry in
                ZStack {
                    // menu icon
                    VStack {
                        HStack {
                            Button(action: {
                                // go to TeeView
                                withAnimation {
                                    self.mode = 4
                                }
                            }) {
                                Image(systemName: "list.bullet")
                                    .font(Font.system(size: 14, weight: .heavy))
                            }
                            // .buttonStyle(PlainButtonStyle())
                            .buttonStyle(Menu())
                            .padding(.leading, 8)
                            // .padding(.leading, 108)
                            
                            Spacer()
                        }.padding(.top, 4)
                        
                        Spacer().frame(maxHeight: .infinity)
                    }
                    
                    // circle
                    VStack {
                        Circle()
                            .strokeBorder(Color(red: 51/255, green: 51/255, blue: 51/255), lineWidth: 8)
                            .frame(width: geometry.size.width, height: geometry.size.width)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    
                    VStack {
                        Circle()
                            .fill(Color(red: 255 / 255, green: 0 / 255, blue: 0 / 255))
                            // .frame(width: geometry.size.width, height: geometry.size.width)
                            .frame(width: 8, height: 8)
                        Spacer().frame(height: geometry.size.width - 8)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    .rotationEffect(Angle(degrees: self.bearing))
                    
                    // text 1
                    VStack(alignment: HorizontalAlignment.center, spacing: 0)  {
                        // Text("별우(STAR) 9TH").font(.system(size: 14)).padding(.top, 46)
                        
                        Button(action: {
                            getHoleViewInfo()
                            
                            // go to HoleView
                            withAnimation {
                                self.mode = 2
                            }
                        }) {
                            Text(self.textHoleName).font(.system(size: 14))
                        }
                        .padding(.top, 46)
                        
                        //.buttonStyle(PlainButtonStyle())
                        .buttonStyle(HoleName())
                        
                        
                        HStack(spacing: 4) {
                            Text(self.textPar).font(.system(size: 14))
                            Text(self.textHandicap).font(.system(size: 14))
                            // Text("• 330").font(.system(size: 14))
                            
                            
                            Button(action: {
                                getTeeViewInfo()
                                
                                // go to TeeView
                                withAnimation {
                                    self.mode = 3
                                }
                            }) {
                                Text(self.textTeeDistance).font(.system(size: 14)).foregroundColor(self.colorTeeDistance)
                            }
                            .buttonStyle(HoleName())
                        }
                        
                        Spacer().frame(maxHeight: .infinity)
                    }
                    
                    // text 2
                    VStack(alignment: .center)  {
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text(self.distance).font(.system(size: 56))
                                .onTapGesture {
                                    toggleUnit()
                                    setTeeDistance()
                                }
                            
                            Text(self.textUnit).font(.system(size: 14))
                                .onTapGesture {
                                    toggleUnit()
                                    setTeeDistance()
                                }
                        }
                    }
                    
                    // text 3
                    VStack(alignment: .leading)  {
                        Spacer().frame(maxHeight: .infinity)
                        
                        HStack(spacing: 2) {
                            Image("hills")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .padding(.top, 4)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                Text(self.height).font(.system(size: 32))
                                    .onTapGesture {
                                        toggleUnit()
                                        setTeeDistance()
                                    }
                                
                                Text(self.textUnit).font(.system(size: 8))
                                    .onTapGesture {
                                        toggleUnit()
                                        setTeeDistance()
                                    }
                            }
                        }
                        .padding(.bottom, 48)
                    }
                    
                    // course name
                    VStack {
                        Spacer().frame(maxHeight: .infinity)
                        
                        Text(Util.getCourseName(self.course?.name)).font(.system(size: 12))
                            .foregroundColor(.gray)
                        //.fixedSize(horizontal: false, vertical: true)
                        //.lineLimit(1)
                        //.frame(maxWidth: .infinity, alignment: .leading)
                    }
                } // end of ZStack
            }
            // .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            // .navigationBarTitle("")
            // .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .onAppear {
                if self.distanceUnit == -1 {
                    if self.teeingGroundInfo?.unit == "M" {
                        self.distanceUnit = 0
                    } else if self.teeingGroundInfo?.unit == "Y" {
                        self.distanceUnit = 1
                    }
                }
                
                // update UI
                self.textHoleName = self.teeingGroundInfo?.holes[self.holeNumber! - 1].name ?? ""
                self.textPar = "PAR " + String(self.teeingGroundInfo?.holes[self.holeNumber! - 1].par ?? 0)
                self.textHandicap = "HDCP " + String(self.teeingGroundInfo?.holes[self.holeNumber! - 1].handicap ?? 0)
                
                // set tee distance
                setTeeDistance()
                
                // set hole distance
                if self.sensors.count == 0 {
                    // get sensors (& subscribe)
                    
                    let groupId = self.course?.id
                    
                    CloudManager.subscribeToSensors(groupId!)
                    
                    getSensors(groupId!) {
                        /*
                         for sensor in self.sensors {
                         if sensor.holeNumber == self.holeNumber! {
                         
                         self.latitude = sensor.location.coordinate.latitude
                         self.longitude = sensor.location.coordinate.longitude
                         self.elevation = sensor.elevation
                         
                         break
                         }
                         }
                         */
                        if self.holeNumber! - 1 < self.sensors.count {
                            let sensor = self.sensors[self.holeNumber! - 1]
                            
                            self.latitude = sensor.location.coordinate.latitude
                            self.longitude = sensor.location.coordinate.longitude
                            self.elevation = sensor.elevation
                        }
                    }
                } else {
                    /*
                     for sensor in self.sensors {
                     if sensor.holeNumber == self.holeNumber! {
                     
                     self.latitude = sensor.location.coordinate.latitude
                     self.longitude = sensor.location.coordinate.longitude
                     self.elevation = sensor.elevation
                     
                     break
                     }
                     }
                     */
                    if self.holeNumber! - 1 < self.sensors.count {
                        let sensor = self.sensors[self.holeNumber! - 1]
                        
                        self.latitude = sensor.location.coordinate.latitude
                        self.longitude = sensor.location.coordinate.longitude
                        self.elevation = sensor.elevation
                    }
                }
                
                // set height
                // print("MainView.getUserElevationTimerStarted ==", MainView.getUserElevationTimerStarted)
                // if MainView.getUserElevationTimerStarted == false {
                startGetUserElevationTimer()
                // MainView.getUserElevationTimerStarted = true
                // }
                
                // start HolePassCheck timer
                startCheckHolePassTimer()
                
                // save hole info
                saveHoleOnAppear()
            }
            .onDisappear {
                // stop timer
                self.timer1?.invalidate()
                self.timer2?.invalidate()
            }
            .onReceive(sensorUpdatedNotification) { notification in
                print(#function, notification)
                
                let s: SensorModel = notification.object as! SensorModel
                
                // let id = s.id
                let holeNumber = s.holeNumber
                let location = s.location
                let elevation = s.elevation
                let timestamp = s.timestamp
                let battery = s.battery
                
                for (index, item) in self.sensors.enumerated() {
                    if item.holeNumber == holeNumber {
                        // print(#function, "updated.")
                        
                        self.sensors[index].location = location
                        self.sensors[index].elevation = elevation
                        self.sensors[index].timestamp = timestamp
                        self.sensors[index].battery = battery
                        
                        self.latitude = location.coordinate.latitude
                        self.longitude = location.coordinate.longitude
                        self.elevation = elevation
                        
                        break
                    }
                }
            }
            
        } else if self.mode == 2 { // open HoleView
            
            HoleView(names: self.names!, selectedIndex: self.holeNumber! - 1,
                     // backup
                     __course: self.course, __teeingGroundInfo: self.teeingGroundInfo, __teeingGroundIndex: self.teeingGroundIndex,
                     /*__holeNumber: self.holeNumber,*/ __distanceUnit: self.distanceUnit,
                     __sensors: self.sensors, __latitude: self.latitude, __longitude: self.longitude, __elevation: self.elevation,
                     __userElevation: self.userElevation
            )
            
        } else if self.mode == 3 { // open TeeView
            
            TeeView(names: self.names!, color: self.color!, distances: self.distances!, selectedIndex: self.teeingGroundIndex!,
                    // backup
                    __course: self.course, __teeingGroundInfo: self.teeingGroundInfo, /*__teeingGroundIndex: self.teeingGroundIndex,*/
                    __holeNumber: self.holeNumber, __distanceUnit: self.distanceUnit,
                    __sensors: self.sensors, __latitude: self.latitude, __longitude: self.longitude, __elevation: self.elevation,
                    __userElevation: self.userElevation
            )
            
        } else if self.mode == 4 { // open MenuView
            
            MenuView(/*names: self.names!, color: self.color!, distances: self.distances!, selectedIndex: self.teeingGroundIndex!,*/
                // backup
                __course: self.course, __teeingGroundInfo: self.teeingGroundInfo, __teeingGroundIndex: self.teeingGroundIndex,
                __holeNumber: self.holeNumber, __distanceUnit: self.distanceUnit,
                __sensors: self.sensors, __latitude: self.latitude, __longitude: self.longitude, __elevation: self.elevation,
                __userElevation: self.userElevation
            )
            
        } else if self.mode == 21 {
            
            // move to HoleSearchView
            HoleSearchView(from: self.from, course: self.course, teeingGroundIndex: self.teeingGroundIndex!)
            
        } else if self.mode == 99 {
            
            // compass test //
            /*
             VStack {
             //Spacer()
             //Capsule().frame(width: 5, height: 50)
             
             ZStack {
             ForEach(Marker.markers(), id: \.self) { marker in
             CompassMarkerView(marker: marker,
             compassDegress: self.locationManager.heading ?? 0)
             }
             }
             .frame(width: 300, height: 300)
             .rotationEffect(Angle(degrees: self.locationManager.heading ?? 0))
             // .statusBar(hidden: true)
             }
             */
            
            /*
             Capsule().frame(width: 5, height: 50)
             
             
             ZStack {
             ForEach(Marker.markers(), id: \.self) { marker in
             CompassMarkerView(marker: marker, compassDegress: self.compassHeading.degrees)
             // CompassMarkerView(marker: marker, compassDegress: self.compassHeading.lastDegrees)
             }
             }
             .frame(width: 300, height: 300)
             .rotationEffect(Angle(degrees: self.compassHeading.degrees))
             // .rotationEffect(Angle(degrees: self.compassHeading.lastDegrees))
             // .statusBar(hidden: true)
             .navigationBarTitle("")
             .navigationBarBackButtonHidden(true)
             .navigationBarHidden(true)
             */
            
            GeometryReader { geometry in
                VStack {
                    Circle()
                        .fill(Color(red: 255 / 255, green: 0 / 255, blue: 0 / 255))
                        // .frame(width: geometry.size.width, height: geometry.size.width)
                        .frame(width: 8, height: 8)
                    Spacer().frame(height: geometry.size.width - 8)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            }
            .rotationEffect(Angle(degrees: self.locationManager.heading ?? 0))
            .edgesIgnoringSafeArea(.all)
            // .navigationBarTitle("")
            // .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            
        }
    }
    
    func getHoleViewInfo() {
        let count = self.teeingGroundInfo?.holes.count
        
        var names: [String] = []
        
        var i = 0
        while (i < count!) {
            let name = self.teeingGroundInfo?.holes[i].name
            
            names.append(name!)
            
            i += 1
        } // end of while
        
        self.names = names
    }
    
    func getTeeViewInfo() {
        let count = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds.count
        
        var names: [String] = []
        var color: [Color] = []
        var distances: [String] = []
        // var selectedIndex: Int = -1
        
        var i = 0
        while (i < count!) {
            let name = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[i].name
            
            let c = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[i].color
            let _c: Color = Util.getColor(c!)
            
            var distance = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[i].distance
            var unit: String
            
            if self.distanceUnit == 0 { // meter
                if self.teeingGroundInfo?.unit == "M" {
                    // N/A
                } else {
                    // yard to meter
                    if let d = distance {
                        let tmp = Double(d) * 0.9144
                        distance = Int(tmp.rounded())
                    }
                }
                
                unit = "m"
            } else { // yard
                if self.teeingGroundInfo?.unit == "Y" {
                    // N/A
                } else {
                    // meter to yard
                    if let d = distance {
                        let tmp = Double(d) * 1.09361
                        distance = Int(tmp.rounded())
                    }
                }
                
                unit = "yd"
            }
            
            let d = String(distance!) + " " + unit
            
            names.append(name!)
            color.append(_c)
            distances.append(d)
            
            i += 1
        } // end of while
        
        self.names = names
        self.color = color
        self.distances = distances
        // self.selectedIndex = self.teeingGroundIndex
    }
    
    func getSensors(_ groupId: Int64, onComplete: @escaping () -> Void) {
        // print("getSensors", groupId)
        
        CloudManager.getSensors(groupId) { records in
            if let records = records {
                for record in records {
                    // let id = record["id"] as! Int64
                    let holeNumber = record["holeNumber"] as! Int64
                    let elevation = record["elevation"] as! Double
                    let location = record["location"] as! CLLocation
                    let battery = record["battery"] as! Int64
                    let timestamp = record["timestamp"] as! Int64
                    
                    let sensor = SensorModel(id: groupId, holeNumber: holeNumber, elevation: elevation, location: location, battery: battery, timestamp: timestamp)
                    print("sensor", sensor)
                    
                    self.sensors.append(sensor)
                    
                    onComplete()
                }
            } else {
                // N/A
            }
        }
    } // end of getSensors
    
    func setTeeDistance() {
        let teeingGround = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[self.teeingGroundIndex!]
        // print(#function, teeingGround)
        
        let color = teeingGround?.color
        let _c = Util.getColor(color!)
        
        // var name = teeingGround?.name
        
        var distance = teeingGround?.distance
        
        if self.distanceUnit == 0 { // meter
            if self.teeingGroundInfo?.unit == "M" {
                // N/A
            } else {
                // yard to meter
                if let d = distance {
                    let tmp = Double(d) * 0.9144
                    distance = Int(tmp.rounded())
                }
            }
            
            self.textUnit = "m"
        } else { // yard
            if self.teeingGroundInfo?.unit == "Y" {
                // N/A
            } else {
                // meter to yard
                if let d = distance {
                    let tmp = Double(d) * 1.09361
                    distance = Int(tmp.rounded())
                }
            }
            
            self.textUnit = "yd"
        }
        
        self.textTeeDistance = "• " + String(distance!)
        self.colorTeeDistance = _c
    }
    
    func toggleUnit() {
        if self.distanceUnit == 0 {
            // meter to yard
            
            self.distanceUnit = 1
            
            self.textUnit = "yd"
        } else {
            // yard to meter
            
            self.distanceUnit = 0
            
            self.textUnit = "m"
        }
    }
    
    func startGetUserElevationTimer() {
        if let time1 = MainView.lastGetUserElevationTime {
            let now = DispatchTime.now()
            var interval = now.uptimeNanoseconds - time1
            interval = interval / 1_000_000 // millisecond
            let sec = interval / 1000 // second
            let min = sec / 60
            
            if min >= 15 {
                // start 1 & 2
                startGetUserElevationTimer1()
            } else {
                // start 2
                let minDiff = 15 - min
                let secDiff: Double = Double(minDiff * 60)
                
                print(#function, "GetUserElevationTimer will be started in", minDiff, "min later.")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + secDiff) { // seconds
                    startGetUserElevationTimer2()
                }
            }
        } else {
            // start 1 & 2
            startGetUserElevationTimer1()
        }
    }
    
    func startGetUserElevationTimer1() {
        // (1)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer1 in
            if let location = locationManager.lastLocation {
                timer1.invalidate()
                
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                let alt = location.altitude
                
                // self.getUserElevation(String(lat), String(lon), alt)
                // ToDo: test (일단 google api 스킵)
                self.userElevation = 20.2
                MainView.elevationDiff = self.userElevation! - alt
                
                MainView.lastGetUserElevationTime = DispatchTime.now().uptimeNanoseconds
                
                // (2) ~ (n)
                self.timer1 = Timer.scheduledTimer(withTimeInterval: 60.0 * 30, repeats: true) { _ in // 1 min x 30
                    // Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer2 in
                    // if let location = locationManager.lastLocation {
                    // timer2.invalidate()
                    
                    let lat2 = location.coordinate.latitude
                    let lon2 = location.coordinate.longitude
                    let alt2 = location.altitude
                    
                    // self.getUserElevation(String(lat2), String(lon2), alt2)
                    // ToDo: test (일단 google api 스킵)
                    self.userElevation = 20.2
                    MainView.elevationDiff = self.userElevation! - alt2
                    
                    MainView.lastGetUserElevationTime = DispatchTime.now().uptimeNanoseconds
                    // }
                    // }
                }
            }
        }
    }
    
    func startGetUserElevationTimer2() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer1 in
            if let location = locationManager.lastLocation {
                timer1.invalidate()
                
                // (2) ~ (n)
                self.timer1 = Timer.scheduledTimer(withTimeInterval: 60.0 * 30, repeats: true) { _ in // 1 min x 30
                    let lat2 = location.coordinate.latitude
                    let lon2 = location.coordinate.longitude
                    let alt2 = location.altitude
                    
                    // self.getUserElevation(String(lat2), String(lon2), alt2)
                    // ToDo: test (일단 google api 스킵)
                    self.userElevation = 20.2
                    MainView.elevationDiff = self.userElevation! - alt2
                    
                    MainView.lastGetUserElevationTime = DispatchTime.now().uptimeNanoseconds
                }
            }
        }
    }
    
    func getUserElevation(_ lat: String, _ lon: String, _ alt: Double) {
        // let params = ["username":"john", "password":"123456"] as Dictionary<String, String>
        
        let url = "https://maps.googleapis.com/maps/api/elevation/json?locations=" + lat + "," + lon + "&key=AIzaSyDGeKg4ewR0-MfmHnBWkv6Qfeoc5Ia4vP8";
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        // request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            // print(response!)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                
                if String(describing: json["status"]) == "OK" {
                    if let results = json["results"] as? [String: Any] {
                        if let elevation = results["elevation"] as? String {
                            self.userElevation = Double(elevation)!
                            
                            MainView.elevationDiff = self.userElevation! - alt
                        }
                    }
                }
            } catch {
                print(#function, "error")
            }
        })
        
        task.resume()
    }
    
    func saveHoleOnAppear() {
        /*
         if let save = self.save { // from HoleSearchView
         if save == true {
         print(#function, "saveHole()", 1)
         
         if Global.halftime == 1 { saveHole(1) } // 전반 중
         else { saveHole(3) } // 후반 중
         
         // return
         }
         
         MainView.lastHoleNumber = self.holeNumber
         MainView.lastTeeingGroundIndex = self.teeingGroundIndex
         
         return
         }
         */
        
        if MainView.lastHoleNumber == nil && MainView.lastTeeingGroundIndex == nil { // 최초 로드
            // print(#function, "saveHole()", 2)
            
            if Global.halftime == 1 { saveHole(1) } // 전반 중
            else { saveHole(3) } // 후반 중
            
            MainView.lastHoleNumber = self.holeNumber
            MainView.lastTeeingGroundIndex = self.teeingGroundIndex
            
            return
        }
        
        if MainView.lastHoleNumber != self.holeNumber {
            // print(#function, "saveHole()", 3)
            
            if Global.halftime == 1 { saveHole(1) } // 전반 중
            else { saveHole(3) } // 후반 중
            
            MainView.lastHoleNumber = self.holeNumber
            
            return
        }
        
        if MainView.lastTeeingGroundIndex != self.teeingGroundIndex {
            // print(#function, "saveHole()", 4)
            
            if Global.halftime == 1 { saveHole(1) } // 전반 중
            else { saveHole(3) } // 후반 중
            
            MainView.lastTeeingGroundIndex = self.teeingGroundIndex
            
            return
        }
    }
    
    func startCheckHolePassTimer() {
        self.timer2 = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in // 1 sec
            if let location = locationManager.lastLocation {
                if self.latitude != nil && self.longitude != nil {
                    self.checkHolePass(location.coordinate.latitude, location.coordinate.longitude, self.latitude!, self.longitude!)
                }
            }
        }
    }
    
    func checkHolePass(_ lat1: Double, _ lon1: Double, _ lat2: Double, _ lon2: Double) {
        let coordinate1 = CLLocation(latitude: lat1, longitude: lon1)
        let coordinate2 = CLLocation(latitude: lat2, longitude: lon2)
        
        // 현재 홀의 홀컵과 나 사이의 거리
        var distance = coordinate1.distance(from: coordinate2) // result is in meters
        
        // ToDo: internal test (distance)
        // print(distance)
        distance = distance - 289642 + 380 // 매탄동
        // distance = distance - 307348 + 380 // 우면동
        
        
        // ToDo: 2021-03-15
        // 1. 현재 홀에 있는지 확인
        let stillIn = stillInCurrentHole(distance)
        if stillIn == false { // 현재 홀을 벗어났다면
            // 2. currentHoleNumber+1 부터 한 바퀴까지 돌면서 각 홀에 있는지 체크
            let number = findHole(coordinate1)
            if number != 0 {
                self.holeNumber = number
                
                withAnimation {
                    self.mode = 0
                }
                
                // init
                self.holePassFlag = 100
                self.holePassCount = 0
            }
        } else {
            let result = self.checkHolePass(distance)
            if result == true {
                if (self.holeNumber! % 9) == 0 {
                    // 9홀 종료
                    
                    if Global.halftime == 1 {
                        // 전반 종료
                        
                        saveHole(2)
                    } else if Global.halftime == 2 {
                        // 후반 종료
                        
                        saveHole(4)
                    }
                    
                    if Global.halftime == 1 { moveToHoleSearchView(200) }
                    else if Global.halftime == 2 { moveToHoleSearchView(300) }
                } else {
                    // 일반 홀 종료. 다음 홀로 이동
                    
                    self.holeNumber! += 1
                    
                    // saveHoleOnAppear에서 저장
                    /*
                     if Global.halftime == 1 {
                     // 전반 중
                     
                     saveHole(1)
                     } else if Global.halftime == 2 {
                     // 후반 중
                     
                     saveHole(3)
                     }
                     */
                    
                    // let holeName = self.teeingGroundInfo?.holes[self.holeNumber! - 1].name ?? ""
                    // showMessage(holeName)
                    withAnimation {
                        self.mode = 0
                    }
                }
            }
        }
    }
    
    func checkHolePass(_ distance: Double) -> Bool {
        switch self.holePassFlag {
        case 100:
            if distance < MainView.HOLE_PASS_DISTANCE { self.holePassFlag = 200 }
            return false
            
        case 200:
            if distance < MainView.HOLE_PASS_DISTANCE {
                
                if self.holePassCount >= 10 { // 10 seconds
                    self.holePassFlag = 300
                    self.holePassCount = 0
                    
                    print(#function, "10 seconds up")
                } else {
                    self.holePassCount += 1
                }
                
                /*
                 if self.holePassStartTime == nil {
                 self.holePassStartTime = DispatchTime.now()
                 } else {
                 let now = DispatchTime.now()
                 var interval = now.uptimeNanoseconds - self.holePassStartTime!.uptimeNanoseconds
                 interval = interval / 1_000_000 // millisecond
                 let sec = interval / 1000 // second
                 
                 if sec >= 10 {
                 self.holePassFlag = 300
                 print(#function, "10 seconds")
                 }
                 }
                 */
                
            } else {
                self.holePassFlag = 100
                self.holePassCount = 0
            }
            return false
            
        case 300:
            if distance > (MainView.HOLE_PASS_DISTANCE + 10) { self.holePassFlag = 400 }
            return false
            
        case 400:
            self.holePassFlag = 100
            self.holePassCount = 0
            return true
            
        default:
            return false
        }
    }
    
    func stillInCurrentHole(_ distance: Double) -> Bool {
        var fullBack = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[0].distance
        
        if self.teeingGroundInfo?.unit == "Y" {
            // yard to meter
            let x = Double(fullBack!) * 0.9144
            fullBack = Int(x.rounded())
        }
        
        // print(#function, "full back tee distance (meter)", fullBack!, distance)
        
        fullBack = fullBack! + 30 // full back tee + 30 m
        
        if Double(fullBack!) - distance < 0 {
            return false
        }
        
        return true
    }
    
    func inHole(_ index: Int, _ coordinate: CLLocation) -> Bool {
        // get distance
        let sensor = self.sensors[index]
        let latitude = sensor.location.coordinate.latitude
        let longitude = sensor.location.coordinate.longitude
        let coordinate2 = CLLocation(latitude: latitude, longitude: longitude)
        
        let distance = coordinate.distance(from: coordinate2) // result is in meters
        
        var fullBack = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[0].distance
        
        if self.teeingGroundInfo?.unit == "Y" {
            // yard to meter
            let x = Double(fullBack!) * 0.9144
            fullBack = Int(x.rounded())
        }
        
        // print(#function, "full back tee distance (meter)", fullBack!)
        
        fullBack = fullBack! + 30 // full back tee + 30 m
        
        if Double(fullBack!) - distance < 0 {
            return false
        }
        
        return true
    }
    
    func findHole(_ coordinate: CLLocation) -> Int {
        // print(#function, "sensors count", self.sensors.count, self.holeNumber!)
        
        if let number = self.holeNumber {
            let count = self.sensors.count - 1
            
            for i in 0...count {
                var index = number + i // 다음 홀 index
                
                if index >= self.sensors.count {
                    index = index - self.sensors.count
                }
                
                let result = inHole(index, coordinate)
                if result == true {
                    return (index + 1) // 다음 홀 number
                }
            }
            
            // return (number + 1)
            /*
             var number2 = number + 1 // 다음 홀 number
             let count2 = self.teeingGroundInfo?.holes.count
             if number2 > count2! {
             number2 = number2 - count2!
             }
             
             return number2
             */
            return 0
        } else {
            return 0 // never happen
        }
    }
    
    func saveHole(_ halftime: Int) {
        print(#function, halftime)
        // 1. time
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 2019-12-20 09:40:08
        // dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss" // 2018-May-01 10:41:31
        let dateString = dateFormatter.string(from: date)
        // let interval = date.timeIntervalSince1970
        
        UserDefaults.standard.set(dateString, forKey: "LAST_PLAYED_HOLE_TIME")
        
        // 2. course
        /*
         var address: String
         var countryCode: String
         var courses: [CourseItem]
         var id: Int64
         var location: CLLocation
         var name: String
         */
        
        if let course = self.course {
            
            
            // ToDo: internal test
            Util.saveCourse(course)
            
            
            // address
            UserDefaults.standard.set(course.address, forKey: "LAST_PLAYED_HOLE_COURSE_ADDRESS")
            
            // countryCode
            UserDefaults.standard.set(course.countryCode, forKey: "LAST_PLAYED_HOLE_COURSE_COUNTRY_CODE")
            
            // courses (convert to json string array)
            var coursesStringArray: [String] = []
            
            for c in course.courses {
                let cd = CourseData(name: c.name, range: c.range)
                do {
                    let encodedData = try JSONEncoder().encode(cd)
                    let jsonString = String(data: encodedData, encoding: .utf8)
                    
                    coursesStringArray.append(jsonString!)
                } catch {
                    print(error)
                    return
                }
            }
            
            UserDefaults.standard.set(coursesStringArray, forKey: "LAST_PLAYED_HOLE_COURSE_COURSES")
            
            // id
            UserDefaults.standard.set(course.id, forKey: "LAST_PLAYED_HOLE_COURSE_ID")
            
            // latitude
            UserDefaults.standard.set(course.location.coordinate.latitude, forKey: "LAST_PLAYED_HOLE_COURSE_LATITUDE")
            
            // longitude
            UserDefaults.standard.set(course.location.coordinate.longitude, forKey: "LAST_PLAYED_HOLE_COURSE_LONGITUDE")
            
            // name
            UserDefaults.standard.set(course.name, forKey: "LAST_PLAYED_HOLE_COURSE_NAME")
        }
        
        // 3. hole number
        UserDefaults.standard.set(self.holeNumber, forKey: "LAST_PLAYED_HOLE_HOLE_NUMBER")
        
        // 4. teeing ground info
        // --
        UserDefaults.standard.set(self.teeingGroundInfo?.unit, forKey: "LAST_PLAYED_HOLE_TEEING_GROUND_INFO_UNIT")
        
        if let holes = self.teeingGroundInfo?.holes {
            var holesStringArray: [String] = []
            
            for hole in holes {
                var teeingGroundDataArray: [TeeingGroundData] = []
                for teeingGround in hole.teeingGrounds {
                    let teeingGroundData = TeeingGroundData(name: teeingGround.name, color: teeingGround.color, distance: teeingGround.distance)
                    teeingGroundDataArray.append(teeingGroundData)
                }
                
                let tgd = TeeingGroundsData(teeingGrounds: teeingGroundDataArray, par: hole.par, handicap: hole.handicap, name: hole.name)
                
                do {
                    let encodedData = try JSONEncoder().encode(tgd)
                    let jsonString = String(data: encodedData, encoding: .utf8)
                    
                    holesStringArray.append(jsonString!)
                } catch {
                    print(error)
                    return
                }
            }
            
            UserDefaults.standard.set(holesStringArray, forKey: "LAST_PLAYED_HOLE_TEEING_GROUND_INFO_HOLES")
        }
        // --
        
        // 5. teeing ground index
        UserDefaults.standard.set(self.teeingGroundIndex, forKey: "LAST_PLAYED_HOLE_TEEING_GROUND_INDEX")
        
        // 6. halftime
        UserDefaults.standard.set(halftime, forKey: "LAST_PLAYED_HOLE_HALFTIME")
    }
    
    func moveToHoleSearchView(_ halftime: Int) { // 200: 전반 종료, 300: 후반 종료
        self.from = halftime
        
        withAnimation {
            self.mode = 21
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

/*
 struct Marker: Hashable {
 let degrees: Double
 let label: String
 
 init(degrees: Double, label: String = "") {
 self.degrees = degrees
 self.label = label
 }
 
 func degreeText() -> String {
 return String(format: "%.0f", self.degrees)
 }
 
 static func markers() -> [Marker] {
 return [
 Marker(degrees: 0, label: "N"),
 Marker(degrees: 30),
 Marker(degrees: 60),
 Marker(degrees: 90, label: "E"),
 Marker(degrees: 120),
 Marker(degrees: 150),
 Marker(degrees: 180, label: "S"),
 Marker(degrees: 210),
 Marker(degrees: 240),
 Marker(degrees: 270, label: "W"),
 Marker(degrees: 300),
 Marker(degrees: 330)
 ]
 }
 }
 
 struct CompassMarkerView: View {
 let marker: Marker
 let compassDegress: Double
 
 var body: some View {
 VStack {
 Text(marker.degreeText())
 .fontWeight(.light)
 .rotationEffect(self.textAngle())
 
 Capsule()
 .frame(width: self.capsuleWidth(),
 height: self.capsuleHeight())
 .foregroundColor(self.capsuleColor())
 
 Text(marker.label)
 .fontWeight(.bold)
 .rotationEffect(self.textAngle())
 .padding(.bottom, 180)
 }.rotationEffect(Angle(degrees: marker.degrees))
 }
 
 private func capsuleWidth() -> CGFloat {
 return self.marker.degrees == 0 ? 7 : 3
 }
 
 private func capsuleHeight() -> CGFloat {
 return self.marker.degrees == 0 ? 45 : 30
 }
 
 private func capsuleColor() -> Color {
 return self.marker.degrees == 0 ? .red : .gray
 }
 
 private func textAngle() -> Angle {
 return Angle(degrees: -self.compassDegress - self.marker.degrees)
 }
 }
 */
