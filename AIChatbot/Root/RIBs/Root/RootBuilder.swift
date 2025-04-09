//
//  RootBuilder.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/9/25.
//

import SwiftUI

@MainActor
struct RootBuilder: Builder {
    let interactor: RootInteractor
    let loggedInRIB: any Builder
    let loggedOutRIB: any Builder
    
    func build() -> AnyView {
        appView().any()
    }
    
    func appView() -> some View {
        AppView(
            presenter: AppPresenter(
                interactor: interactor
            ),
            tabBarView: {
                loggedInRIB.build()            },
            onboardingView: {
                loggedOutRIB.build()
            }
        )
    }
}
