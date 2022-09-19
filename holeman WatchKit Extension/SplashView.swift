//
//  SplashView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2020/12/10.
//

import SwiftUI
// import HealthKit // ToDo: test (get steps)

struct SplashView: View {
    // 1.
    @State var isActive: Bool = false
    
    var body: some View {
        if self.isActive == true {
            
            if #available(watchOSApplicationExtension 8.0, *) {
                
                VStack { // should be VStack
                    IntroView()
                }
                .navigationBarTitle(Locale.current.languageCode == "ko" ? "홀맨" : "Holeman")
                .navigationBarTitleDisplayMode(.inline)
                
            } else {
                
                VStack { // should be VStack
                    IntroView()
                }
                .navigationBarTitle(Locale.current.languageCode == "ko" ? "홀맨" : "Holeman")
                
            }
            
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
                    print("SplashView", proxy.size.width)
                    Global.setDeviceResolution(proxy.size.width)
                    
                    // ToDo: test (open URL)
                    // CloudManager.openURL()
                    
                    // ToDo: test (get steps)
                    /*
                     if HKHealthStore.isHealthDataAvailable() {
                     print("available")
                     
                     // request authorization
                     let healthStore = HKHealthStore()
                     
                     let healthKitTypes: Set = [
                     HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
                     ]
                     
                     healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (bool, error) in
                     if let e = error {
                     print("oops.. something went wrong during authorisation \(e.localizedDescription)")
                     } else {
                     print("User has completed the authorization flow")
                     
                     getTodaysSteps(completion: { steps in
                     print(steps)
                     })
                     }
                     }
                     }
                     */
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
            
        } // elsf if self.isActive == true
    }
    
    // ToDo: test (get steps)
    /*
     func getTodaysSteps(completion: @escaping (Double) -> Void) {
     let healthStore = HKHealthStore()
     
     let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
     
     let now = Date()
     let startOfDay = Calendar.current.startOfDay(for: now)
     let predicate = HKQuery.predicateForSamples(
     withStart: startOfDay,
     end: now,
     options: .strictStartDate
     )
     
     let query = HKStatisticsQuery(
     quantityType: stepsQuantityType,
     quantitySamplePredicate: predicate,
     options: .cumulativeSum
     ) { (_, result, error) in
     guard let result = result, let sum = result.sumQuantity() else {
     print("Failed to fetch steps = \(error?.localizedDescription ?? "N/A")")
     
     // print("1")
     completion(0.0)
     return
     }
     
     completion(sum.doubleValue(for: HKUnit.count())) // not working
     }
     
     healthStore.execute(query)
     }
     */
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
