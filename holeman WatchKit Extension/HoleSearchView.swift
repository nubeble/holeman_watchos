//
//  HoleSearchView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/16.
//

import SwiftUI

struct HoleSearchView: View {
    @State var mode: Int = 0
    
    // @State var course: CourseModel = CourseModel(address: "", countryCode: "", courses: [], id: 0, location: CLLocation(latitude: 0.0, longitude: 0.0), name: "")
    @State var course: CourseModel? = nil
    
    @State var teeingGroundInfo: TeeingGroundInfoModel? = nil
    
    struct HoleData: Codable, Hashable {
        let number: Int
        let par: Int
        let handicap: Int
        let distance: Dictionary<String, Int>
    }
    
    // @State var selectedCourseIndex = 0
    
    // data to MainView
    @State var teeingGroundIndex = -1
    // @State var groupId = 0
    // @State var teeingGroundInfo: TeeingGroundInfoModel? = nil
    
    
    
    
    
    
    var body: some View {
        if (self.mode == 0) {
            
            ZStack {
                
                VStack(alignment: HorizontalAlignment.center)  {
                    
                    if let name = self.course?.name {
                        let start1 = name.firstIndex(of: "(")
                        let end1 = name.firstIndex(of: ")")
                        
                        let i1 = name.index(start1!, offsetBy: -1)
                        
                        let range1 = name.startIndex..<i1
                        let str1 = name[range1]
                        
                        let i2 = name.index(start1!, offsetBy: 1)
                        
                        let range2 = i2..<end1!
                        let str2 = name[range2]
                        
                        Text(str1).font(.system(size: 16)).lineLimit(1)
                        Text(str2).font(.system(size: 16)).lineLimit(1)
                        
                        Spacer().frame(maxHeight: .infinity)
                    }
                }
                
                VStack {
                    Text("스타트 홀로 가시면\n자동으로 시작됩니다.").font(.system(size: 22)).multilineTextAlignment(.center)
                }
                
                VStack(alignment: HorizontalAlignment.center) {
                    Spacer().frame(maxHeight: .infinity)
                    
                    Image("tee up")
                        .resizable()
                        .frame(width: 200 / 5, height: 200 / 5)
                        .padding(.bottom, 15)
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
                
            }
            .onAppear(perform: {
                Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
                    print(#function, "Timer fired.")
                    
                    // ToDo: getStartHole() // 1, 10, 19, ...
                    
                    // get holes data in db
                    let groupId = self.course?.id
                    getHoles(groupId!) {
                        // ToDo:
                        
                        // startHoles
                        
                        // getSensor
                        
                    }
                    
                }
            })
            
        } else if (self.mode == 1) {
            
        } else if (self.mode == 10) { // go back
            
            // CourseView()
            
        } else if (self.mode == 20) { // move to next (MainView)
            
            // pass data
            // 1. teeingGroundIndex
            // let teeingGroundIndex = self.teeingGroundIndex
            
            // 2. holeNumber
            // 3. groupId
            // 4. course
            // let course = self.courses[self.selectedCourseIndex]
            // 5. teeingGroundInfo
            
            
            
            MainView()
            
            
        }
        
    }
    
    func getHoles(_ groupId: Int64, onComplete: @escaping () -> Void) {
        CloudKitManager.getHole(groupId) { records in
            if let records = records {
                if (records.count == 1) {
                    let record = records[0]
                    
                    var info = TeeingGroundInfoModel(unit: "", holes: [])
                    
                    // let id = record["id"] as! Int64
                    let unit = record["unit"] as! String
                    let holes = record["holes"] as! [String]
                    
                    // set unit
                    info.unit = unit
                    
                    // holes
                    var i = 0 // 0 ~ 17
                    for hole in holes {
                        i += 1
                        
                        // create
                        var tg = TeeingGrounds(teeingGrounds: [], par: 0, handicap: 0, name: "")
                        
                        // parse json
                        do {
                            // let data = Data.init(base64Encoded: course)
                            let data = Data(hole.utf8)
                            let decodedData = try JSONDecoder().decode(HoleData.self, from: data)
                            // print(decodedData)
                            
                            tg.par = decodedData.par
                            tg.handicap = decodedData.handicap
                            
                            // let distances = Util.convertToDictionary(text: decodedData.distance)
                            let distances = decodedData.distance
                            
                            // set name
                            if (self.course?.courses.count == 0) {
                                let number = i
                                tg.name = Util.getOrdinalNumber(number) + " HOLE"
                            } else {
                                var number = i
                                
                                for course in self.course!.courses {
                                    let name = course.name
                                    let startNumber = course.range[0]
                                    let endNumber = course.range[1]
                                    
                                    if (startNumber <= number && number <= endNumber) {
                                        number = (number + 9) % 9;
                                        if (number == 0) { number = 9; }
                                        // tg.name = name + " " + number;
                                        // tg.name = name + " HOLE " + number;
                                        tg.name = name + " " + Util.getOrdinalNumber(number);
                                        break;
                                    }
                                }
                            }
                            
                            // set distance
                            
                            // sort
                            // let sorted = distances.sorted {$0.1 < $1.1}
                            let sorted = distances.sorted {$0.1 > $1.1}
                            for (key, value) in sorted {
                                // get name, color
                                let start1 = key.firstIndex(of: "(")
                                let end1 = key.firstIndex(of: ")")
                                
                                let i1 = key.index(start1!, offsetBy: 0)
                                
                                let range1 = key.startIndex..<i1
                                let name = key[range1]
                                
                                let i2 = key.index(start1!, offsetBy: 1)
                                
                                let range2 = i2..<end1!
                                let color = key[range2]
                                
                                // print("name", name)
                                // print("color", color)
                                
                                let distance = value
                                
                                // print("distance", distance)
                                
                                let t = TeeingGround(name: String(name), color: String(color), distance: distance)
                                tg.teeingGrounds.append(t)
                            }
                        } catch {
                            print(error)
                        }
                        
                        // set
                        info.holes.append(tg)
                    } // end of for
                    
                    self.teeingGroundInfo = info
                    print("info", info)
                    
                    onComplete()
                } else { // records.count != 1
                    // ToDo: error handling
                }
            }
            
        } // end of getHole
        
    }
    
    
    
    
    
    
}

struct HoleSearchView_Previews: PreviewProvider {
    static var previews: some View {
        HoleSearchView()
    }
}
