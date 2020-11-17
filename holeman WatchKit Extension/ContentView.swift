//
//  ContentView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/10/13.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var locationManager = LocationManager()
    
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
                /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
            })
            
            
            NavigationLink(destination: IntroView()) {
                Text("IntroView")
            }
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            
            /*
             Text("location status: \(locationManager.statusString)")
             HStack {
             Text("latitude: \(userLatitude)")
             Text("longitude: \(userLongitude)")
             }
             */
            Text("status: \(locationManager.statusString)")
            Text("latitude: \(userLatitude)")
            Text("longitude: \(userLongitude)")

            Capsule().frame(width: 5, height: 50)

            // 1
            ZStack {
                // 2
                ForEach([0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330], id: \.self) { marker in
                    // CompassViewMarker(still to come)
                }
            }
            .frame(width: 300, height: 300)
            .rotationEffect(Angle(degrees: 0)) // 3
            .statusBar(hidden: true)

        }.onAppear(perform: onCreate)
        
        
    } // end of body
    
    private func onCreate() {
        
        // register your app for remote notifications
        // RegistrationHelper.shared.registerForPushNotifications()
        
        // registration.registerForPushNotifications()
        
        
        
    }
    
    
}

struct Marker: Hashable {
    let degrees: Double
    let label: String

    init(degrees: Double, label: String = "") {
        self.degrees = degrees
        self.label = label
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
            Marker(degrees: 270, label: "w"),
            Marker(degrees: 300),
            Marker(degrees: 330)
        ]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
