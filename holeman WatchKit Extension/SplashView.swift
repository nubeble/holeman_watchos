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
                    
                    // ToDo: !!!
                    // Util.checkTips("백돌이는 안전하게 4온 전략으로 가세요. 세컨샷은 좌측 벙커를 보고 치세요. 그린은 왼쪽이 높아요.")
                    // Util.checkTips("전방 끝 카트도로 좌측 끝부분을 겨냥하세요. 티샷이 짧거나 벙커로 들어가면 그린이 보이지 않아요. 세컨샷 지점에서 그린까지 내리막이에요.")
                    // Util.checkTips("우측으로 꺾어진 도그렉 홀이에요. 슬라이스성 바람을 염두에 두세요. 장타자는 우측을 보고 티샷 하세요.")
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
