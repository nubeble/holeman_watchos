//
//  TeeIndicator.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/03/13.
//

import SwiftUI

struct TeeIndicator: View {
    /*
     @State private var isAnimating: Bool = false
     
     var body: some View {
     GeometryReader { (geometry: GeometryProxy) in
     ForEach(0..<5) { index in
     
     Group {
     Circle()
     .frame(width: geometry.size.width / 5, height: geometry.size.height / 5)
     //.scaleEffect(!self.isAnimating ? 1 - CGFloat(index) / 5 : 0.2 + CGFloat(index) / 5)
     .scaleEffect(!self.isAnimating ? CGFloat(1 - CGFloat(index)) / 5 : CGFloat(0.2 + CGFloat(index) / 5))
     .offset(y: geometry.size.width / 10 - geometry.size.height / 2)
     }.frame(width: geometry.size.width, height: geometry.size.height)
     
     .rotationEffect(!self.isAnimating ? .degrees(0) : .degrees(360))
     .animation(Animation
     .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
     .repeatForever(autoreverses: false))
     }
     }
     .aspectRatio(1, contentMode: .fit)
     .onAppear {
     self.isAnimating = true
     }
     }
     */
    @Binding var isAnimating: Bool
    
    private let radius: CGFloat = 24.0
    private let count = 18
    private let interval: TimeInterval = 0.1
    
    private let point = { (index: Int, count: Int, radius: CGFloat, frame: CGRect) -> CGPoint in
        let angle   = 2.0 * .pi / Double(count) * Double(index)
        let circleX = radius * cos(CGFloat(angle))
        let circleY = radius * sin(CGFloat(angle))
        
        return CGPoint(x: circleX + frame.midX, y: circleY + frame.midY)
    }
    
    private let timer = Timer.publish(every: 1.8, on: .main, in: .common).autoconnect()     // every(1.8) = count(18) / interval(0.1)
    
    @State private var scale: CGFloat  = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0 ..< self.count, id: \.self) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: Global.teeIndicatorSize, height: Global.teeIndicatorSize)
                    .animation(nil)
                    .opacity(self.opacity)
                    .scaleEffect(self.scale)
                    .position(self.point(index, self.count, self.radius, geometry.frame(in: .local)))
                    .animation(
                        Animation.easeOut(duration: 1.0)
                            .repeatCount(1, autoreverses: true)
                            .delay(TimeInterval(index) * self.interval)
                    )
            }
            .onReceive(self.timer) { output in
                self.update()
            }
        }
        .rotationEffect(.degrees(10.0))
        .opacity(isAnimating == false ? 0 : 1.0)
        .onAppear {
            self.update()
        }
    }
    
    private func update() {
        scale   = 0 < scale ? 0 : 1.0
        opacity = 0 < opacity ? 0 : 1.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.scale   = 0
            self.opacity = 0
        }
    }
}

struct TeeIndicator_Previews: PreviewProvider {
    static var previews: some View {
        // TeeIndicator()
        
        let view = TeeIndicator(isAnimating: .constant(true))
        
        return Group {
            view.previewDevice("Apple Watch Series 5 - 44mm")
            
            view.previewDevice("Apple Watch Series 4 - 40mm")
            
            view.previewDevice("Apple Watch Series 3 - 42mm")
            
            view.previewDevice("Apple Watch Series 3 - 38mm")
        }
    }
}
