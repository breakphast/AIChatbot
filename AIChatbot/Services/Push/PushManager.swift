//
//  PushManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/14/25.
//

import SwiftUI
import SwiftfulUtilities

@MainActor
@Observable
class PushManager {
    private let logManager: LogManager?
    
    init(logManager: LogManager? = nil) {
        self.logManager = logManager
    }
    
    func requestAuthorization() async throws -> Bool {
        let isAuthorized = try await LocalNotifications.requestAuthorization()
        logManager?.addUserProperties(dict: ["push_is_authorized": isAuthorized], isHighPriority: true)
        return isAuthorized
    }
    
    func canRequestAuthorization() async -> Bool {
        await LocalNotifications.canRequestAuthorization()
    }
    
    func schedulePushNotificationsForTheNextWeek() {
        LocalNotifications.removeAllPendingNotifications()
        LocalNotifications.removeAllDeliveredNotifications()
        
        Task {
            do {
                // Tomorrow
                try await scheduleNotification(
                    title: "Hey you! Read to chat?",
                    subtitle: "Open AI Chat to begin.",
                    triggerDate: Date().adding(days: 1)
                )
                
                // In 3 days
                try await scheduleNotification(
                    title: "Someone sent you a message!",
                    subtitle: "Open AI Chat to respond.",
                    triggerDate: Date().adding(days: 3)
                )
                
                // In 5 days
                try await scheduleNotification(
                    title: "Hey stranger. We miss you!",
                    subtitle: "Don't forget about us.",
                    triggerDate: Date().adding(days: 5)
                )
                logManager?.trackEvent(event: Event.weekScheduled)
            } catch {
                logManager?.trackEvent(event: Event.weekScheduledFail(error: error))
            }
        }
        
    }
    
    private func scheduleNotification(title: String, subtitle: String, triggerDate: Date) async throws {
        let content = AnyNotificationContent(title: title, body: subtitle)
        let trigger = NotificationTriggerOption.date(date: triggerDate, repeats: false)
        try await LocalNotifications.scheduleNotification(content: content, trigger: trigger)
    }
    
    enum Event: LoggableEvent {
        case weekScheduled
        case weekScheduledFail(error: Error)
        
        var eventName: String {
            switch self {
            case .weekScheduled:        return "PushMan_WeekSchedule_Success"
            case .weekScheduledFail:    return "PushMan_WeekSchedule_Success"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .weekScheduledFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .weekScheduledFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
