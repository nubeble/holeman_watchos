//
//  ContentView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/10/13.
//

import SwiftUI

struct ContentView: View {
    
    // private let manager = CloudKitManager()
    
    // private let registration = RegistrationHelper()
    
    var body: some View {
        
        // Text("Hello, \(Image(systemName: "globe"))!")
        
        /*
         VStack(spacing: 10) {
         Text("Hello, World!").font(.system(size: 32)).padding(8)
         // .padding().font(Font.title.weight(.bold))
         Image(systemName: "cloud.heavyrain.fill")
         .font(Font.title.weight(.bold))
         }
         */
        VStack(alignment: .trailing)  {
            Text("QuickNews")
                .font(.title)
                .fontWeight(.thin)
            Text("Daily news, always on your wrist")
                .fontWeight(.thin)
            Spacer()
            
            /*
             NavigationLink(destination: ArticlesView()) {
             Text("Start")
             }
             */
            
            Button(action: {
                /*
                 manager.fetch(completion: { (records, error) in
                 guard error == .none, let records = records else {
                 print("error")
                 // Deal with error
                 return
                 }
                 
                 DispatchQueue.main.async {
                 // self.tableView.set(tasks: records)
                 
                 print(records)
                 }
                 })
                 */
                
                /*
                 let newItem = ListElement(text: "hello")
                 CloudKitHelper.save(item: newItem) { (result) in
                 
                 switch result {
                 case .success(let newItem):
                 // self.listElements.items.insert(newItem, at: 0)
                 print("Successfully added item")
                 case .failure(let err):
                 print(err.localizedDescription)
                 }
                 
                 }
                 */
                
                
                CloudKitHelper.subscribe()
            }, label: {
                /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
            })
        }.onAppear(perform: onCreate)
        
        
    } // end of body
    
    private func onCreate() {
        
        // register your app for remote notifications
        // RegistrationHelper.shared.registerForPushNotifications()
        
        // registration.registerForPushNotifications()
        
        
        
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
