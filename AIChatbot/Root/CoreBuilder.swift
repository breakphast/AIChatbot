//
//  CoreBuilder.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/28/25.
//

import SwiftUI

@Observable
@MainActor
class CoreBuilder {
    let interactor: CoreInteractor
    
    init(interactor: CoreInteractor) {
        self.interactor = interactor
    }
    
    func createAccountView(delegate: CreateAccountDelegate = CreateAccountDelegate()) -> some View {
        CreateAccountView(
            viewModel: CreateAccountViewModel(interactor: interactor),
            delegate: delegate
        )
    }
    
    func createAccountView() -> some View {
        CreateAccountView(
            viewModel: CreateAccountViewModel(interactor: interactor)
        )
    }
    
    func exploreView() -> some View {
        ExploreView(
            viewModel: ExploreViewModel(interactor: interactor)
        )
    }
    
    func devSettingsView() -> some View {
        DevSettingsView(
            viewModel: DevSettingsViewModel(interactor: interactor)
        )
    }
}
