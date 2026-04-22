//
//  CommonMethods.swift
//  ApiDemo
//
//  Created by ios-22 on 22/04/26.
//
import SwiftUI

func dynamicColor(for name: String) -> Color {
    let hash = abs(name.hashValue)
    let hue = Double(hash % 256) / 255.0
    return Color(hue: hue, saturation: 0.6, brightness: 0.8)
}
func timeAgo(_ dateString: String) -> String {
    
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [
        .withInternetDateTime,
        .withFractionalSeconds // 🔥 IMPORTANT FIX
    ]
    
    guard let date = formatter.date(from: dateString) else {
        return ""
    }
    
    let seconds = Int(Date().timeIntervalSince(date))
    
    switch seconds {
    case 0..<60:
        return "\(seconds)s"
    case 60..<3600:
        return "\(seconds / 60)m"
    case 3600..<86400:
        return "\(seconds / 3600)h"
    default:
        return "\(seconds / 86400)d"
    }
}
