//
//  HoleSearchView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/16.
//

import SwiftUI

struct HoleSearchView: View {
    @State var mode: Int = 0
    
    @State var textMessage: String = "스타트 홀로 가시면\n자동으로 시작됩니다."
    @State var findStartHoleCounter = 0
    @State var getLastLocationCounter = 0
    
    // var from: Int?
    @State var from: Int?
    var search: Bool?
    
    // @State var showIcon: Int = 2 // 0: hide, 1: beer, 2: tee up (+ animation)
    @State var showIcon: Int = 300 // 100: rest, 200: end, 300: tee up (+ animation)
    
    // @ObservedObject var locationManager = LocationManager()
    
    @State var course: CourseModel? = nil
    
    @State var teeingGroundInfo: TeeingGroundInfoModel? = nil
    // @State var teeingGroundIndex: Int = 0
    @State var teeingGroundName: String? = nil
    
    @State var greenDirection: Int = 100
    
    @State var startHoles: [StartHole] = []
    
    // @State var selectedStartHoleIndex: Int = 0
    
    @State var holeNumber: Int = 1
    
    struct HoleData: Codable, Hashable {
        let number: Int
        let name: String
        let par: Int
        let handicap: Int
        let distances: Dictionary<String, [Int]>
        let tips: [String]
    }
    
    struct StartHole {
        var title: String
        var number: Int
        var latitude: Double
        var longitude: Double
    }
    
    // pass to MainView
    // @State var save: Bool?
    
    // 2021-10-08
    @State var startHoleNumber: Int?
    @State var startHoleLatitude: Double?
    @State var startHoleLongitude: Double?
    
    var body: some View {
        if self.mode == 0 {
            
            ZStack {
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
                        // .padding(.leading, 2)
                        
                        Text(str2).font(.system(size: Global.text6Size)) // 영문 코스명은 12로 고정
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        // .padding(.leading, 2)
                        
                        Spacer().frame(maxHeight: .infinity)
                    }
                }
                
                VStack {
                    Text(self.textMessage).font(.system(size: Global.text2Size)).fontWeight(.medium).multilineTextAlignment(.center)
                        .transition(.opacity)
                        .id(self.textMessage)
                }
                
                VStack(alignment: HorizontalAlignment.center) {
                    Spacer().frame(maxHeight: .infinity)
                    
                    /*
                     if self.showIcon == 1 { // beer
                     ZStack {
                     Image("beer")
                     .resizable()
                     .frame(width: Global.icon6Size, height: Global.icon6Size)
                     }
                     .padding(.bottom, Global.buttonPaddingBottom)
                     } else if self.showIcon == 2 { // tee up
                     ZStack {
                     Image("tee up")
                     .resizable()
                     .frame(width: Global.icon6Size, height: Global.icon6Size)
                     
                     TeeIndicator(isAnimating: .constant(true))
                     .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                     .foregroundColor(.white)
                     }
                     .padding(.bottom, Global.buttonPaddingBottom)
                     }
                     */
                    if self.showIcon == 100 { // rest
                        Image("rest")
                            .resizable()
                            .frame(width: Global.icon7Size, height: Global.icon7Size)
                            .padding(.bottom, Global.buttonPaddingBottom3)
                    } else if self.showIcon == 200 { // end
                        Image("end")
                            .resizable()
                            .frame(width: Global.icon7Size, height: Global.icon7Size)
                            .padding(.bottom, Global.buttonPaddingBottom3)
                    } else if self.showIcon == 300 { // tee up
                        ZStack {
                            Image("tee up")
                                .resizable()
                                .frame(width: Global.icon6Size, height: Global.icon6Size)
                            
                            TeeIndicator(isAnimating: .constant(true))
                                .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                                .foregroundColor(.white)
                        }
                        .padding(.bottom, Global.buttonPaddingBottom)
                    }
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            .onAppear {
                if let from = self.from {
                    if from == 100 {
                        if let search = self.search {
                            if search == true {
                                self.textMessage = "그늘집에서 잘 쉬셨죠?\n스타트 홀로 가시면\n자동으로 시작됩니다."
                                
                                // ToDo: test timer
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                    // getStartHole() // 1, 10, 19, ...
                                    let groupId = self.course?.id
                                    onGetHoles(groupId!)
                                }
                            } else {
                                // 스타트 홀 검색하지 않고 teeingGroundInfo만 구하고 holeNumber로 실행
                                self.textMessage = "로딩 중입니다."
                                
                                // self.save = false
                                
                                moveNext()
                            }
                        }
                    } else if from == 400 {
                        // print(#function, "400", self.search, self.course, self.teeingGroundInfo, self.teeingGroundIndex, self.greenDirection, self.holeNumber)
                        
                        // ToDo: test timer
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            getStartHole() // 1, 10, 19, ...
                        }
                    } else if from == 200 {
                        // 전반 종료. 앱이 계속 떠 있는 상태에서 홀 근처로 가면 후반 시작
                        
                        self.textMessage = "전반 9홀이 끝났습니다.\n그늘집에서 푹 쉬신 후\n스타트 홀에서 만나요."
                        
                        // self.showIcon = 1 // beer
                        self.showIcon = 100 // rest
                        
                        // self.save = false
                        
                        // ToDo: test timer
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                            // self.showIcon = 2 // tee up
                            self.showIcon = 300 // tee up
                            
                            // getStartHole() // 1, 10, 19, ...
                            let groupId = self.course?.id
                            onGetHoles(groupId!)
                        }
                    } else if from == 300 {
                        // 후반 종료. move to CourseView
                        
                        self.textMessage = "라운드가 끝났네요.\n수고하셨습니다."
                        
                        // self.showIcon = 0 // not show
                        self.showIcon = 200 // end
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                            withAnimation {
                                self.mode = 10
                            }
                        }
                    } else if from == 500 {
                        self.textMessage = "스타트 홀로 가시면\n자동으로 시작됩니다."
                        
                        calcDistance()
                    }
                } else {
                    // 일반 실행
                    
                    // ToDo: test timer
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        getStartHole() // 1, 10, 19, ...
                    }
                }
            }
            
        } else if self.mode == 1 {
            
        } else if self.mode == 2 { // show start hole list
            
            GeometryReader { geometry in
                ScrollView {
                    // VStack {
                    ScrollViewReader { value in
                        LazyVStack {
                            Text("Select Hole").font(.system(size: Global.text2Size, weight: .semibold))
                            Text("스타트 홀을 선택하세요.").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                            
                            ForEach(0 ..< self.startHoles.count, id: \.self) {
                                let index = $0
                                
                                let number = self.startHoles[index].number
                                let title = self.startHoles[index].title
                                
                                Button(action: {
                                    // self.selectedStartHoleIndex = index
                                    self.holeNumber = number
                                    
                                    // self.save = true
                                    
                                    // move to MainView
                                    moveNext()
                                }) {
                                    Text(title).font(.system(size: Global.text2Size))
                                    // .fixedSize(horizontal: false, vertical: true)
                                    // .lineLimit(2)
                                    // .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }.id($0)
                            }
                            
                            // back button
                            /*
                             Button(action: {
                             withAnimation {
                             // self.mode = 3
                             }
                             }) {
                             ZStack {
                             Circle()
                             .fill(Color(red: 49 / 255, green: 49 / 255, blue: 49 / 255))
                             .frame(width: 54, height: 54)
                             
                             Image(systemName: "xmark")
                             .foregroundColor(Color(red: 187 / 255, green: 187 / 255, blue: 187 / 255))
                             .font(Font.system(size: 28, weight: .heavy))
                             }
                             }
                             .buttonStyle(PlainButtonStyle())
                             .padding(.top, 10)
                             .padding(.bottom, -20) // check default padding
                             */
                            
                        }
                        .onAppear {
                            // scroll
                            // value.scrollTo(2)
                        }
                    }
                    // }
                } // ScrollView
            }
            
        } else if self.mode == 9 { // notice
            
            // ToDo: open notification in iPhone
            
            ZStack {
                VStack {
                    Text("Notice").font(.system(size: Global.text2Size, weight: .semibold))
                    Text("위치 서비스를 켜주세요.").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    // let name = Locale.current.languageCode == "ko" ? "홀맨" : "Holeman"
                    // let text = "iPhone에서 설정 앱을 열고 '개인 정보 보호' - '위치 서비스' - '\(name)' - '앱을 사용하는 동안' 선택"
                    let text = "iPhone에서 설정 앱을 열고\n\"개인 정보 보호\" >\n\"위치 서비스\" > \"홀맨\" >\n'앱을 사용하는 동안' 선택"
                    Text(text).font(.system(size: Global.text4Size)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    Button(action: {
                        // go back
                        withAnimation {
                            self.mode = 10
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 49 / 255, green: 49 / 255, blue: 49 / 255))
                                .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                            
                            Image(systemName: "xmark")
                                .foregroundColor(Color(red: 187 / 255, green: 187 / 255, blue: 187 / 255))
                                .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, Global.buttonPaddingBottom)
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            
        } else if self.mode == 10 { // go back
            
            CourseView()
            
        } else if self.mode == 11 { // O/X
            
            ZStack {
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
                        
                        // Text(str2).font(.system(size: 14))
                        Text(str2).font(.system(size: Global.text6Size)) // 영문 코스명은 12로 고정
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer().frame(maxHeight: .infinity)
                    }
                }
                
                VStack {
                    Text(self.textMessage).font(.system(size: Global.text2Size)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                /*
                 VStack(alignment: HorizontalAlignment.center) {
                 Spacer().frame(maxHeight: .infinity)
                 
                 Image("tee up")
                 .resizable()
                 .frame(width: 200 / 5, height: 200 / 5)
                 .padding(.bottom, 15)
                 }
                 .frame(maxHeight: .infinity)
                 .edgesIgnoringSafeArea(.bottom)
                 */
                
                // O/X button
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    HStack(spacing: Global.buttonSpacing2) {
                        // button 1
                        Button(action: {
                            
                            // back to CourseView
                            withAnimation {
                                self.mode = 10
                            }
                            
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 49 / 255, green: 49 / 255, blue: 49 / 255))
                                    .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                                
                                Image(systemName: "xmark")
                                    .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, Global.buttonPaddingBottom)
                        
                        // button 2
                        Button(action: {
                            // self.textMessage = "스타트 홀로 가시면 자동으로 라운드가 시작됩니다."
                            self.from = 500
                            
                            withAnimation {
                                self.mode = 0
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                                
                                Image(systemName: "checkmark")
                                    .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, Global.buttonPaddingBottom)
                    }
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            
        } else if self.mode == 20 { // move to next (MainView)
            
            // 1. teeingGroundIndex
            // let teeingGroundIndex = self.teeingGroundIndex
            let teeingGroundName = self.teeingGroundName != nil ? self.teeingGroundName : Util.getName((self.teeingGroundInfo?.holes[self.holeNumber - 1].teeingGrounds[0])!)
            
            let greenDirection = self.greenDirection
            
            // 2. holeNumber
            let holeNumber = self.holeNumber
            
            // 4. course
            let course = self.course
            
            // 5. teeingGroundInfo
            let teeingGroundInfo = self.teeingGroundInfo
            
            // MainView(course: course, teeingGroundInfo: teeingGroundInfo, teeingGroundIndex: teeingGroundIndex, greenDirection: greenDirection, holeNumber: holeNumber)
            MainView(course: course, teeingGroundInfo: teeingGroundInfo, teeingGroundName: teeingGroundName, greenDirection: greenDirection, holeNumber: holeNumber)
            
        }
    }
    
    func getHoles(_ groupId: Int64, onCompletion: @escaping () -> Void) {
        CloudManager.getHoles(groupId) { record in
            //if let records = records {
            //if records.count == 1 {
            //let record = records[0]
            if let record = record {
                var info = TeeingGroundInfoModel(unit: "", holes: [])
                
                // let id = record["id"] as! Int64
                let unit = record["unit"] as! String
                let holes = record["holes"] as! [String]
                
                // set unit
                info.unit = unit
                
                // holes
                var i = 0 // 0 ~ 17
                for hole in holes {
                    i += 1
                    
                    // create
                    var tg = TeeingGrounds(teeingGrounds: [], par: 0, handicap: 0, title: "", name: "", tips: [])
                    
                    // parse json
                    do {
                        // let data = Data.init(base64Encoded: course)
                        let data = Data(hole.utf8)
                        let decodedData = try JSONDecoder().decode(HoleData.self, from: data)
                        // print(decodedData)
                        
                        tg.name = decodedData.name
                        tg.par = decodedData.par
                        tg.handicap = decodedData.handicap
                        tg.tips = decodedData.tips
                        
                        let distances = decodedData.distances
                        
                        // set title
                        var title: String = ""
                        let number = i
                        
                        title = self.getHoleTitle(number)
                        
                        tg.title = title
                        
                        // set distance
                        
                        // sort
                        // 1. 우선 좌그린 값 (또는 single value) 으로 정렬
                        var sorted = distances.sorted { $0.1[0] > $1.1[0] }
                        
                        // print(#function, sorted)
                        
                        // 2. 색깔로 정렬 (red < yellow < white < blue < black)
                        sorted = sorted.sorted { (lhs, rhs) -> Bool in
                            // white, blue -> blue, white
                            // blue, black -> black, blue
                            // red, white -> white, red
                            
                            let key1 = lhs.0
                            let key2 = rhs.0
                            
                            let c1 = Util.getColorName(key1)
                            let c2 = Util.getColorName(key2)
                            
                            if c1 == "blue" && c2 == "black" { return false }
                            if c1 == "white" && c2 == "blue" { return false }
                            if c1 == "yellow" && c2 == "white" { return false }
                            if c1 == "red" && c2 == "yellow" { return false }
                            if c1 == "red" && c2 == "white" { return false }
                            if c1 == "yellow" && c2 == "blue" { return false }
                            if c1 == "red" && c2 == "blue" { return false }
                            if c1 == "white" && c2 == "black" { return false }
                            if c1 == "yellow" && c2 == "black" { return false }
                            if c1 == "red" && c2 == "black" { return false }
                            
                            if c1 == "black" && c2 == "black" { return false }
                            if c1 == "blue" && c2 == "blue" { return false }
                            if c1 == "white" && c2 == "white" { return false }
                            if c1 == "yellow" && c2 == "yellow" { return false }
                            if c1 == "red" && c2 == "red" { return false }
                            
                            return true
                        }
                        
                        print(#function, sorted)
                        
                        for (key, value) in sorted {
                            // get name, color
                            let start1 = key.firstIndex(of: "(")
                            let end1 = key.firstIndex(of: ")")
                            
                            let i1 = key.index(start1!, offsetBy: 0)
                            
                            let range1 = key.startIndex..<i1
                            let name = key[range1]
                            
                            let i2 = key.index(start1!, offsetBy: 1)
                            
                            let range2 = i2..<end1!
                            let color = key[range2]
                            
                            // print("name", name)
                            // print("color", color)
                            
                            let d = value
                            
                            // print("distance", distance)
                            
                            let t = TeeingGround(name: String(name).uppercased(), color: String(color).uppercased(), distances: d)
                            tg.teeingGrounds.append(t)
                        }
                    } catch {
                        print(error)
                        return
                    }
                    
                    // set
                    info.holes.append(tg)
                } // for
                
                self.teeingGroundInfo = info
                // print("info", info)
                
                onCompletion()
            } else {
                print(#function, "No record found")
            }
        }
    } // getHoles()
    
    func getStartHole() {
        let groupId = self.course?.id
        print(#function, groupId!)
        
        getHoles(groupId!) {
            onGetHoles(groupId!)
        }
    }
    
    func onGetHoles(_ groupId: Int64) {
        print(#function, groupId)
        
        let courses = self.course?.courses
        
        if courses?.count == 1 {
            moveToStartHole()
        } else {
            for (_, item) in courses!.enumerated() {
                // print(#function, index, item.range[0])
                
                let startHoleNumber = item.range[0]
                
                getPin(groupId, Int64(startHoleNumber)) {
                    // onGetSensor
                    
                    if self.startHoles.count == courses?.count {
                        // sort by holeNumber self.startHoles
                        self.startHoles.sort(by: { $0.number < $1.number })
                        // print(#function, self.startHoles)
                        
                        calcDistance()
                    }
                }
            } // for
        }
    }
    
    func moveToStartHole() {
        // ToDo: 2021-10-08
        /*
         self.holeNumber = 1
         
         moveNext()
         */
        
        let locationManager = LocationManager()
        
        // --
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer1 in
            if let status = locationManager.locationStatus {
                DispatchQueue.main.async {
                    // timer1.invalidate()
                    
                    if status == .authorizedWhenInUse || status == .authorizedAlways {
                        timer1.invalidate()
                        
                        getLastLocationTimer()
                    } else if status == .denied {
                        timer1.invalidate()
                        
                        // notice
                        withAnimation {
                            self.mode = 9
                        }
                    }
                }
            }
        }
        // --
    }
    
    func getLastLocationTimer() {
        if self.findStartHoleCounter == 10 {
            self.findStartHoleCounter = 0
            
            self.textMessage = "스타트 홀을 찾을 수\n없네요. 계속 찾을까요?"
            
            withAnimation {
                self.mode = 11
            }
            
            return
        }
        
        let locationManager = LocationManager()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer2 in
            if let location = locationManager.lastLocation {
                DispatchQueue.main.async {
                    timer2.invalidate()
                    
                    let latitude = location.coordinate.latitude
                    let longitude = location.coordinate.longitude
                    
                    checkDistance(latitude, longitude)
                }
            } else {
                self.getLastLocationCounter += 1
                
                if self.getLastLocationCounter == 18 {
                    timer2.invalidate()
                    
                    withAnimation(.linear(duration: 0.5)) {
                        self.textMessage = "잠시 후에 다시\n시도해주세요."
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        // back to CourseView
                        withAnimation {
                            self.mode = 10
                        }
                    }
                    
                    return
                }
                
                if self.getLastLocationCounter % 3 == 0 { // 3, 6, 9, 12, 15
                    // show wait message
                    withAnimation(.linear(duration: 0.5)) {
                        self.textMessage = Util.getWaitMessageForLocation2(self.getLastLocationCounter)
                    }
                }
            }
        }
    }
    
    func checkDistance(_ latitude: Double, _ longitude: Double) {
        if let startHoleNumber = self.startHoleNumber {
            checkDistance(startHoleNumber, self.startHoleLatitude!, self.startHoleLongitude!, latitude, longitude)
        } else {
            // read from server
            
            let groupId = self.course?.id
            
            // start hole number
            let courses = self.course?.courses
            let number = courses![0].range[0]
            
            
            CloudManager.getPin(groupId!, Int64(number)) { record in
                if let record = record {
                    // let id = record["id"] as! Int64
                    // let holeNumber = record["holeNumber"] as! Int64
                    // let elevation = record["elevation"] as! Double
                    let locations = record["locations"] as! [CLLocation]
                    // let battery = record["battery"] as! Int64
                    // let timestamp = record["timestamp"] as! Int64
                    
                    self.startHoleNumber = number
                    self.startHoleLatitude = locations[0].coordinate.latitude
                    self.startHoleLongitude = locations[0].coordinate.longitude
                    
                    checkDistance(self.startHoleNumber!, self.startHoleLatitude!, self.startHoleLongitude!, latitude, longitude)
                }
            }
        }
    }
    
    func checkDistance(_ number: Int, _ lat1: Double, _ lon1: Double, _ lat2: Double, _ lon2: Double) {
        let coordinate1 = CLLocation(latitude: lat2, longitude: lon2)
        
        let coordinate2 = CLLocation(latitude: lat1 + Static.__lat, longitude: lon1 + Static.__lon)
        
        let distance = coordinate1.distance(from: coordinate2) // result is in meters
        
        var backTee = 0
        if let distances = self.teeingGroundInfo?.holes[number - 1].teeingGrounds[0].distances {
            backTee = Util.getMaxValue(distances)
        }
        
        if self.teeingGroundInfo?.unit == "Y" {
            let x = Double(backTee) * 0.9144
            backTee = Int(x.rounded())
        }
        
        let diff = distance - (Double(backTee) + 30) // (나와 홀 사이 거리) - 전장(백티 + 30)
        print(#function, "diff:", diff, distance, backTee)
        
        // 20 m
        if diff <= 20 { // 20미터 이하면 해당 홀 근처로 들어왔다고 간주한다.
            self.holeNumber = number
            
            moveNext()
        } else {
            // change text message
            withAnimation(.linear(duration: 0.5)) {
                self.textMessage = Util.getWaitMessageForHole(self.findStartHoleCounter)
            }
            self.findStartHoleCounter += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.getLastLocationCounter = 0
                
                getLastLocationTimer() // 재귀 (상위 호출)
            }
        }
    }
    
    /*
     func getSensor(_ groupId: Int64, _ holeNumber: Int64, onCompletion: @escaping () -> Void) {
     print("getSensor", groupId, holeNumber)
     
     CloudManager.getSensor(groupId, holeNumber) { record in
     if let record = record {
     // print(#function, record)
     
     // let id = record["id"] as! Int64
     // let holeNumber = record["holeNumber"] as! Int64
     let elevation = record["elevation"] as! Double
     let location = record["location"] as! CLLocation
     let battery = record["battery"] as! Int64
     let timestamp = record["timestamp"] as! Int64
     
     let sensor = SensorModel(id: groupId, holeNumber: holeNumber, elevation: elevation, location: location, battery: battery, timestamp: timestamp)
     print("sensor", sensor)
     
     let startHole = StartHole(title: getHoleTitle(Int(holeNumber)), number: Int(holeNumber), latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
     
     self.startHoles.append(startHole)
     
     onCompletion()
     }
     }
     } // getHole()
     */
    
    func getPin(_ groupId: Int64, _ holeNumber: Int64, onCompletion: @escaping () -> Void) {
        print("getPin", groupId, holeNumber)
        
        CloudManager.getPin(groupId, holeNumber) { record in
            if let record = record {
                // print(#function, record)
                
                // let id = record["id"] as! Int64
                // let holeNumber = record["holeNumber"] as! Int64
                let elevations = record["elevations"] as! [Double]
                let locations = record["locations"] as! [CLLocation]
                let battery = record["battery"] as! Int64
                let timestamp = record["timestamp"] as! Int64
                
                let pin = Pin(id: groupId, holeNumber: holeNumber, elevations: elevations, locations: locations, battery: battery, timestamp: timestamp)
                print("pin", pin)
                
                let startHole = StartHole(title: getHoleTitle(Int(holeNumber)), number: Int(holeNumber), latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
                
                self.startHoles.append(startHole)
                
                onCompletion()
            }
        }
    } // getHole()
    
    func getHoleTitle(_ number: Int) -> String {
        var title: String = ""
        
        let courses = self.course?.courses
        
        if courses?.count == 0 { // never come here
            title = Util.getOrdinalNumber(number) + " HOLE"
        } else {
            for course in courses! {
                let name = course.name
                let start = course.range[0]
                let end = course.range[1]
                
                if start <= number && number <= end {
                    let n = number - start + 1
                    
                    title = name + " " + Util.getOrdinalNumber(n)
                    
                    break
                }
            }
            
            if title == "" { // never come here
                title = Util.getOrdinalNumber(number) + " HOLE"
            }
        }
        
        return title
    }
    
    func calcDistance() {
        // print("calcDistance", self.findStartHoleCounter)
        
        if self.findStartHoleCounter == 10 {
            self.findStartHoleCounter = 0
            
            self.textMessage = "스타트 홀을 찾을 수\n없네요. 계속 찾을까요?"
            
            withAnimation {
                self.mode = 11
            }
            
            return
            
            /*
             // CourseView로 돌아가는게 아니라, O(refresh) | X(go back) 버튼을 띄워 물어봐야 한다!
             
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
             */
        }
        
        let locationManager = LocationManager()
        
        // --
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer1 in
            if let status = locationManager.locationStatus {
                DispatchQueue.main.async {
                    // timer1.invalidate()
                    
                    if status == .authorizedWhenInUse || status == .authorizedAlways {
                        timer1.invalidate()
                        
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer2 in
                            if let location = locationManager.lastLocation {
                                DispatchQueue.main.async {
                                    timer2.invalidate()
                                    
                                    let latitude = location.coordinate.latitude
                                    let longitude = location.coordinate.longitude
                                    let coordinate1 = CLLocation(latitude: latitude, longitude: longitude)
                                    
                                    var list: [Int] = []
                                    
                                    for startHole in self.startHoles {
                                        let coordinate2 = CLLocation(latitude: startHole.latitude + Static.__lat, longitude: startHole.longitude + Static.__lon)
                                        
                                        let distance = coordinate1.distance(from: coordinate2) // result is in meters
                                        
                                        var backTee = 0
                                        if let distances = self.teeingGroundInfo?.holes[startHole.number - 1].teeingGrounds[0].distances {
                                            backTee = Util.getMaxValue(distances)
                                        }
                                        
                                        if self.teeingGroundInfo?.unit == "Y" {
                                            let x = Double(backTee) * 0.9144
                                            backTee = Int(x.rounded())
                                        }
                                        
                                        // print(#function, startHole.number, backTee, distance)
                                        
                                        let diff = distance - (Double(backTee) + 30) // (나와 홀 사이 거리) - 전장(백티 + 30)
                                        print(#function, "diff:", diff, distance, backTee)
                                        
                                        // 20 m
                                        if diff <= 20 { // 20미터 이하면 해당 홀 근처로 들어왔다고 간주한다.
                                            list.append(startHole.number)
                                        }
                                    }
                                    
                                    // update UI
                                    if list.count == 1 {
                                        let n = list[0]
                                        self.holeNumber = n
                                        
                                        // self.save = true
                                        
                                        moveNext()
                                    } else if list.count > 1 {
                                        showList()
                                    } else { // 0
                                        // change text message
                                        withAnimation(.linear(duration: 0.5)) {
                                            self.textMessage = Util.getWaitMessageForHole(self.findStartHoleCounter)
                                        }
                                        self.findStartHoleCounter += 1
                                        
                                        // 하나도 못찾으면 찾을 때까지 계속 돌아야 한다.
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                            calcDistance()
                                        }
                                    }
                                }
                            } else {
                                self.getLastLocationCounter += 1
                                
                                if self.getLastLocationCounter == 18 {
                                    timer2.invalidate()
                                    
                                    withAnimation(.linear(duration: 0.5)) {
                                        self.textMessage = "잠시 후에 다시\n시도해주세요."
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                        // back to CourseView
                                        withAnimation {
                                            self.mode = 10
                                        }
                                    }
                                    
                                    return
                                }
                                
                                if self.getLastLocationCounter % 3 == 0 { // 3, 6, 9, 12, 15
                                    // show wait message
                                    withAnimation(.linear(duration: 0.5)) {
                                        self.textMessage = Util.getWaitMessageForLocation2(self.getLastLocationCounter)
                                    }
                                }
                            }
                        }
                    } else if status == .denied {
                        timer1.invalidate()
                        
                        // notice
                        withAnimation {
                            self.mode = 9
                        }
                    }
                }
            }
        }
        // --
    }
    
    func showList() {
        // show start hole list
        withAnimation {
            self.mode = 2
        }
    }
    
    func moveNext() {
        withAnimation {
            self.mode = 20
        }
    }
}

struct HoleSearchView_Previews: PreviewProvider {
    static var previews: some View {
        HoleSearchView()
    }
}
