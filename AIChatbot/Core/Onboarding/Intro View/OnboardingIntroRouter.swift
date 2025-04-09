//
//  OnboardingIntroRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol OnboardingIntroRouter {
    func showOnboardingCommunityView(delegate: OnboardingCommunityDelegate)
    func showOnboardingColorView(delegate: OnboardingColorDelegate)
}

extension OnbRouter: OnboardingIntroRouter { }
