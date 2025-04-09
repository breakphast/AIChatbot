//
//  OnboardingCommunityRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol OnboardingCommunityRouter {
    func showOnboardingColorView(delegate: OnboardingColorDelegate)
}

extension OnbRouter: OnboardingCommunityRouter { }
