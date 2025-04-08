//
//  OnboardingCommunityInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/27/25.
//

import SwiftUI

@MainActor
protocol OnboardingCommunityInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingCommunityInteractor { }

@MainActor
protocol OnboardingCommunityRouter {
    func showOnboardingColorView(delegate: OnboardingColorDelegate)
}

extension CoreRouter: OnboardingCommunityRouter { }

@MainActor
@Observable
class OnboardingCommunityViewModel {
    private let interactor: OnboardingCommunityInteractor
    private let router: OnboardingCommunityRouter
    
    init(interactor: OnboardingCommunityInteractor, router: OnboardingCommunityRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onContinueButtonPressed() {
        router.showOnboardingColorView(delegate: OnboardingColorDelegate())
    }
}
