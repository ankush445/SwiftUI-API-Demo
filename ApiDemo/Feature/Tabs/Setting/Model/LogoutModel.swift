//
//  LogoutModel.swift
//  ApiDemo
//
//  Created by ios-22 on 21/04/26.
//


// Common Model for both logout and Delete
struct LogoutModel: Codable {
    let success: Bool
    let message: String
}
