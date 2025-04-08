//
//  WelcomeInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol WelcomeInteractor {
    func trackEvent(event: LoggableEvent)
    func updateAppState(showTabBar: Bool)
}

extension CoreInteractor: WelcomeInteractor { }
