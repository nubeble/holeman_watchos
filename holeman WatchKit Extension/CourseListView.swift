//
//  CourseListView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/13.
//

import SwiftUI

struct CourseListView: View {
    var body: some View {
        // Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        GeometryReader { geometry in
            ScrollView() {
                VStack {
                    Text("Select Course").font(.system(size: 20, weight: .semibold))
                    Text("골프장을 선택하세요.").font(.system(size: 16, weight: .light)).padding(.bottom, 20)
                    
                    // Divider()
                    
                    // ToDo
                    // var i = 0
                    // for course in courses {
                    
                    //  button 1
                    Button(action: {
                        // ToDo
                    }) {
                        VStack {
                            Text("안양베네스트골프클럽").font(Font.system(size: 20, weight: .semibold))
                            Text("Anyang Benest GC").font(Font.system(size: 20, weight: .semibold))
                            // Spacer()
                        }
                    }
                    
                    
                    // button 2
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
