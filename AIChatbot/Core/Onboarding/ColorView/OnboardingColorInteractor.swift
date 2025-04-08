//
//  OnboardingColorInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol OnboardingColorInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingColorInteractor { }
