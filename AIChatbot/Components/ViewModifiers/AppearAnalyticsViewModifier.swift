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
                logManager.trackScreenEvent(event: Event.appear(name: name))
            }
            .onDisappear {
                logManager.trackEvent(event: Event.dissapear(name: name))
            }
    }
    
    enum Event: LoggableEvent {
        case appear(name: String)
        case dissapear(name: String)
        
        var eventName: String {
            switch self {
            case .appear(name: let name):       return "\(name)_Appear"
            case .dissapear(name: let name):    return "\(name)_Disappear"
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
