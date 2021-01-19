//
//  CourseListView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/13.
//

import SwiftUI

struct CourseListView: View {
    @State var courses: [CourseModel] = []
    
    @State var selectedCourseIndex = 0
    
    var body: some View {
        
        GeometryReader { geometry in
            ScrollView() {
                ScrollViewReader { value in
                    // VStack {
                    Text("Select Course").font(.system(size: 20, weight: .semibold))
                    Text("골프장을 선택하세요.").font(.system(size: 16, weight: .light)).padding(.bottom, 20)
                    
                    // Divider()
                    
                    ForEach(0 ..< courses.count) {
                        let name = self.courses[$0].name
                        
                        let start1 = name.firstIndex(of: "(")
                        let end1 = name.firstIndex(of: ")")
                        
                        let i1 = name.index(start1!, offsetBy: -1)
                        
                        let range1 = name.startIndex..<i1
                        let str1 = name[range1]
                        
                        let i2 = name.index(start1!, offsetBy: 1)
                        
                        let range2 = i2..<end1!
                        let str2 = name[range2]
                        
                        Button(action: {
                            // ToDo
                            
                            // ToDo: test
                            value.scrollTo(0)
                        }) {
                            Text(str1 + "\n" + str2).font(.system(size: 18))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(2)
                                // .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }.id($0)
                    }
                    // }
                }
            }
        }
    }
}

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView()
    }
}
