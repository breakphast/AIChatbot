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
@Observable
class OnboardingCommunityViewModel {
    private let interactor: OnboardingCommunityInteractor
    
    init(interactor: OnboardingCommunityInteractor) {
        self.interactor = interactor
    }
    
    func onContinueButtonPressed(path: Binding<[OnboardingPathOption]>) {
        path.wrappedValue.append(.color)
    }
}
