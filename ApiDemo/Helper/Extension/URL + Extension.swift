//
//  URL + Extension.swift
//  DictateNow
//
//  Created by ios-22 on 19/03/25.
//

// MARK: - URL Extension for MIME Type Detection
//import Foundation
//import UniformTypeIdentifiers
//
//extension URL {
//    
//    /// Returns the file extension (e.g., "jpg", "pdf") or nil if not available
//    var fileExtension: String? {
//        let ext = self.pathExtension
//        return ext.isEmpty ? nil : ext
//    }
//    
//    /// Returns the MIME type based on the file extension
//    var mimeType: String {
//        let fileExtension = self.pathExtension.lowercased()
//        
//        switch fileExtension {
//        case "jpg", "jpeg": return "image/jpeg"
//        case "png": return "image/png"
//        case "gif": return "image/gif"
//        case "pdf": return "application/pdf"
//        case "txt": return "text/plain"
//        case "json": return "application/json"
//        case "html": return "text/html"
//        case "xml": return "application/xml" // ✅ Added XML format
//        case "m4a": return "audio/x-m4a"
//        case "wav": return "audio/wav"
//        case "mp3": return "audio/mpeg"
//        case "mp4": return "video/mp4"
//        case "mov": return "video/quicktime"
//        default:
//            // Try using UTType to determine MIME type if not found above
//            if let uti = UTType(filenameExtension: fileExtension),
//               let mimeType = uti.preferredMIMEType {
//                return mimeType
//            }
//            return "application/octet-stream" // Fallback MIME type
//        }
//    }
//
//}

