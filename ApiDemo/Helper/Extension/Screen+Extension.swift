//
//  UIExtension.swift
//  DictateNow
//
//  Created by ios-22 on 19/02/25.
//
//import SwiftUI
//
//extension CGFloat {
//    
//    static var screenWidth: Double {
//        return UIScreen.main.bounds.size.width
//    }
//    
//    static var screenHeight: Double {
//        return UIScreen.main.bounds.size.height
//    }
//    
//    static func widthPer(per: Double) -> Double {
//        return screenWidth * per
//    }
//    
//    static func heightPer(per: Double) -> Double {
//        return screenHeight * per
//    }
//    
//    static var topInsets: Double {
//        guard let windowScene = UIApplication.shared.connectedScenes
//            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
//              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
//        else {
//            return 0.0
//        }
//        return keyWindow.safeAreaInsets.top
//    }
//    
//    static var bottomInsets: Double {
//        guard let windowScene = UIApplication.shared.connectedScenes
//            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
//              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
//        else {
//            return 0.0
//        }
//        return keyWindow.safeAreaInsets.bottom
//    }
//    
//    static var horizontalInsets: Double {
//        guard let windowScene = UIApplication.shared.connectedScenes
//            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
//              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
//        else {
//            return 0.0
//        }
//        return keyWindow.safeAreaInsets.left + keyWindow.safeAreaInsets.right
//    }
//    
//    static var verticalInsets: Double {
//        guard let windowScene = UIApplication.shared.connectedScenes
//            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
//              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
//        else {
//            return 0.0
//        }
//
//        return keyWindow.safeAreaInsets.top + keyWindow.safeAreaInsets.bottom
//    }
//
//    
//}
//

