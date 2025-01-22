//
//  NetworkMonitor.swift
//  JMTeng
//
//  Created by PKW on 5/9/24.
//

import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()

    private var monitor: NWPathMonitor?
    private var queue = DispatchQueue.global(qos: .background)

    func startMonitoring() {
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("We're connected!")
                NotificationCenter.default.post(name: .networkStatusChanged, object: nil, userInfo: ["Connected": true])
            } else {
                print("No connection.")
                NotificationCenter.default.post(name: .networkStatusChanged, object: nil, userInfo: ["Connected": false])
            }
        }
        monitor?.start(queue: queue)
    }

    func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
    }
}

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}
