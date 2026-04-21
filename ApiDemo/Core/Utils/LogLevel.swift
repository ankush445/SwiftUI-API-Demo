//
//  LogLevel.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//

import Foundation
enum LogLevel: String {
    case request = "➡️"
    case success = "✅"
    case error = "❌"
    case info = "ℹ️"
}

struct Logger {
    
    static func log(_ message: String, level: LogLevel = .info) {
        #if DEBUG
        print("\(level.rawValue) \(message)")
        #endif
    }
    
    static func prettyJSON(_ data: Data) {
        #if DEBUG
        guard
            let json = try? JSONSerialization.jsonObject(with: data),
            let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
            let prettyString = String(data: prettyData, encoding: .utf8)
        else { return }
        
        print("📄 JSON:\n\(prettyString)")
        #endif
    }
}
