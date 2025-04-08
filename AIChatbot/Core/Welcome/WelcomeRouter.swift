//
//  WelcomeRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol WelcomeRouter {
    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: (() -> Void)?)
    func showOnboardingIntroView(delegate: OnboardingIntroDelegate)
}

extension CoreRouter: WelcomeRouter { }
