//
//  OnboardingColorInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/27/25.
//

import SwiftUI

@MainActor
@Observable
class OnboardingColorPresenter {
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
        
        if interactor.onboardingCategoryTest {
            let delegate = OnboardingCategoryDelegate(selectedColor: selectedColor)
            router.showOnboardingCategoryView(delegate: delegate)
        } else {
            let delegate = OnboardingCompletedDelegate(selectedColor: selectedColor)
            router.showOnboardingCompletedView(delegate: delegate)
        }
    }
}
