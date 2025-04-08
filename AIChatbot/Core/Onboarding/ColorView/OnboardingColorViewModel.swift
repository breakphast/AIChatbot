//
//  OnboardingColorInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/27/25.
//

import SwiftUI

@MainActor
protocol OnboardingColorInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingColorInteractor { }

@MainActor
protocol OnboardingColorRouter {
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelegate)
}

extension CoreRouter: OnboardingColorRouter { }

@MainActor
@Observable
class OnboardingColorViewModel {
    private let interactor: OnboardingColorInteractor
    private let router: OnboardingColorRouter
    
    private(set) var selectedColor: Color?
    let profileColors: [Color] = [.red, .green, .indigo, .blue, .orange, .pink, .yellow, .purple, .cyan]
    
    init(interactor: OnboardingColorInteractor, router: OnboardingColorRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onColorPressed(color: Color) {
        selectedColor = color
    }
    
    func onContinueButtonPressed() {
        guard let selectedColor else { return }
        
        let delegate = OnboardingCompletedDelegate(selectedColor: selectedColor)
        router.showOnboardingCompletedView(delegate: delegate)
    }
}
