//
//  Util.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/21.
//

import Foundation
import CoreLocation
import SwiftUI
import StoreKit

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
        if i == 1 { return "1ST"; }
        else if i == 2 { return "2ND"; }
        else if i == 3 { return "3TH"; }
        
        else if i == 11 { return "11ST"; }
        else if i == 12 { return "12ND"; }
        else if i == 13 { return "13TH"; }
        
        else if i == 21 { return "21ST"; }
        else if i == 22 { return "22ND"; }
        else if i == 23 { return "23TH"; }
        
        else if i == 31 { return "31ST"; }
        else if i == 32 { return "32ND"; }
        else if i == 33 { return "33TH"; }
        
        else if i == 41 { return "41ST"; }
        else if i == 42 { return "42ND"; }
        else if i == 43 { return "43TH"; }
        
        else if i == 51 { return "51ST"; }
        else if i == 52 { return "52ND"; }
        else if i == 53 { return "53TH"; }
        
        else { return "\(i)" + "TH"; }
    }
    
    static func getColor(_ c: String) -> Color {
        var _c: Color = Color.white
        
        if c == "BLACK" { _c = Color.gray }
        else if c == "BLUE" { _c = Color.blue }
        else if c == "WHITE" { _c = Color.white }
        else if c == "YELLOW" { _c = Color.yellow }
        else if c == "RED" { _c = Color.red }
        else if c == "GREEN" { _c = Color.green }
        else if c == "GOLD" { _c = Color(red: 212 / 255, green: 175 / 255, blue: 55 / 255) }
        else if c == "PINK" { _c = Color.pink }
        else if c == "PURPLE" { _c = Color.purple }
        
        return _c
    }
    
    static func getCourseName(_ name: String?) -> String { // only return local language
        if let name = name {
            let start1 = name.firstIndex(of: "(")
            let end1 = name.firstIndex(of: ")")
            
            let i1 = name.index(start1!, offsetBy: -1)
            
            let range1 = name.startIndex..<i1
            let str1 = name[range1]
            
            let i2 = name.index(start1!, offsetBy: 1)
            
            let range2 = i2..<end1!
            let str2 = name[range2]
            
            return String(str1)
        } else {
            return ""
        }
    }
    
    static func getBearing(_ lat1: Double, _ lon1: Double, _ lat2: Double, _ lon2: Double) -> Double {
        let dLon = (lon2 - lon1);
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        
        var bearing = Util.toDegrees(atan2(y, x));
        // bearing = (bearing + 360) % 360;
        
        let tmp = bearing + 360
        bearing = tmp.truncatingRemainder(dividingBy: 360)
        
        return bearing;
    }
    
    static func toDegrees(_ number: Double) -> Double { // radian to degree
        return number * 180 / .pi
    }
    
    static func getWaitMessageForCourse(_ number: Int) -> String { // find course
        var num = number
        
        num = num % 5
        
        switch num {
        case 0:
            return "잠시만 기다려주세요."
            
        case 1:
            return "골프장을 찾을 수 없네요. 😥"
            
        case 2:
            return "실내에서는 GPS가 안잡혀요."
            
        case 3:
            return "클럽하우스 밖으로 나와주세요."
            
        case 4:
            return "열심히 찾고 있어요. 🥵"
            
        default:
            return "잠시만 기다려주세요."
        }
    }
    
    static func getWaitMessageForHole(_ number: Int) -> String { // find start hole
        var num = number
        
        num = num % 4
        
        switch num {
        case 0:
            return "근처에 스타트 홀을 찾고 있습니다."
            
        case 1:
            return "스타트 홀로 가시면 자동으로 시작됩니다."
            
        case 2:
            return "스타트 홀이 멀리 떨어져 있네요."
            
        case 3:
            return "스타트 홀 근처로 이동해주세요."
            
        default:
            return "스타트 홀로 가시면 자동으로 시작됩니다."
        }
    }
    
    // billing success 후 코스 정보 저장 (CourseSearchView, CourseListView에서 호출)
    static func saveCourse(_ course: CourseModel) {
        // 1. time
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 2019-12-20 09:40:08
        // dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss" // 2018-May-01 10:41:31
        let dateString = dateFormatter.string(from: date)
        // let interval = date.timeIntervalSince1970
        
        UserDefaults.standard.set(dateString, forKey: "LAST_PURCHASED_COURSE_TIME")
        
        // 2. course
        /*
         var address: String
         var countryCode: String
         var courses: [CourseItem]
         var id: Int64
         var location: CLLocation
         var name: String
         */
        
        // address
        UserDefaults.standard.set(course.address, forKey: "LAST_PURCHASED_COURSE_COURSE_ADDRESS")
        
        // countryCode
        UserDefaults.standard.set(course.countryCode, forKey: "LAST_PURCHASED_COURSE_COURSE_COUNTRY_CODE")
        
        // courses (convert to json string array)
        var coursesStringArray: [String] = []
        
        for c in course.courses {
            let cd = CourseData(name: c.name, range: c.range)
            do {
                let encodedData = try JSONEncoder().encode(cd)
                let jsonString = String(data: encodedData, encoding: .utf8)
                
                coursesStringArray.append(jsonString!)
            } catch {
                print(error)
                return
            }
        }
        
        UserDefaults.standard.set(coursesStringArray, forKey: "LAST_PURCHASED_COURSE_COURSE_COURSES")
        
        // id
        UserDefaults.standard.set(course.id, forKey: "LAST_PURCHASED_COURSE_COURSE_ID")
        
        // latitude
        UserDefaults.standard.set(course.location.coordinate.latitude, forKey: "LAST_PURCHASED_COURSE_COURSE_LATITUDE")
        
        // longitude
        UserDefaults.standard.set(course.location.coordinate.longitude, forKey: "LAST_PURCHASED_COURSE_COURSE_LONGITUDE")
        
        // name
        UserDefaults.standard.set(course.name, forKey: "LAST_PURCHASED_COURSE_COURSE_NAME")
    }
    
    static func contains(_ products: [SKProduct], _ id: String) -> Bool {
        
        for product in products {
            if product.productIdentifier == id {
                return true
            }
        }
        
        return false
    }
    
    static func getProduct(_ products: [SKProduct], _ id: String) -> SKProduct? {
        
        for product in products {
            if product.productIdentifier == id {
                return product
            }
        }
        
        return nil
    }
    
    static func checkLastPurchasedCourse(_ id: Int64) -> Bool {
        let time = UserDefaults.standard.string(forKey: "LAST_PURCHASED_COURSE_TIME")
        if let time = time {
            // get current time
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 2019-12-20 09:40:08
            let dateString = dateFormatter.string(from: date)
            
            var i1 = dateString.index(dateString.startIndex, offsetBy: 0)
            var i2 = dateString.index(dateString.startIndex, offsetBy: 10)
            let date2 = dateString[i1..<i2] // yyyy-MM-dd
            
            i1 = time.index(time.startIndex, offsetBy: 0)
            i2 = time.index(time.startIndex, offsetBy: 10)
            let date1 = time[i1..<i2]
            
            if date1 == date2 { // 오늘 구매
                let courseId = UserDefaults.standard.integer(forKey: "LAST_PURCHASED_COURSE_COURSE_ID")
                if courseId == id {
                    return true
                }
                
                return false
            } else { // 날짜가 다르면 새 구매
                return false
            }
        } else { // 정보가 없으면 새 구매
            return false
        }
    }
}
