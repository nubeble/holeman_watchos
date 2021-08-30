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
        if self.isActive == true {
            
            VStack { // should be VStack
                IntroView()
            }
            .navigationBarTitle(Locale.current.languageCode == "ko" ? "홀맨" : "Holeman")
            
        } else {
            
            GeometryReader { proxy in
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Image("logo")
                            .resizable()
                            .frame(width: Global.logoWidth, height: Global.logoHeight)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .onAppear {
                    print(#function, proxy.size.width)
                    Global.setDeviceResolution(proxy.size.width)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
            
        }
        /*
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
         
         .onAppear {
         DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
         withAnimation {
         self.isActive = true
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
