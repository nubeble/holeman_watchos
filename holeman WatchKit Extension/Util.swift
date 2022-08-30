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
        if i <= 0 { return "" }
        if i == 1 { return "1ST" }
        if i == 2 { return "2ND" }
        if i == 3 { return "3RD" }
        
        if i >= 20 {
            if i % 10 == 1 { return String(i) + "ST" }
            if i % 10 == 2 { return String(i) + "ND" }
            if i % 10 == 3 { return String(i) + "RD" }
        } else {
            return String(i) + "TH"
        }
        
        return ""
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
        else { _c = Color.orange }
        
        return _c
    }
    
    static func getCourseName(_ name: String?) -> String { // only return local language
        if let name = name {
            let start1 = name.firstIndex(of: "(")
            // let end1 = name.firstIndex(of: ")")
            
            let i1 = name.index(start1!, offsetBy: -1)
            
            let range1 = name.startIndex..<i1
            let str1 = name[range1]
            
            // let i2 = name.index(start1!, offsetBy: 1)
            
            // let range2 = i2..<end1!
            // let str2 = name[range2]
            
            return String(str1)
        } else {
            return ""
        }
    }
    
    static func getCourseDescription(_ name: String, _ hlds: Int64) -> String {
        if hlds == 100 {
            return name + "에는 HLDS™가 설치되어 있어요. 홀맨이 정확한 거리를 알려드릴게요."
        }
        /*
         if hlds == 200 { // 그린
         return name + "에는\nHLDS™가 미설치되어 있어요.\n하지만 홀맨이 그린 중앙을\n기준으로 거리를 알려드릴게요."
         }
         
         if hlds == 300 { // 좌그린
         return name + "에는\nHLDS™가 미설치되어 있어요.\n하지만 홀맨이 좌그린 중앙을\n기준으로 거리를 알려드릴게요."
         }
         
         if hlds == 400 { // 우그린
         return name + "에는\nHLDS™가 미설치되어 있어요.\n하지만 홀맨이 우그린 중앙을\n기준으로 거리를 알려드릴게요."
         }
         */
        return name + "에는 HLDS™가 미설치되어 있어요. 하지만 홀맨이 그린 중앙을 기준으로 거리를 알려드릴게요."
    }
    
    static func getBearing(_ lat1: Double, _ lon1: Double, _ lat2: Double, _ lon2: Double) -> Double {
        /*
         let dLon = (lon2 - lon1)
         let y = sin(dLon) * cos(lat2)
         let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
         
         var bearing = Util.toDegrees(atan2(y, x))
         // bearing = (bearing + 360) % 360
         
         let tmp = bearing + 360
         bearing = tmp.truncatingRemainder(dividingBy: 360)
         
         return bearing
         */
        let _lat1 = degreesToRadians(degrees: lat1)
        let _lon1 = degreesToRadians(degrees: lon1)
        
        let _lat2 = degreesToRadians(degrees: lat2)
        let _lon2 = degreesToRadians(degrees: lon2)
        
        let dLon = _lon2 - _lon1
        
        let y = sin(dLon) * cos(_lat2)
        let x = cos(_lat1) * sin(_lat2) - sin(_lat1) * cos(_lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansToDegrees(radians: radiansBearing)
    }
    
    static func toDegrees(_ number: Double) -> Double { // radian to degree
        return number * 180 / .pi
    }
    
    static func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    static func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
    
    static func getWaitMessageForCourse(_ number: Int) -> String { // find course
        var num = number
        
        num = num % 5
        
        switch num {
        case 0:
            return "잠시만 기다려주세요."
            
        case 1:
            return "골프장을 찾을 수 없네요. 😥"
            
        case 2:
            return "실내에서는 GPS가 안 잡혀요."
            
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
    
    static func getWaitMessageForLocation2(_ number: Int) -> String { // 3, 6, 9, 12, 15
        var num = number
        
        num = num / 3 // 1, 2, 3, 4, 5
        
        switch num {
        case 1:
            return "잠시만 기다려주세요."
            
        case 2:
            return "실내에서는 GPS가 잡히지 않아요. 😥"
            
        case 3:
            return "클럽하우스 밖으로 나와주세요."
            
        case 4:
            return "위치 정보를 확인할 수 없네요. 👀"
            
        case 5:
            return "가만히 있지 마시고 움직여주세요."
            
        default:
            return "잠시만 기다려주세요."
        }
    }
    
    static func getWaitMessageForLocation(_ number: Int) -> String { // 3, 6, 9, 12, 15
        var num = number
        
        num = num / 3 // 1, 2, 3, 4, 5
        
        switch num {
        case 1:
            return "잠시만 기다려주세요."
            
        case 2:
            return "실내에서는 GPS가 안 잡혀요. 😥"
            
        case 3:
            return "클럽하우스 밖으로 나와주세요."
            
        case 4:
            return "위치 정보를 가져올 수 없네요. 👀"
            
        case 5:
            return "가만히 있지 마시고 움직여주세요."
            
        default:
            return "잠시만 기다려주세요."
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
        
        // email
        UserDefaults.standard.set(course.email, forKey: "LAST_PURCHASED_COURSE_COURSE_EMAIL")
        
        // hlds
        UserDefaults.standard.set(course.hlds, forKey: "LAST_PURCHASED_COURSE_COURSE_HLDS")
    }
    
    static func contains(_ products: [SKProduct], _ id: String) -> Bool {
        for product in products {
            if product.productIdentifier == id {
                return true
            }
        }
        
        return false
    }
    
    static func contains(_ products: [SKProduct], _ ids: [String]) -> Bool {
        print(#function, products, ids)
        
        var count = ids.count
        
        for product in products {
            for id in ids {
                if product.productIdentifier == id {
                    count = count - 1
                    break
                }
            }
        }
        
        // never come here
        if count == 0 {
            return true
        } else {
            return false
        }
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
        print(#function, id)
        
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
    
    /*
     // static func purchasedAll() -> Bool { // check if the last purchased product id is 99
     static func purchasedAll(onCompletion: @escaping ((_ result: Bool) -> Void)) {
     // check UserDefaults
     let id = UserDefaults.standard.string(forKey: "IAP_PRODUCT_ID") // last purchased product id
     print(#function, "IAP_PRODUCT_ID", id)
     
     if let id = id { // "com.nubeble.holeman.iap.course.X"
     let charArray = Array(id)
     let num = charArray[id.count - 1]
     print(#function, "num", num)
     
     if String(num) == "99" {
     onCompletion(true)
     } else {
     onCompletion(false)
     }
     } else {
     // check CloudKit
     if let userId = Global.userId {
     
     CloudManager.getProductId(userId) { productId in
     print(#function, "last purchased product id", productId)
     
     if productId == "" {
     onCompletion(false)
     } else {
     if productId == "99" {
     onCompletion(true)
     } else {
     onCompletion(false)
     }
     }
     }
     
     } else { // never come here
     onCompletion(false)
     }
     }
     }
     */
    
    /*
     static func getProductId(onCompletion: @escaping ((_ productId: String) -> Void)) {
     // check UserDefaults
     let id = UserDefaults.standard.string(forKey: "IAP_PRODUCT_ID") // last purchased product id
     print(#function, "IAP_PRODUCT_ID", id)
     
     // if id != nil {
     if let id = id { // "com.nubeble.holeman.iap.course.X"
     // print("product ID", id)
     
     var nextNumber = 1
     
     let charArray = Array(id)
     let num = charArray[id.count - 1]
     // print(#function, "num", num)
     
     if let number = Int(String(num)) {
     nextNumber = number + 1
     }
     
     // print(#function, "nextNumber", nextNumber)
     
     let nextId = "com.nubeble.holeman.iap.course." + String(nextNumber)
     onCompletion(nextId)
     } else {
     // check CloudKit
     
     // get product id with user
     if let userId = Global.userId {
     
     CloudManager.getProductId(userId) { productId in
     print(#function, "productId", productId)
     
     if productId == "" {
     let nextId = "com.nubeble.holeman.iap.course.1"
     onCompletion(nextId)
     } else {
     onCompletion(productId)
     }
     }
     
     } else { // never come here
     let nextId = "com.nubeble.holeman.iap.course.1"
     onCompletion(nextId)
     }
     }
     }
     */
    
    /*
     static func setProductId(_ id: String) {
     // UserDefaults
     UserDefaults.standard.set(id, forKey: "IAP_PRODUCT_ID") // last purchased product id
     
     // CloudKit
     if let userId = Global.userId {
     CloudManager.setProductId(userId, id)
     }
     }
     */
    
    static func convertHoleTitle(_ title: String) -> String {
        if title == "" { return "" }
        
        let words = title.split(separator: " ") // OAK HILL 1ST
        
        // let courseName = words[0]
        let size = words.count - 1
        var str = ""
        for i in 0 ..< size {
            str += words[i]
            if i != (size - 1) {
                str += " "
            }
        }
        let courseName = str
        
        // let word = String(words[1])
        let word = String(words[words.count - 1])
        let index2 = Util.getSuffixIndex(word)
        let holeNumber = word[..<index2]
        
        return courseName + " 코스 " + holeNumber + "번 홀"
    }
    
    static func splitHoleTitle(_ title: String) -> [String] {
        if title == "" { return [] }
        
        let words = title.split(separator: " ") // OAK HILL 1ST
        
        // let courseName = words[0]
        let size = words.count - 1
        var str = ""
        for i in 0 ..< size {
            str += words[i]
            if i != (size - 1) {
                str += " "
            }
        }
        let courseName = str
        
        // let word = String(words[1])
        let word = String(words[words.count - 1])
        let index2 = Util.getSuffixIndex(word)
        let holeNumber = word[..<index2]
        
        var titles: [String] = []
        titles.append(courseName + " 코스")
        titles.append(holeNumber + "번 홀")
        
        return titles
    }
    
    static func getSuffixIndex(_ str: String) -> String.Index {
        if let range1 = str.range(of: "ST") {
            return range1.lowerBound
        } else {
            if let range2 = str.range(of: "ND") {
                return range2.lowerBound
            } else {
                if let range3 = str.range(of: "RD") {
                    return range3.lowerBound
                } else {
                    if let range4 = str.range(of: "TH") {
                        return range4.lowerBound
                    } else {
                        // N/A
                        return str.index(str.firstIndex(of: " ")!, offsetBy: 2)
                    }
                }
            }
        }
    }
    
    static func getMaxValue(_ list: [Int]) -> Int {
        var maxValue = 0
        
        for value in list {
            if value > maxValue {
                maxValue = value
            }
        }
        
        return maxValue
    }
    
    static func getColorName(_ key: String) -> String {
        // get color
        let start1 = key.firstIndex(of: "(")
        let end1 = key.firstIndex(of: ")")
        
        let i2 = key.index(start1!, offsetBy: 1)
        
        let range2 = i2..<end1!
        let color = key[range2]
        
        return String(color)
    }
    
    static func getTeeingGroundDistancesLength(_ tgs: [TeeingGround], _ str: String) -> Int { // str: REGULAR-2 (WHITE)
        let start1 = str.firstIndex(of: "(")
        let i1 = str.index(start1!, offsetBy: -1)
        let range1 = str.startIndex..<i1
        
        let name = str[range1] // REGULAR-2
        // print(#function, "name: " + name)
        
        for tg in tgs {
            if tg.name == name { return tg.distances.count }
        }
        
        return 0
    }
    
    static func getNextTeeingGroundName(_ tgs: [TeeingGround], _ str: String) -> String { // str: REGULAR-2 (WHITE)
        // 여기서 파라미터로 넘어온 str은 이전 홀의 이름이다. 이 함수에서 구한 이름으로 현재 홀에 셋팅한다.
        
        let start1 = str.firstIndex(of: "(")
        let end1 = str.firstIndex(of: ")")
        
        let i1 = str.index(start1!, offsetBy: -1)
        
        let range1 = str.startIndex..<i1
        let name = str[range1]
        
        let i2 = str.index(start1!, offsetBy: 1)
        
        let range2 = i2..<end1!
        let color = str[range2]
        
        // print(#function, "name: " + name, "color: " + color)
        
        // 우선 이름으로 먼저 검색한다.
        for tg in tgs {
            if tg.name == name { return str }
        }
        
        // 이름이 같은 티박스가 없으면 색깔로 검색한다.
        for tg in tgs {
            if tg.color == color { return tg.name + " (" + tg.color + ")" }
        }
        
        // return ""
        
        // 색깔로 검색이 안되면 디폴트 0번째 티박스를 선택한다. (이전 홀에서는 YELLOW 티를 선택했는데, 이번 홀에서는 사라졌다.)
        let tg = tgs[0]
        return tg.name + " (" + tg.color + ")"
    }
    
    static func getIndex(_ tgs: [TeeingGround], _ str: String) -> Int { // str: REGULAR-2 (WHITE)
        let start1 = str.firstIndex(of: "(")
        let i1 = str.index(start1!, offsetBy: -1)
        let range1 = str.startIndex..<i1
        
        let name = str[range1] // REGULAR-2
        // print(#function, "name: " + name)
        
        for (i, tg) in tgs.enumerated() {
            if tg.name == name { return i }
        }
        
        return 0
    }
    
    static func getName(_ tg: TeeingGround) -> String {
        return tg.name + " (" + tg.color + ")" // REGULAR-2 (WHITE)
    }
    
    static func getSentenceCount(_ str: String) -> Int {
        var count = 0
        
        var i = 0
        
        while i < str.count {
            let index = str.index(str.startIndex, offsetBy: i)
            let ch = str[index]
            
            let unicodeVal = UnicodeScalar(String(ch))?.value
            if let value = unicodeVal {
                if (value < 0xAC00 || value > 0xD7A3) {
                    // 한글 아님
                    count += 1
                } else {
                    // 한글
                    count += 2
                }
            } else {
                return 5 // 5줄
            }
            
            i += 1
        }
        
        // let returnValue = (count / 34) + 1 // 한 줄에 34자
        
        var returnValue = 4
        
        if count > 123 {
            returnValue = 5
        }
        
        // print(#function, returnValue)
        
        return returnValue
    }
    
    static func generateToken(_ id: String, _ code: String) {
        let url = "https://asia-northeast1-holeman-4070a.cloudfunctions.net/generate_token"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        let params = ["id":id, "code":code] as Dictionary<String, String>
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            // print(#function, response!)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(#function, json)
                
                let status = json["status"] as! String
                if status == "OK" {
                    let results = json["results"] as! [[String:Any]]
                    print(#function, results)
                    /*
                    let results = json["results"] as! [[String:Any]]
                    if let elevation = results[0]["elevation"] as? Double {
                        // self.userElevation = elevation
                        
                        // MainView.elevationDiff = elevation - alt
                    }
                     */
                }
            } catch {
                print(#function, "error")
            }
        })
        
        task.resume()
    }
    
    static func deleteAccount(_ code: String) {
        let url = "https://asia-northeast1-holeman-4070a.cloudfunctions.net/delete_account"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        let params = ["code":code, "password":"123456"] as Dictionary<String, String>
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            // print(#function, response!)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(#function, json)
                
                let status = json["status"] as! String
                if status == "OK" {
                    let results = json["results"] as! [[String:Any]]
                    if let elevation = results[0]["elevation"] as? Double {
                        // self.userElevation = elevation
                        
                        // MainView.elevationDiff = elevation - alt
                    }
                }
            } catch {
                print(#function, "error")
            }
        })
        
        task.resume()
    }
}
