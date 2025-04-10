//
//  AppearAnalyticsViewModifier.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/11/25.
//

import SwiftUI

struct AppearAnalyticsViewModifier: ViewModifier {
    @Environment(LogManager.self) private var logManager
    let name: String
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                logManager.trackScreenView(event: Event.appear(name: name))
            }
            .onDisappear {
                logManager.trackEvent(event: Event.disappear(name: name))
            }
    }
    
    enum Event: LoggableEvent {
        case appear(name: String)
        case disappear(name: String)
        
        var eventName: String {
            switch self {
            case .appear(name: let name):       return "\(name)_Appear"
            case .disappear(name: let name):    return "\(name)_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            nil
        }
        
        var type: LogType {
            .analytic
        }
    }
}

extension View {
    func screenAppearAnalytics(name: String) -> some View {
        self
            .modifier(AppearAnalyticsViewModifier(name: name))
    }
}
