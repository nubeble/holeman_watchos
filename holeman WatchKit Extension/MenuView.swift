//
//  MenuView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/02/11.
//

import SwiftUI

struct MenuView: View {
    @State var mode: Int = 0
    @State var textMessage: String = ""
    // @State var menu: Int?
    
    // backup of MainView
    var __course: CourseModel?
    var __teeingGroundInfo: TeeingGroundInfoModel?
    // var __teeingGroundIndex: Int?
    var __teeingGroundName: String?
    var __greenDirection: Int?
    var __holeNumber: Int?
    var __distanceUnit: Int?
    var __sensors: [SensorModel]?
    var __latitude: Double?
    var __longitude: Double?
    var __elevation: Double?
    var __userElevation: Double?
    
    var body: some View {
        if self.mode == 0 {
            
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        Text("Settings").font(.system(size: Global.text2Size, weight: .semibold))
                        Text("원하시는 기능을 선택하세요.").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                        
                        // item 1
                        Button(action: {
                            self.textMessage = "플레이 중인 라운드를\n종료하시겠어요?"
                            
                            withAnimation {
                                self.mode = 1
                            }
                        }) {
                            HStack(spacing: Global.buttonSpacing3) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: Global.circleIconSize, height: Global.circleIconSize)
                                    
                                    Image(systemName: "flag.fill")
                                        .font(Font.system(size: Global.icon1Size, weight: .heavy))
                                }
                                
                                VStack(spacing: Global.buttonSpacing1) {
                                    Text("메인으로").font(.system(size: Global.text3Size))
                                    // .fixedSize(horizontal: false, vertical: true)
                                    // .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("라운드를 종료하고 코스 선택으로 돌아갑니다.").font(.system(size: Global.text6Size)).foregroundColor(Color.gray)
                                    // .fixedSize(horizontal: false, vertical: true)
                                    // .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        
                        // item 2
                        /*
                         Button(action: {
                         self.textMessage = "앱을 종료하시겠습니까?"
                         
                         withAnimation {
                         self.mode = 2
                         }
                         }) {
                         HStack(spacing: 10) {
                         ZStack {
                         Circle()
                         .fill(Color.red)
                         .frame(width: 26, height: 26)
                         
                         Image(systemName: "xmark")
                         .font(Font.system(size: 13, weight: .heavy))
                         }
                         
                         VStack(spacing: 2) {
                         Text("앱 닫기").font(.system(size: 18))
                         // .fixedSize(horizontal: false, vertical: true)
                         // .lineLimit(1)
                         .frame(maxWidth: .infinity, alignment: .leading)
                         Text("앱을 종료합니다.").font(.system(size: 12)).foregroundColor(Color.gray)
                         // .fixedSize(horizontal: false, vertical: true)
                         // .lineLimit(1)
                         .frame(maxWidth: .infinity, alignment: .leading)
                         }
                         }
                         }
                         */
                        
                        // item 3
                        Button(action: {
                            self.textMessage = "정말 로그아웃을\n하시겠어요?"
                            
                            withAnimation {
                                self.mode = 3
                            }
                        }) {
                            HStack(spacing: Global.buttonSpacing3) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: Global.circleIconSize, height: Global.circleIconSize)
                                    
                                    Image(systemName: "stop.fill")
                                        .font(Font.system(size: Global.icon1Size, weight: .heavy))
                                }
                                
                                VStack(spacing: Global.buttonSpacing1) {
                                    Text("로그아웃").font(.system(size: Global.text3Size))
                                    // .fixedSize(horizontal: false, vertical: true)
                                    // .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("로그아웃 후 계정 정보를 삭제합니다.").font(.system(size: Global.text6Size)).foregroundColor(Color.gray)
                                    // .fixedSize(horizontal: false, vertical: true)
                                    // .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        
                        // cancel button
                        Button(action: {
                            // go back to MainView
                            withAnimation {
                                self.mode = 9
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 49 / 255, green: 49 / 255, blue: 49 / 255))
                                    .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                                
                                Image(systemName: "arrow.left")
                                    .foregroundColor(Color(red: 187 / 255, green: 187 / 255, blue: 187 / 255))
                                    .font(Font.system(size: Global.icon5Size, weight: .heavy))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.top, Global.buttonPaddingTop)
                        .padding(.bottom, Global.buttonPaddingBottom2)
                        
                    } // VStack
                } // ScrollView
            } // GeometryReader
            
        } else if self.mode == 1 || self.mode == 2 || self.mode == 3 {
            
            ZStack {
                VStack {
                    Text(self.textMessage).font(.system(size: Global.text2Size)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    HStack(spacing: Global.buttonSpacing3) {
                        // button 1
                        Button(action: {
                            // back to MainView
                            withAnimation {
                                self.mode = 9
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 49 / 255, green: 49 / 255, blue: 49 / 255))
                                    .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                                
                                Image(systemName: "xmark")
                                    .font(Font.system(size: Global.icon5Size, weight: .heavy))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, Global.buttonPaddingBottom)
                        
                        // button 2
                        Button(action: {
                            if self.mode == 1 {
                                // go to CourseView
                                withAnimation {
                                    self.mode = 8
                                }
                                // } else if self.mode == 2 {
                            } else if self.mode == 3 {
                                withAnimation {
                                    self.mode = 4
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                                
                                Image(systemName: "checkmark")
                                    .font(Font.system(size: Global.icon5Size, weight: .heavy))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, Global.buttonPaddingBottom)
                    }
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            
        } else if self.mode == 4 {
            // loading indicator
            ZStack {
                ProgressView()
                    .scaleEffect(1.2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
            }
            .onAppear {
                // remove DB & UserDefaults
                
                let id = UserDefaults.standard.string(forKey: "USER_ID")
                if let id = id {
                    // update DB
                    CloudManager.removeUser(id) { result in
                        Global.halftime = 1
                        
                        // go to IntroView (Sign in with Apple)
                        withAnimation {
                            self.mode = 5
                        }
                    }
                    
                    // USER_ID
                    UserDefaults.standard.removeObject(forKey: "USER_ID")
                    
                    // LAST_PURCHASED_COURSE, LAST_PLAYED_HOLE
                    let defaults = UserDefaults.standard
                    let dictionary = defaults.dictionaryRepresentation()
                    dictionary.keys.forEach { key in
                        
                        if key.hasPrefix("LAST_PURCHASED_COURSE") || key.hasPrefix("LAST_PLAYED_HOLE") {
                            defaults.removeObject(forKey: key)
                        }
                        
                    }
                    
                    // SUBSCRIPTION_SENSORS 는 그냥 둔다.
                    
                    print(#function, "finished removing UserDefaults")
                }
            }
        } else if self.mode == 5 { // back to IntroView
            
            IntroView(mode: 2)
            
        } else if self.mode == 8 { // back to CourseView
            
            CourseView()
            
        } else if self.mode == 9 { // back to MainView
            /*
             MainView(mode: 1,
             course: self.__course, teeingGroundInfo: self.__teeingGroundInfo, teeingGroundIndex: self.__teeingGroundIndex,
             greenDirection: self.__greenDirection, holeNumber: self.__holeNumber, distanceUnit: self.__distanceUnit!,
             sensors: self.__sensors!, latitude: self.__latitude, longitude: self.__longitude, elevation: self.__elevation,
             userElevation: self.__userElevation
             )
             */
            MainView(mode: 1,
                     course: self.__course, teeingGroundInfo: self.__teeingGroundInfo, teeingGroundName: self.__teeingGroundName,
                     greenDirection: self.__greenDirection, holeNumber: self.__holeNumber, distanceUnit: self.__distanceUnit!,
                     sensors: self.__sensors!, latitude: self.__latitude, longitude: self.__longitude, elevation: self.__elevation,
                     userElevation: self.__userElevation
            )
            
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
