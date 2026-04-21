//
//  NetworkMonitor.swift
//  ApiDemo
//
//  Created by ios-22 on 16/03/26.
//


import Network

final class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private(set) var isConnected: Bool = true
    
    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        
        monitor.start(queue: queue)
    }
}