//
//  OnboardingCommunityInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol OnboardingCommunityInteractor {
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingCommunityInteractor { }
