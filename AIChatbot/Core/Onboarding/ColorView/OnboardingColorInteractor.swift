//
//  OnboardingColorInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol OnboardingColorInteractor: GlobalInteractor {
    func trackEvent(event: LoggableEvent)
    var onboardingCategoryTest: Bool { get }
}

extension OnbInteractor: OnboardingColorInteractor { }
