//
//  InterfaceController.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/04/19.
//

import WatchKit
// import Foundation

class InterfaceController: WKInterfaceController, WKExtendedRuntimeSessionDelegate {
    var session: WKExtendedRuntimeSession!
    
    //var time = 15
    //var timer = Timer()
    
    //@IBAction func startTimerButtonPressed() {
    func ready() {
        
        print("InterfaceController.init()")

        session = WKExtendedRuntimeSession()
        session.delegate = self
        session.start()
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        // Track when your session ends.
        // Also handle errors here.
        print(#function, Date())
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Track when your session starts.
        print(#function, Date())
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // Finish and clean up any tasks before the session ends.
        print(#function, Date())
    }
}
