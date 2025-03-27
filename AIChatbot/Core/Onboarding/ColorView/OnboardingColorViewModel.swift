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
@Observable
class OnboardingColorViewModel {
    private let interactor: OnboardingColorInteractor
    
    private(set) var selectedColor: Color?
    let profileColors: [Color] = [.red, .green, .indigo, .blue, .orange, .pink, .yellow, .purple, .cyan]
    
    init(interactor: OnboardingColorInteractor, selectedColor: Color) {
        self.interactor = interactor
        self.selectedColor = selectedColor
    }
    
    func onColorPressed(color: Color) {
        selectedColor = color
    }
    
    func onContinueButtonPressed(path: Binding<[OnboardingPathOption]>) {
        path.wrappedValue.append(.completed(selectedColor: selectedColor ?? .orange))
    }
}
