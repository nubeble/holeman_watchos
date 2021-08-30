//
//  Global.swift
//  holeman WatchKit Extension
//
//  Created by Jay Kim on 2021/02/06.
//

import Foundation
import SwiftUI

struct Global {
    static var halftime: Int? // 1: 전반, 2: 후반
    
    static var userId: String?
    
    
    
    static var title2PaddingBottom: CGFloat = 8
    static var buttonPaddingTop: CGFloat = 6
    static var buttonPaddingBottom2: CGFloat = -20
    static var buttonPadding: CGFloat = 8
    static var textPaddingTop: CGFloat = -6
    
    
    
    
    
    static var logoWidth: CGFloat = 147.89
    static var logoHeight: CGFloat = 26.11
    
    static var iconWidth: CGFloat = 48
    
    static var text1Size: CGFloat = 24
    static var text2Size: CGFloat = 20
    static var text3Size: CGFloat = 18
    static var text4Size: CGFloat = 16
    static var text5Size: CGFloat = 14
    static var text6Size: CGFloat = 12
    
    static var buttonPaddingBottom: CGFloat = 10
    static var circleButtonSize: CGFloat = 54
    static var circleButtonArrowSize: CGFloat = 28
    
    static var signInWithAppleButtonWidth: CGFloat = 180
    static var signInWithAppleButtonHeight: CGFloat = 16
    
    static var buttonSpacing1: CGFloat = 2
    static var buttonSpacing2: CGFloat = 40
    
    static var circleIconSize: CGFloat = 26
    static var icon1Size: CGFloat = 13
    static var icon2Size: CGFloat = 14
    static var icon3Size: CGFloat = 20
    static var icon4Size: CGFloat = 16
    static var icon5Size: CGFloat = 28
    static var icon6Size: CGFloat = 32
    
    static var textButtonSize: CGFloat = 50
    
    static var checkIconSize: CGFloat = 40
    static var checkmarkIconSize: CGFloat = 16
    
    static var progressBarSize: CGFloat = 46
    static var progressBarLineWidth: CGFloat = 8
    
    static var radius1: CGFloat = 8
    
    
    // 8:9
    static func setDeviceResolution(_ width: CGFloat) -> Void {
        
        if width < 160 { // 150 ?
            // ToDo: !!!
            // 38 mm
            
            return
        }
        
        if 160 <= width && width < 170 { // 161.0
            // 40 mm
            
            title2PaddingBottom = title2PaddingBottom / 183.0 * 161.0
            buttonPaddingTop = buttonPaddingTop / 183.0 * 161.0
            buttonPaddingBottom2 = buttonPaddingBottom2 / 183.0 * 161.0
            buttonPadding = buttonPadding / 183.0 * 161.0
            textPaddingTop = textPaddingTop / 183.0 * 161.0
            
            
            
            
            logoWidth = logoWidth / 183.0 * 161.0
            logoHeight = logoHeight / 183.0 * 161.0
            
            iconWidth = iconWidth / 183.0 * 161.0
            
            text1Size = text1Size / 183.0 * 161.0
            text2Size = text2Size / 183.0 * 161.0
            text3Size = text3Size / 183.0 * 161.0
            text4Size = text4Size / 183.0 * 161.0
            text5Size = text5Size / 183.0 * 161.0
            text6Size = text6Size / 183.0 * 161.0
            
            buttonPaddingBottom = buttonPaddingBottom / 183.0 * 161.0
            circleButtonSize = circleButtonSize / 183.0 * 161.0
            circleButtonArrowSize = circleButtonArrowSize / 183.0 * 161.0
            
            signInWithAppleButtonWidth = signInWithAppleButtonWidth / 183.0 * 161.0
            signInWithAppleButtonHeight = signInWithAppleButtonHeight / 183.0 * 161.0
            
            buttonSpacing1 = buttonSpacing1 / 183.0 * 161.0
            buttonSpacing2 = buttonSpacing2 / 183.0 * 161.0
            
            circleIconSize = circleIconSize / 183.0 * 161.0
            icon1Size = icon1Size / 183.0 * 161.0
            icon2Size = icon2Size / 183.0 * 161.0
            icon3Size = icon3Size / 183.0 * 161.0
            icon4Size = icon4Size / 183.0 * 161.0
            icon5Size = icon5Size / 183.0 * 161.0
            icon6Size = icon6Size / 183.0 * 161.0
            
            textButtonSize = textButtonSize / 183.0 * 161.0
            
            checkIconSize = checkIconSize / 183.0 * 161.0
            checkmarkIconSize = checkmarkIconSize / 183.0 * 161.0
            
            progressBarSize = progressBarSize / 183.0 * 161.0
            progressBarLineWidth = progressBarLineWidth / 183.0 * 161.0
            
            radius1 = radius1 / 183.0 * 161.0
            
            return
        }
        
        if 170 <= width && width < 180 { // 170 ?
            // 42 mm ?
            /*
             logoWidth = logoWidth / 183.0 * 170 // ?
             logoHeight = logoHeight / 183.0 * 170 // ?
             */
            
            return
        }
        
        if 180 < width && width < 190 { // 183.0
            // 44 mm
            
            // N/A
            
            return
        } else { // 190
            // ToDo: !!!
            
            return
        }
    }
}
