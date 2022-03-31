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
    // var __teeingGroundIndex: Int?
    var __teeingGroundName: String?
    var __greenDirection: Int?
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
                            Text("Select Hole").font(.system(size: Global.text2Size, weight: .semibold))
                            Text("플레이 홀을 선택하세요.").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                            
                            ForEach(0 ..< self.titles.count, id: \.self) {
                                let index = $0
                                
                                let title = self.titles[index]
                                let titles = Util.splitHoleTitle(title)
                                
                                Button(action: {
                                    self.selectedIndex = index
                                    
                                    // go back
                                    withAnimation {
                                        self.mode = 1
                                    }
                                    
                                }) {
                                    HStack(spacing: Global.buttonSpacing3) {
                                        VStack {
                                            Text(titles[0]).font(.system(size: Global.text3Size))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text(titles[1]).font(.system(size: Global.text2Size))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        
                                        if index == self.selectedIndex {
                                            Spacer()
                                            
                                            Image(systemName: "checkmark")
                                                .foregroundColor(Color.green)
                                                .font(Font.system(size: Global.checkmarkIconSize, weight: .heavy))
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
                                        .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                                    
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(Color(red: 187 / 255, green: 187 / 255, blue: 187 / 255))
                                        .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, Global.buttonPaddingTop)
                            .padding(.bottom, Global.buttonPaddingBottom2)
                            
                        }
                        .onAppear {
                            // scroll
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    value.scrollTo(self.selectedIndex, anchor: .center)
                                }
                            }
                        }
                    }
                    // }
                } // ScrollView
                // .animation(Animation.linear(duration: 5000).repeatForever(autoreverses: false))
                // .animation(.easeInOut(duration: 5.0))
            }
            
        } else if self.mode == 1 {
            /*
             MainView(mode: 1,
             course: self.__course, teeingGroundInfo: self.__teeingGroundInfo, teeingGroundIndex: self.__teeingGroundIndex,
             greenDirection: self.__greenDirection, holeNumber: self.selectedIndex + 1, distanceUnit: self.__distanceUnit!,
             sensors: self.__sensors!, latitude: self.__latitude, longitude: self.__longitude, elevation: self.__elevation,
             userElevation: self.__userElevation
             )
             */
            
            let teeingGroundName = Util.getNextTeeingGroundName((self.__teeingGroundInfo?.holes[self.selectedIndex].teeingGrounds)!, self.__teeingGroundName!)
            
            MainView(mode: 1,
                     course: self.__course, teeingGroundInfo: self.__teeingGroundInfo, teeingGroundName: teeingGroundName,
                     greenDirection: self.__greenDirection, holeNumber: self.selectedIndex + 1, distanceUnit: self.__distanceUnit!,
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
