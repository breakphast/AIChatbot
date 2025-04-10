//
//  OnboardingCategoryPresenter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/10/25.
//

import SwiftUI

@MainActor
@Observable
class OnboardingCategoryPresenter {
    private let interactor: OnboardingCategoryInteractor
    private let router: OnboardingCategoryRouter
    
    var selectedColor: Color?
    let categories: [CharacterOption] = CharacterOption.allCases
    var selectedCategory: CharacterOption = .alien
    
    init(interactor: OnboardingCategoryInteractor, router: OnboardingCategoryRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onContinueButtonPressed() {
        guard let selectedColor else {
            return
        }
        
        let delegate = OnboardingCompletedDelegate(selectedColor: selectedColor, selectedCategory: selectedCategory)
        router.showOnboardingCompletedView(delegate: delegate)
    }
}
