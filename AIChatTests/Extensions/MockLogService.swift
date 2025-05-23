//
//  MockLogService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/21/25.
//

import Testing
@testable import AIChatbot

final class MockLogService: LogService, @unchecked Sendable {
    var identifiedUser: IdentifiedUser?
    var trackedEvents: [LoggableEvent] = []
    var userPropertiesHigh: [String: Any] = [:]
    var userPropertiesLow: [String: Any] = [:]
    
    func identifyUser(userId: String, name: String?, email: String?) {
        identifiedUser = IdentifiedUser(userID: userId, name: name, email: email)
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        if isHighPriority {
            userPropertiesHigh.merge(dict) { _, new in new }
        } else {
            userPropertiesLow.merge(dict) { _, new in new }
        }
    }
    
    func deleteUserProfile() { }

    func trackEvent(event: LoggableEvent) {
        trackedEvents.append(event)
    }

    func trackScreenView(event: LoggableEvent) { }
}

struct IdentifiedUser {
    let userID: String
    let name: String?
    let email: String?
}
