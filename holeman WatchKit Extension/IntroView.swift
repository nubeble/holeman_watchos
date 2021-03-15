//
//  IntroView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/12/11.
//

import SwiftUI
import AuthenticationServices
import UserNotifications

struct IntroView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State var mode: Int = -1
    
    @State var text1: String = "안녕하세요!"
    @State var text1Opacity: Double = 0
    
    @State var text2: String = "정확한 거리"
    @State var text2Opacity: Double = 0
    
    @State var text3: String = "홀맨이 알려드릴게요."
    @State var text3Opacity: Double = 0
    
    @State var button1Opacity: Double = 0
    
    
    @State var textMessage: String = ""
    
    @State var onComplete: ((Bool) -> Void)?
    
    @State var name: String?
    
    // pass to HoleSearchView
    @State var from: Int?
    @State var search: Bool?
    @State var course: CourseModel?
    @State var holeNumber: Int?
    @State var teeingGroundInfo: TeeingGroundInfoModel?
    @State var teeingGroundIndex: Int?
    
    // @State private var textValue: String = "Sample Data"
    // @State private var opacity: Double = 1
    
    var body: some View {
        if self.mode == -1 {
            
            VStack {
                // N/A
            }
            .onAppear {
                // ToDo: test (remove all UserDefaults)
                // --
                /*
                 let defaults = UserDefaults.standard
                 let dictionary = defaults.dictionaryRepresentation()
                 dictionary.keys.forEach { key in
                 defaults.removeObject(forKey: key)
                 }
                 */
                // --
                
                checkLastPurchasedCourse()
            }
            
        } else if self.mode == 0 {
            
            VStack {
                Text(text1).font(.system(size: 24)).fontWeight(.medium).opacity(text1Opacity)
            }
            .onAppear {
                
                withAnimation(.easeInOut(duration: 1), {
                    self.text1Opacity = 1
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    // Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                    // hide
                    /*
                     withAnimation(.easeInOut(duration: 0.5), {
                     self.text1Opacity = 0
                     })
                     
                     DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                     // show
                     self.mode = 1
                     }
                     */
                    withAnimation {
                        self.mode = 1
                    }
                }
            }
            
        } else if self.mode == 1 {
            
            ZStack {
                VStack {
                    Text(text2).font(.system(size: 24)).fontWeight(.medium).opacity(text2Opacity)
                    Text(text3).font(.system(size: 24)).fontWeight(.medium).opacity(text3Opacity)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    Button(action: {
                        print("button click")
                        
                        // Sign in with Apple
                        // checkUserIdentifierValidation()
                        
                        requestNotificationAuthorization() { result in
                            if result == true {
                                // Sign in with Apple
                                checkUserIdentifierValidation()
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 54, height: 54)
                            
                            Image(systemName: "arrow.right")
                                .font(Font.system(size: 28, weight: .heavy))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 10)
                    .opacity(button1Opacity)
                } // end of VStack
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1), {
                    self.text2Opacity = 1
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    withAnimation(.easeInOut(duration: 1), {
                        self.text3Opacity = 1
                    })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        // Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        // show button & move to next view
                        
                        withAnimation(.easeInOut(duration: 1), {
                            self.button1Opacity = 1
                        })
                    }
                }
            }
            
        } else if self.mode == 2 { // Sign in with Apple
            
            ZStack {
                VStack(alignment: HorizontalAlignment.center) {
                    Image("icon")
                        .resizable()
                        .frame(width: 200 / 5, height: 200 / 5)
                    // .padding(.bottom, 15)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    Text("홀맨을 이용하시려면 로그인이 필요합니다.").font(.system(size: 20)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    }
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            print("Authorisation successful", authResults)
                            
                            guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential, let identityToken = credential.identityToken, let identityTokenString = String(data: identityToken, encoding: .utf8) else { return }
                            
                            // let body = ["appleIdentityToken": identityTokenString]
                            // guard let jsonData = try? JSONEncoder().encode(body) else { return }
                            
                            // print("credential", credential)
                            // This is where you'd fire an API request to your server to authenticate with the identity token attached in the request headers.
                            
                            // get fullName, email
                            let userIdentifier = credential.user
                            
                            var name: String = "noname"
                            if let fullName = credential.fullName {
                                let firstName = fullName.givenName ?? ""
                                let lastName = fullName.familyName ?? ""
                                
                                if firstName.count > 0 {
                                    if lastName.count > 0 {
                                        name = firstName + " " + lastName
                                    } else {
                                        name = firstName
                                    }
                                    
                                    self.name = name
                                } else {
                                    let nickname = fullName.nickname ?? "noname"
                                    name = nickname
                                }
                            }
                            
                            let email: String = credential.email ?? "noemail"
                            
                            // print(userIdentifier, name, email)
                            
                            // 1. save to db
                            CloudManager.saveUser(userIdentifier, name, email)
                            
                            // 2. save to UserDefaults
                            UserDefaults.standard.set(userIdentifier, forKey: "USER_ID")
                            
                            // move to welcome
                            // withAnimation {
                            self.mode = 4
                        // }
                        
                        case .failure (let error):
                            print("Authorisation failed: \(error.localizedDescription)")
                        }
                    }
                    // .signInWithAppleButtonStyle(.black) // black button
                    // .signInWithAppleButtonStyle(.white) // white button
                    .signInWithAppleButtonStyle(.whiteOutline) // white with border
                    // .frame(width: .infinity, height: 30)
                    // .frame(width: 100, height: 30)
                    .frame(height: 30)
                }
            }
            
        } else if self.mode == 3 { // move to course view
            
            CourseView()
            
        } else if self.mode == 4 { // welcome
            
            VStack {
                let str1 = self.name ?? "홀맨 회원"
                let str2 = "즐거운 라운드 되세요."
                
                Text(str1 + "님,").font(.system(size: 24)).fontWeight(.medium)
                Text(str2).font(.system(size: 24)).fontWeight(.medium)
            }.onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        self.mode = 3
                    }
                }
            }
            
        } else if self.mode == 11 || self.mode == 12 || self.mode == 13 || self.mode == 14 || self.mode == 15 {
            
            ZStack {
                VStack {
                    // show course name & hole name
                    
                    if self.mode == 11 || self.mode == 13 {
                        let course = Util.getCourseName(self.course?.name)
                        let hole = self.teeingGroundInfo?.holes[self.holeNumber! - 1].name ?? ""
                        
                        Text(course).font(.system(size: 16))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(hole).font(.system(size: 14))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else if self.mode == 12 {
                        // let course = self.course?.name ?? ""
                        let course = Util.getCourseName(self.course?.name)
                        let hole = "후반전 시작" // ToDo: language bundle
                        
                        Text(course).font(.system(size: 16))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(hole).font(.system(size: 14))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else { // 14, 15
                        let course = Util.getCourseName(self.course?.name)
                        let hole = "전반전 시작" // ToDo: language bundle
                        
                        Text(course).font(.system(size: 16))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(hole).font(.system(size: 14))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    Text(self.textMessage).font(.system(size: 20)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    HStack(spacing: 40) {
                        // button 1
                        Button(action: {
                            // 새 게임으로 시작
                            
                            startNew(true, true, false)
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
                        // .opacity(button1Opacity)
                        
                        // button 2
                        Button(action: {
                            if self.mode == 11 {
                                Global.halftime = 1
                                
                                // moveNext(false)
                                requestNotificationAuthorization() { result in
                                    if result == true {
                                        moveNext(false)
                                    }
                                }
                            } else if self.mode == 12 {
                                Global.halftime = 2
                                
                                // moveNext(true)
                                requestNotificationAuthorization() { result in
                                    if result == true {
                                        moveNext(true)
                                    }
                                }
                            } else if self.mode == 13 {
                                Global.halftime = 2
                                
                                // moveNext(false)
                                requestNotificationAuthorization() { result in
                                    if result == true {
                                        moveNext(false)
                                    }
                                }
                            } else if self.mode == 14 {
                                Global.halftime = 1
                                
                                // moveNextFromPurchase(false) // moveToHoleSearchActivity
                                requestNotificationAuthorization() { result in
                                    if result == true {
                                        moveNextFromPurchase(false)
                                    }
                                }
                            } else if self.mode == 15 {
                                Global.halftime = 1
                                
                                // moveNextFromPurchase(true) // moveToHoleSearchActivity (+ 홀 정보 삭제)
                                requestNotificationAuthorization() { result in
                                    if result == true {
                                        moveNextFromPurchase(true)
                                    }
                                }
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
                        // .opacity(button1Opacity)
                    }
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            
        } else if self.mode == 21 {
            
            // move to HoleSearchView
            HoleSearchView(from: self.from, search: self.search, course: self.course, teeingGroundInfo: self.teeingGroundInfo, teeingGroundIndex: self.teeingGroundIndex!, holeNumber: self.holeNumber!)
            
        } else if self.mode == 31 {
            
            // 알림을 허용해주세요 (Please Allow Notifications)
            // iPhone에서 Apple Watch 앱을 열고
            // '나의 시계' 탭 - '알림' - 'Holeman' - 알림 허용
            
            // ToDo: open Notification in iPhone
            
            ZStack {
                VStack {
                    // Text("알림을 허용해주세요.").font(.system(size: 20)).fontWeight(.medium).multilineTextAlignment(.center)
                    Text("알림을 허용해주세요.").font(.system(size: 20, weight: .semibold)).padding(.top, 10)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    Text("iPhone에서 Apple Watch 앱을 열고 '나의 시계' - '알림' - 'Holeman' - 알림 허용").font(.system(size: 16)).padding(.top, 10).multilineTextAlignment(.center)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    Button(action: {
                        requestNotificationAuthorization() { result in
                            if result == true {
                                if let fun = self.onComplete {
                                    fun(true)
                                }
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 54, height: 54)
                            
                            Image(systemName: "arrow.right")
                                .font(Font.system(size: 28, weight: .heavy))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 10)
                    // .opacity(button1Opacity)
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    print("Inactive")
                } else if newPhase == .active {
                    print("Active")
                    
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        print("Notification settings: \(settings)")
                        
                        if settings.authorizationStatus == .authorized {
                            print("Push notification is enabled")
                            
                            if let fun = self.onComplete {
                                fun(true)
                            }
                        } else {
                            print("Push notification is not enabled")
                            
                            // return
                        }
                    }
                } else if newPhase == .background {
                    print("Background")
                }
            }
        }
    }
    
    func checkLastPurchasedCourse() {
        let time = UserDefaults.standard.string(forKey: "LAST_PURCHASED_COURSE_TIME")
        if let time = time {
            // get current time
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 2019-12-20 09:40:08
            let dateString = dateFormatter.string(from: date)
            
            var i1 = dateString.index(dateString.startIndex, offsetBy: 0)
            var i2 = dateString.index(dateString.startIndex, offsetBy: 10)
            let date2 = dateString[i1..<i2] // yyyy-MM-dd
            
            i1 = time.index(time.startIndex, offsetBy: 0)
            i2 = time.index(time.startIndex, offsetBy: 10)
            let date1 = time[i1..<i2]
            
            if date1 == date2 { // 오늘 구매 (last played hole 정보 비교)
                checkLastPlayedHole()
            } else { // 날짜가 다르면 새 게임 (last purchased course 정보만 삭제)
                startNew(true, false, true)
            }
        } else { // 정보가 없으면 새 게임 (last played hole 정보는 유지)
            startNew(true, false, true)
        }
    }
    
    func checkLastPlayedHole() {
        let time = UserDefaults.standard.string(forKey: "LAST_PLAYED_HOLE_TIME")
        let halftime = UserDefaults.standard.integer(forKey: "LAST_PLAYED_HOLE_HALFTIME")
        
        if let time = time {
            // get current time
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 2019-12-20 09:40:08
            let dateString = dateFormatter.string(from: date)
            
            var i1 = dateString.index(dateString.startIndex, offsetBy: 0)
            var i2 = dateString.index(dateString.startIndex, offsetBy: 10)
            let date2 = dateString[i1..<i2] // yyyy-MM-dd
            
            i1 = time.index(time.startIndex, offsetBy: 0)
            i2 = time.index(time.startIndex, offsetBy: 10)
            let date1 = time[i1..<i2]
            
            if date1 == date2 { // 이전 플레이 홀에 이어서 실행
                
                if halftime == 1 { // 전반 중 앱이 죽었다가 다시 실행
                    loadHole()
                    
                    self.textMessage = "플레이 중인 라운드와 이어서 하시겠습니까?"
                    
                    withAnimation {
                        self.mode = 11
                    }
                } else if halftime == 2 { // 전반 종료 후 앱이 죽었다가 다시 실행
                    loadHole()
                    
                    self.textMessage = "플레이 중인 라운드와 이어서 하시겠습니까?"
                    
                    withAnimation {
                        self.mode = 12
                    }
                } else if halftime == 3 { // 후반 중 앱이 죽었다가 다시 실행
                    loadHole()
                    
                    self.textMessage = "플레이 중인 라운드와 이어서 하시겠습니까?"
                    
                    withAnimation {
                        self.mode = 13
                    }
                } else if halftime == 4 { // 후반 종료 후 앱이 죽었다가 다시 실행
                    startNew(true, true, true)
                }
                
            } else { // 이전 플레이 홀 날짜가 다를 수 있다. (오늘 구매하고 아직 홀 정보가 없다는 뜻)
                loadCourse()
                
                self.textMessage = "플레이 중인 라운드와 이어서 하시겠습니까?"
                
                withAnimation {
                    self.mode = 15
                }
            }
        } else { // 구매하고 홀 플레이 하기 전에 앱이 종료되었다.
            loadCourse()
            
            self.textMessage = "플레이 중인 라운드와 이어서 하시겠습니까?"
            
            withAnimation {
                self.mode = 14
            }
        }
    }
    
    func moveNext(_ search: Bool) {
        print(#function, search)
        
        /*
         let time = UserDefaults.standard.string(forKey: "LAST_PLAYED_HOLE_TIME")
         let holeNumber = UserDefaults.standard.integer(forKey: "LAST_PLAYED_HOLE_HOLE_NUMBER")
         let teeingGroundIndex = UserDefaults.standard.integer(forKey: "LAST_PLAYED_HOLE_TEEING_GROUND_INDEX")
         
         if time != nil {
         // get course
         // --
         var c: CourseModel = CourseModel(address: "", countryCode: "", courses: [], id: 0, location: CLLocation(latitude: 0.0, longitude: 0.0), name: "")
         
         let address = UserDefaults.standard.string(forKey: "LAST_PLAYED_HOLE_COURSE_ADDRESS")
         let countryCode = UserDefaults.standard.string(forKey: "LAST_PLAYED_HOLE_COURSE_COUNTRY_CODE")
         
         c.address = address!
         c.countryCode = countryCode!
         
         let courses = UserDefaults.standard.stringArray(forKey: "LAST_PLAYED_HOLE_COURSE_COURSES")
         for course in courses! {
         do {
         let data = Data(course.utf8)
         let decodedData = try JSONDecoder().decode(CourseData.self, from: data)
         
         let item = CourseItem(name: decodedData.name, range: [decodedData.range[0], decodedData.range[1]])
         c.courses.append(item)
         } catch {
         print(error)
         return
         }
         }
         
         let id = UserDefaults.standard.integer(forKey: "LAST_PLAYED_HOLE_COURSE_ID")
         
         let latitude = UserDefaults.standard.double(forKey: "LAST_PLAYED_HOLE_COURSE_LATITUDE")
         let longitude = UserDefaults.standard.double(forKey: "LAST_PLAYED_HOLE_COURSE_LONGITUDE")
         let name = UserDefaults.standard.string(forKey: "LAST_PLAYED_HOLE_COURSE_NAME")
         
         c.id = Int64(id)
         c.location = CLLocation(latitude: latitude, longitude: longitude)
         c.name = name!
         // --
         
         // get teeingGroundInfo
         // --
         let unit = UserDefaults.standard.string(forKey: "LAST_PLAYED_HOLE_TEEING_GROUND_INFO_UNIT")
         
         let holes = UserDefaults.standard.stringArray(forKey: "LAST_PLAYED_HOLE_TEEING_GROUND_INFO_HOLES")
         var array: [TeeingGrounds] = []
         for hole in holes! {
         do {
         let data = Data(hole.utf8)
         let decodedData = try JSONDecoder().decode(TeeingGroundsData.self, from: data)
         
         //let item = CourseItem(name: decodedData.name, range: [decodedData.range[0], decodedData.range[1]])
         //c.courses.append(item)
         
         var teeingGrounds: [TeeingGround] = []
         for tg in decodedData.teeingGrounds {
         let teeingGround = TeeingGround(name: tg.name, color: tg.color, distance: tg.distance)
         teeingGrounds.append(teeingGround)
         }
         
         let item = TeeingGrounds(teeingGrounds: teeingGrounds, par: decodedData.par, handicap: decodedData.handicap, name: decodedData.name)
         
         array.append(item)
         } catch {
         print(error)
         return
         }
         }
         
         let t = TeeingGroundInfoModel(unit: unit!, holes: array)
         // --
         
         moveToHoleSearchView(100, search, c, holeNumber, t, teeingGroundIndex)
         }
         */
        // moveToHoleSearchView(100, search, self.course, self.holeNumber, self.teeingGroundInfo, self.teeingGroundIndex)
        
        self.from = 100
        self.search = search
        
        withAnimation {
            self.mode = 21
        }
    }
    
    func moveToHoleSearchView(_ from: Int, _ search: Bool, _ course: CourseModel?, _ holeNumber: Int?, _ teeingGroundInfo: TeeingGroundInfoModel?, _ teeingGroundIndex: Int?) {
        self.from = from
        self.search = search
        self.course = course
        self.holeNumber = holeNumber
        self.teeingGroundInfo = teeingGroundInfo
        self.teeingGroundIndex = teeingGroundIndex
        
        withAnimation {
            self.mode = 21
        }
    }
    
    func moveNextFromPurchase(_ removePlayData: Bool) {
        print(#function)
        
        if removePlayData == true {
            let defaults = UserDefaults.standard
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                
                if key.hasPrefix("LAST_PLAYED_HOLE") {
                    defaults.removeObject(forKey: key)
                }
                
            }
        }
        
        /*
         // get course
         // --
         var c: CourseModel = CourseModel(address: "", countryCode: "", courses: [], id: 0, location: CLLocation(latitude: 0.0, longitude: 0.0), name: "")
         
         let address = UserDefaults.standard.string(forKey: "LAST_PURCHASED_COURSE_COURSE_ADDRESS")
         let countryCode = UserDefaults.standard.string(forKey: "LAST_PURCHASED_COURSE_COURSE_COUNTRY_CODE")
         
         c.address = address!
         c.countryCode = countryCode!
         
         let courses = UserDefaults.standard.stringArray(forKey: "LAST_PURCHASED_COURSE_COURSE_COURSES")
         for course in courses! {
         do {
         let data = Data(course.utf8)
         let decodedData = try JSONDecoder().decode(CourseData.self, from: data)
         
         let item = CourseItem(name: decodedData.name, range: [decodedData.range[0], decodedData.range[1]])
         c.courses.append(item)
         } catch {
         print(error)
         return
         }
         }
         
         let id = UserDefaults.standard.integer(forKey: "LAST_PURCHASED_COURSE_COURSE_ID")
         
         let latitude = UserDefaults.standard.double(forKey: "LAST_PURCHASED_COURSE_COURSE_LATITUDE")
         let longitude = UserDefaults.standard.double(forKey: "LAST_PURCHASED_COURSE_COURSE_LONGITUDE")
         let name = UserDefaults.standard.string(forKey: "LAST_PURCHASED_COURSE_COURSE_NAME")
         
         c.id = Int64(id)
         c.location = CLLocation(latitude: latitude, longitude: longitude)
         c.name = name!
         // --
         */
        
        // moveToHoleSearchView(400, true, c, 0, nil, -1)
        self.from = 400
        self.search = true
        // self.course = c
        self.holeNumber = 0
        // self.teeingGroundInfo = nil
        self.teeingGroundIndex = -1
        
        withAnimation {
            self.mode = 21
        }
    }
    
    /*
     func startNew(_ removeData: Bool, _ showTextAnimation: Bool) {
     print(#function, removeData, showTextAnimation)
     
     // clean UserDefaults except USER ID, SUB
     if removeData == true {
     let defaults = UserDefaults.standard
     let dictionary = defaults.dictionaryRepresentation()
     dictionary.keys.forEach { key in
     if key == "USER_ID" || key == "SUBSCRIPTION_SENSORS_SUB_ID" || key == "SUBSCRIPTION_SENSORS_COURSE_ID" {
     // skip
     } else {
     defaults.removeObject(forKey: key)
     }
     }
     }
     
     Global.halftime = 1
     
     if showTextAnimation == true {
     self.mode = 0
     } else {
     // Sign in with Apple
     checkUserIdentifierValidation()
     }
     }
     */
    func startNew(_ removePurchaseData: Bool, _ removePlayData: Bool, _ showTextAnimation: Bool) {
        if removePurchaseData == true {
            let defaults = UserDefaults.standard
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                
                if key.hasPrefix("LAST_PURCHASED_COURSE") {
                    defaults.removeObject(forKey: key)
                }
                
            }
        }
        
        if removePlayData == true {
            let defaults = UserDefaults.standard
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                
                if key.hasPrefix("LAST_PLAYED_HOLE") {
                    defaults.removeObject(forKey: key)
                }
                
            }
        }
        
        Global.halftime = 1
        
        if showTextAnimation == true {
            self.mode = 0
        } else {
            // Sign in with Apple
            // checkUserIdentifierValidation()
            
            requestNotificationAuthorization() { result in
                if result == true {
                    // Sign in with Apple
                    checkUserIdentifierValidation()
                }
            }
        }
    }
    
    func checkUserIdentifierValidation() {
        let id = UserDefaults.standard.string(forKey: "USER_ID")
        if let id = id {
            // check validation
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: id) { (credentialState, error) in
                /*
                 switch credentialState {
                 case .authorized:
                 // The Apple ID credential is valid.
                 
                 case .revoked:
                 // The Apple ID credential is revoked.
                 
                 case .notFound:
                 // No credential was found, so show the sign-in UI.
                 
                 default:
                 }
                 */
                if credentialState != .authorized {
                    // show UI
                    withAnimation {
                        self.mode = 2
                    }
                } else {
                    // pass
                    withAnimation {
                        self.mode = 3
                    }
                }
            }
        } else {
            // show UI
            withAnimation {
                self.mode = 2
            }
        }
    }
    
    func requestNotificationAuthorization(onComplete: @escaping (_ result: Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print(error.localizedDescription)
                
                // ToDo: error handling
                
                return
            }
            
            if granted {
                print("Notification Permission granted")
                
                DispatchQueue.main.async {
                    WKExtension.shared().registerForRemoteNotifications()
                }
                
                onComplete(true)
            } else { // denied
                print("Permission denied")
                
                if self.onComplete == nil {
                    print("self.onComplete is nil")
                    self.onComplete = onComplete
                    
                    // open request window
                    withAnimation {
                        self.mode = 31
                    }
                } else {
                    print("self.onComplete is NOT nil")
                }
            }
        }
    }
    
    func loadHole() {
        // let time = UserDefaults.standard.string(forKey: "LAST_PLAYED_HOLE_TIME")
        let holeNumber = UserDefaults.standard.integer(forKey: "LAST_PLAYED_HOLE_HOLE_NUMBER")
        let teeingGroundIndex = UserDefaults.standard.integer(forKey: "LAST_PLAYED_HOLE_TEEING_GROUND_INDEX")
        
        // if time != nil {
        // get course
        // --
        var c: CourseModel = CourseModel(address: "", countryCode: "", courses: [], id: 0, location: CLLocation(latitude: 0.0, longitude: 0.0), name: "")
        
        let address = UserDefaults.standard.string(forKey: "LAST_PLAYED_HOLE_COURSE_ADDRESS")
        let countryCode = UserDefaults.standard.string(forKey: "LAST_PLAYED_HOLE_COURSE_COUNTRY_CODE")
        
        c.address = address!
        c.countryCode = countryCode!
        
        let courses = UserDefaults.standard.stringArray(forKey: "LAST_PLAYED_HOLE_COURSE_COURSES")
        for course in courses! {
            do {
                let data = Data(course.utf8)
                let decodedData = try JSONDecoder().decode(CourseData.self, from: data)
                
                let item = CourseItem(name: decodedData.name, range: [decodedData.range[0], decodedData.range[1]])
                c.courses.append(item)
            } catch {
                print(error)
                
                // ToDo: error handling
                
                return
            }
        }
        
        let id = UserDefaults.standard.integer(forKey: "LAST_PLAYED_HOLE_COURSE_ID")
        
        let latitude = UserDefaults.standard.double(forKey: "LAST_PLAYED_HOLE_COURSE_LATITUDE")
        let longitude = UserDefaults.standard.double(forKey: "LAST_PLAYED_HOLE_COURSE_LONGITUDE")
        let name = UserDefaults.standard.string(forKey: "LAST_PLAYED_HOLE_COURSE_NAME")
        
        c.id = Int64(id)
        c.location = CLLocation(latitude: latitude, longitude: longitude)
        c.name = name!
        // --
        
        // get teeingGroundInfo
        // --
        let unit = UserDefaults.standard.string(forKey: "LAST_PLAYED_HOLE_TEEING_GROUND_INFO_UNIT")
        
        let holes = UserDefaults.standard.stringArray(forKey: "LAST_PLAYED_HOLE_TEEING_GROUND_INFO_HOLES")
        var array: [TeeingGrounds] = []
        for hole in holes! {
            do {
                let data = Data(hole.utf8)
                let decodedData = try JSONDecoder().decode(TeeingGroundsData.self, from: data)
                
                //let item = CourseItem(name: decodedData.name, range: [decodedData.range[0], decodedData.range[1]])
                //c.courses.append(item)
                
                var teeingGrounds: [TeeingGround] = []
                for tg in decodedData.teeingGrounds {
                    let teeingGround = TeeingGround(name: tg.name, color: tg.color, distance: tg.distance)
                    teeingGrounds.append(teeingGround)
                }
                
                let item = TeeingGrounds(teeingGrounds: teeingGrounds, par: decodedData.par, handicap: decodedData.handicap, name: decodedData.name)
                
                array.append(item)
            } catch {
                print(error)
                
                // ToDo: error handling
                
                return
            }
        }
        
        let t = TeeingGroundInfoModel(unit: unit!, holes: array)
        // --
        
        self.course = c
        self.holeNumber = holeNumber
        self.teeingGroundInfo = t
        self.teeingGroundIndex = teeingGroundIndex
        // }
    } // end of func loadHole()
    
    func loadCourse() {
        // get course
        // --
        var c: CourseModel = CourseModel(address: "", countryCode: "", courses: [], id: 0, location: CLLocation(latitude: 0.0, longitude: 0.0), name: "")
        
        let address = UserDefaults.standard.string(forKey: "LAST_PURCHASED_COURSE_COURSE_ADDRESS")
        let countryCode = UserDefaults.standard.string(forKey: "LAST_PURCHASED_COURSE_COURSE_COUNTRY_CODE")
        
        c.address = address!
        c.countryCode = countryCode!
        
        let courses = UserDefaults.standard.stringArray(forKey: "LAST_PURCHASED_COURSE_COURSE_COURSES")
        for course in courses! {
            do {
                let data = Data(course.utf8)
                let decodedData = try JSONDecoder().decode(CourseData.self, from: data)
                
                let item = CourseItem(name: decodedData.name, range: [decodedData.range[0], decodedData.range[1]])
                c.courses.append(item)
            } catch {
                print(error)
                return
            }
        }
        
        let id = UserDefaults.standard.integer(forKey: "LAST_PURCHASED_COURSE_COURSE_ID")
        
        let latitude = UserDefaults.standard.double(forKey: "LAST_PURCHASED_COURSE_COURSE_LATITUDE")
        let longitude = UserDefaults.standard.double(forKey: "LAST_PURCHASED_COURSE_COURSE_LONGITUDE")
        let name = UserDefaults.standard.string(forKey: "LAST_PURCHASED_COURSE_COURSE_NAME")
        
        c.id = Int64(id)
        c.location = CLLocation(latitude: latitude, longitude: longitude)
        c.name = name!
        // --
        
        self.course = c
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
