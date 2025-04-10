//
//  OnboardingCompletedInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol OnboardingCompletedInteractor {
    func updateAppState(showTabBar: Bool)
    func markOnboardingCompletedForCurrentUser(profileColorHex: String, category: String) async throws
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingCompletedInteractor { }
