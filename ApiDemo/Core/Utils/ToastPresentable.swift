//
//  ToastPresentable.swift
//  ApiDemo
//
//  Created by ios-22 on 21/04/26.
//


// ToastPresentable.swift

import Foundation
import FancyToastKit
protocol ToastPresentable: AnyObject {
    var toast: FancyToast? { get set }
}

extension ToastPresentable {
    
    func showError(_ error: Error) {
        toast = FancyToast(
            type: .error,
            title: "Error",
            message: error.localizedDescription,
            duration: 2.5
        )
    }
    
    func showError(message: String) {
        toast = FancyToast(
            type: .error,
            title: "Error",
            message: message,
            duration: 2.5
        )
    }
    
    func showSuccess(message: String) {
        toast = FancyToast(
            type: .success,
            title: "Success",
            message: message,
            duration: 2.0
        )
    }
    
    func showWarning(message: String) {
        toast = FancyToast(
            type: .warning,
            title: "Warning",
            message: message,
            duration: 2.5
        )
    }
    
    func showInfo(message: String) {
        toast = FancyToast(
            type: .info,
            title: "Info",
            message: message,
            duration: 2.0
        )
    }
}
