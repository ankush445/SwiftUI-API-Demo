//
//  HapticType.swift
//  ApiDemo
//
//  Created by ios-22 on 21/04/26.
//


import UIKit

enum HapticType {
    case light
    case medium
    case heavy
    case soft
    case success
    case error
}

struct HapticManager {
    
    static func trigger(_ type: HapticType) {
        switch type {
            
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            
        case .soft:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}