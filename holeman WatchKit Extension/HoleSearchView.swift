//
//  HoleSearchView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/16.
//

import SwiftUI

struct HoleSearchView: View {
    // @State var course: CourseModel = CourseModel(address: "", countryCode: "", courses: [], id: 0, location: CLLocation(latitude: 0.0, longitude: 0.0), name: "")
    @State var courses: [CourseModel] = []
    
    @State var selectedCourseIndex = 0
    
    var body: some View {
        // Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        /*
         Button(action: {
         // self.count = 0
         
         print(#function, self.course.address)
         }) {
         Text("Reset")
         }
         */
        
        ZStack {
            
            VStack {
                // picker
                Picker(selection: $selectedCourseIndex, label: Text("")) {
                    ForEach(0 ..< courses.count) {
                        
                        let name = self.courses[$0].name
                        
                        let start1 = name.firstIndex(of: "(")
                        let end1 = name.firstIndex(of: ")")
                        
                        let i1 = name.index(start1!, offsetBy: -1)
                        
                        let range1 = name.startIndex..<i1
                        let str1 = name[range1]
                        
                        let i2 = name.index(start1!, offsetBy: 1)
                        // let i2 = name.index(start1!, offsetBy: 5) // ToDo: test
                        // let i3 = name.index(end1!, offsetBy: -1)
                        
                        let range2 = i2..<end1!
                        let str2 = name[range2]
                        
                        Text(str1 + "\n" + str2).font(.system(size: 18))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(2)
                            // .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .defaultWheelPickerItemHeight(48)
                .labelsHidden()
                .frame(height: 86)
                // .clipped()
                .padding(.top, 10)
                
                Spacer().frame(maxHeight: .infinity)
            }
            
            VStack {
                Spacer().frame(maxHeight: .infinity)
                
                HStack(spacing: 40) {
                    // button 1
                    Button(action: {
                        // print("button click")
                        /*
                         withAnimation {
                         self.mode = 3
                         }
                         */
                        
                        // ToDo: test
                        print(#function, self.selectedCourseIndex)
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.gray)
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
                        print("button click")
                        /*
                         withAnimation {
                         self.mode = 3
                         }
                         */
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 54, height: 54)
                            
                            Image(systemName: "arrow.triangle.2.circlepath")
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

struct HoleSearchView_Previews: PreviewProvider {
    static var previews: some View {
        HoleSearchView()
    }
}
