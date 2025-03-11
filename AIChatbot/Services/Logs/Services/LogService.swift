//
//  LogService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/10/25.
//

import SwiftUI

protocol LogService {
    func identifyUser(userID: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any], isHighPriority: Bool)
    func deleteUserProfile()
    
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}
