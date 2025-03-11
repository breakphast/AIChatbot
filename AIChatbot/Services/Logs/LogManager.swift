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
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        for service in services {
            service.addUserProperties(dict: dict, isHighPriority: isHighPriority)
        }
    }
    
    func deleteUserProfile() {
        for service in services {
            service.deleteUserProfile()
        }
    }
    
    func trackEvent(eventName: String, parameters: [String: Any]? = nil, type: LogType = .analytic) {
        let event = AnyLoggableEvent(eventName: eventName, parameters: parameters, type: type)
        for service in services {
            service.trackEvent(event: event)
        }
    }
    
    func trackEvent(event: AnyLoggableEvent) {
        for service in services {
            service.trackEvent(event: event)
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
