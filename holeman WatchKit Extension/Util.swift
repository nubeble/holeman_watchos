//
//  Util.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/21.
//

import Foundation
import CoreLocation

struct Util {
    
    // static func convertToDictionary(text: String) -> [String: Any]? {
    static func convertToDictionary(text: String) -> [String: Int]? {
        if let data = text.data(using: .utf8) {
            do {
                // return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Int]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    static func getOrdinalNumber(_ i: Int) -> String { // hole number
        if (i == 1) { return "1ST"; }
        else if (i == 2) { return "2ND"; }
        else if (i == 3) { return "3TH"; }
        
        else if (i == 11) { return "11ST"; }
        else if (i == 12) { return "12ND"; }
        else if (i == 13) { return "13TH"; }
        
        else if (i == 21) { return "21ST"; }
        else if (i == 22) { return "22ND"; }
        else if (i == 23) { return "23TH"; }
        
        else if (i == 31) { return "31ST"; }
        else if (i == 32) { return "32ND"; }
        else if (i == 33) { return "33TH"; }
        
        else if (i == 41) { return "41ST"; }
        else if (i == 42) { return "42ND"; }
        else if (i == 43) { return "43TH"; }
        
        else if (i == 51) { return "51ST"; }
        else if (i == 52) { return "52ND"; }
        else if (i == 53) { return "53TH"; }
        
        else { return "\(i)" + "TH"; }
    }
    
}

