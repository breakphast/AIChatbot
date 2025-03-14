//
//  AnyNotificationListenerViewModifier.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/14/25.
//

import SwiftUI

struct AnyNotificationListenerViewModifier: ViewModifier {
    let notificationName: Notification.Name
    let onNotificationReceived: (Notification) -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: notificationName), perform: { notification in
                onNotificationReceived(notification)
            })
    }
}

extension View {
    func onNotificationReceived(name: Notification.Name, action: @MainActor @escaping (Notification) -> Void) -> some View {
        modifier(AnyNotificationListenerViewModifier(notificationName: name, onNotificationReceived: action))
    }
}
