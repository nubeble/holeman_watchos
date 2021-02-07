//
//  IntroView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/12/11.
//

import SwiftUI

struct IntroView: View {
    @State var mode: Int = 0
    
    @State var text1: String = "안녕하세요!"
    @State var text1Opacity: Double = 0
    
    @State var text2: String = "정확한 거리"
    @State var text2Opacity: Double = 0
    
    @State var text3: String = "홀맨이 알려드릴게요."
    @State var text3Opacity: Double = 0
    
    @State var button1Opacity: Double = 0
    
    
    @State var textMessage: String = ""
    
    
    
    // @State private var textValue: String = "Sample Data"
    // @State private var opacity: Double = 1
    
    var body: some View {
        
        if self.mode == 0 {
            
            VStack {
                Text(text1).font(.system(size: 24)).opacity(text1Opacity)
            }
            .onAppear {
                
                // ToDo: test
                checkLastPlayedHole()
                
                
                
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
                    Text(text2).font(.system(size: 24)).opacity(text2Opacity)
                    Text(text3).font(.system(size: 24)).opacity(text3Opacity)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    Button(action: {
                        print("button click")
                        
                        withAnimation {
                            self.mode = 2
                        }
                    }) {
                        /*
                         VStack {
                         Image(systemName: "arrow.right")
                         .font(Font.system(size: 28, weight: .heavy))
                         // .resizable()
                         // .frame(width: 30, height: 30)
                         // Text("Circle!")
                         }
                         .padding(14)
                         .background(Color.green)
                         .mask(Circle())
                         */
                        
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
                    
                    /*
                     Text("\(textValue)")
                     .opacity(opacity)
                     
                     Button("Next") {
                     withAnimation(.easeInOut(duration: 0.5), {
                     self.opacity = 0
                     })
                     self.textValue = "uuuuuuuuuuuuuuu"
                     withAnimation(.easeInOut(duration: 1), {
                     self.opacity = 1
                     })
                     }
                     */
                }
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
            
        } else if self.mode == 2 {
            
            // move to course view
            CourseView()
            
        } else if self.mode == 11 {
            
            ZStack {
                VStack {
                    Text(self.textMessage).font(.system(size: 24)).bold()
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
                    Text(self.textMessage).font(.system(size: 24)).bold()
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
                    Text(self.textMessage).font(.system(size: 24)).bold()
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
            
        }
    }
    
    func checkLastPlayedHole() {
        let time = UserDefaults.standard.string(forKey: "TIME")
        let halftime = UserDefaults.standard.integer(forKey: "HALFTIME")
        
        if let _time = time {
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
            
            
            i1 = _time.index(_time.startIndex, offsetBy: 0)
            i2 = _time.index(_time.startIndex, offsetBy: 10)
            let date1 = _time[i1..<i2]
            
            i1 = _time.index(_time.startIndex, offsetBy: 11)
            i2 = _time.index(_time.startIndex, offsetBy: 13)
            let hour1 = _time[i1..<i2]
            
            i1 = _time.index(_time.startIndex, offsetBy: 11)
            i2 = _time.index(_time.startIndex, offsetBy: 13)
            let min1 = _time[i1..<i2]
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
                        self.textMessage = "플레이 중인 라운드와 이어서 하시겠습니까?"
                        
                        withAnimation {
                            self.mode = 11
                        }
                    } else if halftime == 2 { // 전반 종료 후 앱이 죽었다가 다시 실행
                        self.textMessage = "플레이 중인 라운드와 이어서 하시겠습니까?"
                        
                        withAnimation {
                            self.mode = 12
                        }
                    } else if halftime == 3 { // 후반 중 앱이 죽었다가 다시 실행
                        self.textMessage = "플레이 중인 라운드와 이어서 하시겠습니까?"
                        
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
        // ToDo
        
        
        
        
        
    }
    
    func moveToHoleSearchView() {
        // ToDo
        
        
        var c: CourseModel = CourseModel(address: "", countryCode: "", courses: [], id: 0, location: CLLocation(latitude: 0.0, longitude: 0.0), name: "")
        
        let address = UserDefaults.standard.string(forKey: "COURSE_ADDRESS")
        let countryCode = UserDefaults.standard.string(forKey: "COURSE_COUNTRY_CODE")
        
        c.address = address!
        c.countryCode = countryCode!
        
        let strings = UserDefaults.standard.stringArray(forKey: "COURSE_COURSES")
        for string in strings! {
            do {
                let data = Data(string.utf8)
                let decodedData = try JSONDecoder().decode(CourseData.self, from: data)
                
                let item = CourseItem(name: decodedData.name, range: [decodedData.range[0], decodedData.range[1]])
                c.courses.append(item)
            } catch {
                // ToDo: error handling
                print(error)
            }
        }
        
        let id = UserDefaults.standard.integer(forKey: "COURSE_ID")
        
        let latitude = UserDefaults.standard.double(forKey: "COURSE_LATITUDE")
        let longitude = UserDefaults.standard.double(forKey: "COURSE_LONGITUDE")
        let name = UserDefaults.standard.string(forKey: "COURSE_NAME")
        
        c.id = Int64(id)
        c.location = CLLocation(latitude: latitude, longitude: longitude)
        c.name = name!
        
        
        let holeNumber = UserDefaults.standard.integer(forKey: "HOLE_NUMBER")
        let teeingGroundIndex = UserDefaults.standard.integer(forKey: "TEEING_GROUND_INDEX")
        let halftime = UserDefaults.standard.integer(forKey: "HALFTIME")
        
    }
    
    func startNew(_ removeData: Bool, _ showTextAnimation: Bool) {
        // ToDo
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
