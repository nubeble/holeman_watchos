//
//  CourseSearchView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/13.
//

import SwiftUI
import StoreKit

struct CourseSearchView: View {
    @State var mode: Int = 0
    
    @State var textMessage: String = ""
    @State var findNearbyCourseCounter = 0
    
    // @ObservedObject var locationManager = LocationManager()
    @State var placemark: CLPlacemark?
    // @State var city: String?
    // @State var country: String?
    @State var countryCode: String?
    
    @State var courses: [CourseModel] = []
    
    @State var selectedCourseIndex: Int = -1
    
    // data to MainView
    // @State var teeingGroundIndex = -1
    // @State var groupId = 0
    // @State var teeingGroundInfo: TeeingGroundInfoModel? = nil
    
    @EnvironmentObject var storeManager: StoreManager
    
    @State var buttonFlag: Bool = false
    
    // @State var productId: String?
    
    @State var textMessage2: String = ""
    
    @State var textMessage3: String = "" // 검색된 골프장이 맞나요? / 선택하신 골프장이 맞나요?
    
    var body: some View {
        if self.mode == 0 {
            
            // loading indicator
            ZStack {
                ProgressView()
                    .scaleEffect(1.2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                
                VStack {
                    Spacer()
                    
                    Text(self.textMessage).font(.system(size: 16)).foregroundColor(Color.gray).fontWeight(.medium)
                        .transition(.opacity)
                        .id(self.textMessage)
                }
            }.onAppear(perform: onCreate)
            
        } else if self.mode == 1 {
            
            /*
             ZStack {
             VStack {
             // picker
             Picker(selection: $selectedCourseIndex, label: Text("")) {
             ForEach(0 ..< self.courses.count) {
             let name = self.courses[$0].name
             
             let start1 = name.firstIndex(of: "(")
             let end1 = name.firstIndex(of: ")")
             
             let i1 = name.index(start1!, offsetBy: -1)
             
             let range1 = name.startIndex..<i1
             let str1 = name[range1]
             
             let i2 = name.index(start1!, offsetBy: 1)
             
             let range2 = i2..<end1!
             let str2 = name[range2]
             
             Text(str1 + "\n" + str2).font(.system(size: 18))
             .fixedSize(horizontal: false, vertical: true)
             .lineLimit(2)
             // .multilineTextAlignment(.leading)
             .frame(maxWidth: .infinity, alignment: .leading)
             }
             }
             .defaultWheelPickerItemHeight(48)
             .labelsHidden()
             .frame(height: 86)
             // .clipped()
             .padding(.top, 10)
             
             Spacer().frame(maxHeight: .infinity)
             }
             
             VStack {
             Spacer().frame(maxHeight: .infinity)
             
             HStack(spacing: 40) {
             // button 1
             Button(action: {
             // go back
             withAnimation {
             self.mode = 10
             }
             }) {
             ZStack {
             Circle()
             .fill(Color(red: 49 / 255, green: 49 / 255, blue: 49 / 255))
             .frame(width: 54, height: 54)
             
             Image(systemName: "xmark")
             .font(Font.system(size: 28, weight: .heavy))
             }
             }
             .buttonStyle(PlainButtonStyle())
             .padding(.bottom, 10)
             // .opacity(button1Opacity)
             
             // button 2
             Button(action: {
             print("button click")
             
             // move to next
             withAnimation {
             self.mode = 20
             }
             }) {
             ZStack {
             Circle()
             .fill(Color.green)
             .frame(width: 54, height: 54)
             
             Image(systemName: "checkmark")
             .font(Font.system(size: 28, weight: .heavy))
             }
             }
             .buttonStyle(PlainButtonStyle())
             .padding(.bottom, 10)
             // .opacity(button1Opacity)
             }
             }
             .frame(maxHeight: .infinity)
             .edgesIgnoringSafeArea(.bottom)
             }
             */
            // change picker to List
            GeometryReader { geometry in
                ScrollView {
                    // VStack {
                    ScrollViewReader { value in
                        LazyVStack {
                            Text("Select Course").font(.system(size: 20, weight: .semibold))
                            Text("골프장을 선택하세요.").font(.system(size: 14, weight: .light)).padding(.bottom, Static.title2PaddingBottom)
                            
                            // Divider()
                            
                            ForEach(0 ..< self.courses.count) {
                                let index = $0
                                
                                let name = self.courses[index].name
                                
                                let start1 = name.firstIndex(of: "(")
                                let end1 = name.firstIndex(of: ")")
                                
                                let i1 = name.index(start1!, offsetBy: -1)
                                
                                let range1 = name.startIndex..<i1
                                let str1 = name[range1]
                                
                                let i2 = name.index(start1!, offsetBy: 1)
                                
                                let range2 = i2..<end1!
                                let str2 = name[range2]
                                
                                Button(action: {
                                    self.selectedCourseIndex = index
                                    
                                    self.textMessage3 = "선택하신 골프장이 맞나요?"
                                    
                                    withAnimation {
                                        self.mode = 50
                                    }
                                }) {
                                    /*
                                     Text(str1 + "\n" + str2).font(.system(size: 18))
                                     .fixedSize(horizontal: false, vertical: true)
                                     .lineLimit(2)
                                     // .multilineTextAlignment(.leading)
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     */
                                    VStack(spacing: 2) {
                                        Text(str1).font(.system(size: 18))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        // Text(str2).font(.system(size: 14))
                                        Text(str2).font(.system(size: 12)) // 영문 코스명은 12로 고정
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }.id($0)
                            } // ForEach
                            
                            Button(action: {
                                // go back
                                withAnimation {
                                    self.mode = 10
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 49 / 255, green: 49 / 255, blue: 49 / 255))
                                        .frame(width: 54, height: 54)
                                    
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(Color(red: 187 / 255, green: 187 / 255, blue: 187 / 255))
                                        .font(Font.system(size: 28, weight: .heavy))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, Static.buttonPaddingTop)
                            .padding(.bottom, -20) // check default padding
                            
                        }.onAppear {
                            // scroll
                            // value.scrollTo(2)
                        }
                    }
                    // }
                } // ScrollView
            }
            
        } else if self.mode == 9 { // notice
            
            // Consider: open Notification in iPhone
            
            ZStack {
                VStack {
                    Text("Notice").font(.system(size: 20, weight: .semibold))
                    Text("위치 서비스를 켜주세요.").font(.system(size: 14, weight: .light)).padding(.bottom, Static.title2PaddingBottom)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    let name = Locale.current.languageCode == "ko" ? "홀맨" : "Holeman"
                    let text = "iPhone에서 설정 앱을 열고 '개인 정보 보호' - '위치 서비스' - '\(name)' - '앱을 사용하는 동안' 선택"
                    Text(text).font(.system(size: 16)).padding(.top, 10).multilineTextAlignment(.center)
                }
                
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    Button(action: {
                        // go back
                        withAnimation {
                            self.mode = 10
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 49 / 255, green: 49 / 255, blue: 49 / 255))
                                .frame(width: 54, height: 54)
                            
                            Image(systemName: "xmark")
                                .foregroundColor(Color(red: 187 / 255, green: 187 / 255, blue: 187 / 255))
                                .font(Font.system(size: 28, weight: .heavy))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 10)
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            
        } else if self.mode == 10 { // go back
            
            CourseView()
            
        } else if self.mode == 20 { // move to next (HoleSearchView)
            
            let c = self.courses[self.selectedCourseIndex]
            HoleSearchView(course: c)
            
        } else if self.mode == 50 {
            
            //            ZStack {
            //                VStack {
            //                    Text("Selected Course").font(.system(size: 18, weight: .regular)).foregroundColor(.gray)
            //                        .frame(maxWidth: .infinity, alignment: .leading)
            //                        .padding(.leading, 4)
            //                        .padding(.top, 8)
            //
            //                    VStack {
            //                        if let name = self.courses[self.selectedCourseIndex].name {
            //                            let start1 = name.firstIndex(of: "(")
            //                            let end1 = name.firstIndex(of: ")")
            //
            //                            let i1 = name.index(start1!, offsetBy: -1)
            //
            //                            let range1 = name.startIndex..<i1
            //                            let str1 = name[range1]
            //
            //                            let i2 = name.index(start1!, offsetBy: 1)
            //
            //                            let range2 = i2..<end1!
            //                            let str2 = name[range2]
            //
            //                            Text(str1).font(.system(size: 20))
            //                                .fixedSize(horizontal: false, vertical: true)
            //                                .lineLimit(1)
            //                                .frame(maxWidth: .infinity, alignment: .leading)
            //
            //                            Text(str2).font(.system(size: 14)) // 영문 코스명은 12로 고정, BUT 여기는 확대
            //                                .fixedSize(horizontal: false, vertical: true)
            //                                .lineLimit(1)
            //                                .frame(maxWidth: .infinity, alignment: .leading)
            //                        }
            //
            //                        if let address = self.courses[self.selectedCourseIndex].address {
            //                            let start1 = address.firstIndex(of: "(")
            //                            // let end1 = address.firstIndex(of: ")")
            //
            //                            let i1 = address.index(start1!, offsetBy: -1)
            //
            //                            let range1 = address.startIndex..<i1
            //                            let str1 = address[range1]
            //
            //                            // let i2 = address.index(start1!, offsetBy: 1)
            //
            //                            // let range2 = i2..<end1!
            //                            // let str2 = address[range2]
            //
            //                            // local language only
            //                            Text(str1).font(.system(size: 14)).foregroundColor(Color.gray)
            //                                .fixedSize(horizontal: false, vertical: true)
            //                                .lineLimit(1)
            //                                .frame(maxWidth: .infinity, alignment: .leading)
            //                                .padding(.top, 2)
            //                        }
            //                    }
            //                    .padding(.all, 8)
            //                    .background(Color(red: 32 / 255, green: 32 / 255, blue: 32 / 255))
            //                    .cornerRadius(8)
            //
            //                    Spacer().frame(maxHeight: .infinity)
            //                }
            //
            //                VStack {
            //                    Spacer().frame(maxHeight: .infinity)
            //
            //                    HStack(spacing: 40) {
            //                        // button 1
            //                        Button(action: {
            //                            withAnimation {
            //                                // self.mode = 1 // show list
            //                                self.mode = 10 // go back
            //                            }
            //                        }) {
            //                            ZStack {
            //                                Circle()
            //                                    .fill(Color(red: 49 / 255, green: 49 / 255, blue: 49 / 255))
            //                                    .frame(width: 54, height: 54)
            //
            //                                Image(systemName: "xmark")
            //                                    .font(Font.system(size: 28, weight: .heavy))
            //                            }
            //                        }
            //                        .buttonStyle(PlainButtonStyle())
            //                        .padding(.bottom, 10)
            //
            //                        // button 2
            //                        Button(action: {
            //                            // ToDo: 2021-04-26 IAP
            //                            /*
            //                             if self.buttonFlag == false {
            //                             self.buttonFlag = true
            //
            //                             Util.purchasedAll() { result in
            //                             if result == true {
            //                             withAnimation {
            //                             self.mode = 54
            //                             }
            //                             } else {
            //                             self.storeManager.initProducts()
            //                             self.storeManager.getProducts(productIDs: Static.productIDs)
            //
            //                             withAnimation {
            //                             self.mode = 51
            //                             }
            //                             }
            //
            //                             self.buttonFlag = false
            //                             }
            //                             }
            //                             */
            //
            //                            self.storeManager.initProducts()
            //                            // self.storeManager.getProducts(productIDs: Static.productIDs)
            //                            self.storeManager.getProducts(productIDs: [Static.productId])
            //
            //                            withAnimation {
            //                                self.mode = 51
            //                            }
            //                        }) {
            //                            ZStack {
            //                                Circle()
            //                                    .fill(Color.green)
            //                                    .frame(width: 54, height: 54)
            //
            //                                Image(systemName: "checkmark")
            //                                    .font(Font.system(size: 28, weight: .heavy))
            //                            }
            //                        }
            //                        .buttonStyle(PlainButtonStyle())
            //                        .padding(.bottom, 10)
            //                    }
            //                }
            //                .frame(maxHeight: .infinity)
            //                .edgesIgnoringSafeArea(.bottom)
            //            }
            
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        Text("Select Course").font(.system(size: 20, weight: .semibold))
                        Text(self.textMessage3).font(.system(size: 14, weight: .light)).padding(.bottom, Static.title2PaddingBottom)
                        
                        VStack {
                            if let name = self.courses[self.selectedCourseIndex].name {
                                let start1 = name.firstIndex(of: "(")
                                let end1 = name.firstIndex(of: ")")
                                
                                let i1 = name.index(start1!, offsetBy: -1)
                                
                                let range1 = name.startIndex..<i1
                                let str1 = name[range1]
                                
                                let i2 = name.index(start1!, offsetBy: 1)
                                
                                let range2 = i2..<end1!
                                let str2 = name[range2]
                                
                                Text(str1).font(.system(size: 20))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                Text(str2).font(.system(size: 14)) // 영문 코스명은 12로 고정, BUT 여기는 확대
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            if let address = self.courses[self.selectedCourseIndex].address {
                                let start1 = address.firstIndex(of: "(")
                                // let end1 = address.firstIndex(of: ")")
                                
                                let i1 = address.index(start1!, offsetBy: -1)
                                
                                let range1 = address.startIndex..<i1
                                let str1 = address[range1]
                                
                                // let i2 = address.index(start1!, offsetBy: 1)
                                
                                // let range2 = i2..<end1!
                                // let str2 = address[range2]
                                
                                // local language only
                                Text(str1).font(.system(size: 14)).foregroundColor(Color.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        .padding(.all, 8)
                        .background(Color(red: 32 / 255, green: 32 / 255, blue: 32 / 255))
                        .cornerRadius(8)
                        
                        HStack(spacing: 40) {
                            // button 1
                            Button(action: {
                                // go back
                                withAnimation {
                                    self.mode = 10
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 49 / 255, green: 49 / 255, blue: 49 / 255))
                                        .frame(width: 54, height: 54)
                                    
                                    Image(systemName: "xmark")
                                        .font(Font.system(size: 28, weight: .heavy))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.bottom, 10)
                            
                            // button 2
                            Button(action: {
                                // self.checkFreeTrial()
                                
                                withAnimation {
                                    self.mode = 70
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 54, height: 54)
                                    
                                    Image(systemName: "checkmark")
                                        .font(Font.system(size: 28, weight: .heavy))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.bottom, 10)
                        }
                        .padding(.top, Static.buttonPaddingTop)
                    } // VStack
                } // ScrollView
            } // GeometryReader
            
        } else if self.mode == 51 {
            
            if Util.contains(self.storeManager.myProducts, Static.productId) == true {
                // if Util.contains(self.storeManager.myProducts, Static.productIDs) == true {
                GeometryReader { geometry in
                    ScrollView {
                        VStack {
                            Text("Payment").font(.system(size: 20, weight: .semibold))
                            Text("바우처를 구매해주세요.").font(.system(size: 14, weight: .light)).padding(.bottom, Static.title2PaddingBottom)
                            
                            Text(Locale.current.languageCode == "ko" ? "홀맨 이용권" : "Holeman Voucher")
                                .font(.system(size: 20, weight: .regular))
                                // .foregroundColor(Color(red: 137 / 255, green: 209 / 255, blue: 254 / 255))
                                .foregroundColor(.green)
                                // .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.center)
                                .padding(.top, -6)
                            
                            Text(Util.getCourseName(self.courses[self.selectedCourseIndex].name) + " 18홀의 정확한 거리 측정 서비스를 1,000원에 이용하세요.")
                                .font(.system(size: 16))
                                .fontWeight(.light)
                                // .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 8)
                            
                            Button(action: {
                                withAnimation {
                                    self.mode = 52
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    
                                    Text("￦1,000 / 18 holes").foregroundColor(.black)
                                    //.font(.system(size: 15))
                                    // .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                .frame(height: 50)
                                // .background(Color(red: 137 / 255, green: 209 / 255, blue: 254 / 255))
                                .background(Color.green)
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                // go back
                                withAnimation {
                                    self.mode = 10
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 49 / 255, green: 49 / 255, blue: 49 / 255))
                                        .frame(width: 54, height: 54)
                                    
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(Color(red: 187 / 255, green: 187 / 255, blue: 187 / 255))
                                        .font(Font.system(size: 28, weight: .heavy))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, Static.buttonPaddingTop)
                            .padding(.bottom, -20) // check default padding
                        }
                    }
                }
            } else {
                // loading indicator
                ProgressView()
                    .scaleEffect(1.2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
            }
            
        } else if self.mode == 52 {
            
            if self.storeManager.remainingTransactionsCount == nil || self.storeManager.remainingTransactionsCount == 0 {
                // loading indicator
                ProgressView()
                    .scaleEffect(1.2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                    .onAppear {
                        self.storeManager.initState() {
                            // ToDo: 2021-04-26 IAP
                            /*
                             Util.getProductId() { productId in
                             print(#function, "purchasing product id", productId)
                             
                             self.productId = productId
                             
                             // purchase
                             // let product = Util.getProduct(self.storeManager.myProducts, "com.nubeble.holeman.iap.course")
                             let product = Util.getProduct(self.storeManager.myProducts, productId)
                             if let product = product {
                             self.storeManager.purchaseProduct(product)
                             
                             withAnimation {
                             self.mode = 53
                             }
                             }
                             }
                             */
                            let product = Util.getProduct(self.storeManager.myProducts, Static.productId)
                            if let product = product {
                                self.storeManager.purchaseProduct(product)
                                
                                withAnimation {
                                    self.mode = 53
                                }
                            }
                        } // initState()
                    } // onAppear()
            } else {
                // loading indicator
                ProgressView()
                    .scaleEffect(1.2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
            }
            
        } else if self.mode == 53 {
            
            if self.storeManager.transactionState == nil || self.storeManager.transactionState == .purchasing {
                // loading indicator
                ProgressView()
                    .scaleEffect(1.2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
            } else if self.storeManager.transactionState == .failed {
                // back to payment
                ZStack {
                    VStack {
                        Text("잠시 후 다시 시도해주세요.").font(.system(size: 20)).fontWeight(.medium).multilineTextAlignment(.center)
                    }
                    
                    VStack {
                        Spacer().frame(maxHeight: .infinity)
                        
                        Button(action: {
                            withAnimation {
                                self.mode = 51
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 49 / 255, green: 49 / 255, blue: 49 / 255))
                                    .frame(width: 54, height: 54)
                                
                                Image(systemName: "arrow.left")
                                    .foregroundColor(Color(red: 187 / 255, green: 187 / 255, blue: 187 / 255))
                                    .font(Font.system(size: 28, weight: .heavy))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, 10)
                    } // VStack
                    .frame(maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.bottom)
                }
            } else if self.storeManager.transactionState == .purchased {
                // move next in 3 secs
                
                VStack {
                    Image(systemName: "checkmark")
                        .font(Font.system(size: 40, weight: .semibold))
                        .foregroundColor(.green)
                }.onAppear {
                    self.storeManager.destroy()
                    
                    // ToDo: 2021-04-26 IAP
                    /*
                     // save purchased product id (UserDefaults, CloudKit)
                     if let productId = self.productId {
                     Util.setProductId(productId)
                     }
                     */
                    
                    // update DB
                    if let userId = Global.userId {
                        CloudManager.updatePurchaseCount(userId)
                    }
                    
                    let c = self.courses[self.selectedCourseIndex]
                    Util.saveCourse(c)
                    
                    // ToDo: test timer
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation {
                            self.mode = 20 // move next
                        }
                    }
                }
            } else { // restored
                // N/A
            }
            
        } else if self.mode == 54 {
            
            VStack {
                Text("홀맨을 사랑해주셔서 감사합니다. 이제부터 무료로 이용하세요.").font(.system(size: 20)).fontWeight(.medium).multilineTextAlignment(.center)
            }.onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    let c = self.courses[self.selectedCourseIndex]
                    Util.saveCourse(c)
                    
                    withAnimation {
                        self.mode = 20 // move next
                    }
                }
            }
            
        } else if self.mode == 60 {
            
            ZStack {
                // header
                VStack {
                    Text("Free Trial").font(.system(size: 20, weight: .semibold))
                    Text("무료로 체험하세요!").font(.system(size: 14, weight: .light)).padding(.bottom, Static.title2PaddingBottom)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    Text(self.textMessage2).font(.system(size: 16)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                // next button
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    Button(action: {
                        withAnimation {
                            self.mode = 20 // move next
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 54, height: 54)
                            
                            Image(systemName: "arrow.right")
                                .font(Font.system(size: 28, weight: .heavy))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 10)
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            
        } else if self.mode == 61 {
            
            ZStack {
                // header
                VStack {
                    Text("Free Trial").font(.system(size: 20, weight: .semibold))
                    Text("무료로 체험하세요!").font(.system(size: 14, weight: .light)).padding(.bottom, Static.title2PaddingBottom)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    Text(self.textMessage2).font(.system(size: 16)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                // next button
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    Button(action: {
                        self.storeManager.initProducts()
                        // self.storeManager.getProducts(productIDs: Static.productIDs)
                        self.storeManager.getProducts(productIDs: [Static.productId])
                        
                        withAnimation {
                            self.mode = 51
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 54, height: 54)
                            
                            Image(systemName: "arrow.right")
                                .font(Font.system(size: 28, weight: .heavy))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 10)
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            
        } else if self.mode == 70 {
            
            // loading indicator
            ZStack {
                ProgressView()
                    .scaleEffect(1.2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                
                VStack {
                    Spacer()
                    
                    Text(self.textMessage).font(.system(size: 16)).foregroundColor(Color.gray).fontWeight(.medium)
                        .transition(.opacity)
                        .id(self.textMessage)
                }
            }.onAppear {
                let result = Util.checkLastPurchasedCourse(self.courses[self.selectedCourseIndex].id)
                if result == true {
                    withAnimation {
                        self.mode = 20 // move next
                    }
                } else {
                    self.checkFreeTrial()
                }
            }
            
        }
    }
    
    func onCreate() {
        // print(#function, "onCreate()")
        
        // get country code
        getCountryCodeTimer()
    }
    
    func getCountryCodeTimer() {
        let locationManager = LocationManager()
        
        // --
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer1 in
            if let status = locationManager.locationStatus {
                DispatchQueue.main.async {
                    // timer1.invalidate()
                    
                    if status == .authorizedWhenInUse || status == .authorizedAlways {
                        timer1.invalidate()
                        
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer2 in
                            if let location = locationManager.lastLocation {
                                DispatchQueue.main.async {
                                    timer2.invalidate()
                                    
                                    self.getCountryCode(location: location)
                                }
                            }
                        }
                    } else if status == .denied {
                        timer1.invalidate()
                        
                        // notice
                        withAnimation {
                            self.mode = 9
                        }
                    }
                }
            }
        }
        // --
    }
    
    func getCountryCode(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            // always good to check if no error
            // also we have to unwrap the placemark because it's optional
            // I have done all in a single if but you check them separately
            if error == nil, let placemark = placemarks, !placemark.isEmpty {
                self.placemark = placemark.last
            }
            
            // a new function where you start to parse placemarks to get the information you need
            let result = self.parsePlacemarks(location: location)
            if result == false {
                // call timer again
                getCountryCodeTimer()
            } else {
                findNearbyCourse(location)
            }
        })
    }
    
    func findNearbyCourse(_ location: CLLocation) {
        findNearbyCourse(location) { result in
            if result == false {
                // no course nearby. try again in 3 secs
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    if self.findNearbyCourseCounter == 10 {
                        withAnimation(.linear(duration: 0.5)) {
                            self.textMessage = "잠시 후 다시 시도해주세요."
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            // back to CourseView
                            withAnimation {
                                self.mode = 10
                            }
                        }
                        
                        return
                    }
                    
                    // show wait message
                    withAnimation(.linear(duration: 0.5)) {
                        self.textMessage = Util.getWaitMessageForCourse(self.findNearbyCourseCounter)
                    }
                    self.findNearbyCourseCounter += 1
                    
                    findNearbyCourse(location)
                }
            }
        }
    }
    
    func findNearbyCourse(_ location: CLLocation, onCompletion: @escaping (_ result: Bool) -> Void) {
        let lat = location.coordinate.latitude - Static.__lat
        let lon = location.coordinate.longitude - Static.__lon
        let __lo = CLLocation(latitude: lat, longitude: lon)
        
        // CloudManager.fetchNearbyLocations(String(self.countryCode!), location) { records in
        CloudManager.fetchNearbyLocations(String(self.countryCode!), __lo) { records in
            // print(#function, records)
            if let records = records {
                var count = 0
                for record in records {
                    count += 1
                    // print("course #\(count)", record)
                    
                    print("course #\(count)")
                    
                    let address = record["address"] as! String
                    // let countryCode = record["countryCode"] as! String
                    let courses = record["courses"] as! [String]
                    let id = record["id"] as! Int64
                    let location = record["location"] as! CLLocation
                    let name = record["name"] as! String
                    let email = record["email"] as! String
                    
                    // set data
                    // --
                    var c: CourseModel = CourseModel(address: "", countryCode: "", courses: [], id: 0, location: CLLocation(latitude: 0.0, longitude: 0.0), name: "", email: "")
                    
                    c.address = address
                    c.countryCode = countryCode!
                    
                    // courses
                    var i = 0
                    for course in courses {
                        // print("course[\(i)]", course)
                        i += 1
                        
                        // parse json
                        do {
                            // let data = Data.init(base64Encoded: course)
                            let data = Data(course.utf8)
                            let decodedData = try JSONDecoder().decode(CourseData.self, from: data)
                            // print(decodedData)
                            
                            // decodedData.name
                            // decodedData.range[0], decodedData.range[1]
                            
                            let item = CourseItem(name: decodedData.name, range: [decodedData.range[0], decodedData.range[1]])
                            c.courses.append(item)
                        } catch {
                            print(error)
                            return
                        }
                    }
                    
                    c.id = id
                    c.location = location
                    c.name = name
                    c.email = email
                    
                    self.courses.append(c)
                    // --
                    
                    // print
                    // --
                    /*
                     print("address", address)
                     
                     var i = 0
                     for course in courses {
                     // print("course[\(i)]", course)
                     i += 1
                     
                     // parse json
                     do {
                     // let data = Data.init(base64Encoded: course)
                     let data = Data(course.utf8)
                     let decodedData = try JSONDecoder().decode(CourseData.self, from: data)
                     print(decodedData)
                     
                     // decodedData.name
                     // decodedData.range[0], decodedData.range[1]
                     } catch {
                     print(error)
                     }
                     }
                     
                     print("id", id)
                     print("latitude", location.coordinate.latitude)
                     print("longitude", location.coordinate.longitude)
                     print("name", name)
                     */
                    // --
                }
                
                if count == 0 {
                    print(#function, "no course nearby. try again in 3 seconds")
                    
                    onCompletion(false)
                } else if count == 1 {
                    self.selectedCourseIndex = 0
                    
                    self.textMessage3 = "검색된 골프장이 맞나요?"
                    
                    withAnimation {
                        self.mode = 50
                    }
                } else {
                    // show list
                    withAnimation {
                        self.mode = 1
                    }
                    
                    onCompletion(true)
                }
            } else {
                // N/A
            }
        }
    }
    
    func parsePlacemarks(location: CLLocation) -> Bool {
        // let location = self.lastLocation
        
        // here we check if location manager is not nil using a _ wild card
        //if let _ = location {
        // unwrap the placemark
        if let placemark = self.placemark {
            // wow now you can get the city name. remember that apple refers to city name as locality not city
            // again we have to unwrap the locality remember optionalllls also some times there is no text so we check that it should not be empty
            /*
             if let city = placemark.locality, !city.isEmpty {
             // here you have the city name
             // assign city name to our iVar
             self.city = city
             
             print(#function, city)
             }
             // the same story optionalllls also they are not empty
             if let country = placemark.country, !country.isEmpty {
             
             self.country = country
             
             print(#function, country)
             }
             */
            // get the country short name which is called isoCountryCode
            if let countryShortName = placemark.isoCountryCode, !countryShortName.isEmpty {
                self.countryCode = countryShortName
                
                print(#function, countryShortName)
                
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    } // parsePlacemarks()
    
    func checkFreeTrial() {
        if let userId = Global.userId {
            /*
             CloudManager.getFreeTrialCount(userId) { freeTrialCount in
             if freeTrialCount < 10 {
             let n = 10 - freeTrialCount
             if n == 10 {
             self.textMessage2 = "홀맨의 정확한 거리 측정 서비스를 10회까지 무료로 이용하실 수 있어요."
             } else {
             self.textMessage2 = "홀맨의 정확한 거리 측정 서비스를 10회까지 무료로 이용하실 수 있어요. (" + String(n) + "회 남았습니다.)"
             }
             
             // update DB
             CloudManager.setFreeTrialCount(userId, freeTrialCount + 1)
             
             let c = self.courses[self.selectedCourseIndex]
             Util.saveCourse(c)
             
             withAnimation {
             self.mode = 60
             }
             } else {
             self.textMessage2 = "홀맨의 정확한 거리 측정 서비스를 10회까지 무료로 이용하실 수 있어요. (모두 사용하셨습니다.)"
             
             withAnimation {
             self.mode = 61
             }
             }
             }
             */
            CloudManager.checkFreeTrialCount(userId) { freeTrialCount in
                if freeTrialCount < 10 {
                    let n = 10 - freeTrialCount
                    if n == 10 {
                        self.textMessage2 = "홀맨의 정확한 거리 측정 서비스를 10회까지 무료로 이용하실 수 있어요."
                    } else {
                        self.textMessage2 = "홀맨의 정확한 거리 측정 서비스를 10회까지 무료로 이용하실 수 있어요. (" + String(n) + "회 남았습니다.)"
                    }
                    
                    let c = self.courses[self.selectedCourseIndex]
                    Util.saveCourse(c)
                    
                    withAnimation {
                        self.mode = 60
                    }
                } else {
                    self.textMessage2 = "홀맨의 정확한 거리 측정 서비스를 10회까지 무료로 이용하실 수 있어요. (모두 사용하셨습니다.)"
                    
                    withAnimation {
                        self.mode = 61
                    }
                }
            } // CloudManager.checkFreeTrialCount()
        }
    } // checkFreeTrial()
}

struct CourseSearchView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSearchView()
    }
}
