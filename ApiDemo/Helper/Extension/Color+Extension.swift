//
//  Color+Extension.swift
//  DictateNow
//
//  Created by ios-22 on 19/02/25.
//

import SwiftUI
extension Color {
    
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
            case 3: // RGB(12 -bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    func toHex() -> String? {
        // Get the RGB components of the color
        let uiColor = UIColor(self)
        let red = uiColor.cgColor.components?[0] ?? 0
        let green = uiColor.cgColor.components?[1] ?? 0
        let blue = uiColor.cgColor.components?[2] ?? 0
        
        // Convert RGB components to hex format
        let rgb = (Int(red * 255), Int(green * 255), Int(blue * 255))
        
        return String(format: "#%02X%02X%02X", rgb.0, rgb.1, rgb.2)
    }
}



