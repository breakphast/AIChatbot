//
//  ConsoleService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/10/25.
//

import SwiftUI
import OSLog

actor LogSystem {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ConsoleLogger")
    
    func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message)")
    }
    
    nonisolated func log(level: LogType, message: String) {
        Task {
            await log(level: level.OSLogType, message: message)
        }
    }
}

enum LogType {
    /// Use 'info' for informative tasks. These are not considered analytics issues or errors.
    case info
    /// Default type for analytics.
    case analytic
    /// Issues or errors that should not occur but will not negatively affect the user experience.
    case warning
    /// Issues or errors that do negatively affect the user experience.
    case severe
    
    var OSLogType: OSLogType {
        switch self {
        case .info:
            .info
        case .analytic:
            .default
        case .warning:
            .error
        case .severe:
            .fault
        }
    }
    
    var emoji: String {
        switch self {
        case .info:
            "👋"
        case .analytic:
            "📈"
        case .warning:
            "⚠️"
        case .severe:
            "🚨"
        }
    }
}

struct ConsoleService: LogService {
    let logger = LogSystem()
    private let printParameters: Bool
    
    init(printParameters: Bool = true) {
        self.printParameters = printParameters
    }
    
    func identifyUser(userId: String, name: String?, email: String?) {
        let string = """
                    📈 Identify User
                    userID: \(userId)
                    name: \(name ?? "unknown")
                    email: \(email ?? "unknown")
                    """
        
        logger.log(level: LogType.info, message: string)
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        var string = """
                    📈 Log User Properties (isHighPriority: \(isHighPriority.description))
                    """
        
        if printParameters {
            let sortedKeys = dict.keys.sorted()
            for key in sortedKeys {
                if let value = dict[key] {
                    string += "\n (key: \(key), value: \(value))"
                }
            }
        }
        
        logger.log(level: LogType.info, message: string)
    }
    
    func deleteUserProfile() {
        let string = """
                    📈 Delete user profile
                    """
        
        logger.log(level: LogType.info, message: string)
    }
    
    func trackEvent(event: any LoggableEvent) {
        var string = "\(event.type.emoji) \(event.eventName)"
        
        if printParameters, let parameters = event.parameters, !parameters.isEmpty {
            let sortedKeys = parameters.keys.sorted()
            for key in sortedKeys {
                if let value = parameters[key] {
                    string += "\n (key: \(key), value: \(value))"
                }
            }
        }
        
        logger.log(level: event.type, message: string)
    }
    
    func trackScreenEvent(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
