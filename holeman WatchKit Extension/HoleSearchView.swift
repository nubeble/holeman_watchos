//
//  HoleSearchView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/16.
//

import SwiftUI

struct HoleSearchView: View {
    @State var mode: Int = 0
    
    @State var textMessage: String = "스타트 홀로 가시면 자동으로 시작됩니다."
    @State var findStartHoleCounter = 0
    
    // var from: Int?
    @State var from: Int?
    var search: Bool?
    
    // @ObservedObject var locationManager = LocationManager()
    
    @State var course: CourseModel? = nil
    
    @State var teeingGroundInfo: TeeingGroundInfoModel? = nil
    @State var teeingGroundIndex: Int = 0
    
    @State var greenDirection: Int = 100
    
    @State var startHoles: [StartHole] = []
    
    // @State var selectedStartHoleIndex: Int = 0
    
    @State var holeNumber: Int = 1
    
    struct HoleData: Codable, Hashable {
        let number: Int
        let name: String
        let par: Int
        let handicap: Int
        // let distance: Dictionary<String, Int>
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
                        
                        Text(str1).font(.system(size: 18))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        // .padding(.leading, 2)
                        
                        Text(str2).font(.system(size: 12)) // 영문 코스명은 12로 고정
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        // .padding(.leading, 2)
                        
                        Spacer().frame(maxHeight: .infinity)
                    }
                }
                
                VStack {
                    Text(self.textMessage).font(.system(size: 20)).fontWeight(.medium).multilineTextAlignment(.center)
                        .transition(.opacity)
                        .id(self.textMessage)
                }
                
                VStack(alignment: HorizontalAlignment.center) {
                    Spacer().frame(maxHeight: .infinity)
                    
                    if self.from == 200 {
                        ZStack {
                            Image("beer")
                                .resizable()
                                .frame(width: 32, height: 32)
                        }
                        .padding(.bottom, 10)
                    } else {
                        ZStack {
                            Image("tee up")
                                .resizable()
                                .frame(width: 32, height: 32)
                            
                            TeeIndicator(isAnimating: .constant(true))
                                .frame(width: 54, height: 54)
                                .foregroundColor(.white)
                        }
                        .padding(.bottom, 10)
                    }
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            .onAppear(perform: {
                if let from = self.from {
                    if from == 100 {
                        if let search = self.search {
                            if search == true {
                                self.textMessage = "그늘집에서 잘 쉬셨나요? 스타트 홀로 가시면 자동 시작됩니다."
                                
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
                        
                        self.textMessage = "전반 플레이가 끝났습니다. 그늘집에서 쉬시고 스타트 홀로 가시면 자동 시작됩니다."
                        
                        // self.save = false
                        
                        // ToDo: test timer
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            // getStartHole() // 1, 10, 19, ...
                            
                            let groupId = self.course?.id
                            onGetHoles(groupId!)
                        }
                    } else if from == 300 {
                        // 후반 종료. move to CourseSearchView
                        
                        self.textMessage = "전후반 플레이가 모두 끝났습니다. 수고하셨습니다."
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            withAnimation {
                                self.mode = 21
                            }
                        }
                    } else if from == 500 {
                        self.textMessage = "스타트 홀로 가시면 자동으로 시작됩니다."
                        
                        calcDistance()
                    }
                } else {
                    // 일반 실행
                    
                    // ToDo: test timer
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        getStartHole() // 1, 10, 19, ...
                    }
                }
            })
            
        } else if self.mode == 1 {
            
        } else if self.mode == 2 { // show start hole list
            
            GeometryReader { geometry in
                ScrollView {
                    // VStack {
                    ScrollViewReader { value in
                        LazyVStack {
                            Text("Select Hole").font(.system(size: 20, weight: .semibold))
                            Text("스타트 홀을 선택하세요.").font(.system(size: 14, weight: .light)).padding(.bottom, Static.title2PaddingBottom)
                            
                            ForEach(0 ..< self.startHoles.count) {
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
                                    Text(title).font(.system(size: 20))
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
                            
                        }.onAppear {
                            // scroll
                            // value.scrollTo(2)
                        }
                    }
                    // }
                } // ScrollView
            }
            
        } else if self.mode == 9 { // notice
            
            // ToDo: open Notification in iPhone
            
            ZStack {
                VStack {
                    Text("Notice").font(.system(size: 20, weight: .semibold))
                    Text("위치 서비스를 켜주세요.").font(.system(size: 14, weight: .light)).padding(.bottom, Static.title2PaddingBottom)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    let name = Locale.current.languageCode == "ko" ? "홀맨" : "Holeman"
                    let text = "iPhone에서 설정 앱을 열고 '개인 정보 보호' - '위치 서비스' - '\(name)' - '앱을 사용하는 동안' 선택"
                    Text(text).font(.system(size: 16)).padding(.top, 10).multilineTextAlignment(.center)
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
                                .frame(width: 54, height: 54)
                            
                            Image(systemName: "xmark")
                                .foregroundColor(Color(red: 187 / 255, green: 187 / 255, blue: 187 / 255))
                                .font(Font.system(size: 28, weight: .heavy))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 10)
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
                        
                        Text(str1).font(.system(size: 18))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Text(str2).font(.system(size: 14))
                        Text(str2).font(.system(size: 12)) // 영문 코스명은 12로 고정
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer().frame(maxHeight: .infinity)
                    }
                }
                
                VStack {
                    Text(self.textMessage).font(.system(size: 20)).fontWeight(.medium).multilineTextAlignment(.center)
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
                    
                    HStack(spacing: 40) {
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
                                    .frame(width: 54, height: 54)
                                
                                Image(systemName: "xmark")
                                    .font(Font.system(size: 28, weight: .heavy))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, 10)
                        
                        // button 2
                        Button(action: {
                            
                            // self.textMessage = "스타트 홀로 가시면 자동으로 시작됩니다."
                            self.from = 500
                            
                            withAnimation {
                                self.mode = 0
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
            
        } else if self.mode == 20 { // move to next (MainView)
            
            // 1. teeingGroundIndex
            let teeingGroundIndex = self.teeingGroundIndex
            
            let greenDirection = self.greenDirection
            
            // 2. holeNumber
            let holeNumber = self.holeNumber
            
            // 3. groupId
            // let groupdId = self.course?.id
            
            // 4. course
            let course = self.course
            
            // 5. teeingGroundInfo
            let teeingGroundInfo = self.teeingGroundInfo
            
            MainView(course: course, teeingGroundInfo: teeingGroundInfo, teeingGroundIndex: teeingGroundIndex, greenDirection: greenDirection, holeNumber: holeNumber)
            
        } else if self.mode == 21 { // move to CourseSearchView
            
            CourseSearchView() // Consider
            
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
                        
                        // let distances = Util.convertToDictionary(text: decodedData.distance)
                        let distances = decodedData.distances
                        
                        // set title
                        var title: String = "";
                        let number = i
                        
                        title = self.getHoleTitle(number)
                        
                        tg.title = title
                        
                        // set distance
                        
                        // sort
                        // let sorted = distances.sorted {$0.1 < $1.1}
                        let sorted = distances.sorted {$0.1[0] > $1.1[0]} // 좌그린 값으로 비교
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
                
                getSensor(groupId, Int64(startHoleNumber)) {
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
        self.holeNumber = 1
        
        moveNext()
    }
    
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
            
            self.textMessage = "스타트 홀을 못찾았습니다. 계속 찾을까요?"
            
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
        
        DispatchQueue.main.async {
            let locationManager = LocationManager()
            
            // --
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer1 in
                if let status = locationManager.locationStatus {
                    // timer1.invalidate()
                    
                    if status == .authorizedWhenInUse || status == .authorizedAlways {
                        timer1.invalidate()
                        
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer2 in
                            if let location = locationManager.lastLocation {
                                timer2.invalidate()
                                
                                let latitude = location.coordinate.latitude
                                let longitude = location.coordinate.longitude
                                let coordinate1 = CLLocation(latitude: latitude, longitude: longitude)
                                
                                var list: [Int] = []
                                
                                for startHole in self.startHoles {
                                    let coordinate2 = CLLocation(latitude: startHole.latitude + Static.__lat, longitude: startHole.longitude + Static.__lon)
                                    
                                    let distance = coordinate1.distance(from: coordinate2) // result is in meters
                                    
                                    // var backTee = self.teeingGroundInfo?.holes[startHole.number - 1].teeingGrounds[0].distance
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
            // --
        }
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
