//
//  IntroView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/12/11.
//

import SwiftUI
import AuthenticationServices
import UserNotifications
import NaturalLanguage

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
    @State var textMessage2: String = ""
    
    @State var onCompletion: ((Bool) -> Void)?
    
    @State var name: String?
    
    // pass to HoleSearchView
    @State var from: Int?
    @State var search: Bool?
    @State var course: CourseModel?
    @State var holeNumber: Int?
    @State var teeingGroundInfo: TeeingGroundInfoModel?
    // @State var teeingGroundIndex: Int?
    @State var teeingGroundName: String?
    @State var greenDirection: Int?
    
    // @State private var textValue: String = "Sample Data"
    // @State private var opacity: Double = 1
    
    @State var clickCount = 0
    
    @State var showToast: Bool = false
    @State var toastMessage: String = ""
    
    var body: some View {
        if self.mode == -1 {
            
            VStack {
                // N/A
            }
            .onAppear {
                checkLastPurchasedCourse()
            }
            
        } else if self.mode == 0 {
            
            VStack {
                Text(self.text1).font(.system(size: Global.text1Size)).fontWeight(.medium).opacity(self.text1Opacity)
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
                    if self.showToast == true {
                        Text(self.toastMessage).font(.system(size: Global.text5Size))
                    }
                    
                    Spacer()
                }
                
                
                
                VStack {
                    Text(self.text2).font(.system(size: Global.text1Size)).fontWeight(.medium).opacity(self.text2Opacity)
                        .onTapGesture {
                            if self.showToast == true {
                                self.showToast = false
                                
                                return
                            }
                            
                            self.clickCount += 1
                            
                            if self.clickCount == 10 {
                                
                                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                                    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                                        let message = "버전 " + version + " (" + build + ")" + " (" + Static.buildMode + " 빌드)"
                                        
                                        self.toastMessage = message
                                        self.showToast = true
                                    }
                                }
                                
                                self.clickCount = 0
                            }
                        }
                    
                    Text(self.text3).font(.system(size: Global.text1Size)).fontWeight(.medium).opacity(self.text3Opacity)
                        .onTapGesture {
                            if self.showToast == true {
                                self.showToast = false
                                
                                return
                            }
                            
                            self.clickCount += 1
                            
                            if self.clickCount == 10 {
                                
                                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                                    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                                        let message = "버전 " + version + " (" + build + ")" + " (" + Static.buildMode + " 빌드)"
                                        
                                        self.toastMessage = message
                                        self.showToast = true
                                    }
                                }
                                
                                self.clickCount = 0
                            }
                        }
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    Button(action: {
                        Global.halftime = 1
                        
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
                                .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                            
                            Image(systemName: "arrow.right")
                                .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, Global.buttonPaddingBottom)
                    .opacity(self.button1Opacity)
                } // VStack
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
                        .frame(width: Global.iconWidth, height: Global.iconWidth)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    Text("홀맨을 이용하시려면 로그인이 필요합니다.").font(.system(size: Global.text2Size)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    SignInWithAppleButton(.signIn,
                                          onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                                          onCompletion: { result in
                        self.mode = 5
                        
                        switch result {
                        case .success(let authResults):
                            print("Authorization successful", authResults)
                            
                            guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential, let identityToken = credential.identityToken, let identityTokenString = String(data: identityToken, encoding: .utf8) else { return }
                            
                            let body = ["appleIdentityToken": identityTokenString]
                            guard let jsonData = try? JSONEncoder().encode(body) else { return }
                            
                            print(#function, "credential", credential, "json data", jsonData)
                            // This is where you'd fire an API request to your server to authenticate with the identity token attached in the request headers.
                            
                            // get fullName, email
                            let userIdentifier = credential.user
                            print(#function, "user", userIdentifier)
                            
                            var name: String = "noname"
                            if let fullName = credential.fullName {
                                print(#function, "fullName", fullName)
                                
                                let firstName = fullName.givenName ?? ""
                                let lastName = fullName.familyName ?? ""
                                
                                if firstName.count > 0 {
                                    let recognizer = NLLanguageRecognizer()
                                    recognizer.processString(firstName)
                                    let code = recognizer.dominantLanguage!.rawValue
                                    print("language code", code)
                                    
                                    /*
                                     if lastName.count > 0 {
                                     name = firstName + " " + lastName
                                     } else {
                                     name = firstName
                                     }
                                     */
                                    
                                    if code == "ko" || code == "zh" {
                                        name = lastName + firstName // 김재원, 逢坂大河
                                    } else {
                                        name = firstName + " " + lastName // Jay Kim
                                    }
                                } else {
                                    if let nickname = fullName.nickname {
                                        name = nickname
                                    } else {
                                        name = "noname"
                                    }
                                }
                            }
                            
                            // self.name = name
                            
                            let email: String = credential.email ?? "noemail"
                            print(#function, "email", email)
                            
                            if name == "noname" { // sign in again
                                // load from DB
                                CloudManager.getUserName(userIdentifier) { userName in
                                    var __name = ""
                                    
                                    if userName == "" {
                                        __name = "noname" // never happen
                                    } else {
                                        __name = userName
                                        self.name = __name
                                    }
                                    
                                    // CloudManager.saveUser(userIdentifier, __name, email)
                                    
                                    UserDefaults.standard.set(userIdentifier, forKey: "USER_ID")
                                    // UserDefaults.standard.set(email, forKey: "USER_EMAIL")
                                    
                                    Global.userId = userIdentifier
                                    
                                    // move to welcome
                                    withAnimation {
                                        self.mode = 4
                                    }
                                }
                            } else {
                                self.name = name
                                
                                CloudManager.saveUser(userIdentifier, name, email)
                                
                                UserDefaults.standard.set(userIdentifier, forKey: "USER_ID")
                                // UserDefaults.standard.set(email, forKey: "USER_EMAIL")
                                
                                Global.userId = userIdentifier
                                
                                // move to welcome
                                withAnimation {
                                    self.mode = 4
                                }
                            }
                        case .failure (let error):
                            print("Authorisation failed: \(error.localizedDescription)")
                            
                            // show wait message
                            withAnimation(.linear(duration: 0.5)) {
                                self.textMessage2 = "잠시 후 다시 시도해주세요."
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation {
                                    self.mode = 2
                                }
                            }
                            
                        } // end of onCompletion
                    })
                    // .signInWithAppleButtonStyle(.black) // black button
                    // .signInWithAppleButtonStyle(.white) // white button
                    .signInWithAppleButtonStyle(.whiteOutline) // white with border
                    .frame(width: Global.signInWithAppleButtonWidth, height: Global.signInWithAppleButtonHeight)
                }
            }
            
        } else if self.mode == 3 { // move to course view
            
            CourseView()
            
        } else if self.mode == 4 { // welcome
            
            ZStack {
                VStack {
                    let str1 = self.name ?? "홀맨 회원"
                    let str2 = "오늘도 홀맨과 함께"
                    let str3 = "즐거운 라운드 되세요."
                    
                    Text(str1 + "님,").font(.system(size: Global.text2Size)).fontWeight(.medium).multilineTextAlignment(.center)
                    Text(str2).font(.system(size: Global.text2Size)).fontWeight(.medium).multilineTextAlignment(.center)
                    Text(str3).font(.system(size: Global.text2Size)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                VStack(alignment: HorizontalAlignment.center) {
                    Spacer().frame(maxHeight: .infinity)
                    
                    Image("welcome")
                        .resizable()
                        .frame(width: Global.icon7Size, height: Global.icon7Size)
                        .padding(.bottom, Global.buttonPaddingBottom3)
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        self.mode = 3
                    }
                }
            }
            
        } else if self.mode == 5 {
            
            // loading indicator
            ZStack {
                ProgressView()
                    .scaleEffect(1.2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                
                VStack {
                    Spacer()
                    
                    Text(self.textMessage2).font(.system(size: Global.text4Size)).foregroundColor(Color.gray).fontWeight(.medium)
                        .transition(.opacity)
                        .id(self.textMessage2)
                }
            }
            
        } else if self.mode == 11 || self.mode == 12 || self.mode == 13 || self.mode == 14 || self.mode == 15 {
            
            ZStack {
                VStack {
                    // show course name & hole name
                    
                    if self.mode == 11 || self.mode == 13 {
                        let course = Util.getCourseName(self.course?.name)
                        // let hole = self.teeingGroundInfo?.holes[self.holeNumber! - 1].title ?? ""
                        let hole = Util.convertHoleTitle(self.teeingGroundInfo?.holes[self.holeNumber! - 1].title ?? "")
                        
                        Text(course).font(.system(size: Global.text3Size))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(hole).font(.system(size: Global.text4Size))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else if self.mode == 12 {
                        // let course = self.course?.name ?? ""
                        let course = Util.getCourseName(self.course?.name)
                        let hole = "후반전 시작"
                        
                        Text(course).font(.system(size: Global.text3Size))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(hole).font(.system(size: Global.text4Size))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else { // 14, 15
                        let course = Util.getCourseName(self.course?.name)
                        let hole = "전반전 시작"
                        
                        Text(course).font(.system(size: Global.text3Size))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(hole).font(.system(size: Global.text4Size))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    Text(self.textMessage).font(.system(size: Global.text2Size)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    HStack(spacing: Global.buttonSpacing2) {
                        // button 1
                        Button(action: {
                            // 새 게임으로 시작
                            
                            startNew(true, true, false)
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
                                    .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                                
                                Image(systemName: "checkmark")
                                    .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, Global.buttonPaddingBottom)
                        // .opacity(button1Opacity)
                    }
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            
        } else if self.mode == 21 {
            
            // move to HoleSearchView
            /*
             HoleSearchView(from: self.from, search: self.search, course: self.course,
             teeingGroundInfo: self.teeingGroundInfo, teeingGroundIndex: self.teeingGroundIndex!, greenDirection: self.greenDirection!, holeNumber: self.holeNumber!)
             */
            HoleSearchView(from: self.from, search: self.search, course: self.course,
                           teeingGroundInfo: self.teeingGroundInfo, teeingGroundName: self.teeingGroundName, greenDirection: self.greenDirection!, holeNumber: self.holeNumber!)
            
        } else if self.mode == 31 { // notice
            
            // Consider: open Notification in iPhone
            
            ZStack {
                VStack {
                    Text("Notice").font(.system(size: Global.text2Size, weight: .semibold))
                    Text("알림을 허용해주세요.").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    // let name = Locale.current.languageCode == "ko" ? "홀맨" : "Holeman"
                    // let text = "iPhone에서 Apple Watch 앱을 열고 '나의 시계' - '알림' - '\(name)' - '알림 허용' 선택"
                    let text = "iPhone에서 Apple Watch 앱을 열고 \"나의 시계\" > \"알림\" > \"홀맨\" > '알림 허용' 선택"
                    Text(text).font(.system(size: Global.text4Size)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    Button(action: {
                        requestNotificationAuthorization() { result in
                            if result == true {
                                if let fun = self.onCompletion {
                                    fun(true)
                                }
                            }
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
                            
                            if let fun = self.onCompletion {
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
            
            if date1 == date2 { // 플레이 중인 홀에 이어서 진행
                
                if halftime == 1 { // 전반 중 앱이 죽었다가 다시 실행
                    loadHole()
                    
                    self.textMessage = "플레이 중인 라운드가 있습니다. 이어서 할까요?"
                    
                    withAnimation {
                        self.mode = 11
                    }
                } else if halftime == 2 { // 전반 종료 후 앱이 죽었다가 다시 실행
                    loadHole()
                    
                    self.textMessage = "플레이 중인 라운드가 있습니다. 이어서 할까요?"
                    
                    withAnimation {
                        self.mode = 12
                    }
                } else if halftime == 3 { // 후반 중 앱이 죽었다가 다시 실행
                    loadHole()
                    
                    self.textMessage = "플레이 중인 라운드가 있습니다. 이어서 할까요?"
                    
                    withAnimation {
                        self.mode = 13
                    }
                } else if halftime == 4 { // 후반 종료 후 앱이 죽었다가 다시 실행
                    startNew(true, true, true)
                }
                
            } else { // 이전 플레이 홀 날짜가 다를 수 있다. (오늘 구매하고 아직 홀 정보가 없다는 뜻)
                
                loadCourse()
                
                self.textMessage = "플레이 중인 라운드가 있습니다. 이어서 할까요?"
                
                withAnimation {
                    self.mode = 15
                }
            }
        } else { // 구매하고 홀 플레이 하기 전에 앱이 종료되었다.
            
            loadCourse()
            
            self.textMessage = "플레이 중인 라운드가 있습니다. 이어서 할까요?"
            
            withAnimation {
                self.mode = 14
            }
        }
    }
    
    func moveNext(_ search: Bool) {
        print(#function, search)
        
        self.from = 100
        self.search = search
        
        withAnimation {
            self.mode = 21
        }
    }
    
    // func moveToHoleSearchView(_ from: Int, _ search: Bool, _ course: CourseModel?, _ holeNumber: Int?, _ teeingGroundInfo: TeeingGroundInfoModel?, _ teeingGroundIndex: Int?, _ greenDirection: Int?) {
    func moveToHoleSearchView(_ from: Int, _ search: Bool, _ course: CourseModel?, _ holeNumber: Int?, _ teeingGroundInfo: TeeingGroundInfoModel?, _ teeingGroundName: String?, _ greenDirection: Int?) {
        self.from = from
        self.search = search
        self.course = course
        self.holeNumber = holeNumber
        self.teeingGroundInfo = teeingGroundInfo
        // self.teeingGroundIndex = teeingGroundIndex
        self.teeingGroundName = teeingGroundName
        self.greenDirection = greenDirection
        
        withAnimation {
            self.mode = 21
        }
    }
    
    func moveNextFromPurchase(_ removePlayData: Bool) {
        print(#function, removePlayData)
        
        if removePlayData == true {
            let defaults = UserDefaults.standard
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                
                if key.hasPrefix("LAST_PLAYED_HOLE") {
                    defaults.removeObject(forKey: key)
                }
                
            }
        }
        
        // moveToHoleSearchView(400, true, c, 0, nil, -1)
        self.from = 400
        // self.search = true // not used
        self.holeNumber = 1 // set default
        // self.teeingGroundIndex = 0 // set default
        // self.teeingGroundName = ""
        self.greenDirection = 100 // set default
        
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
        
        
        if showTextAnimation == true {
            self.mode = 0
        } else {
            Global.halftime = 1
            
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
                    /*
                     if let email = UserDefaults.standard.string(forKey: "USER_EMAIL") {
                     if email.contains("privaterelay.appleid.com") {
                     // show UI
                     withAnimation {
                     self.mode = 2
                     }
                     } else {
                     Global.userId = id
                     
                     // pass
                     withAnimation {
                     self.mode = 3
                     }
                     }
                     } else {
                     Global.userId = id
                     
                     // pass
                     withAnimation {
                     self.mode = 3
                     }
                     }
                     */
                    
                    Global.userId = id
                    
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
    
    func requestNotificationAuthorization(onCompletion: @escaping (_ result: Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                // print(error.localizedDescription)
                print(error)
                
                return
            }
            
            if granted {
                print("Notification Permission granted")
                
                DispatchQueue.main.async {
                    WKExtension.shared().registerForRemoteNotifications()
                }
                
                onCompletion(true)
            } else { // denied
                print("Permission denied")
                
                if self.onCompletion == nil {
                    print("self.onCompletion is nil")
                    self.onCompletion = onCompletion
                    
                    // open request window
                    withAnimation {
                        self.mode = 31
                    }
                } else {
                    print("self.onCompletion is NOT nil")
                }
            }
        }
    }
    
    func loadHole() {
        // let time = UserDefaults.standard.string(forKey: "LAST_PLAYED_HOLE_TIME")
        let holeNumber = UserDefaults.standard.integer(forKey: "LAST_PLAYED_HOLE_HOLE_NUMBER")
        // let teeingGroundIndex = UserDefaults.standard.integer(forKey: "LAST_PLAYED_HOLE_TEEING_GROUND_INDEX")
        let teeingGroundName = UserDefaults.standard.string(forKey: "LAST_PLAYED_HOLE_TEEING_GROUND_NAME")
        let greenDirection = UserDefaults.standard.integer(forKey: "LAST_PLAYED_HOLE_GREEN_DIRECTION")
        
        // if time != nil {
        // get course
        // --
        var c: CourseModel = CourseModel(address: "", countryCode: "", courses: [], id: 0, location: CLLocation(latitude: 0.0, longitude: 0.0), name: "", email: "", hlds: 0)
        
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
        let email = UserDefaults.standard.string(forKey: "LAST_PLAYED_HOLE_COURSE_EMAIL")
        let hlds = UserDefaults.standard.integer(forKey: "LAST_PLAYED_HOLE_COURSE_HLDS")
        
        c.id = Int64(id)
        c.location = CLLocation(latitude: latitude, longitude: longitude)
        c.name = name!
        c.email = email!
        c.hlds = Int64(hlds)
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
                    let teeingGround = TeeingGround(name: tg.name, color: tg.color, distances: tg.distances)
                    teeingGrounds.append(teeingGround)
                }
                
                let item = TeeingGrounds(teeingGrounds: teeingGrounds, par: decodedData.par, handicap: decodedData.handicap, title: decodedData.title, name: decodedData.name, tips: decodedData.tips)
                
                array.append(item)
            } catch {
                print(error)
                
                return
            }
        }
        
        let t = TeeingGroundInfoModel(unit: unit!, holes: array)
        // --
        
        self.course = c
        self.holeNumber = holeNumber
        self.teeingGroundInfo = t
        // self.teeingGroundIndex = teeingGroundIndex
        self.teeingGroundName = teeingGroundName
        self.greenDirection = greenDirection
        // }
    } // loadHole()
    
    func loadCourse() {
        // get course
        // --
        var c: CourseModel = CourseModel(address: "", countryCode: "", courses: [], id: 0, location: CLLocation(latitude: 0.0, longitude: 0.0), name: "", email: "", hlds: 0)
        
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
        let email = UserDefaults.standard.string(forKey: "LAST_PURCHASED_COURSE_COURSE_EMAIL")
        let hlds = UserDefaults.standard.integer(forKey: "LAST_PURCHASED_COURSE_COURSE_HLDS")
        
        c.id = Int64(id)
        c.location = CLLocation(latitude: latitude, longitude: longitude)
        c.name = name!
        c.email = email!
        c.hlds = Int64(hlds)
        // --
        
        self.course = c
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
