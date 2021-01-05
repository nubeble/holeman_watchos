//
//  HomeView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/11/15.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var course: Course // 2
    
    var body: some View {
        
        // VStack(alignment: .center) {
        ZStack {
            // go back
            /*
             Button("Go Back", action: {
             self.presentationMode.wrappedValue.dismiss()
             })
             */
            
            // Text("Detail view")
            
            
            // add score
            /*
             Button(action: {
             self.course.score += 1
             print("HomeView score: ", self.course.score)
             }) {
             Text("Add")
             }
             */
            
            
            
            // circle
            Circle()
                .strokeBorder(Color(red: 79/255, green: 79/255, blue: 79/255), lineWidth: 8)
            // .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            // .edgesIgnoringSafeArea(.all)
            /*
             Circle()
             .strokeBorder(Color.blue,lineWidth: 10)
             .background(Circle().foregroundColor(Color.red))
             */
            
            
            // text 1
            VStack(alignment: HorizontalAlignment.center, spacing: 4)  {
                Text("별우(STAR) 9TH").font(.system(size: 14)).padding(.top, 50)
                
                HStack(spacing: 4) {
                    Text("PAR 4").font(.system(size: 14))
                    Text("HDCP 12").font(.system(size: 14))
                    Text("• 330").font(.system(size: 14))
                }
                // .padding(.horizontal, 12)
                
                Spacer().frame(maxHeight: .infinity)
            }
            
            // text 2
            VStack(alignment: .center)  {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("384").font(.system(size: 48))
                    Text("m").font(.system(size: 12))
                }
            }
            
            // text 3
            VStack(alignment: .leading)  {
                Spacer().frame(maxHeight: .infinity)
                // Text("9").font(.system(size: 22)).padding(.bottom, 40)
                
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("-9").font(.system(size: 36))
                    Text("m").font(.system(size: 9))
                }.padding(.bottom, 50)
            }
            
            
            
            
            
            
            // var width = WKInterfaceDevice.current().screenBounds.size.width
            
            
            /*
             Circle()
             .strokeBorder(Color(red: 79/255, green: 79/255, blue: 79/255), lineWidth: 10)
             .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
             .edgesIgnoringSafeArea(.bottom)
             */
            
            
            
            /*
             VStack(alignment: .center)  {
             Text("363")
             }
             */
            
            /*
             VStack  {
             Text("title")
             .font(.headline)
             
             // Text("By \(article.author)")
             
             Text("subtitle")
             .fontWeight(.ultraLight)
             
             
             // Divider()
             
             
             Text("Published At:")
             
             // Text("Read the full story at: \(article.link)")
             
             }
             */
            
            
            
            
            
            // .background(    Circle().foregroundColor(Color.red)  )
            
            
            
            /*
             Circle()
             .overlay(
             
             Circle().stroke(Color.green,lineWidth: 1)
             
             ).foregroundColor(Color.red)
             */
            
            
            
            
        }
        // .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .ignoresSafeArea(.all)
    }
}

/*
 struct HomeView_Previews: PreviewProvider {
 static var previews: some View {
 HomeView()
 }
 }
 */
