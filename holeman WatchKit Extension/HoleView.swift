//
//  HoleView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/02/04.
//

import SwiftUI

struct HoleView: View {
    @State var mode: Int = 0
    
    @State var titles: [String] = []
    @State var selectedIndex: Int = -1
    
    // backup of MainView
    var __course: CourseModel?
    var __teeingGroundInfo: TeeingGroundInfoModel?
    var __teeingGroundIndex: Int?
    // var __holeNumber: Int?
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
                    // VStack {
                    ScrollViewReader { value in
                        LazyVStack {
                            Text("Select Hole").font(.system(size: 20, weight: .semibold))
                            Text("플레이 홀을 선택하세요.").font(.system(size: 14, weight: .light)).padding(.bottom, Static.title2PaddingBottom)
                            
                            ForEach(0 ..< self.titles.count) {
                                let index = $0
                                
                                let title = self.titles[index]
                                
                                Button(action: {
                                    self.selectedIndex = index
                                    
                                    // go back
                                    withAnimation {
                                        self.mode = 1
                                    }
                                    
                                }) {
                                    HStack(spacing: 10) {
                                        // Text(name).font(.system(size: 18))
                                        Text(title).font(.system(size: 20))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        if index == self.selectedIndex {
                                            Spacer()
                                            
                                            Image(systemName: "checkmark")
                                                .foregroundColor(Color.green)
                                                .font(Font.system(size: 16, weight: .heavy))
                                        }
                                    }
                                }.id($0)
                            }
                            
                            Button(action: {
                                withAnimation {
                                    self.mode = 1
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    value.scrollTo(self.selectedIndex, anchor: .center)
                                }
                            }
                        }
                    }
                    // }
                } // end of ScrollView
                // .animation(Animation.linear(duration: 5000).repeatForever(autoreverses: false))
                // .animation(.easeInOut(duration: 5.0))
            }
            
        } else if self.mode == 1 {
            
            MainView(mode: 1,
                     course: self.__course, teeingGroundInfo: self.__teeingGroundInfo, teeingGroundIndex: self.__teeingGroundIndex,
                     holeNumber: self.selectedIndex + 1, distanceUnit: self.__distanceUnit!,
                     sensors: self.__sensors!, latitude: self.__latitude, longitude: self.__longitude, elevation: self.__elevation,
                     userElevation: self.__userElevation
            )
            
        }
    }
}

struct HoleView_Previews: PreviewProvider {
    static var previews: some View {
        HoleView()
    }
}
