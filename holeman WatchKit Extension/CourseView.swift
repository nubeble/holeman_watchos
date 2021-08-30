//
//  CourseView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/09.
//

import SwiftUI

struct CourseView: View {
    @State var mode: Int = 0
    
    var body: some View {
        if self.mode == 0 {
            
            // use GeometryReader for height & weight
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        Text("Select Course").font(.system(size: Global.text2Size, weight: .semibold))
                        Text("골프장을 선택하세요.").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                        
                        /*
                         Picker(selection: self.$selectedTimeIndex, label: Text("select Time")) {
                         Text("Option 1")
                         Text("Option 2")
                         Text("Option 3")
                         }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                         */
                        
                        // add item with loop
                        /*
                         ForEach(self.exercises, id: \.self) { exercise in
                         Button(action: {
                         self.selectedExercise = exercise
                         }) {
                         HStack(spacing: 10) {
                         VStack {
                         Image(systemName: "magnifyingglass")
                         .font(Font.system(size: 12, weight: .heavy))
                         .foregroundColor(.white)
                         }
                         .padding(4)
                         .background(Color.orange)
                         .mask(Circle())
                         
                         Text(exercise)
                         
                         Spacer()
                         }
                         }
                         }
                         */
                        
                        // item 1
                        Button(action: {
                            withAnimation {
                                self.mode = 1
                            }
                        }) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: Global.circleIconSize, height: Global.circleIconSize)
                                    
                                    Image(systemName: "magnifyingglass")
                                        .font(Font.system(size: Global.icon1Size, weight: .heavy))
                                }
                                
                                Text("자동으로 검색").font(Font.system(size: Global.text2Size, weight: .semibold))
                                
                                Spacer()
                            }
                        }
                        
                        // item 2
                        Button(action: {
                            withAnimation {
                                self.mode = 2
                            }
                        }) {
                            HStack(spacing: Global.buttonPaddingBottom) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: Global.circleIconSize, height: Global.circleIconSize)
                                    
                                    Image(systemName: "list.bullet")
                                        .font(Font.system(size: Global.icon1Size, weight: .heavy))
                                }
                                
                                Text("목록에서 선택").font(Font.system(size: Global.text2Size, weight: .semibold))
                                
                                Spacer()
                            }
                        }
                    } // VStack
                } // ScrollView
            } // GeometryReader
            
        } else if self.mode == 1 {
            
            CourseSearchView()
            
        } else if self.mode == 2 {
            
            CourseListView()
            
        }
    }
}

struct CourseView_Previews: PreviewProvider {
    static var previews: some View {
        CourseView()
    }
}
