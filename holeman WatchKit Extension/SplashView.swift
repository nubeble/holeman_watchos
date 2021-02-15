//
//  SplashView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/12/10.
//

import SwiftUI

struct SplashView: View {
    // 1.
    @State var isActive: Bool = false
    
    var body: some View {
        VStack {
            // 2.
            if self.isActive {
                // 3.
                IntroView()
            } else {
                // 4.
                Image("logo")
                    .resizable()
                    .frame(width: 710 / 4.2, height: 239 / 4.2)
            }
        }
        // 5.
        .onAppear {
            // 6.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                // 7.
                withAnimation {
                    self.isActive = true
                }
            }
        }
        
        /*
         if self.isActive == true {
         IntroView()
         } else {
         
         VStack {
         Image(systemName: "cloud.heavyrain.fill")
         .resizable()
         .frame(width: 80, height: 80)
         }
         // 5.
         .onAppear {
         // 6.
         DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
         // 7.
         withAnimation {
         self.isActive = true
         }
         }
         }
         
         }
         */
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
