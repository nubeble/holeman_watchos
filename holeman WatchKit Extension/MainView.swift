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
    
    let altitudeDiff: Double = 46 // ToDo: 안드로이드와의 차이 (m)
    
    let sensorUpdatedNotification = NotificationCenter.default.publisher(for: .sensorUpdated)
    
    @State var textHoleTitle: String = "별우(STAR) 9TH"
    @State var textPar: String = "PAR 4"
    @State var textHandicap: String = "HDCP 12"
    @State var textUnit: String = ""
    @State var textTeeDistance: String = "• 330"
    @State var colorTeeDistance: Color = Color.white
    // @State var textDistance: String = "384"
    // @State var textHeight: String = "-9"
    @State var message1: String = ""
    @State var message2: String = ""
    @State var message1FontSize: CGFloat = Global.text1Size
    @State var progressValue: Float = 0.0
    @State var tips: String = ""
    
    @ObservedObject var locationManager = LocationManager()
    
    var distance: String {
        if let location = self.locationManager.lastLocation {
            if self.latitude == nil || self.longitude == nil { return "0" }
            
            let coordinate1 = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let coordinate2 = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
            
            let distance = coordinate1.distance(from: coordinate2) // result is in meters
            
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
        } else { // never come here
            return "0"
        }
    }
    
    var height: String {
        if let location = self.locationManager.lastLocation {
            if MainView.elevationDiff == nil || self.elevation == nil { return "0" }
            
            let altitude = location.altitude + self.altitudeDiff
            // print(#function, "altitude", altitude)
            
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
        if let location = self.locationManager.lastLocation {
            if let heading = self.locationManager.heading {
                // print(#function, heading)
                
                if self.latitude == nil || self.longitude == nil { return 0 }
                
                // calc bearing
                // let bearing = Util.getBearing(self.latitude!, self.longitude!, location.coordinate.latitude, location.coordinate.longitude)
                let bearing = Util.getBearing(location.coordinate.latitude, location.coordinate.longitude, self.latitude!, self.longitude!)
                
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
    // for saveHole
    static var lastHoleNumber: Int?
    // static var lastTeeingGroundIndex: Int?
    static var lastTeeingGroundName: String?
    static var lastGreenDirection: Int?
    
    
    @State var course: CourseModel? = nil
    @State var teeingGroundInfo: TeeingGroundInfoModel? = nil
    // @State var teeingGroundIndex: Int?
    @State var teeingGroundName: String?
    @State var greenDirection: Int? // 100: left green, 200: right green
    @State var holeNumber: Int? // current hole number
    @State var distanceUnit: Int = -1 // 0: meter, 1: yard
    @State var sensors: [SensorModel] = []
    @State var latitude: Double? // hole latitude
    @State var longitude: Double? // hole longitude
    @State var elevation: Double? // hole elevation
    // 3.
    @State var userElevation: Double? // user elevation (meter)
    
    @State var showGreenButton: Bool = false
    
    struct Menu: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .padding(Global.buttonStyle1Padding)
                .background(configuration.isPressed ? Color.gray.opacity(0.5) : Color.gray.opacity(0))
                .clipShape(Circle())
        }
    }
    
    struct GreenNormal: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .padding(Global.buttonStyle2Padding)
                .background(configuration.isPressed ? Color.gray.opacity(0.5) : Color.gray.opacity(0))
                .clipShape(Circle())
        }
    }
    
    struct GreenSelected: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .padding(Global.buttonStyle2Padding)
                .background(configuration.isPressed ? Color.gray.opacity(0.5) : Color.gray.opacity(0))
                .clipShape(Circle())
        }
    }
    
    struct HoleTitle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .padding(Global.buttonStyle3Padding)
                .background(configuration.isPressed ? Color.gray.opacity(0.5) : Color.gray.opacity(0))
                .cornerRadius(Global.radius2)
        }
    }
    
    // @ObservedObject var compassHeading = CompassHeading()
    
    static let HOLE_PASS_DISTANCE: Double = 50 // 50 m
    @State var holePassFlag = 100 // 100: normal state, 200: 홀까지 남은 거리가 50미터 안으로 들어왔을 때, 300: 10초 머물렀을 때, 400: 다시 50미터 밖으로 나갔을 때
    @State var holePassStartTime: DispatchTime? = nil
    
    // pass to TeeView & HoleView
    @State var titles: [String]?
    
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
                        
                        Text(str1).font(.system(size: Global.text3Size))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(str2).font(.system(size: Global.text6Size)) // 영문 코스명은 12로 고정
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer().frame(maxHeight: .infinity)
                    }
                }
                
                if self.message2 == "" {
                    VStack {
                        // textMessage 폰트 크기는 20이지만, holeTitle만 24로 키운다
                        Text(self.message1).font(.system(size: self.message1FontSize)).fontWeight(.medium).multilineTextAlignment(.center)
                        // .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    VStack {
                        // hole title
                        Text(self.message1).font(.system(size: self.message1FontSize)).fontWeight(.medium).multilineTextAlignment(.center)
                    }
                    
                    VStack {
                        // hole name
                        Text(self.message2).font(.system(size: Global.text2Size)).fontWeight(.medium).multilineTextAlignment(.center)
                            .padding(.top, Global.holeNamePaddingTop)
                    }
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    ProgressBar(progress: self.$progressValue)
                    // .frame(width: 54, height: 54)
                        .frame(width: Global.progressBarSize, height: Global.progressBarSize) // 54 - 8 (line width)
                    // .padding(.bottom, 10)
                    // .padding(.bottom, 14) // 10 + 4
                        .padding(.bottom, Global.buttonPaddingBottom + Global.progressBarLineWidth / 2) // 10 + 4
                        .onAppear {
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
                                            // self.mode = 1
                                            self.mode = 9
                                        }
                                    }
                                }
                            }
                        }
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }.onAppear {
                // let title = self.teeingGroundInfo?.holes[self.holeNumber! - 1].title ?? ""
                let title = Util.convertHoleTitle(self.teeingGroundInfo?.holes[self.holeNumber! - 1].title ?? "")
                let name = self.teeingGroundInfo?.holes[self.holeNumber! - 1].name ?? ""
                
                self.message1 = title
                if title.count >= 14 { self.message1FontSize = Global.text8Size }
                if title.count >= 16 { self.message1FontSize = Global.text2Size }
                
                self.message2 = name
            }
            
        } else if self.mode == 9 { // tips
            
            ZStack {
                
                if Util.getSentenceCount(self.tips) <= 4 {
                    
                    ZStack {
                        // header
                        VStack {
                            Text("Tips").font(.system(size: Global.text2Size, weight: .semibold))
                            Text("홀을 공략하세요.").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                            
                            Spacer().frame(maxHeight: .infinity)
                        }
                        
                        // tips
                        VStack {
                            Text(self.tips).font(.system(size: Global.text4Size)).fontWeight(.medium).multilineTextAlignment(.center)
                        }
                        
                        // next button
                        VStack {
                            Spacer().frame(maxHeight: .infinity)
                            
                            Button(action: {
                                withAnimation {
                                    self.mode = 1
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                                    
                                    Image(systemName: "arrow.right")
                                        .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.bottom, Global.buttonPaddingBottom)
                        }
                        .frame(maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.bottom)
                    }
                    
                } else { // >= 5
                    
                    GeometryReader { geometry in
                        ScrollView {
                            // VStack {
                            ScrollViewReader { value in
                                LazyVStack {
                                    // header
                                    Text("Tips").font(.system(size: Global.text2Size, weight: .semibold))
                                    Text("홀을 공략하세요.").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                                    
                                    //  tips
                                    Text(self.tips).font(.system(size: Global.text4Size)).fontWeight(.medium).multilineTextAlignment(.center)
                                    
                                    // next button
                                    Button(action: {
                                        withAnimation {
                                            self.mode = 1
                                        }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.green)
                                                .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                                            
                                            Image(systemName: "arrow.right")
                                                .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.top, Global.buttonPaddingTop)
                                    .padding(.bottom, Global.buttonPaddingBottom2)
                                }
                                .onAppear {
                                    // scroll
                                    // value.scrollTo(2)
                                }
                            }
                            // }
                        } // ScrollView
                    }
                    
                }
            }
            .onAppear {
                if let tips = self.teeingGroundInfo?.holes[self.holeNumber! - 1].tips {
                    var str = ""
                    let size = tips.count
                    for i in 0 ..< size {
                        str += tips[i]
                        if i != (size - 1) {
                            str += " "
                        }
                    }
                    
                    self.tips = Util.checkTips(str)
                }
            }
            
        } else if self.mode == 8 { // notice
            
            ZStack {
                // header
                VStack {
                    Text("Notice").font(.system(size: Global.text2Size, weight: .semibold))
                    Text("홀 정보가 변경되었습니다.").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    Text("홀컵 위치가 이동하여\n거리를 다시 계산했어요.").font(.system(size: Global.text2Size)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                // next button
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    Button(action: {
                        withAnimation {
                            self.mode = 1
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                            
                            Image(systemName: "arrow.right")
                                .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, Global.buttonPaddingBottom)
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            
        } else if self.mode == 1 { // main
            
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
                                    .font(Font.system(size: Global.icon2Size, weight: .heavy))
                            }
                            // .buttonStyle(PlainButtonStyle())
                            .buttonStyle(Menu())
                            .padding(.leading, Global.buttonPadding)
                            // .padding(.leading, 108)
                            
                            Spacer()
                        }.padding(.top, Global.menuButtonPaddingTop)
                        
                        Spacer().frame(maxHeight: .infinity)
                    }
                    
                    // circle
                    VStack {
                        Circle()
                            .strokeBorder(Color(red: 51/255, green: 51/255, blue: 51/255), lineWidth: Global.edgeLineWidth)
                            .frame(width: geometry.size.width, height: geometry.size.width)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    
                    // green button
                    if self.showGreenButton == true {
                        ZStack {
                            HStack(alignment: .center) {
                                Button(action: {
                                    self.greenDirection = 100
                                    
                                    // change distance
                                    changeTeeDistance()
                                    
                                    // save hole
                                    if Global.halftime == 1 { saveHole(1) } // 전반 중
                                    else { saveHole(3) } // 후반 중
                                    
                                    MainView.lastGreenDirection = self.greenDirection
                                }) {
                                    Image(systemName: "l.circle")
                                        .foregroundColor(self.greenDirection == 100 ? Color.green : Color.gray)
                                        .font(Font.system(size: Global.icon3Size, weight: .light))
                                }
                                // .buttonStyle(PlainButtonStyle())
                                .buttonStyle(GreenNormal())
                                // .padding(.leading, 8)
                                
                                Spacer()
                            }.padding(Global.greenButtonPadding)
                            
                            HStack(alignment: .center) {
                                Spacer()
                                
                                Button(action: {
                                    self.greenDirection = 200
                                    
                                    // change distance
                                    changeTeeDistance()
                                    
                                    // save hole
                                    if Global.halftime == 1 { saveHole(1) } // 전반 중
                                    else { saveHole(3) } // 후반 중
                                    
                                    MainView.lastGreenDirection = self.greenDirection
                                }) {
                                    Image(systemName: "r.circle")
                                        .foregroundColor(self.greenDirection == 200 ? Color.green : Color.gray)
                                        .font(Font.system(size: Global.icon3Size, weight: .light))
                                }
                                // .buttonStyle(PlainButtonStyle())
                                .buttonStyle(GreenSelected())
                                // .padding(.leading, 8)
                            }.padding(Global.greenButtonPadding)
                        }
                    }
                    
                    VStack {
                        Circle()
                            .fill(Color(red: 255 / 255, green: 0 / 255, blue: 0 / 255))
                        // .frame(width: geometry.size.width, height: geometry.size.width)
                            .frame(width: Global.edgeLineWidth, height: Global.edgeLineWidth)
                        Spacer().frame(height: geometry.size.width - Global.edgeLineWidth)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    .rotationEffect(Angle(degrees: self.bearing))
                    
                    // text 1
                    VStack(alignment: HorizontalAlignment.center, spacing: 0)  {
                        Button(action: {
                            getHoleViewInfo()
                            
                            // go to HoleView
                            withAnimation {
                                self.mode = 2
                            }
                        }) {
                            Text(self.textHoleTitle).font(.system(size: Global.text5Size))
                        }
                        .padding(.top, Global.holeTextPaddingTop)
                        //.buttonStyle(PlainButtonStyle())
                        .buttonStyle(HoleTitle())
                        
                        HStack(spacing: Global.buttonSpacing4) {
                            Text(self.textPar).font(.system(size: Global.text5Size))
                            Text(self.textHandicap).font(.system(size: Global.text5Size))
                            // Text("• 330").font(.system(size: 14))
                            
                            Button(action: {
                                getTeeViewInfo()
                                
                                // go to TeeView
                                withAnimation {
                                    self.mode = 3
                                }
                            }) {
                                Text(self.textTeeDistance).font(.system(size: Global.text5Size)).foregroundColor(self.colorTeeDistance)
                            }
                            .buttonStyle(HoleTitle())
                        }
                        
                        Spacer().frame(maxHeight: .infinity)
                    }
                    
                    // text 2
                    VStack(alignment: .center)  {
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text(self.distance).font(.system(size: Global.text9Size))
                                .onTapGesture {
                                    toggleUnit()
                                    setTeeDistance()
                                }
                            
                            Text(self.textUnit).font(.system(size: Global.text5Size))
                                .onTapGesture {
                                    toggleUnit()
                                    setTeeDistance()
                                }
                        }
                    }
                    
                    // text 3
                    VStack(alignment: .leading)  {
                        Spacer().frame(maxHeight: .infinity)
                        
                        HStack(spacing: Global.buttonSpacing1) {
                            Image("hills")
                                .resizable()
                                .frame(width: Global.icon5Size, height: Global.icon5Size)
                                .padding(.top, Global.menuButtonPaddingTop)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                Text(self.height).font(.system(size: Global.text10Size))
                                    .onTapGesture {
                                        toggleUnit()
                                        setTeeDistance()
                                    }
                                
                                Text(self.textUnit).font(.system(size: Global.text11Size))
                                    .onTapGesture {
                                        toggleUnit()
                                        setTeeDistance()
                                    }
                            }
                        }
                        .padding(.bottom, Global.holeNamePaddingTop)
                    }
                    
                    // course name
                    VStack {
                        Spacer().frame(maxHeight: .infinity)
                        
                        Text(Util.getCourseName(self.course?.name)).font(.system(size: Global.text6Size))
                            .foregroundColor(.gray)
                        //.fixedSize(horizontal: false, vertical: true)
                        //.lineLimit(1)
                        //.frame(maxWidth: .infinity, alignment: .leading)
                    }
                } // ZStack
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
                
                // if self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[self.teeingGroundIndex!].distances.count == 1 {
                if Util.getTeeingGroundDistancesLength((self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds)!, self.teeingGroundName!) == 1 {
                    self.showGreenButton = false
                } else {
                    self.showGreenButton = true
                }
                
                // update UI
                self.textHoleTitle = self.teeingGroundInfo?.holes[self.holeNumber! - 1].title ?? ""
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
                        
                        // print("1 hole number", self.holeNumber, "sensor count", self.sensors.count)
                        
                        if self.holeNumber! - 1 < self.sensors.count {
                            let sensor = self.sensors[self.holeNumber! - 1]
                            
                            self.latitude = sensor.location.coordinate.latitude + Static.__lat
                            self.longitude = sensor.location.coordinate.longitude + Static.__lon
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
                    
                    // print("2 hole number", self.holeNumber, "sensor count", self.sensors.count)
                    
                    if self.holeNumber! - 1 < self.sensors.count {
                        let sensor = self.sensors[self.holeNumber! - 1]
                        
                        self.latitude = sensor.location.coordinate.latitude + Static.__lat
                        self.longitude = sensor.location.coordinate.longitude + Static.__lon
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
                
                /*
                 for (index, item) in self.sensors.enumerated() {
                 if item.holeNumber == holeNumber {
                 // print(#function, "updated.")
                 
                 self.sensors[index].location = location
                 self.sensors[index].elevation = elevation
                 self.sensors[index].timestamp = timestamp
                 self.sensors[index].battery = battery
                 
                 self.latitude = location.coordinate.latitude + Static.__lat
                 self.longitude = location.coordinate.longitude + Static.__lon
                 self.elevation = elevation
                 
                 break
                 }
                 }
                 */
                let index = Int(holeNumber) - 1
                self.sensors[index].location = location
                self.sensors[index].elevation = elevation
                self.sensors[index].timestamp = timestamp
                self.sensors[index].battery = battery
                
                if self.holeNumber! == holeNumber {
                    self.latitude = location.coordinate.latitude + Static.__lat
                    self.longitude = location.coordinate.longitude + Static.__lon
                    self.elevation = elevation
                    
                    if self.mode == 1 {
                        // show notice
                        withAnimation {
                            self.mode = 8
                        }
                    }
                }
            }
            
        } else if self.mode == 2 { // open HoleView
            
            HoleView(titles: self.titles!, selectedIndex: self.holeNumber! - 1,
                     // backup
                     __course: self.course, __teeingGroundInfo: self.teeingGroundInfo, __teeingGroundName: self.teeingGroundName,
                     __greenDirection: self.greenDirection, /*__holeNumber: self.holeNumber,*/ __distanceUnit: self.distanceUnit,
                     __sensors: self.sensors, __latitude: self.latitude, __longitude: self.longitude, __elevation: self.elevation,
                     __userElevation: self.userElevation
            )
            
        } else if self.mode == 3 { // open TeeView
            
            TeeView(names: self.names!, color: self.color!, distances: self.distances!, selectedIndex: Util.getIndex((self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds)!, self.teeingGroundName!),
                    // backup
                    __course: self.course, __teeingGroundInfo: self.teeingGroundInfo, /*__teeingGroundIndex: self.teeingGroundIndex,*/
                    __greenDirection: self.greenDirection, __holeNumber: self.holeNumber, __distanceUnit: self.distanceUnit,
                    __sensors: self.sensors, __latitude: self.latitude, __longitude: self.longitude, __elevation: self.elevation,
                    __userElevation: self.userElevation
            )
            
        } else if self.mode == 4 { // open MenuView
            
            MenuView(
                // backup
                __course: self.course, __teeingGroundInfo: self.teeingGroundInfo, __teeingGroundName: self.teeingGroundName,
                __greenDirection: self.greenDirection, __holeNumber: self.holeNumber, __distanceUnit: self.distanceUnit,
                __sensors: self.sensors, __latitude: self.latitude, __longitude: self.longitude, __elevation: self.elevation,
                __userElevation: self.userElevation
            )
            
        } else if self.mode == 21 {
            
            // move to HoleSearchView
            
            if self.from == 200 { // 전반 종료
                HoleSearchView(from: self.from, course: self.course, teeingGroundInfo: self.teeingGroundInfo, teeingGroundName: self.teeingGroundName, greenDirection: self.greenDirection!)
            } else { // 300 후반 종료
                HoleSearchView(from: self.from, course: self.course, teeingGroundName: self.teeingGroundName)
            }
            
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
            
            //  circle frame test
            GeometryReader { geometry in
                VStack {
                    Circle()
                        .fill(Color(red: 255 / 255, green: 0 / 255, blue: 0 / 255))
                    // .frame(width: geometry.size.width, height: geometry.size.width)
                        .frame(width: Global.edgeLineWidth, height: Global.edgeLineWidth)
                    Spacer().frame(height: geometry.size.width - Global.edgeLineWidth)
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
        
        var titles: [String] = []
        
        var i = 0
        while (i < count!) {
            let title = self.teeingGroundInfo?.holes[i].title
            
            titles.append(title!)
            
            i += 1
        } // while
        
        self.titles = titles
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
            
            var distance = 0
            if let distances = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[i].distances {
                if distances.count == 1 {
                    distance = distances[0]
                } else {
                    if self.greenDirection == 100 {
                        distance = distances[0]
                    } else if self.greenDirection == 200 {
                        distance = distances[1]
                    }
                }
            }
            
            var unit: String
            
            if self.distanceUnit == 0 { // meter
                if self.teeingGroundInfo?.unit == "M" {
                    // N/A
                } else {
                    // yard to meter
                    let tmp = Double(distance) * 0.9144
                    distance = Int(tmp.rounded())
                }
                
                unit = "m"
            } else { // yard
                if self.teeingGroundInfo?.unit == "Y" {
                    // N/A
                } else {
                    // meter to yard
                    let tmp = Double(distance) * 1.09361
                    distance = Int(tmp.rounded())
                }
                
                unit = "yd"
            }
            
            let d = String(distance) + " " + unit
            
            names.append(name!)
            color.append(_c)
            distances.append(d)
            
            i += 1
        } // while
        
        self.names = names
        self.color = color
        self.distances = distances
        // self.selectedIndex = self.teeingGroundIndex
    }
    
    func getSensors(_ groupId: Int64, onCompletion: @escaping () -> Void) {
        print("getSensors", groupId)
        
        CloudManager.getSensors(groupId) { records in
            if let records = records {
                print(#function, "record count", records.count)
                
                for record in records {
                    // let id = record["id"] as! Int64
                    let holeNumber = record["holeNumber"] as! Int64
                    let elevation = record["elevation"] as! Double
                    let location = record["location"] as! CLLocation
                    let battery = record["battery"] as! Int64
                    let timestamp = record["timestamp"] as! Int64
                    
                    let sensor = SensorModel(id: groupId, holeNumber: holeNumber, elevation: elevation, location: location, battery: battery, timestamp: timestamp)
                    print(#function, sensor)
                    
                    self.sensors.append(sensor)
                    
                    onCompletion()
                }
            } else {
                // N/A
            }
        }
    } // getSensors()
    
    func setTeeDistance() {
        // let teeingGround = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[self.teeingGroundIndex!]
        let index = Util.getIndex((self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds)!, self.teeingGroundName!)
        let teeingGround = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[index]
        // print(#function, teeingGround)
        
        let color = teeingGround?.color
        let _c = Util.getColor(color!)
        
        // var name = teeingGround?.name
        
        // var distance = teeingGround?.distance
        var distance = 0
        if let distances = teeingGround?.distances {
            if distances.count == 1 {
                distance = distances[0]
            } else {
                if self.greenDirection == 100 {
                    distance = distances[0]
                } else if self.greenDirection == 200 {
                    distance = distances[1]
                }
            }
        }
        
        if self.distanceUnit == 0 { // meter
            if self.teeingGroundInfo?.unit == "M" {
                // N/A
            } else {
                // yard to meter
                let tmp = Double(distance) * 0.9144
                distance = Int(tmp.rounded())
            }
            
            self.textUnit = "m"
        } else { // yard
            if self.teeingGroundInfo?.unit == "Y" {
                // N/A
            } else {
                // meter to yard
                let tmp = Double(distance) * 1.09361
                distance = Int(tmp.rounded())
            }
            
            self.textUnit = "yd"
        }
        
        self.textTeeDistance = "• " + String(distance)
        self.colorTeeDistance = _c
    }
    
    func changeTeeDistance() {
        // let teeingGround = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[self.teeingGroundIndex!]
        let index = Util.getIndex((self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds)!, self.teeingGroundName!)
        let teeingGround = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[index]
        
        var distance = 0
        if let distances = teeingGround?.distances {
            if self.greenDirection == 100 {
                distance = distances[0]
            } else if self.greenDirection == 200 {
                distance = distances[1]
            }
        }
        
        if self.distanceUnit == 0 { // meter
            if self.teeingGroundInfo?.unit == "M" {
                // N/A
            } else {
                // yard to meter
                let tmp = Double(distance) * 0.9144
                distance = Int(tmp.rounded())
            }
            
            self.textUnit = "m"
        } else { // yard
            if self.teeingGroundInfo?.unit == "Y" {
                // N/A
            } else {
                // meter to yard
                let tmp = Double(distance) * 1.09361
                distance = Int(tmp.rounded())
            }
            
            self.textUnit = "yd"
        }
        
        self.textTeeDistance = "• " + String(distance)
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
            if let location = self.locationManager.lastLocation {
                DispatchQueue.main.async {
                    timer1.invalidate()
                    
                    let lat = location.coordinate.latitude
                    let lon = location.coordinate.longitude
                    let alt = location.altitude + self.altitudeDiff
                    
                    getUserElevation(String(lat), String(lon), alt)
                    
                    // ToDo: internal test (일단 google api 스킵)
                    /*
                     self.userElevation = 20.2
                     MainView.elevationDiff = self.userElevation! - alt
                     */
                    
                    MainView.lastGetUserElevationTime = DispatchTime.now().uptimeNanoseconds
                    
                    // (2) ~ (n)
                    self.timer1 = Timer.scheduledTimer(withTimeInterval: 60.0 * 30, repeats: true) { _ in // 30 min
                        // Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer2 in
                        // if let location = self.locationManager.lastLocation {
                        // timer2.invalidate()
                        
                        let lat2 = location.coordinate.latitude
                        let lon2 = location.coordinate.longitude
                        let alt2 = location.altitude + self.altitudeDiff
                        
                        getUserElevation(String(lat2), String(lon2), alt2)
                        
                        // ToDo: internal test (일단 google api 스킵)
                        /*
                         self.userElevation = 20.2
                         MainView.elevationDiff = self.userElevation! - alt2
                         */
                        
                        MainView.lastGetUserElevationTime = DispatchTime.now().uptimeNanoseconds
                        // }
                        // }
                    }
                }
            } else {
                // N/A
            }
        }
    }
    
    func startGetUserElevationTimer2() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer1 in
            if let location = self.locationManager.lastLocation {
                DispatchQueue.main.async {
                    timer1.invalidate()
                    
                    // (2) ~ (n)
                    self.timer1 = Timer.scheduledTimer(withTimeInterval: 60.0 * 30, repeats: true) { _ in // 30 min
                        let lat2 = location.coordinate.latitude
                        let lon2 = location.coordinate.longitude
                        let alt2 = location.altitude + self.altitudeDiff
                        
                        getUserElevation(String(lat2), String(lon2), alt2)
                        
                        // ToDo: internal test (일단 google api 스킵)
                        /*
                         self.userElevation = 20.2
                         MainView.elevationDiff = self.userElevation! - alt2
                         */
                        
                        MainView.lastGetUserElevationTime = DispatchTime.now().uptimeNanoseconds
                    }
                }
            } else {
                // N/A
            }
        }
    }
    
    func getUserElevation(_ lat: String, _ lon: String, _ alt: Double) {
        // let params = ["username":"john", "password":"123456"] as Dictionary<String, String>
        
        let url = "https://maps.googleapis.com/maps/api/elevation/json?locations=" + lat + "," + lon + "&key=AIzaSyDGeKg4ewR0-MfmHnBWkv6Qfeoc5Ia4vP8"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        // request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            // print(#function, response!)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(#function, json)
                
                let status = json["status"] as! String
                if status == "OK" {
                    let results = json["results"] as! [[String:Any]]
                    if let elevation = results[0]["elevation"] as? Double {
                        self.userElevation = elevation
                        
                        MainView.elevationDiff = elevation - alt
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
        
        // if MainView.lastHoleNumber == nil && MainView.lastTeeingGroundIndex == nil && MainView.lastGreenDirection == nil { // 최초 로드
        if MainView.lastHoleNumber == nil && MainView.lastTeeingGroundName == nil && MainView.lastGreenDirection == nil { // 최초 로드
            // print(#function, "saveHole()", 2)
            
            if Global.halftime == 1 { saveHole(1) } // 전반 중
            else { saveHole(3) } // 후반 중
            
            MainView.lastHoleNumber = self.holeNumber
            // MainView.lastTeeingGroundIndex = self.teeingGroundIndex
            MainView.lastTeeingGroundName = self.teeingGroundName
            MainView.lastGreenDirection = self.greenDirection
            
            return
        }
        
        if MainView.lastHoleNumber != self.holeNumber {
            // print(#function, "saveHole()", 3)
            
            if Global.halftime == 1 { saveHole(1) } // 전반 중
            else { saveHole(3) } // 후반 중
            
            // init
            self.holePassFlag = 100
            self.holePassStartTime = nil
            
            MainView.lastHoleNumber = self.holeNumber
            
            return
        }
        
        // if MainView.lastTeeingGroundIndex != self.teeingGroundIndex {
        if MainView.lastTeeingGroundName != self.teeingGroundName {
            // print(#function, "saveHole()", 4)
            
            if Global.halftime == 1 { saveHole(1) } // 전반 중
            else { saveHole(3) } // 후반 중
            
            // MainView.lastTeeingGroundIndex = self.teeingGroundIndex
            MainView.lastTeeingGroundName = self.teeingGroundName
            
            return
        }
        
        if MainView.lastGreenDirection != self.greenDirection {
            // print(#function, "saveHole()", 5)
            
            if Global.halftime == 1 { saveHole(1) } // 전반 중
            else { saveHole(3) } // 후반 중
            
            MainView.lastGreenDirection = self.greenDirection
            
            return
        }
    }
    
    func startCheckHolePassTimer() {
        self.timer2 = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in // 1 sec
            if let location = self.locationManager.lastLocation {
                DispatchQueue.main.async {
                    if self.latitude != nil && self.longitude != nil {
                        checkHolePass(location.coordinate.latitude, location.coordinate.longitude, self.latitude!, self.longitude!)
                    }
                }
            } else {
                // N/A
            }
        }
    }
    
    func checkHolePass(_ lat1: Double, _ lon1: Double, _ lat2: Double, _ lon2: Double) {
        let coordinate1 = CLLocation(latitude: lat1, longitude: lon1) // 내 위치
        let coordinate2 = CLLocation(latitude: lat2, longitude: lon2) // 홀 위치
        
        // 현재 홀의 홀컵과 나 사이의 거리
        let distance = coordinate1.distance(from: coordinate2) // result is in meters
        
        // ToDo: 2021-03-15 hole pass check
        // 1. 현재 홀에 있는지 확인
        if stillInCurrentHole(distance) == false { // 현재 홀을 벗어났다면
            let number = findHole(coordinate1)
            if number != 0 {
                if checkHalftimePass(self.holeNumber!, number) == true {
                    if Global.halftime == 2 {
                        // 후반 진행 중에 홀을 벗어나서 코스 밖으로 나왔다..
                        
                        saveHole(4) // 후반 종료
                        
                        moveToHoleSearchView(300)
                        
                        return
                    } else {
                        // 전반 진행하다가 후반 홀로 넘어갔다.
                        Global.halftime = 2
                    }
                }
                
                self.holeNumber = number
                
                self.teeingGroundName = Util.getNextTeeingGroundName((self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds)!, self.teeingGroundName!)
                
                withAnimation {
                    self.mode = 0
                }
                
                // init
                self.holePassFlag = 100
                self.holePassStartTime = nil
            } else {
                // 현재 홀을 벗어나서 다음 홀을 찾기 시도하다가 마지막 홀까지 돌아도 못찾으면 종료한다.
                
                // 전반 또는 후반 종료
                
                if Global.halftime == 1 {
                    Global.halftime = 2
                    
                    saveHole(2) // 전반 종료
                    
                    moveToHoleSearchView(200)
                } else {
                    saveHole(4) // 후반 종료
                    
                    moveToHoleSearchView(300)
                }
            }
        } else {
            if checkHolePass(distance) == true {
                if checkLastHole() == true {
                    // 전반 또는 후반 종료
                    
                    if Global.halftime == 1 {
                        Global.halftime = 2
                        
                        saveHole(2) // 전반 종료
                        
                        moveToHoleSearchView(200)
                    } else {
                        saveHole(4) // 후반 종료
                        
                        moveToHoleSearchView(300)
                    }
                } else {
                    // 일반 홀 종료. 다음 홀로 이동
                    
                    self.holeNumber! += 1
                    
                    self.teeingGroundName = Util.getNextTeeingGroundName((self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds)!, self.teeingGroundName!)
                    
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
            if distance < MainView.HOLE_PASS_DISTANCE {
                self.holePassFlag = 200
                
                // set timer start time
                self.holePassStartTime = DispatchTime.now()
            }
            return false
            
        case 200:
            if distance < MainView.HOLE_PASS_DISTANCE {
                /*
                 if self.holePassStartTime == nil {
                 self.holePassStartTime = DispatchTime.now()
                 } else {
                 let now = DispatchTime.now()
                 var interval = now.uptimeNanoseconds - self.holePassStartTime!.uptimeNanoseconds
                 interval = interval / 1_000_000 // millisecond
                 let sec = interval / 1000 // second
                 
                 if sec >= 10 {
                 print(#function, "10 seconds up")
                 
                 self.holePassFlag = 300
                 self.holePassStartTime = nil
                 }
                 }
                 */
                let now = DispatchTime.now()
                var interval = now.uptimeNanoseconds - self.holePassStartTime!.uptimeNanoseconds
                interval = interval / 1_000_000 // millisecond
                let sec = interval / 1000 // second
                
                if sec >= 10 {
                    print(#function, "10 seconds up")
                    
                    self.holePassFlag = 300
                    self.holePassStartTime = nil
                }
            } else {
                // init
                self.holePassFlag = 100
                self.holePassStartTime = nil
            }
            return false
            
        case 300:
            // if distance > (MainView.HOLE_PASS_DISTANCE + 10) { self.holePassFlag = 400 }
            if distance >= MainView.HOLE_PASS_DISTANCE {
                // init
                self.holePassFlag = 100
                self.holePassStartTime = nil
                
                return true
            }
            return false
            
            /*
             case 400:
             // init
             self.holePassFlag = 100
             self.holePassStartTime = nil
             return true
             */
            
        default:
            return false
        }
    }
    
    func checkLastHole() -> Bool {
        let number = self.holeNumber!
        
        let courses = self.course?.courses
        
        for course in courses! {
            let start = course.range[0]
            let end = course.range[1]
            
            if start <= number && number <= end {
                if number == end {
                    return true
                } else {
                    return false
                }
            }
        }
        
        return false
    }
    
    func stillInCurrentHole(_ distance: Double) -> Bool {
        // var backTee = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[0].distance
        var backTee = 0
        if let distances = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[0].distances {
            backTee = Util.getMaxValue(distances)
        }
        
        if self.teeingGroundInfo?.unit == "Y" {
            // yard to meter
            let x = Double(backTee) * 0.9144
            backTee = Int(x.rounded())
        }
        
        // print(#function, "full back tee distance (meter)", backTee!, distance)
        
        /*
         backTee = backTee! + 30 // full back tee + 30 m
         
         if Double(backTee!) - distance < 0 {
         return false
         }
         
         return true
         */
        
        if Double(backTee) + 30 - distance >= 0 {
            return true
        } else {
            return false
        }
    }
    
    func inHole(_ index: Int, _ coordinate: CLLocation) -> Bool {
        // get distance
        let sensor = self.sensors[index]
        
        let coordinate2 = CLLocation(latitude: sensor.location.coordinate.latitude + Static.__lat, longitude: sensor.location.coordinate.longitude + Static.__lon)
        
        let distance = coordinate.distance(from: coordinate2) // result is in meters
        
        // var backTee = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[0].distance
        var backTee = 0
        if let distances = self.teeingGroundInfo?.holes[self.holeNumber! - 1].teeingGrounds[0].distances {
            backTee = Util.getMaxValue(distances)
        }
        
        if self.teeingGroundInfo?.unit == "Y" {
            // yard to meter
            let x = Double(backTee) * 0.9144
            backTee = Int(x.rounded())
        }
        
        // print(#function, "full back tee distance (meter)", backTee!)
        
        /*
         backTee = backTee! + 30 // full back tee + 30 m
         
         if Double(backTee!) - distance < 0 {
         return false
         }
         
         return true
         */
        
        if Double(backTee) + 30 - distance >= 0 {
            return true
        } else {
            return false
        }
    }
    
    func findHole(_ coordinate: CLLocation) -> Int {
        let number = self.holeNumber!
        
        let count = self.sensors.count
        
        for i in 0..<count {
            var index = number + i // 다음 홀 index
            
            if index >= self.sensors.count {
                index = index - self.sensors.count
            }
            
            if inHole(index, coordinate) == true {
                let n = index + 1 // 다음 홀 number
                
                print(#function, "hole number", n)
                
                return n
            }
        }
        
        return 0
    }
    
    func checkHalftimePass(_ prevHoleNumber: Int, _ curHoleNumber: Int) -> Bool {
        let courses = self.course?.courses
        
        for course in courses! {
            let start = course.range[0]
            let end = course.range[1]
            
            if start <= prevHoleNumber && prevHoleNumber <= end {
                if start <= curHoleNumber && curHoleNumber <= end {
                    return false
                }
                
                return true
            }
        }
        
        return false
    }
    
    func saveHole(_ halftime: Int) {
        // print(#function, halftime)
        
        // 1. time
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 2019-12-20 09:40:08
        // dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss" // 2018-May-01 10:41:31
        let dateString = dateFormatter.string(from: date)
        // let interval = date.timeIntervalSince1970
        
        UserDefaults.standard.set(dateString, forKey: "LAST_PLAYED_HOLE_TIME")
        
        // 2. course
        if let course = self.course {
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
                    print(#function, error)
                    
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
            
            // email
            UserDefaults.standard.set(course.email, forKey: "LAST_PLAYED_HOLE_COURSE_EMAIL")
            
            // hlds
            UserDefaults.standard.set(course.hlds, forKey: "LAST_PLAYED_HOLE_COURSE_HLDS")
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
                    let teeingGroundData = TeeingGroundData(name: teeingGround.name, color: teeingGround.color, distances: teeingGround.distances)
                    teeingGroundDataArray.append(teeingGroundData)
                }
                
                let tgd = TeeingGroundsData(teeingGrounds: teeingGroundDataArray, par: hole.par, handicap: hole.handicap, title: hole.title, name: hole.name, tips: hole.tips)
                
                do {
                    let encodedData = try JSONEncoder().encode(tgd)
                    let jsonString = String(data: encodedData, encoding: .utf8)
                    
                    holesStringArray.append(jsonString!)
                } catch {
                    print(#function, error)
                    
                    return
                }
            }
            
            UserDefaults.standard.set(holesStringArray, forKey: "LAST_PLAYED_HOLE_TEEING_GROUND_INFO_HOLES")
        }
        // --
        
        // 5. teeing ground index
        // UserDefaults.standard.set(self.teeingGroundIndex, forKey: "LAST_PLAYED_HOLE_TEEING_GROUND_INDEX")
        UserDefaults.standard.set(self.teeingGroundName, forKey: "LAST_PLAYED_HOLE_TEEING_GROUND_NAME")
        
        // 6. halftime
        UserDefaults.standard.set(halftime, forKey: "LAST_PLAYED_HOLE_HALFTIME")
        
        // 7. green direction
        UserDefaults.standard.set(self.greenDirection, forKey: "LAST_PLAYED_HOLE_GREEN_DIRECTION")
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
