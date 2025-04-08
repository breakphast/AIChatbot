//
//  OnboardingColorRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol OnboardingColorRouter {
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelegate)
}

extension CoreRouter: OnboardingColorRouter { }
