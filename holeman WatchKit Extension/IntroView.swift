//
//  IntroView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/12/11.
//

import SwiftUI

struct IntroView: View {
    @State var mode: Int = 0
    
    @State var text1: String = "안녕하세요?"
    @State var text1Opacity: Double = 0
    
    @State var text2: String = "정확한 거리"
    @State var text2Opacity: Double = 0
    
    @State var text3: String = "홀맨이 알려드릴게요."
    @State var text3Opacity: Double = 0
    
    @State var button1Opacity: Double = 0
    
    
    
    // @State private var textValue: String = "Sample Data"
    // @State private var opacity: Double = 1
    
    var body: some View {
        
        if (self.mode == 0) {
            
            VStack {
                Text(text1).font(.system(size: 24)).opacity(text1Opacity)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1), {
                    self.text1Opacity = 1
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    // hide
                    /*
                     withAnimation(.easeInOut(duration: 0.5), {
                     self.text1Opacity = 0
                     })
                     
                     DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                     // show
                     self.mode = 1
                     }
                     */
                    withAnimation {
                        self.mode = 1
                    }
                }
            }
            
        } else if (self.mode == 1) {
            
            ZStack {
                VStack {
                    Text(text2).font(.system(size: 24)).opacity(text2Opacity)
                    Text(text3).font(.system(size: 24)).opacity(text3Opacity)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    Button(action: {
                        print("button click")
                        
                        withAnimation {
                            self.mode = 2
                        }
                    }) {
                        VStack {
                            Image(systemName: "arrow.right")
                                .font(Font.system(size: 28, weight: .heavy))
                            // .resizable()
                            // .frame(width: 30, height: 30)
                            // Text("Circle!")
                        }
                        .padding(14)
                        .background(Color.green)
                        .mask(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 10)
                    .opacity(button1Opacity)

                    /*
                     Text("\(textValue)")
                     .opacity(opacity)
                     
                     Button("Next") {
                     withAnimation(.easeInOut(duration: 0.5), {
                     self.opacity = 0
                     })
                     self.textValue = "uuuuuuuuuuuuuuu"
                     withAnimation(.easeInOut(duration: 1), {
                     self.opacity = 1
                     })
                     }
                     */
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
                
                
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1), {
                    self.text2Opacity = 1
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeInOut(duration: 1), {
                        self.text3Opacity = 1
                    })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        // show button & move to next view
                        
                        withAnimation(.easeInOut(duration: 1), {
                            self.button1Opacity = 1
                        })
                    }
                }
            }
            
        } else if (self.mode == 2) {
            // MainView()
            
            // ToDo: move to HoleSearch view
            
            
            
            
            
            
            
        }
        
        
        
        /*
         Text("안녕하세요?").font(.system(size: 24))
         .onAppear {
         DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
         // 7.
         withAnimation {
         // self.isActive = true
         }
         }
         }
         */
        
        /*
         Text(textValue)
         .font(.system(size: 24))
         // .frame(width: 200, height: 200)
         .transition(.opacity)
         .id("MyTitleComponent" + textValue)
         */
        
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
