//
//  ProgressBar.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/02/06.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8.0)
                .opacity(0.3)
                .foregroundColor(Color.red)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.red)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            
            Text(String(format: "%.0f%%", min(self.progress, 1.0)*100.0))
                // .font(.largeTitle)
                .font(.system(size: 12))
                // .bold()
                .foregroundColor(Color.white)
        }
    }
}

/*
 struct ProgressBar_Previews: PreviewProvider {
 static var previews: some View {
 ProgressBar()
 }
 }
 */
