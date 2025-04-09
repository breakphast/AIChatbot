//
//  OnboardingCommunityInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/27/25.
//

import SwiftUI

@MainActor
@Observable
class OnboardingCommunityPresenter {
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
