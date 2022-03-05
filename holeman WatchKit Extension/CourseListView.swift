//
//  CourseListView.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/01/13.
//

import SwiftUI
import StoreKit

struct CourseListView: View {
    @State var mode: Int = 0
    
    @State var textMessage: String = ""
    @State var findNearbyCourseCounter = 0
    @State var getLastLocationCounter = 0
    
    // @ObservedObject var locationManager = LocationManager()
    @State var placemark: CLPlacemark?
    @State var countryCode: String?
    
    @State var courses: [CourseModel] = []
    
    @State var selectedCourseIndex: Int = -1
    
    @EnvironmentObject var storeManager: StoreManager
    
    @State var buttonFlag: Bool = false
    
    // @State var productId: String?
    
    @State var textMessage2: String = ""
    
    @State var textMessage3: String = ""
    
    var body: some View {
        if self.mode == 0 {
            // loading indicator
            ZStack {
                ProgressView()
                    .scaleEffect(1.2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                
                VStack {
                    Spacer()
                    
                    Text(self.textMessage).font(.system(size: Global.text4Size)).foregroundColor(Color.gray).fontWeight(.medium)
                        .transition(.opacity)
                        .id(self.textMessage)
                }
            }
            .onAppear {
                // get country code
                getCountryCodeTimer()
            }
            
        } else if self.mode == 1 {
            
            GeometryReader { geometry in
                ScrollView {
                    // VStack {
                    ScrollViewReader { value in
                        LazyVStack {
                            Text("Select Course").font(.system(size: Global.text2Size, weight: .semibold))
                            Text("골프장을 선택하세요.").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                            
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
                                    VStack(spacing: Global.buttonSpacing1) {
                                        Text(str1).font(.system(size: Global.text3Size))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text(str2).font(.system(size: Global.text6Size)) // 영문 코스명은 12로 고정
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
                                        .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                                    
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(Color(red: 187 / 255, green: 187 / 255, blue: 187 / 255))
                                        .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, Global.buttonPaddingTop)
                            .padding(.bottom, Global.buttonPaddingBottom2)
                        }
                        .onAppear {
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
                    Text("Notice").font(.system(size: Global.text2Size, weight: .semibold))
                    Text("위치 서비스를 켜주세요.").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    // let name = Locale.current.languageCode == "ko" ? "홀맨" : "Holeman"
                    // let text = "iPhone에서 설정 앱을 열고 '개인 정보 보호' - '위치 서비스' - '\(name)' - '앱을 사용하는 동안' 선택"
                    let text = "iPhone에서 설정 앱을 열고\n\"개인 정보 보호\" >\n\"위치 서비스\" > \"홀맨\" >\n'앱을 사용하는 동안' 선택"
                    Text(text).font(.system(size: Global.text4Size)).fontWeight(.medium).multilineTextAlignment(.center)
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
                                .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                            
                            Image(systemName: "xmark")
                                .foregroundColor(Color(red: 187 / 255, green: 187 / 255, blue: 187 / 255))
                                .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, Global.buttonPaddingBottom)
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
                        Text("Select Course").font(.system(size: Global.text2Size, weight: .semibold))
                        Text("선택하신 골프장이 맞나요?").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                        
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
                                
                                Text(str1).font(.system(size: Global.text2Size))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                Text(str2).font(.system(size: Global.text5Size)) // 영문 코스명은 12로 고정, BUT 여기는 확대
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
                                Text(str1).font(.system(size: Global.text5Size)).foregroundColor(Color.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        .padding(.all, Global.buttonPadding)
                        .background(Color(red: 32 / 255, green: 32 / 255, blue: 32 / 255))
                        .cornerRadius(Global.radius1)
                        
                        HStack(spacing: Global.buttonSpacing2) {
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
                                        .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                                    
                                    Image(systemName: "xmark")
                                        .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.bottom, Global.buttonPaddingBottom)
                            
                            // button 2
                            Button(action: {
                                // checkFreeTrial()
                                
                                withAnimation {
                                    self.mode = 70
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                                    
                                    Image(systemName: "checkmark")
                                        .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.bottom, Global.buttonPaddingBottom)
                        }
                        .padding(.top, Global.buttonPaddingTop)
                    } // VStack
                } // ScrollView
            } // GeometryReader
            
        } else if self.mode == 21 {
            
            // ToDo: test (show billing UI)
            /*
             List(self.storeManager.myProducts, id: \.self) { product in
             
             HStack {
             VStack(alignment: .leading) {
             Text(product.localizedTitle) // 1
             .font(.headline)
             Text(product.localizedDescription) // 2
             .font(.caption2)
             }
             
             Spacer()
             
             if UserDefaults.standard.bool(forKey: product.productIdentifier) { // 3
             Text ("Purchased")
             .foregroundColor(.green)
             } else {
             Button(action: {
             // Purchase particular ILO product
             }) {
             Text("Buy for \(product.price) $") // 4
             }
             .foregroundColor(.blue)
             }
             }
             
             }
             */
            
        } else if self.mode == 22 { // HLDS
            
            ZStack {
                VStack {
                    Text("Notice").font(.system(size: Global.text2Size, weight: .semibold))
                    Text("HLDS™를 확인해주세요.").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    let c = self.courses[self.selectedCourseIndex]
                    let name = Util.getCourseName(self.courses[self.selectedCourseIndex].name)
                    // let text = c.hlds == 100 ? name + "에는\nHLDS™가 설치되어 있어요.\n홀맨이 정확한 거리를 알려드릴게요." : name + "에는\nHLDS™가 미설치되어 있어요.\n하지만 홀맨이 그린 정중앙을\n기준으로 거리를 알려드릴게요."
                    let text = Util.getCourseDescription(name, c.hlds)
                    
                    Text(text).font(.system(size: Global.text4Size)).fontWeight(.medium).multilineTextAlignment(.center)
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
                                .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                            
                            Image(systemName: "arrow.right")
                                .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, Global.buttonPaddingBottom)
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            
        } else if self.mode == 51 {
            
            if Util.contains(self.storeManager.myProducts, Static.productId) == true {
                // if Util.contains(self.storeManager.myProducts, Static.productIDs) == true {
                GeometryReader { geometry in
                    ScrollView {
                        VStack {
                            Text("Payment").font(.system(size: Global.text2Size, weight: .semibold))
                            Text("바우처를 구매해주세요.").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                            
                            Text(Locale.current.languageCode == "ko" ? "홀맨 이용권" : "Holeman Voucher")
                            // .font(.system(size: 20, weight: .regular))
                                .font(.system(size: Global.text2Size, weight: .semibold))
                            
                            // .foregroundColor(Color(red: 137 / 255, green: 209 / 255, blue: 254 / 255))
                                .foregroundColor(.green)
                            // .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.center)
                                .padding(.top, Global.textPaddingTop)
                            
                            // Text(Util.getCourseName(self.courses[self.selectedCourseIndex].name) + " 18홀의 정확한 거리 측정 서비스를 1,000원에 이용하세요.")
                            Text(Util.getCourseName(self.courses[self.selectedCourseIndex].name) + "의\n정확한 거리 측정 서비스를\n1,000원에 이용하세요.")
                                .font(.system(size: Global.text4Size))
                            // .fontWeight(.light)
                                .fontWeight(.medium)
                            
                            // .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, Global.buttonPadding)
                            
                            Button(action: {
                                withAnimation {
                                    self.mode = 52
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    
                                    Text("￦1,000 / 18 holes").foregroundColor(.black).font(.system(size: Global.text7Size))
                                    //.font(.system(size: 15))
                                    // .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                .frame(height: Global.textButtonSize)
                                // .background(Color(red: 137 / 255, green: 209 / 255, blue: 254 / 255))
                                .background(Color.green)
                                .cornerRadius(Global.radius1)
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
                                        .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                                    
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(Color(red: 187 / 255, green: 187 / 255, blue: 187 / 255))
                                        .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, Global.buttonPaddingTop)
                            .padding(.bottom, Global.buttonPaddingBottom2)
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
                        Text("잠시 후 다시 시도해주세요.").font(.system(size: Global.text2Size)).fontWeight(.medium).multilineTextAlignment(.center)
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
                                    .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                                
                                Image(systemName: "arrow.left")
                                    .foregroundColor(Color(red: 187 / 255, green: 187 / 255, blue: 187 / 255))
                                    .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, Global.buttonPaddingBottom)
                    } // VStack
                    .frame(maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.bottom)
                }
            } else if self.storeManager.transactionState == .purchased {
                // move next in 3 secs
                
                VStack {
                    Image(systemName: "checkmark")
                        .font(Font.system(size: Global.checkIconSize, weight: .semibold))
                        .foregroundColor(.green)
                }
                .onAppear {
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
                            // self.mode = 20 // move next
                            
                            // 2021-08-24
                            self.mode = 22
                        }
                    }
                }
            } else { // restored
                // N/A
            }
            
        } else if self.mode == 54 {
            
            VStack {
                Text("홀맨을 사랑해주셔서 감사합니다. 이제부터 무료로 이용하세요.").font(.system(size: Global.text2Size)).fontWeight(.medium).multilineTextAlignment(.center)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    let c = self.courses[self.selectedCourseIndex]
                    Util.saveCourse(c)
                    
                    withAnimation {
                        // self.mode = 20 // move next
                        
                        // 2021-08-24
                        self.mode = 22
                    }
                }
            }
            
        } else if self.mode == 60 {
            
            ZStack {
                // header
                VStack {
                    Text("Free Trial").font(.system(size: Global.text2Size, weight: .semibold))
                    Text("무료로 체험하세요!").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    Text(self.textMessage2).font(.system(size: Global.text4Size)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                // next button
                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    
                    Button(action: {
                        withAnimation {
                            // self.mode = 20 // move next
                            
                            // 2021-08-24
                            self.mode = 22
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                            
                            Image(systemName: "arrow.right")
                                .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, Global.buttonPaddingBottom)
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            
        } else if self.mode == 61 {
            
            ZStack {
                // header
                VStack {
                    Text("Free Trial").font(.system(size: Global.text2Size, weight: .semibold))
                    Text("무료로 체험하세요!").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    Text(self.textMessage2).font(.system(size: Global.text4Size)).fontWeight(.medium).multilineTextAlignment(.center)
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
                                .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                            
                            Image(systemName: "arrow.right")
                                .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, Global.buttonPaddingBottom)
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
                    
                    Text(self.textMessage).font(.system(size: Global.text4Size)).foregroundColor(Color.gray).fontWeight(.medium)
                        .transition(.opacity)
                        .id(self.textMessage)
                }
            }
            .onAppear {
                self.textMessage = ""
                
                checkDistance()
            }
            
        } else if self.mode == 71 {
            
            ZStack {
                // header
                VStack {
                    Text("Select Course").font(.system(size: Global.text2Size, weight: .semibold))
                    Text("선택하신 골프장이 맞나요?").font(.system(size: Global.text5Size, weight: .light)).padding(.bottom, Global.title2PaddingBottom)
                    
                    Spacer().frame(maxHeight: .infinity)
                }
                
                VStack {
                    Text(self.textMessage3).font(.system(size: Global.text2Size)).fontWeight(.medium).multilineTextAlignment(.center)
                }
                
                // next button
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
                                .frame(width: Global.circleButtonSize, height: Global.circleButtonSize)
                            
                            Image(systemName: "arrow.left")
                                .foregroundColor(Color(red: 187 / 255, green: 187 / 255, blue: 187 / 255))
                                .font(Font.system(size: Global.circleButtonArrowSize, weight: .heavy))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, Global.buttonPaddingBottom)
                }
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            
        } // 71
    }
    
    func getCountryCodeTimer() {
        let locationManager = LocationManager()
        
        // --
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer1 in
            if let status = locationManager.locationStatus {
                DispatchQueue.main.async {
                    if status == .authorizedWhenInUse || status == .authorizedAlways {
                        timer1.invalidate()
                        
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer2 in
                            if let location = locationManager.lastLocation {
                                DispatchQueue.main.async {
                                    timer2.invalidate()
                                    
                                    self.getCountryCode(location: location)
                                }
                            } else {
                                self.getLastLocationCounter += 1
                                
                                if self.getLastLocationCounter == 18 {
                                    timer2.invalidate()
                                    
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
                                
                                if self.getLastLocationCounter % 3 == 0 { // 3, 6, 9, 12, 15
                                    // show wait message
                                    withAnimation(.linear(duration: 0.5)) {
                                        self.textMessage = Util.getWaitMessageForLocation(self.getLastLocationCounter)
                                    }
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
        findAllCourses() { result in
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
    
    func findAllCourses(onCompletion: @escaping (_ result: Bool) -> Void) {
        CloudManager.fetchAllCourses(String(self.countryCode!)) { records in
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
                    let hlds = record["hlds"] as! Int64
                    
                    // set data
                    // --
                    var c: CourseModel = CourseModel(address: "", countryCode: "", courses: [], id: 0, location: CLLocation(latitude: 0.0, longitude: 0.0), name: "", email: "", hlds: 0)
                    
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
                    c.hlds = hlds
                    
                    self.courses.append(c)
                    // --
                }
                
                if count == 0 {
                    print(#function, "no course nearby. try again in 3 seconds")
                    
                    onCompletion(false)
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
            CloudManager.checkFreeTrialCount(userId) { freeTrialCount in
                if freeTrialCount < 10 {
                    let n = 10 - freeTrialCount
                    if n == 10 {
                        self.textMessage2 = "새로운 골프 경험의 시작, 홀맨을\n10회까지 무료로 이용 가능해요."
                    } else {
                        self.textMessage2 = "새로운 골프 경험의 시작, 홀맨을\n10회까지 무료로 이용 가능해요.\n(" + String(n) + "회 남았습니다.)"
                    }
                    
                    let c = self.courses[self.selectedCourseIndex]
                    Util.saveCourse(c)
                    
                    withAnimation {
                        self.mode = 60
                    }
                } else {
                    self.textMessage2 = "새로운 골프 경험의 시작, 홀맨을\n10회까지 무료로 이용 가능해요.\n(모두 사용하셨습니다.)"
                    
                    withAnimation {
                        self.mode = 61
                    }
                }
            } // CloudManager.checkFreeTrialCount()
        }
    } // checkFreeTrial()
    
    func checkDistance() {
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
                                    
                                    let location2 = self.courses[self.selectedCourseIndex].location
                                    
                                    let coordinate1 = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                                    let coordinate2 = CLLocation(latitude: location2.coordinate.latitude + Static.__lat, longitude: location2.coordinate.longitude + Static.__lon)
                                    
                                    let distance = coordinate1.distance(from: coordinate2) // result is in meters
                                    print(#function, "distance", distance)
                                    
                                    if distance < 3000 { // 3 km
                                        let result = Util.checkLastPurchasedCourse(self.courses[self.selectedCourseIndex].id)
                                        if result == true {
                                            withAnimation {
                                                // self.mode = 20 // move next
                                                
                                                // 2021-08-24
                                                self.mode = 22
                                            }
                                        } else {
                                            checkFreeTrial()
                                        }
                                    } else {
                                        let d = Int(distance / 1000) // km
                                        self.textMessage3 = "선택하신 골프장은\n" + String(d) + " km 떨어져 있어요."
                                        
                                        withAnimation {
                                            self.mode = 71 // go back
                                        }
                                    } // if distance < 3000
                                }
                            } else {
                                self.getLastLocationCounter += 1
                                
                                if self.getLastLocationCounter == 18 {
                                    timer2.invalidate()
                                    
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
                                
                                if self.getLastLocationCounter % 3 == 0 { // 3, 6, 9, 12, 15
                                    // show wait message
                                    withAnimation(.linear(duration: 0.5)) {
                                        self.textMessage = Util.getWaitMessageForLocation(self.getLastLocationCounter)
                                    }
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
}

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView()
    }
}
