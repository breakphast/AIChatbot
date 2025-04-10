//
//  GlobalInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/10/25.
//

import SwiftUI

@MainActor
protocol GlobalInteractor {
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType)
    func trackEvent(event: AnyLoggableEvent)
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}
