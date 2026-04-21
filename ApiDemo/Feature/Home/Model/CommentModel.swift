//
//  CommentModel.swift
//  ApiDemo
//
//  Created by ios-22 on 21/04/26.
//
import Foundation

struct CommentResponse: Codable {
    let success: Bool
    let data: Comment
}
