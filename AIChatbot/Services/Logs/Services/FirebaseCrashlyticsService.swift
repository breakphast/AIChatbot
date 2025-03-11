//
//  FirebaseCrashlyticsService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/10/25.
//

import FirebaseCrashlytics

struct FirebaseCrashlyticsService: LogService {
    func identifyUser(userID: String, name: String?, email: String?) {
        Crashlytics.crashlytics().setUserID(userID)
        
        if let name {
            Crashlytics.crashlytics().setCustomValue(name, forKey: "account_name")
        }
        if let email {
            Crashlytics.crashlytics().setCustomValue(email, forKey: "account_email")
        }
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        guard isHighPriority else { return }
        
        for (key, value) in dict {
            Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        }
    }
    
    func deleteUserProfile() {
        Crashlytics.crashlytics().setUserID("new")
    }
    
    func trackEvent(event: any LoggableEvent) {
        switch event.type {
        case .info, .analytic, .warning:
            break
        case .severe:
            let error = NSError(
                domain: event.eventName,
                code: event.eventName.stableHashValue,
                userInfo: event.parameters
            )
            Crashlytics.crashlytics().record(error: error, userInfo: event.parameters)
        }
    }
    
    func trackScreenEvent(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
