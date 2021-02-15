//
//  ContentView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/10/13.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var locationManager = LocationManager()
    
    
    @ObservedObject var course: Course = Course() // 1
    
    
    var userLatitude: String {
        return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"
    }
    
    var userLongitude: String {
        return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"
    }
    
    // private let manager = CloudManager()
    
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
            
            /*
             Text("QuickNews")
             .font(.title)
             .fontWeight(.thin)
             Text("Daily news, always on your wrist")
             .fontWeight(.thin)
             Spacer()
             */
            
            Button(action: {
                
                // database
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
                 CloudKitManager.save(item: newItem) { (result) in
                 
                 switch result {
                 case .success(let newItem):
                 // self.listElements.items.insert(newItem, at: 0)
                 print("Successfully added item")
                 case .failure(let err):
                 print(err.localizedDescription)
                 }
                 
                 }
                 */
                
                CloudKitManager.subscribe()
                
            }, label: {
                Text("subscribe")
            })
            
            /*
             NavigationLink(destination: MainView()) {
             Text("MainView")
             }
             .navigationBarTitle("")
             .navigationBarBackButtonHidden(true)
             .navigationBarHidden(true)
             */
            
            Button(action: {
                self.course.score += 1
                print("ContentView score: ", self.course.score)
            }) { Text("Add score")}
            
            NavigationLink(destination: HomeView(course: self.course)) {
                Text("IntroView")
            }
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            
            
            // location
            /*
             Text("status: \(locationManager.statusString)")
             Text("latitude: \(userLatitude)")
             Text("longitude: \(userLongitude)")
             */
            
            
        }.onAppear(perform: onCreate)
        
    } // end of body
    
    func onCreate() {
        
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
