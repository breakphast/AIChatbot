//
//  OnboardingCategoryRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/10/25.
//

import SwiftUI

@MainActor
protocol OnboardingCategoryRouter {
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelegate)
}

extension OnbRouter: OnboardingCategoryRouter { }
