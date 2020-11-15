//
//  IntroView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/11/15.
//

import SwiftUI

struct IntroView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        // Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        
        VStack(spacing: 8) {
            Text("Detail view")
            /*
             Button("Go Back", action: {
             self.presentationMode.wrappedValue.dismiss()
             })
             */
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
