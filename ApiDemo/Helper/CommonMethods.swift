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
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    var date = formatter.date(from: dateString)
    
    // 🔁 fallback if milliseconds not present
    if date == nil {
        formatter.formatOptions = [.withInternetDateTime]
        date = formatter.date(from: dateString)
    }
    
    guard let finalDate = date else { return "" }
    
    let seconds = Int(Date().timeIntervalSince(finalDate))
    
    switch seconds {
    case 0..<60: return "\(seconds)s"
    case 60..<3600: return "\(seconds / 60)m"
    case 3600..<86400: return "\(seconds / 3600)h"
    default: return "\(seconds / 86400)d"
    }
}

func makeCaption(username: String, content: String) -> AttributedString {
    
    var attributed = AttributedString(username + " " + content)
    
    if let usernameRange = attributed.range(of: username) {
        attributed[usernameRange].font = .system(size: 14, weight: .semibold)
    }
    
    if let contentRange = attributed.range(of: content) {
        attributed[contentRange].font = .system(size: 14, weight: .regular)
        attributed[contentRange].foregroundColor = .secondaryText
    }
    
    return attributed
}



func formatCount(_ value: Int) -> String {
    if value >= 1_000_000 {
        return String(format: "%.1fM", Double(value)/1_000_000)
    } else if value >= 1_000 {
        return String(format: "%.1fK", Double(value)/1_000)
    }
    return "\(value)"
}
