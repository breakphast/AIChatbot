//
//  OnboardingCompletedRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol OnboardingCompletedRouter {
    func showAlert(error: Error)
    
    func dismissAlert()
}

extension CoreRouter: OnboardingCompletedRouter { }
