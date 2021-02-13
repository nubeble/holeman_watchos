//
//  IntroView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/12/11.
//

import SwiftUI
import AuthenticationServices

struct IntroView: View {
    @State var mode: Int = -1
    
    @State var text1: String = "안녕하세요!"
    @State var text1Opacity: Double = 0
    
    @State var text2: String = "정확한 거리"
    @State var text2Opacity: Double = 0
    
    @State var text3: String = "홀맨이 알려드릴게요."
    @State var text3Opacity: Double = 0
    
    @State var button1Opacity: Double = 0
    
    
    @State var textMessage: String = ""
    
    // pass to HoleSearchView
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

                
                
                
                
                checkLastPlayedHole()
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
                        // Sign in with Apple
                        checkUserIdentifierValidation()
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
                    withAnimation(.easeInOut(duration: 1), {
                        self.text3Opacity = 1
                    })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
                    Text("홀맨을 이용하시려면\n로그인이 필요합니다.").font(.system(size: 22)).fontWeight(.medium).multilineTextAlignment(.center)
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
                            
                            var name: String = ""
                            if let fullName = credential.fullName {
                                let firstName = fullName.givenName ?? ""
                                let lastName = fullName.familyName ?? ""
                                
                                if firstName.count > 0 {
                                    if lastName.count > 0 {
                                        name = firstName + " " + lastName
                                    } else {
                                        name = firstName
                                    }
                                } else {
                                    let nickname = fullName.nickname ?? "Unknown"
                                    name = nickname
                                }
                            }
                            
                            let email: String = credential.email ?? ""
                            
                            print(userIdentifier, name, email)
                            
                            // 1. save to db
                            CloudKitManager.saveUser(userIdentifier, name, email)
                            
                            // 2. save to UserDefaults
                            UserDefaults.standard.set(userIdentifier, forKey: "USER_ID")
                            
                            // move next
                            self.mode = 3
                            
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
            
        } else if self.mode == 11 {
            
            ZStack {
                VStack {
                    Text(self.textMessage).font(.system(size: 22)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    HStack(spacing: 40) {
                        // button 1
                        Button(action: {
                            // 새 게임으로 시작
                            
                            startNew(true, false)
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
                            Global.halftime = 1
                            
                            moveNext(false)
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
            
        } else if self.mode == 12 {
            
            ZStack {
                VStack {
                    Text(self.textMessage).font(.system(size: 22)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    HStack(spacing: 40) {
                        // button 1
                        Button(action: {
                            // 새 게임으로 시작
                            
                            startNew(true, false)
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
                            Global.halftime = 2
                            
                            moveNext(true)
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
            
        } else if self.mode == 13 {
            
            ZStack {
                VStack {
                    Text(self.textMessage).font(.system(size: 22)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    HStack(spacing: 40) {
                        // button 1
                        Button(action: {
                            // 새 게임으로 시작
                            
                            startNew(true, false)
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
                            Global.halftime = 2
                            
                            moveNext(false)
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
            HoleSearchView(from: 100, search: self.search, course: self.course, teeingGroundInfo: self.teeingGroundInfo, teeingGroundIndex: self.teeingGroundIndex!, holeNumber: self.holeNumber!)
            
        }
    }
    
    func checkLastPlayedHole() {
        let time = UserDefaults.standard.string(forKey: "TIME")
        let halftime = UserDefaults.standard.integer(forKey: "HALFTIME")
        
        if let time = time {
            // get current time
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 2019-12-20 09:40:08
            let dateString = dateFormatter.string(from: date)
            
            
            var i1 = dateString.index(dateString.startIndex, offsetBy: 0)
            var i2 = dateString.index(dateString.startIndex, offsetBy: 10)
            let date2 = dateString[i1..<i2] // yyyy-MM-dd
            
            i1 = dateString.index(dateString.startIndex, offsetBy: 11)
            i2 = dateString.index(dateString.startIndex, offsetBy: 13)
            let hour2 = dateString[i1..<i2] // HH
            
            i1 = dateString.index(dateString.startIndex, offsetBy: 14)
            i2 = dateString.index(dateString.startIndex, offsetBy: 16)
            let min2 = dateString[i1..<i2] // mm
            print(#function, date2, hour2, min2)
            
            
            i1 = time.index(time.startIndex, offsetBy: 0)
            i2 = time.index(time.startIndex, offsetBy: 10)
            let date1 = time[i1..<i2]
            
            i1 = time.index(time.startIndex, offsetBy: 11)
            i2 = time.index(time.startIndex, offsetBy: 13)
            let hour1 = time[i1..<i2]
            
            i1 = time.index(time.startIndex, offsetBy: 11)
            i2 = time.index(time.startIndex, offsetBy: 13)
            let min1 = time[i1..<i2]
            print(#function, date1, hour1, min1)
            
            
            if date1 == date2 {
                let h1 = Int(hour1)
                let m1 = Int(min1)
                let h2 = Int(hour2)
                let m2 = Int(min2)
                let sum1 = h1! * 60 + m1!
                let sum2 = h2! * 60 + m2!
                
                if (sum2 - sum1) < 60 {
                    if halftime == 1 { // 전반 중 앱이 죽었다가 다시 실행
                        self.textMessage = "플레이 중인 라운드와\n이어서 하시겠습니까?"
                        
                        withAnimation {
                            self.mode = 11
                        }
                    } else if halftime == 2 { // 전반 종료 후 앱이 죽었다가 다시 실행
                        self.textMessage = "플레이 중인 라운드와\n이어서 하시겠습니까?"
                        
                        withAnimation {
                            self.mode = 12
                        }
                    } else if halftime == 3 { // 후반 중 앱이 죽었다가 다시 실행
                        self.textMessage = "플레이 중인 라운드와\n이어서 하시겠습니까?"
                        
                        withAnimation {
                            self.mode = 13
                        }
                    } else if halftime == 4 { // 후반 종료 후 앱이 죽었다가 다시 실행
                        startNew(true, true)
                    }
                } else {
                    startNew(true, true)
                }
            } else {
                startNew(true, true)
            }
        } else {
            startNew(false, true)
        }
    }
    
    func moveNext(_ search: Bool) {
        // holeNumber, teeingGroundIndex, course
        
        let time = UserDefaults.standard.string(forKey: "TIME")
        let holeNumber = UserDefaults.standard.integer(forKey: "HOLE_NUMBER")
        let teeingGroundIndex = UserDefaults.standard.integer(forKey: "TEEING_GROUND_INDEX")
        
        
        if time != nil {
            // get course
            // --
            var c: CourseModel = CourseModel(address: "", countryCode: "", courses: [], id: 0, location: CLLocation(latitude: 0.0, longitude: 0.0), name: "")
            
            let address = UserDefaults.standard.string(forKey: "COURSE_ADDRESS")
            let countryCode = UserDefaults.standard.string(forKey: "COURSE_COUNTRY_CODE")
            
            c.address = address!
            c.countryCode = countryCode!
            
            let courses = UserDefaults.standard.stringArray(forKey: "COURSE_COURSES")
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
            
            let id = UserDefaults.standard.integer(forKey: "COURSE_ID")
            
            let latitude = UserDefaults.standard.double(forKey: "COURSE_LATITUDE")
            let longitude = UserDefaults.standard.double(forKey: "COURSE_LONGITUDE")
            let name = UserDefaults.standard.string(forKey: "COURSE_NAME")
            
            c.id = Int64(id)
            c.location = CLLocation(latitude: latitude, longitude: longitude)
            c.name = name!
            // --
            
            // get teeingGroundInfo
            // --
            let unit = UserDefaults.standard.string(forKey: "TEEING_GROUND_INFO_UNIT")
            
            let holes = UserDefaults.standard.stringArray(forKey: "TEEING_GROUND_INFO_HOLES")
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
            
            moveToHoleSearchView(search, c, holeNumber, t, teeingGroundIndex)
        }
        
    }
    
    func moveToHoleSearchView(_ search: Bool, _ course: CourseModel, _ holeNumber: Int, _ teeingGroundInfo: TeeingGroundInfoModel, _ teeingGroundIndex: Int) {
        self.search = search
        self.course = course
        self.holeNumber = holeNumber
        self.teeingGroundInfo = teeingGroundInfo
        self.teeingGroundIndex = teeingGroundIndex
        
        withAnimation {
            self.mode = 21
        }
    }
    
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
    
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
