//
//  MainView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/11/22.
//

import SwiftUI

struct MainView: View {
    @State var mode: Int = 0
    
    @ObservedObject var locationManager = LocationManager()
    
    var angle: Double {
        return locationManager.degree ?? locationManager.lastDegree
    }
    
    @State var course: CourseModel? = nil
    @State var teeingGroundInfo: TeeingGroundInfoModel? = nil
    @State var teeingGroundIndex: Int = -1
    @State var holeNumber: Int = 0
    
    
    
    
    
    
    // @ObservedObject var compassHeading = CompassHeading()
    
    var body: some View {
        
        if (self.mode == 0) {
            
            // compass //
/*
             // Capsule().frame(width: 5, height: 50)
             
             
             ZStack {
             ForEach(Marker.markers(), id: \.self) { marker in
             CompassMarkerView(marker: marker, compassDegress: self.compassHeading.degrees)
             }
             }
             .frame(width: 300, height: 300)
             .rotationEffect(Angle(degrees: self.compassHeading.degrees))
             // .statusBar(hidden: true)
             .navigationBarTitle("")
             .navigationBarBackButtonHidden(true)
             .navigationBarHidden(true)
*/
            

            ZStack {
                VStack {
                    Circle()
                        .fill(Color(red: 255 / 255, green: 0 / 255, blue: 0 / 255))
                        .frame(width: 8, height: 8)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
            }
            // .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            // .rotationEffect(Angle(degrees: self.compassHeading.degrees))
            .rotationEffect(Angle(degrees: self.angle))
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)

        } else if (self.mode == 1) {
            
            // main //
            
            ZStack {
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
                VStack(alignment: HorizontalAlignment.center, spacing: 2)  {
                    Text("별우(STAR) 9TH").font(.system(size: 14)).padding(.top, 46)
                    
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
                        Text("384").font(.system(size: 56))
                        Text("m").font(.system(size: 14))
                    }
                }
                
                // text 3
                VStack(alignment: .leading)  {
                    Spacer().frame(maxHeight: .infinity)
                    // Text("9").font(.system(size: 22)).padding(.bottom, 40)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text("-9").font(.system(size: 40))
                        Text("m").font(.system(size: 10))
                    }.padding(.bottom, 46)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            
        }
        
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

struct Marker: Hashable {
    let degrees: Double
    let label: String
    
    init(degrees: Double, label: String = "") {
        self.degrees = degrees
        self.label = label
    }
    
    func degreeText() -> String {
        return String(format: "%.0f", self.degrees)
    }
    
    static func markers() -> [Marker] {
        return [
            Marker(degrees: 0, label: "N"),
            Marker(degrees: 30),
            Marker(degrees: 60),
            Marker(degrees: 90, label: "E"),
            Marker(degrees: 120),
            Marker(degrees: 150),
            Marker(degrees: 180, label: "S"),
            Marker(degrees: 210),
            Marker(degrees: 240),
            Marker(degrees: 270, label: "W"),
            Marker(degrees: 300),
            Marker(degrees: 330)
        ]
    }
}

struct CompassMarkerView: View {
    let marker: Marker
    let compassDegress: Double
    
    var body: some View {
        VStack {
            // text
            Text(marker.degreeText())
                .fontWeight(.light)
                .rotationEffect(self.textAngle())
            
            // capsule
            Capsule()
                .frame(width: self.capsuleWidth(),
                       height: self.capsuleHeight())
                .foregroundColor(self.capsuleColor())
            
            // text
            Text(marker.label)
                .fontWeight(.bold)
                .rotationEffect(self.textAngle())
                .padding(.bottom, 180)
        }.rotationEffect(Angle(degrees: marker.degrees))
    }
    
    private func capsuleWidth() -> CGFloat {
        return self.marker.degrees == 0 ? 7 : 3
    }
    
    private func capsuleHeight() -> CGFloat {
        return self.marker.degrees == 0 ? 45 : 30
    }
    
    private func capsuleColor() -> Color {
        return self.marker.degrees == 0 ? .red : .gray
    }
    
    private func textAngle() -> Angle {
        return Angle(degrees: -self.compassDegress - self.marker.degrees)
    }
}
