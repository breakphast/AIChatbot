//
//  OnboardingCategoryInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/10/25.
//

import SwiftUI

@MainActor
protocol OnboardingCategoryInteractor: GlobalInteractor {
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingCategoryInteractor { }
