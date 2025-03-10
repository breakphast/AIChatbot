//
//  LogManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/10/25.
//

import SwiftUI

@MainActor
@Observable
class LogManager {
    private let services: [LogService]
    
    init(services: [LogService] = []) {
        self.services = services
    }
    
    func identifyUser(userID: String, name: String?, email: String?) {
        for service in services {
            service.identifyUser(userID: userID, name: name, email: email)
        }
    }
    
    func addUserProperties(dict: [String: Any]) {
        for service in services {
            service.addUserProperties(dict: dict)
        }
    }
    
    func deleteUserProfile() {
        for service in services {
            service.deleteUserProfile()
        }
    }
    
    func trackEvent(event: LoggableEvent) {
        for service in services {
            service.trackEvent(event: event)
        }
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        for service in services {
            service.trackScreenEvent(event: event)
        }
    }
}

protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: LogType { get }
}
